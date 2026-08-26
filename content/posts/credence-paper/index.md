---
title: "The Ablation That Beat the Agent"
subtitle: "A paper re-framed itself three times. The third time, the thing doing the re-framing was its own benchmark, telling me the headline number had been measuring the benchmark's asymmetries rather than the architecture"
description: "I said a Credence paper was going to arXiv. It never went. Each of its three framings was killed by a specific measurement: frontier-LLM dominance, then a one-line greedy ablation that beat the full Bayesian agent under fair conditions, robustly, under every credit-assignment rule tested. What survived is narrower, conditional, and better — an exploration-attribution contingency law — and the experience is the direct origin of the pre-registration discipline everything I have built since runs under."
author: "Guy Freeman"
date: 2026-08-03
series: [credence]
series_order: 7
categories: [essays, bayesian, machine-learning, ai]
---

In April I wrote, on this site, that a paper was being prepared for arXiv: *Credence: A Bayesian Decision-Theoretic Framework for LLM Agent Tool Selection*. It was going to argue that choosing which tool to query is a decision problem under uncertainty, and that solving it as one beats solving it as a language-generation problem. I had the number to prove it: the Bayesian agent scored +129.5 against the best LLM variant's +10.8, a factor of twelve, while being *less* accurate on the questions it attempted --- 62.6% against 76.4%.

The paper never went out. The last commit on its branch is dated 4 June; the research artefacts were moved to a separate repository on 20 July and have not moved since. This is the account of why, and it is not a story about running out of time. It is a story about a claim that got narrower three times, each time because a specific measurement said it had to, until what was left was true, conditional, and not the thing I had announced.

I am telling it because the sequence is more useful than the paper would have been, and because the discipline I have run every project under since --- freezing the acceptance criteria before the code exists, and signing them --- is a direct response to what follows.

## What the original number was measuring

The first framing was the one I published: Bayesian dominates LLMs. It was drawn from a benchmark of fifty questions, four simulated tools with category-dependent reliability, scoring +10 for a correct answer, −5 for a wrong one, 0 for an abstention, minus the cost of tools queried.

That benchmark had two structural asymmetries, and I want to be precise that neither was a bug. Both were modelling choices that looked reasonable at the time and that I could not see past from inside.

The first: the Bayesian agent received each question's category as a perfect oracle, handed straight to its per-category reliability table. The LLM agents received the question text and four candidate answers, and had to work out for themselves what kind of question they were looking at. "Knows which tool suits this category" was structural for one competitor and inferential for the other. That is not a hard comparison to win.

The second: many of the fifty questions were answerable from a frontier model's own world knowledge, with no tool call at all --- Haiku 4.5 answers about thirty of the fifty cold. So the benchmark could not separate the value of *tool selection* from the value of *parametric recall*. It was scoring two different skills and reporting one number.

## Pivot one: the frontier model wins on score

The first thing to break the original framing was not subtle. Redesign the benchmark to remove the worst of the asymmetry, run a frontier model on it properly, and Haiku 4.5 scores +445.5 against the Bayesian agent's +163.7.

That is not a narrow loss. It ended "Bayesian dominates LLMs" as a sentence I could write, and the framing moved to something defensible and considerably less exciting: the Bayesian approach is the principled, near-zero-cost one; frontier models win on raw score, but they win at API cost. A cost-performance argument rather than a dominance argument.

I could have stopped there and written that paper. The reason I did not is the next measurement.

## Pivot two: the ablation

The Phase A bootstrap, run on 4 May, tested the full Bayesian agent against its own ablations. One of those ablations is close to trivial: query the single tool with the highest expected reliability, submit the answer, stop. No value-of-information computation. No abstention. One query, always.

That ablation beat the full agent by Δ = +25.75, with a 95% confidence interval of [+1.15, +51.10], p = 0.0386, over twenty paired seeds.

The interval's lower bound is barely above zero and the result is only marginally significant, so I want to be careful about how much weight it carries on its own. What made it impossible to set aside was that its *sign* was exactly what the fairness analysis predicted. When the category is given to you for free, the reliability table already concentrates on the right tool, so the marginal value of VOI's tool-by-tool exploration collapses --- there is nothing left to learn that you were not handed. And abstention actively costs you when the best available tool is good enough that submitting has positive expected utility on average. Both of the agent's distinguishing mechanisms were being paid for and neither was earning under those conditions.

Read against my published ablation table --- the one that said removing VOI costs the agent 78.1 points --- this is a straightforward reversal. That table was computed under oracle categories. Remove the oracle and the sign flips.

## The de-confound, and why it settled the matter

There was one honest way out, and I took it seriously because it would have rescued the claim.

Under fair conditions the agent has to infer categories rather than being told them, which it does with a Gaussian naive-Bayes classifier over offline sentence embeddings --- leave-one-out accuracy about 0.78. Every inferred-category result therefore sits downstream of a second choice nobody had tested: the *credit-assignment rule*, which decides how an observed outcome updates per-category reliability when you are not certain which category you were in. The deployed rule spread fractional credit across every category. If that leakage was what denied exploration its signal, then the fair loss was an artefact of a tractable approximation, not a fact about the architecture.

