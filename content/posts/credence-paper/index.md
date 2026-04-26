---
title: "Two Proofs of the Same Argument"
subtitle: "The paper going to arXiv and the proxy running in production are making the same claim, in different registers"
description: "A Credence paper is being prepared for arXiv. A Credence proxy is already on Docker Hub cutting inference costs by ninety-six percent. They are not alternatives. They are two demonstrations of the same underlying claim: that LLM tool selection is a decision problem, and treating it as one produces better outcomes than prompting."
author: "Guy Freeman"
date: 2026-04-15
draft: true
categories: [essays, bayesian, machine-learning, ai]
---

There's a paper, and there's a proxy. They are not in competition. They are two forms of the same argument.

The paper, *Credence: A Bayesian Decision-Theoretic Framework for LLM Agent Tool Selection*, is being prepared for arXiv. Its central claim is that the problem of picking which tool to query --- when to stop, when to abstain --- is a decision problem under uncertainty, and that solving it as a decision problem produces substantially better outcomes than solving it as a language generation problem. The evidence is a controlled benchmark: fifty questions, four simulated tools, a small Bayesian agent that beats the best LLM variant by a factor of twelve in total score while being twelve percent less accurate on the questions it attempts.

The proxy, meanwhile, is [already shipping](/posts/ninety-six-percent-cheaper/). It is an OpenAI-compatible endpoint that routes real requests to real models on the basis of learned per-category reliability, observed latency, and observed cost, and on a 50-query OpenClaw benchmark it cut inference cost by 96%, cut latency by 52%, and raised quality by 1.24 points against an always-Sonnet baseline.

These are two proofs of the same theorem. The paper will be the formal version: axioms, convergence results, comparison with related work. The proxy is the empirical version: Docker image, metrics endpoint, production traffic. Both are necessary, and the argument is stronger because both exist.

## The Three Headline Results (from the Benchmark)

The paper builds around three results that have replicated across seeds and whose mechanisms are explicit.

**The accuracy paradox.** The Bayesian agent achieves 62.6% accuracy on its submitted answers. The best LLM variant achieves 76.4%. The Bayesian agent scores +129.5 points total. The best LLM scores +10.8. [A previous post](/posts/accuracy-paradox/) explains the mechanism. For the paper, this result matters because it demonstrates that accuracy, as conventionally measured, is the wrong metric for deployed agents operating under cost constraints.

**The prompting ceiling.** Three LLM variants form a clear gradient: Bare (-160.5), ReAct (-15.3), ReAct+S+H (+10.8). Each prompting technique --- reasoning traces, strategy guidance, cross-question history --- improves both accuracy and score. But the improvements never close the gap: even the fully enhanced variant, with the highest accuracy of any agent in the experiment, scores twelve times less than Credence. The additional reasoning makes the agent more thorough, but thoroughness costs queries, and the LLM has no formal mechanism for computing whether a query is worth its cost. The ceiling is not a prompting failure. It is a category error.

**Graceful degradation.** When tool reliability shifts mid-experiment, the Bayesian agent barely notices: its score drops by 21.8 points. A heuristic baseline that always queries the historically best tool collapses: its score drops by 69.0 points. Robustness to distribution shift is what distinguishes an architecture from a fitting exercise.

## What Each Component Is Worth

The paper includes an ablation study that is in some ways more informative than the headline results.

| Removed component | Score | Delta from full agent |
|---|---|---|
| Nothing (full agent) | +112.6 | --- |
| Category inference | +10.6 | -102.0 |
| VOI-based tool selection | +34.5 | -78.1 |
| Reliability learning | +34.5 | -78.1 |
| Abstention | +91.1 | -21.5 |

Category inference is the most valuable component by a wide margin. Without it, the agent cannot route questions to appropriate tools. Accuracy collapses from 59.6% to 31.6%.

VOI and reliability learning contribute equally (-78.1 each), and this is not coincidence but mathematical consequence: when reliability priors are uninformative (p = 0.5), all tools look equally trustworthy, so the VOI calculation degenerates to cost-based selection. The framework's power comes from the *interaction* between learned category-specific beliefs and VOI, not from either component alone.

Abstention provides a moderate but consistent benefit (-21.5) by avoiding -5 penalties on low-confidence questions. Removing it also doubles the score variance (82.2 vs 44.6), indicating less consistent performance --- the agent is now gambling on questions it should walk away from.

