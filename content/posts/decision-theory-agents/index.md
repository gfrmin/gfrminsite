---
title: "How Decision Theory Cuts Your AI Agent's API Bill in Half"
subtitle: "Beta posteriors, value of information, and why your LangChain agent queries everything every time"
description: "Most LLM agents use tools like a tourist uses a phrasebook. A few lines of probability theory can fix it."
author: "Guy Freeman"
date: 2026-02-23
categories: [python, bayesian, machine-learning, ai]
image: og-image.png
---

The [companion essay](/posts/agentic-ai/) argued that LLM-based "agents" don't earn the title. No beliefs, no uncertainty quantification, no principled mechanism for deciding whether a tool query justifies its cost. This post supplies the technical scaffolding for that claim --- the mathematics and code behind [Credence](https://github.com/gfrmin/credence), the benchmark I built to test it. Think of it as the receipts.

{{< callout type="note" >}}
For the philosophical argument, see [Agentic AI Is Neither Intelligent Nor an Agent](/posts/agentic-ai/).
{{< /callout >}}

## The Problem: Every Query Has a Price

Hand a standard LangChain ReAct agent a question and four tools, and it will query most of them most of the time. It possesses no apparatus for reasoning about whether the next query repays its cost. The prompt says "be helpful"; the agent takes helpfulness to mean exhaustiveness.

If queries were free, this would be a perfectly reasonable strategy. They are not free. Every API call costs tokens, latency, and --- in a benchmark with explicit costs --- points. The operative question is not "might this tool help me?" but "does the expected information gain from this tool exceed what I'm paying for it?"

To answer that, you need three things the LangChain agent conspicuously lacks: a model of tool reliability that updates from experience, a way to compute the expected value of information before committing to a query, and a decision rule that weighs querying against submitting or walking away. All three are undergraduate probability theory. The maths has been lying around for decades; nobody thought to hand it to the agent.

## Modelling Tool Reliability with Beta Distributions

Each tool has a different reliability for each question category. A calculator is perfect for arithmetic and useless for everything else. A knowledge base excels at factual recall but charges accordingly. We don't know these reliabilities in advance --- we learn them, which is rather the point.

The natural model is Beta-Bernoulli. For each tool-category pair, maintain a Beta distribution over the probability the tool returns the correct answer:

$$r_{t,c} \sim \text{Beta}(\alpha_{t,c},\, \beta_{t,c})$$

Start with $\alpha = 1, \beta = 1$ --- a uniform prior, the formal expression of total ignorance. Expected reliability is the familiar ratio:

$$\mathbb{E}[r_{t,c}] = \frac{\alpha_{t,c}}{\alpha_{t,c} + \beta_{t,c}}$$

After each question, once ground truth is revealed, we update. Correct answer: increment $\alpha$. Wrong answer: increment $\beta$. The update is weighted by the category posterior, distributing learning across categories in proportion to their plausibility:

```python
def update_reliability_table(
    table: ReliabilityTable,
    tool_idx: int,
    category_posterior: CategoryPosterior,
    tool_was_correct: bool | None,
    forgetting: float = 1.0,
) -> ReliabilityTable:
    new_table = table.copy()
    if tool_was_correct is None:
        return new_table

    params = new_table[tool_idx]

    if forgetting < 1.0:
        params[:, 0] = np.maximum(1e-10, forgetting * params[:, 0])
        params[:, 1] = np.maximum(1e-10, forgetting * params[:, 1])

    if tool_was_correct:
        params[:, 0] += category_posterior  # increment alpha
    else:
        params[:, 1] += category_posterior  # increment beta

    return new_table
```

The `forgetting` parameter ($\lambda = 0.95$ in the drift experiments) implements exponential decay --- multiplying $\alpha$ and $\beta$ by $\lambda$ before each update. This prevents ancient observations from tyrannising the present when tool reliability shifts mid-task. It is what allows the agent to notice a degraded tool and quietly redirect its queries elsewhere within a handful of questions.

Two properties make this work well. First, the update is exact. No gradient descent, no approximation, no convergence check. Observe, update, move on. Second, the Beta distribution encodes both the estimate *and* the uncertainty in a single object. A tool with $\text{Beta}(2, 2)$ and one with $\text{Beta}(20, 20)$ both have expected reliability 0.5, but the agent knows it should trust the second estimate far more than the first.

## Bayesian Updates on Answers

When a tool returns answer $x_j$, we update our beliefs about which answer is correct. The likelihood model is straightforward: if the tool's effective reliability is $r$, it returns the correct answer with probability $r$ and each wrong answer with probability $\frac{1-r}{3}$:

$$P(\text{tool says } x_j \mid \text{true answer is } x_i, r) = \begin{cases} r & \text{if } i = j \\ \frac{1-r}{3} & \text{if } i \neq j \end{cases}$$

Bayes' rule gives us the posterior over answers:

$$P(x_i \mid \text{tool says } x_j) \propto P(\text{tool says } x_j \mid x_i, r) \cdot P(x_i)$$

