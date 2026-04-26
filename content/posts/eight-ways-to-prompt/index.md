---
title: "The Prompting Gradient"
subtitle: "Three LLM variants, three layers of sophistication, and the ceiling they cannot reach"
description: "Each prompting technique helps. Reasoning traces, strategy guidance, cross-question history --- each one improves accuracy and score. None of them closes the gap with a Bayesian agent that does not use language at all. The ceiling exists because descriptions of calculations are not calculations."
author: "Guy Freeman"
date: 2026-04-01
publishDate: 2026-04-30
categories: [essays, bayesian, machine-learning, ai]
---

The [accuracy paradox post](/posts/accuracy-paradox/) reported the headline: a Bayesian agent scoring +129.5 against an LLM agent's +10.8, despite lower accuracy. This post is about the LLM side of that experiment --- what was tried, what helped, and where the ceiling is.

## The Three Variants

Three LLM agents were tested on the same 50-question benchmark. They differed only in prompting:

**LLM Bare.** The model receives a description of the four available tools, the scoring system (+10 correct, -5 wrong, 0 abstain, minus tool costs), and the current question with its four candidate answers. No guidance on how to decide. No reasoning format imposed. The model chooses a tool, receives a response, and decides what to do next.

Score: -160.5. Accuracy: 43.8%. Tools per question: 3.26. Time per question: 0.93 seconds.

The bare agent queries roughly three tools per question and gets less than half of them right. Without any structure, the model treats tool selection as a text generation problem --- it picks tools based on what seems reasonable to write next. The cost of 3.26 queries per question, at 1--2 points each, destroys the value even when the final answer is correct.

**LLM ReAct.** The model is now required to emit a "Thought:" line before every action, following the ReAct framework (Yao et al. 2023). The thought must explain the reasoning behind the tool choice. Otherwise the setup is identical.

Score: -15.3. Accuracy: 66.0%. Tools per question: 2.70. Time per question: 4.60 seconds.

A 145-point improvement. Reasoning traces work. Forcing the model to write out its chain of reasoning before acting catches obvious errors: it identifies that numerical questions should go to the calculator, that recent-events questions benefit from web search, that cross-verifying an already-confident answer is wasteful. Accuracy jumps by 22 percentage points and tool usage drops by half a tool per question.

This is consistent with what the ReAct literature reports. It is also the largest single improvement in the experiment. If you are going to add one thing to an LLM agent, reasoning traces are the thing to add.

**LLM ReAct+S+H.** The fully enhanced variant. In addition to reasoning traces, the model receives two blocks of text:

A *strategy block* explaining which tools are reliable for which question types, warning about misconception traps (where web search returns popular-but-wrong answers), and suggesting an abstention threshold: "If you think there's less than a 1 in 3 chance you're right, abstain."

A *history block* containing the outcomes of the last 10 questions --- which tools were queried, what they returned, whether the final answer was correct. This allows the model to observe patterns in tool reliability over time, a crude approximation of the Bayesian updating that the Credence agent performs analytically.

Score: +10.8. Accuracy: 76.4%. Tools per question: 3.05. Time per question: 5.65 seconds.

Another 26-point improvement. The best LLM variant. Highest accuracy of any agent in the experiment, including the Bayesian one. This is the version that prompting advocates would point to: a well-engineered LLM agent, given appropriate guidance and context, performing at 76% accuracy on a challenging benchmark.

It scores twelve times less than the Bayesian agent.

## Where the Ceiling Is

The three variants form a clear gradient. Each layer of prompting sophistication --- reasoning structure, domain knowledge, historical context --- adds both accuracy and score. The improvements are genuine and replicable across seeds. There is no result here that says prompting is useless.

The result is that the gradient has a ceiling, and the ceiling is well below what the Bayesian agent achieves. The mechanism is visible in the tools-per-question column: 3.26, 2.70, 3.05. The bare agent queries many tools thoughtlessly. ReAct reduces this by forcing deliberation. But the enhanced variant *increases* tool usage back to 3.05 --- because the strategy guidance makes the model more thorough. It now considers reliability differences, which leads it to cross-verify more often. Cross-verification is sometimes valuable. Computing *when* it is valuable requires knowing the expected information gain from the second query and comparing it to the cost. The model does not know how to do this calculation. It knows that cross-verification is described as sometimes-valuable, and so it cross-verifies.

This is the prompting trap in precise terms. The model's accuracy increases because it is gathering more information per question. Its score increases because the accuracy gains outweigh the costs --- but only barely. The Bayesian agent, by computing VOI analytically, queries 1.80 tools per question and achieves +129.5. The gap between 1.80 and 3.05 unnecessary queries per question, across 50 questions, is the gap between computing the trade-off and describing it.

## What the Time Column Says

The fully enhanced LLM takes 5.65 seconds per question. The Bayesian agent takes 0.07 seconds. An 80x difference.

The LLM's time is spent on inference: generating reasoning traces, processing strategy text, digesting history, producing the action. This is the cost of using a language model as a decision-maker. The Bayesian agent performs closed-form Beta posterior updates and a VOI computation that amounts to a few multiplications and an argmax. The decision layer is orders of magnitude simpler and orders of magnitude faster.

This matters beyond the benchmark. In production, where tool queries cost API fees and latency is a user experience metric, the LLM's deliberation overhead is a real cost. The fully enhanced variant's strategy of "reason carefully about every query" would be the most expensive and least efficient approach to tool selection in deployment. It achieves the highest accuracy and the worst cost efficiency.

## The Structural Argument

I want to be precise about what this experiment does and does not demonstrate.

It does not demonstrate that prompting is useless. Each technique helps, measurably and consistently.

It does not demonstrate that LLMs are bad at reasoning. The enhanced variant's 76.4% accuracy is genuinely impressive on a benchmark designed to be difficult, with misconception traps and heterogeneous tool reliability.

What it demonstrates is that there is a class of decisions --- specifically, decisions that require comparing the expected information gain from an action against its cost --- where the description of the calculation cannot substitute for performing it. The model can write "I should only query this tool if the expected benefit exceeds the cost." It cannot compute the expected benefit, compare it to the cost, and act on the result. This is not a prompting failure. It is a category error: treating a calculation as a generation task.

The [Credence architecture](/posts/three-types/) separates these concerns. The LLM serves as a tool --- a noisy sensor that returns candidate answers, evaluated by the Bayesian agent for their information content. In this role, the LLM is genuinely valuable. The `llm_direct` tool is the most reliable option for reasoning questions (72%) and competitive across other categories. What the LLM is not doing is deciding which tools to query or when to stop querying. That job belongs to the decision layer, which is smaller, faster, and --- on this benchmark --- twelve times more effective.

The result generalises. The same decision-layer-plus-LLM-as-sensor pattern, applied to production LLM routing rather than simulated tools, [cuts inference cost by ninety-six percent](/posts/ninety-six-percent-cheaper/) against an always-Sonnet baseline while raising quality. The thing that doesn't scale is the prompting gradient. The thing that does is the calculator.

{{< callout type="note" >}}
This benchmark used text-based LLM parsing and prompted variants of a single model. Later configurations with frontier models and native tool-calling narrow the score gap considerably --- but the prompting gradient (each technique helps, none closes the structural gap) and the category error (describing a calculation is not performing it) remain the core findings.
{{< /callout >}}