## Why the Proxy Is Evidence for the Paper

A reviewer encountering the benchmark will ask whether the result generalises. The benchmark has four simulated tools with known reliability parameters; production systems have real LLM providers with unknown reliability across a distribution of real queries. The natural objection is that the result is benchmark-specific.

The proxy is the answer to that objection. It runs the same decision-theoretic core, with the same Beta-Bernoulli reliability tracking, the same expected utility calculation, the same posterior updating on observed outcomes. The tools are real LLM providers. The queries are real agent traffic. The reward signal is a judge model scoring outcomes on a 0--10 scale.

The mechanism transfers without modification. The Bayesian agent in the benchmark calls fewer tools per question (1.80 vs 3.05); the proxy calls cheaper models per request. Both behaviours fall out of computing value of information against cost, rather than describing the trade-off in prose. The benchmark is a controlled demonstration; the proxy is the same mechanism under production conditions. That both produce large improvements is not coincidence. It is exactly what you would expect if the underlying claim were correct.

## What the Related Work Nearly Does

Three recent papers occupy positions adjacent to what Credence does.

RAFA (Liu et al., ICML 2024) uses Bayesian regret bounds to guide a language model's reasoning and acting loop. The distinction is that RAFA treats the language model as the decision-maker and uses Bayesian reasoning to guide its selection among action proposals. In Credence, the language model is a tool --- a noisy sensor --- and the decision-maker is a separate Bayesian agent with explicit beliefs and an explicit utility function.

DeLLMa (Liu et al., ICLR 2025) applies expected utility maximisation to LLM decision-making under uncertainty. This is the closest thing in the literature. The distinction is scope: DeLLMa applies EU maximisation to a fixed decision problem with a known utility function, while Credence applies it where the utility function is itself uncertain and updated from observation. DeLLMa assumes the objective; Credence learns it.

MACLA (Forouzandeh et al., AAMAS 2026) uses Beta posteriors for procedure selection, which is structurally similar to Credence's Beta-Bernoulli reliability tracking. The distinction is that MACLA does not compute VOI; it selects by reliability estimate alone. Credence computes whether the expected benefit of a query exceeds its cost before deciding whether to query at all.

None of these three combines per-tool beliefs, VOI computation, EU maximisation, and posterior updating on query outcomes in a single architecture. The gap the paper is filling is real.

## The Arguments Under Scrutiny

A paper making architectural claims invites two standard objections.

The benchmark-specificity objection is that the 50-question benchmark is constructed to favour a Bayesian approach. This is partly true and should be acknowledged. The benchmark was designed to test what Credence claims to be good at: cost-aware tool selection with heterogeneous tool reliability. A benchmark that did not test these properties would be uninformative. The question is whether the properties tested are the properties that matter in deployment. The proxy's performance on real traffic is the strongest available answer.

The apples-to-apples objection is that comparing a Bayesian agent with known tool specifications to an LLM that must infer tool properties from prompts is not fair. This misunderstands the architecture. The Bayesian agent does not know the tool specifications. It begins with uninformative Beta priors over reliability per category and updates from observation, exactly as the LLM is given historical context to reason from. If anything, the LLM has the advantage on early questions, before the Bayesian posteriors concentrate. The divergence grows as the experiment continues, which is the correct direction for a learning system.

## Why Both Forms of the Argument Matter

A paper establishes characterisations. A production system establishes that the characterisations apply to the world. Neither replaces the other.

The paper's job is to work out what the framework is doing formally: the convergence properties of the Beta posteriors, the conditions under which EU maximisation produces optimal selections, the relation to the rest of the literature. The proxy cannot do these things; a Docker image is not a mathematical object. The benchmark is controlled, which is what allows the three headline results to be stated as precisely as they are.

The proxy's job is to demonstrate that the mechanism survives contact with reality. It is one thing to show that computing VOI beats prompting in a simulation; it is another to show that the same computation, applied to real LLM providers with real latency distributions and real cost curves, produces ninety-six percent savings. Both are necessary. Either one, alone, is less convincing than the two together.

I intend to submit the paper. The architecture is [open source](https://github.com/gfrmin/credence), the benchmark is reproducible, the proxy is deployable, and the argument, I think, is correct.