In code, a few lines of NumPy:

```python
def update_answer_posterior(
    prior: AnswerPosterior,
    response_idx: int,
    r_effective: float,
) -> AnswerPosterior:
    n = len(prior)
    wrong_likelihood = (1.0 - r_effective) / (n - 1)
    likelihood = np.full(n, wrong_likelihood)
    likelihood[response_idx] = r_effective
    updated = prior * likelihood
    total = updated.sum()
    if total < 1e-10:
        return prior.copy()
    return updated / total
```

But the effective reliability $r$ is not known exactly --- we have a distribution over it. So we marginalise over category uncertainty:

$$r_{\text{eff}} = \sum_{c} P(c \mid \text{question}) \cdot \mathbb{E}[r_{t,c}]$$

The agent doesn't know which category a question belongs to either. It maintains a category posterior that updates as tools respond. A calculator returning "not applicable" eliminates the numerical category. A knowledge base returning nothing shifts probability toward categories with low coverage. Every scrap of information tightens every belief simultaneously. The whole thing is coupled, in the pleasant way that Bayesian networks tend to be.

## Expected Utility: When to Answer

The scoring rule: +10 for correct, -5 for wrong, 0 for abstaining. The expected utility of submitting answer $x_j$ is therefore:

$$\text{EU}_{\text{submit}}(x_j) = P(x_j) \cdot 10 + (1 - P(x_j)) \cdot (-5) = 15 \cdot P(x_j) - 5$$

Setting $\text{EU}_{\text{submit}} > \text{EU}_{\text{abstain}} = 0$ yields a satisfyingly clean threshold: only submit when your best candidate has posterior probability above $\frac{1}{3}$. Below that, the expected cost of being wrong outweighs the expected benefit of being right. The arithmetic is indifferent to your feelings about how confident you "seem."

```python
def eu_submit(answer_posterior: AnswerPosterior) -> float:
    p_best = float(np.max(answer_posterior))
    return p_best * REWARD_CORRECT + (1.0 - p_best) * PENALTY_WRONG

def eu_abstain() -> float:
    return REWARD_ABSTAIN

def eu_star(answer_posterior: AnswerPosterior) -> float:
    return max(eu_submit(answer_posterior), eu_abstain())
```

This is why the Bayesian agent abstains on some questions. Not because it "doesn't know" --- that would be a vibes-based assessment --- but because the posterior probability of its best answer falls below the decision-theoretic threshold. Abstention here is a calculated act of self-preservation, not an admission of defeat.

## Value of Information: When to Query

Here is the heart of the whole enterprise. Before querying any tool, compute whether the expected improvement in decision quality exceeds the cost.

$$\text{VOI}(t) = \mathbb{E}_{\text{response}}\left[\max(\text{EU}^*_{\text{submit}},\, \text{EU}_{\text{abstain}}) \mid \text{after response}\right] - \max(\text{EU}^*_{\text{submit}},\, \text{EU}_{\text{abstain}}) \mid \text{current}$$

In plain language: what is the expected best EU *after* receiving the tool's response, minus the best EU *right now*? If that gain exceeds the tool's cost, make the call. Otherwise, don't. The formulation has the austere beauty of something that was always obvious once someone writes it down.

Computing this requires enumerating possible responses. For each candidate answer the tool might return, we compute the probability of that response, update the answer posterior, and evaluate the resulting EU:

```python
def compute_voi(
    answer_posterior: AnswerPosterior,
    reliability_table: ReliabilityTable,
    tool_idx: int,
    category_posterior: CategoryPosterior,
    tool_config: ToolConfig,
) -> float:
    eu_current = eu_star(answer_posterior)
    coverage = tool_config.coverage_by_category

    p_covered = float(np.dot(category_posterior, coverage))
    expected_eu = 0.0

    if p_covered > 0:
        cat_given_answer = update_category_posterior_on_response(
            category_posterior, coverage, got_answer=True,
        )
        r_eff = effective_reliability(
            reliability_table, tool_idx, cat_given_answer,
        )

        wrong_lik = (1.0 - r_eff) / (NUM_CANDIDATES - 1)
        for j in range(NUM_CANDIDATES):
            lik_j = np.where(
                np.arange(NUM_CANDIDATES) == j, r_eff, wrong_lik,
            )
            p_resp_j = float(np.dot(answer_posterior, lik_j))
            if p_resp_j > 1e-15:
                post_j = update_answer_posterior(answer_posterior, j, r_eff)
                expected_eu += p_covered * p_resp_j * eu_star(post_j)

    expected_eu += (1.0 - p_covered) * eu_current

    return max(expected_eu - eu_current, 0.0)
```

