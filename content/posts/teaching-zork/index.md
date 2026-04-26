---
title: "Teaching Zork to a Bayesian"
subtitle: "What happens when your LLM is a sensor, not a commander"
description: "A Bayesian agent plays text adventures with four information sources and a VOI gate on every query. The LLM recommends actions. The mathematics decides whether to listen."
author: "Guy Freeman"
date: 2026-03-23
publishDate: 2026-04-28
categories: [python, bayesian, machine-learning, ai, interactive-fiction]
---

{{< callout type="note" >}}
This is Part 2 of a series. For the axioms and types underneath, see [Part 1: Three Types and a Funeral](/posts/three-types/). For the state-representation consequences, see [Part 3: The Loop Problem](/posts/loop-problem/).
{{< /callout >}}

Every AI agent demo involves web search, retrieval, or API calls --- tasks where querying everything is merely expensive. A LangChain ReAct agent that hammers all four tools on every question wastes money but still gets answers. The penalty is economic, not existential.

Text adventures are different. You have a world state you cannot fully observe, hundreds of valid actions, sparse rewards, and every action is irreversible. You cannot try all the doors. You cannot examine every object. You cannot ask the LLM about every room, because by the time it answers, the troll has eaten you. The question is not "can I afford to query this tool?" but "will querying this tool improve my next decision enough to justify *not acting* right now?"

This is value of information in its native habitat. I built an agent that plays interactive fiction --- Enchanter, Zork, the classics --- using the Bayesian decision theory from [Part 1](/posts/three-types/). The architecture is simple: four information-gathering tools, a VOI gate on every query, and an LLM that is explicitly a sensor, not a commander. The results are instructive, less for what the agent achieves than for what the constraints prevent it from doing wrong.

## The Architecture

Each game step is a fresh decision problem. The agent observes the current game state --- room description, valid actions, inventory, score --- and must commit to a single irreversible action. Before committing, it can consult information sources. Each consultation has a cost (even if only computational), and the question is always the same: does the expected improvement in decision quality exceed the price?

```python
class IFAgent:
    """Bayesian decision-theoretic IF agent.

    Uses BayesianAgent as the information-gathering controller: each game step,
    VOI decides which info sources to consult before committing to an action.
    The reliability table persists across steps, learning which sources work
    in which situations.
    """
```

The agent has four tools:

**Look** (cost: 0.0) --- peek at the room description via a save/restore bracket, without consuming a game turn. Extract keywords. Match them against valid actions. Coverage prior: 90% useful for exploration, 50% for puzzles, 30% for inventory management.

**Examine** (cost: 0.0) --- examine the most novel visible object, again without consuming a turn. The tool picks up to three targets, preferring items the agent hasn't interacted with. Coverage prior: 90% for puzzles, 50% for exploration.

**Inventory** (cost: 0.0) --- check what the agent is carrying. Coverage prior: 90% for inventory situations, 20% for exploration.

**LLM Advisor** (cost: 0.02) --- ask a language model which action to take. Returns a recommended action *index*. Coverage prior: 70% across all categories.

The first three tools are free and domain-specific. The fourth costs money and is general-purpose. The coverage priors encode what kind of situation each tool is useful for --- and these priors get updated from experience. A tool that claims 90% coverage for puzzles but consistently recommends wrong actions in puzzle situations will see its reliability posterior collapse. The agent stops querying it for puzzles. No configuration change required. Just Bayes' rule doing what it does.

## The VOI Gate

Before each action, the agent runs the decision loop from Part 1:

1. Classify the current situation --- exploration, puzzle, inventory, dialogue, combat --- using keyword patterns from the observation text.
2. Compute the expected utility of committing to the best action now.
3. For each unused tool, compute the VOI: how much would its response improve the decision?
4. If any tool's net VOI exceeds zero, query it. Update beliefs. Repeat from step 2.
5. When no tool justifies its cost, commit to the action with the highest expected utility.

The category classification matters because tool reliability varies by situation. Looking around is highly informative when you're exploring a new area. It tells you almost nothing during combat. The agent maintains a reliability table --- $P(\text{correct} \mid \text{tool}, \text{category})$ --- as a grid of Beta distributions, one per tool-category pair. Each distribution starts with a prior ($\text{Beta}(1, 1)$ for the free tools, $\text{Beta}(7, 3)$ for the LLM) and updates after every step based on whether the chosen action produced progress.

The LLM's warm start at $\text{Beta}(7, 3)$ --- an expected reliability of 70% --- deserves comment. A uniform prior of $\text{Beta}(1, 1)$ would give the LLM zero initial VOI: the agent doesn't yet believe the tool can help, so the expected information gain from querying it is negligible, so it never queries it, so it never learns whether the tool can help. This is the cold-start problem for Bayesian tool selection, and the fix is to encode a modest prior belief that the LLM is somewhat reliable. If the LLM turns out to be useless, a few negative updates will collapse the posterior. If it's useful, the warm start saved the agent from missing out on early opportunities. The asymmetry is deliberate: the cost of briefly over-querying a useless tool is small. The cost of never discovering a useful one is permanent.