So all three rules were tested against both policies, cost-blind, twenty seeds:

| credit rule | greedy | horizon-VOI | gap |
| --- | ---: | ---: | ---: |
| soft (deployed) | 149.8 | 116.7 | −33.1 |
| hard (argmax) --- zero leakage | 142.5 | 130.4 | −12.1 |
| post (the proper de Finettian rule) | 151.4 | 126.7 | −24.6 |

Greedy wins under all three. The mechanism call was right --- better attribution does help exploration, lifting horizon-VOI by 13.7 points from soft to hard --- but even at exploration's best case, zero-leakage hard credit, it still loses by 12. And the *proper* rule lands at −24.6, because cleaner attribution lifts greedy too.

Only under a perfect-attribution oracle does exploration win, and there it wins clearly: horizon-aware VOI scores 216.8 against greedy's 189.4, about +27. The exact decoupled ceiling is 211.8, and a depth-one lookahead already reaches it.

A 78%-accurate classifier is not enough. Under no credit rule is it enough.

## What actually survived

This is the part that would have been the paper, and I think it is a better contribution than the one I set out to make --- it is just much smaller, and it is a law rather than a victory.

**In category-conditioned tool selection, the value of exploration is contingent on the quality of category attribution.** Given clean categories, horizon-aware VOI --- valuing information across the remaining questions rather than only the next one --- repairs myopic VOI's under-exploration and beats optimism-greedy by 27. Given inferred categories, attribution noise denies exploration the clean per-category signal it depends on, and minimal-query optimism wins. The +27 and the −12 are not a result and an embarrassment. They are two points on one curve, and the curve is the finding.

Three things survive alongside it, and I list them because a retrospective that reports only the losses is as unbalanced as one that reports only the wins:

The Bayesian *substrate* --- reliability learning plus category inference --- earns the cost-efficient frontier in both conditions. Every learning policy buries every non-learning baseline. That was never in question and was never what fell.

VOI dominates the free local Llama outright: fewer tool calls *and* a higher score. It is the frugal point on the frontier, which is a real if modest claim.

And optimism-greedy is itself a member of the Bayesian family. The thing that beat the VOI action layer is not a non-Bayesian rival; it is a cheaper Bayesian policy. The family owns the cheap regime either way. What the experiment refuted was the narrower prior that the VOI *action layer* specifically beats greedy under fair conditions.

## Why there is no paper

Three framings in four months, each retired by a measurement rather than by a reviewer. That is the system working. But it left me with a paper whose thesis had become "the value of exploration depends on how well you can tell what kind of problem you are looking at" --- true, supported, and a long way from the claim that justified writing it.

Then the ground moved underneath the question. The foundation this was all built on has since been superseded by [a successor language](/posts/make-it-unsayable/) that makes the architectural rules unwriteable rather than merely written down, and much of what Credence argued in prose it now enforces in grammar. Writing up a decision-theoretic framework whose foundation I had already replaced would have meant defending a design I had moved past. The honest options were to rewrite the paper around the contingency law alone, or to leave it. I left it, and put the record here instead.

## The part that changed how I work

The failure mode in all of this is worth stating plainly, because it is not "I made a mistake in a benchmark."

At every stage I held both pens. I designed the benchmark, I designed the agent, I chose the ablations, and I read the results --- and when a result was disappointing I was free to adjust the conditions and run it again. Every individual adjustment was defensible. Giving the Bayesian agent categories was a deliberate modelling choice to expose the reliability structure. Redesigning the benchmark after the frontier-model result was correcting a real asymmetry. Testing three credit rules was rigour, not motivated reasoning.

But the aggregate is a benchmark that moved every time it delivered bad news, and there is no sequence of locally-defensible adjustments that gets you back the epistemic standing of a criterion fixed in advance. The thing that saved this project was one measurement I did not design my way around: a one-line ablation, simpler than the agent, that beat it. It won because it was cheap enough that nobody had thought to protect it.

So every project since runs the other way round. The acceptance criteria are written first, before any implementation exists, and cryptographically sealed --- [the frozen-oracle protocol](/posts/signed-before-the-code-existed/), where the tests are handed to the builder already failing red and cannot be edited to pass. The point is not that I distrust myself more than average. It is that "I will not soften this test when it becomes inconvenient" is a promise, and a hash is not. The same instinct produced [a gate that decides whether a tool is worth adopting](/posts/the-gate-that-said-no/) and was given the power to refuse --- and refused.

None of that machinery would have saved the original paper. Freezing the wrong criterion in advance just gets you a frozen wrong criterion, and no amount of custody chain tells you that your fifty questions are answerable without tools. What it would have done is make the record legible: three framings, each one dated, each one's falsifier named, with no possibility of the earliest one quietly disappearing.

Which is the version I would rather publish anyway. The paper is not on arXiv, the headline I announced did not survive contact with a fair benchmark, and the ablation that beat the agent is a better result than the one I went looking for.