VOI is always non-negative (Jensen's inequality --- you can always ignore the information). The decision to query reduces to `VOI(t) - cost(t) > 0`. No agonising over "should I check one more tool just in case." No precautionary principle. A number that either exceeds a threshold or doesn't. The agent's emotional range on the matter is nil.

This is why the Bayesian agent averaged fewer than one tool query per question while the LangChain agent averaged over three. After zero or one queries, the VOI of additional queries dropped below their cost for most questions. The agent stopped --- not because it was instructed to be frugal, but because the mathematics told it further queries were a bad investment. Parsimony as a theorem rather than a suggestion.

## The Decision Loop

The full loop ties these components together. At each step, the agent computes the EU of submitting its best answer, the EU of abstaining, and the net VOI of each unused tool. It selects the action with the highest expected utility:

```python
def select_action(state, reliability_table, tool_configs):
    eu_sub = eu_submit(state.answer_posterior)
    eu_abs = eu_abstain()

    best_action = Action(ActionType.ABSTAIN, eu=eu_abs)
    if eu_sub >= eu_abs:
        best_idx = int(np.argmax(state.answer_posterior))
        best_action = Action(ActionType.SUBMIT, answer_idx=best_idx, eu=eu_sub)

    for t_idx in range(len(tool_configs)):
        if t_idx in state.used_tools:
            continue
        voi = compute_voi(
            state.answer_posterior, reliability_table,
            t_idx, state.category_posterior, tool_configs[t_idx],
        )
        net = voi - tool_configs[t_idx].cost
        if net > best_action.eu:
            best_action = Action(
                ActionType.QUERY, tool_idx=t_idx, eu=net,
            )

    return best_action
```

The loop terminates when the best action is to submit or abstain --- when no tool query has a net VOI exceeding the current best option. This is *convergent by construction*: each query either improves the posterior enough to justify its cost, or the agent stops. No maximum iteration count. No hardcoded "query at most N tools." The mathematics handles termination the way mathematics handles most things: by making the alternative numerically absurd.

## What the Numbers Show

The benchmark runs 50 multiple-choice questions with four tools of varying cost and reliability. The results from the essay are worth restating now that the mechanism is laid bare:

| Agent | Accuracy | Score | Tools/Question |
|-------|----------|-------|----------------|
| Bayesian | 59.6% | +112.6 | ~1.0 |
| LangChain ReAct | 63.7% | -8.0 | 3.22 |
| LangChain Enhanced | 66.0% | -68.2 | 3.94 |
| Random | 25.0% | -72.5 | 2.0 |

The LangChain Enhanced agent --- the one given careful prompting about being selective with its tool use --- performed *worse* than vanilla LangChain and barely outscored random guessing. The prompt instructed it to be careful; it interpreted "careful" as "thorough," querying 3.94 tools per question. More elaborate prompting produced worse outcomes because *cost-benefit analysis is not a prompting problem*. You cannot prompt your way to decision theory any more than you can prompt your way to calculus.

The Bayesian agent's lower raw accuracy is a feature, not a deficiency. It abstained on questions where its posterior confidence was too low to justify the gamble --- choosing 0 points over an expected loss. The LangChain agents submitted answers to every question, cheerfully accumulating wrong-answer penalties on questions they should have declined. The confidence of the uninformed is a reliable generator of negative expected value.

## Adaptation Under Drift

In the drift experiment, one tool's reliability degrades partway through the task. An agent that continues trusting the degraded tool sees its score collapse by 69 points. The Bayesian agent's forgetting mechanism ($\lambda = 0.95$) exponentially discounts old observations:

$$\alpha_{\text{new}} = 0.95 \cdot \alpha_{\text{old}} + \Delta\alpha$$

Within a few questions of the degradation, the posterior shifts, the VOI calculation redirects queries to more reliable alternatives, and the score barely notices. No change-detection heuristic, no special-case logic. Just Bayes' rule with a discount factor. The machinery does not require a memo informing it that conditions have changed; it works it out from the data, which is what machinery designed to work things out from data tends to do.

## What I Still Don't Know

The benchmark has 50 questions, 4 tools, and 5 categories. The VOI calculation enumerates all possible responses for each tool --- four candidates per tool, entirely tractable at this scale. In a production system with hundreds of endpoints, ambiguous objectives, and continuous rather than discrete responses, that enumeration detonates. Whether you can approximate VOI cheaply enough to preserve the advantage remains genuinely open.

There is also the matter of composability. The Bayesian agent treats each tool query as independent. Real tools harbour correlated errors --- two endpoints hitting the same upstream database will fail in solidarity. Modelling those correlations means graduating from independent Betas to something like a Dirichlet or a full joint distribution, and the computational cost scales with enthusiasm.

And perhaps the most interesting open question: whether principled decision theory and the flexibility of language models are complementary rather than competing approaches. A hybrid that uses Bayesian VOI to decide *whether* to call a tool, and an LLM to interpret the response, might combine the strengths of both without inheriting the worst habits of either. I haven't built it yet, but the interfaces are clean enough that the attempt wouldn't require heroism.

Code and full results: [github.com/gfrmin/credence](https://github.com/gfrmin/credence)