## The LLM as Sensor

Here is the `LLMAdvisorTool`. It asks a language model which action to take and returns the action *index*:

```python
class LLMAdvisorTool(IFTool):
    name = "llm_advisor"
    cost = 0.02

    def query(self, world, observation, valid_actions, **kwargs):
        actions_str = "\n".join(f"  {i}: {a}" for i, a in enumerate(valid_actions))
        prompt = (
            f"You are playing a text adventure game.\n\n"
            f"Current situation:\n{observation.text}\n\n"
            f"Available actions:\n{actions_str}\n\n"
            f"Which action number is best? Reply with ONLY the number."
        )
        response = self._generate(prompt)
        match = re.search(r"\d+", response)
        if match:
            idx = int(match.group())
            if 0 <= idx < len(valid_actions):
                return idx
        return None
```

The LLM says "take the sword." The agent does not take the sword. The agent says: "I'm in an exploration situation. Looking has historically been 85% reliable for exploration and costs nothing. The LLM is 68% reliable across categories and costs \$0.02. The VOI of looking is 0.12. The VOI of asking the LLM is 0.03, minus \$0.02, net 0.01. I'll look first."

After looking, the agent might find that the room description confirms the sword is important --- or that there's a passage north it hadn't noticed. Either way, the posterior over actions has shifted. Maybe the LLM's VOI is now negative (looking already answered the question). Maybe it's higher (the new information raised uncertainty about which action is best, making the LLM's advice more valuable). The agent recomputes and decides.

This is the "LLM as sensor, not commander" principle from Part 1, made concrete. The LLM's output is a noisy observation with quantified uncertainty. The Bayesian machinery makes the actual decision. The LLM cannot override this, for the same reason a thermometer cannot override a thermostat's setpoint. The thermometer provides data. The controller acts on it. Conflating the two is how you get systems that heat the house to 40°C because the thermometer said "40."

## The Save/Restore Trick

The free tools --- look, examine, inventory --- peek at game state without consuming a turn. They do this via a save/restore bracket:

```python
class LookTool(IFTool):
    name = "look"
    cost = 0.0

    def query(self, world, observation, valid_actions, **kwargs):
        snapshot = world.save()
        try:
            obs, _, _ = world.step("look")
            keywords = _extract_keywords(obs.text)
            return _score_actions(valid_actions, verb=None, nouns=keywords)
        finally:
            world.restore(snapshot)
```

Save the game state. Execute the information-gathering action. Extract what you learned. Restore the state. The game turn was never consumed. This is the interactive fiction equivalent of "thinking before acting" --- and the agent has to decide whether thinking is worth the computational cost.

In a web-search agent, this would be like previewing a search result without counting it as a query. The save/restore bracket makes the cost of free tools genuinely zero, which means their VOI calculation reduces to pure information value. The agent always consults free tools when they have positive VOI. The interesting decisions are about the LLM: is the expected improvement from an LLM recommendation worth \$0.02 *after* the free tools have already contributed their information?

Often the answer is no. The free tools, being domain-specific, frequently resolve enough uncertainty to make the LLM query redundant. Looking tells you there's a passage north. Examining the desk reveals a key. Inventory confirms you're carrying the lantern. By the time the free tools have spoken, the posterior over actions is concentrated enough that the LLM's marginal contribution falls below its cost. The agent saves \$0.02 per step without being told to be frugal. The mathematics handles parsimony.

## Category Inference

The agent classifies each situation into one of five categories: exploration, puzzle, inventory, dialogue, combat. The classification uses keyword patterns:

```python
CATEGORIES = ("exploration", "puzzle", "inventory", "dialogue", "combat")

_CATEGORY_PATTERNS = {
    "exploration": [re.compile(r"\b(dark|passage|room|door|north|south|...)\b", re.I)],
    "puzzle":      [re.compile(r"\b(locked|key|lever|button|switch|...)\b", re.I)],
    "inventory":   [re.compile(r"\b(take|drop|carry|holding|...)\b", re.I)],
    "dialogue":    [re.compile(r"\b(says?|asks?|tells?|speak|...)\b", re.I)],
    "combat":      [re.compile(r"\b(attack|kill|fight|sword|troll|...)\b", re.I)],
}
```

The classification feeds the VOI calculation by selecting which column of the reliability table to use. When the agent sees "A troll blocks the passage," the category posterior concentrates on "combat." The agent now knows that looking around (30% reliable in combat) is less likely to help than the LLM advisor (reliability learned from previous combat encounters). The VOI of each tool shifts accordingly.

The structured observation also provides a hint mechanism: if the agent is carrying a key and the room description mentions a locked door, the category hint jumps to "puzzle" with a +9.0 boost. This is prior information being encoded as --- wait for it --- prior information. Not a special case. Not a rule. A number that enters the posterior through the same `condition` call as everything else.

## Learning the Scoring Rule

Most benchmarks have a fixed reward structure. Text adventures don't. Some games give +5 for picking up a treasure. Others give +25 for solving a puzzle. Some penalise death at -10; others just restart you. The agent doesn't know the reward scale in advance.

The solution is online adaptation. The agent maintains exponential moving averages of observed positive and negative score deltas, and adjusts its scoring rule accordingly:

```python
# After each step:
score_delta = obs.score - prev_obs.score
if score_delta > 0:
    self._ema_reward = 0.7 * self._ema_reward + 0.3 * score_delta
elif score_delta < 0:
    self._ema_penalty = 0.7 * self._ema_penalty + 0.3 * score_delta

self.bayesian.scoring = ScoringRule(
    reward_correct=max(self._ema_reward, 0.1),
    penalty_wrong=min(self._ema_penalty, -0.1),
    reward_abstain=min(-0.05 * abs(self._ema_reward), -0.01),
)
```

The utility function evolves with the game. In Enchanter, where early puzzles give small rewards and later ones give large ones, the agent's VOI threshold adjusts upward as it learns that the stakes are increasing. In a game with harsh death penalties, the agent becomes more cautious --- it needs higher confidence before committing to risky actions, because the penalty for being wrong is larger relative to the reward for being right.

One might object that this violates Part 1's prohibition on ad-hoc mechanisms. It doesn't, quite. The EMA isn't modifying beliefs. It's updating the *utility function* --- the scoring rule that defines what "correct" and "wrong" mean in expected-utility terms. The beliefs (reliability posteriors) are still updated exclusively by `condition`. The decision mechanism is still EU maximisation. What changes is the payoff matrix, which is a parameter of the problem, not the solution. Whether this distinction is principled or convenient is a question I have not entirely settled. The agent doesn't seem to mind.

## Reward Attribution

The trickiest part of applying Bayesian tool reliability to interactive fiction is the reward signal. In a multiple-choice benchmark, you know the ground truth after each question. In a text adventure, you know the score delta --- but what does a delta of zero mean?

```python
def attribute_reward(score_delta, prev_obs, new_obs):
    if score_delta > 0:
        return True   # action led to progress
    elif score_delta < 0:
        return False  # action was harmful
    elif new_obs.intermediate_reward > 0:
        return True   # sub-quest progress
    elif _state_changed(prev_obs, new_obs):
        return True   # evidence of progress
    else:
        return None   # ambiguous — don't update
```

A positive score delta is clear: the action helped. A negative delta is clear: the action hurt. A zero delta with a state change (new room, new inventory) is treated as progress --- the agent moved forward even if the score didn't reflect it yet. A zero delta with no state change is ambiguous: the agent might have typed "look" (useful but scoreless) or "take rug" (futile). The system returns `None`, which tells the Bayesian machinery to skip the reliability update for this step. Better to learn nothing than to learn the wrong thing.

This is conservative by design. Many correct actions in interactive fiction produce no score change. Walking north, examining objects, picking up items --- these are often necessary preconditions for scoring actions, but they don't score themselves. Treating all zero-delta actions as failures would penalise exploratory tools and drive the agent toward passivity. Treating them as successes would inflate reliability estimates and make the agent overconfident. Returning `None` --- declining to update when the signal is ambiguous --- preserves the integrity of the reliability table at the cost of slower learning. Given that the reliability table persists across the entire game, the cost is modest.

## What the Constraints Prevent

The interesting thing about this agent is not what it does. It's what it *cannot* do.

It cannot query the LLM on every step. The VOI gate prevents this: once the free tools have resolved enough uncertainty, the LLM's marginal information value drops below its cost. The agent is parsimonious by construction, not by instruction.

It cannot ignore a tool's declining reliability. The Beta posteriors update after every step. A tool that recommends bad actions sees its $\alpha/(\alpha+\beta)$ ratio drop. Its VOI drops with it. The agent redirects queries without being told to, because the mathematics makes the alternative numerically absurd.

It cannot treat the LLM's recommendation as authoritative. The LLM returns an action *index* --- a noisy observation. The Bayesian machinery integrates this observation with the priors, the category posterior, and the outputs of the other tools. If three free tools agree on "go north" and the LLM says "take the sword," the posterior concentrates on "go north." Not because of a hard-coded priority system, but because three concordant signals outweigh one discordant one in the posterior calculation.

It cannot explore for its own sake. There is no exploration bonus, no curiosity mechanism, no epsilon-greedy override. When the agent explores --- and it does explore --- it's because the EU of exploring exceeds the EU of exploiting. When the EU of interacting with a new object equals the EU of waiting (both zero), the agent interacts, because indifference implies the VOI from the interaction outcome is positive (Part 1, forbidden pattern: "indifference implies exploration"). Exploration arises from honest uncertainty, not from a coin flip.

Every one of these properties traces back to the four axioms and the forbidden patterns. The agent doesn't need to be told not to over-query, not to ignore failing tools, not to blindly follow the LLM. The constitution makes these errors structurally impossible. This is, I think, the point: building intelligence is less about adding capabilities and more about making the right things impossible to violate.

[Part 3](/posts/loop-problem/) applies the same principles to a different failure mode --- the loop --- and eliminates 98.5% of them.

Code: [github.com/gfrmin/bayesian-if](https://github.com/gfrmin/bayesian-if)
