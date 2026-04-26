---
title: "Sixty-Two Percent Correct and Winning by a Hundred and Twenty Points"
subtitle: "What happens when you add a utility function to a question-answering benchmark"
description: "A Bayesian decision-theoretic agent scores lower on accuracy than every LLM variant it competes against --- and beats the best of them by 120 points. The explanation requires thinking about something that LLM benchmarks typically refuse to think about."
author: "Guy Freeman"
date: 2026-04-01
publishDate: 2026-05-07
categories: [essays, bayesian, machine-learning, ai]
---

The standard way to evaluate a question-answering system is to measure how often it gets the right answer. This seems reasonable. It is, in practice, a trap.

I ran an experiment to demonstrate why. A [Bayesian decision-theoretic agent](/posts/three-types/) --- built on the Credence DSL, using Beta-Bernoulli reliability tracking and value-of-information calculations --- competed against several LLM agents on a 50-question benchmark. All had access to the same four tools. All faced the same questions. All were scored on the same objective.

The Bayesian agent got 62.6% of its *submitted* answers correct. The best LLM variant --- ReAct with strategy prompting and cross-question history --- got 76.4% correct. By the standard benchmark logic, the LLM wins by a wide margin.

The LLM scored +10.8 points. The Bayesian agent scored +129.5.

## The Scoring Function

The benchmark had a simple reward structure: +10 points for a correct answer, -5 points for a wrong answer, 0 points for abstaining. Each tool query also cost between 1 and 2 points, deducted regardless of the result.

Under this structure, accuracy is not what you are optimising. Total score is. And total score depends on *which* questions you answer, *how many tools you query*, and *when you walk away*. These are decision problems. They are not accuracy problems.

The four available tools were a `quick_search` (broad but unreliable --- 70% correct for factual questions, 20% for numerical), a `knowledge_base` (expensive but 92% reliable for factual, sparse coverage elsewhere), a `calculator` (perfect for numerical, does nothing for anything else), and `llm_direct` (variable: 65--72% on factual and reasoning, 40--50% on misconceptions and recent events). Each question belonged to one of five categories: factual, numerical, recent events, misconceptions, or reasoning.

The Bayesian agent knew none of this in advance. It maintained Beta distributions over each tool's reliability per category, updated them as queries returned, and at each step computed whether the expected value of information from the next query exceeded the tool's cost. When no query was worth taking, it either submitted its best guess or abstained, depending on whether the expected score from submitting exceeded zero.

## Where the Points Come From

The best LLM agent averaged 3.05 tool queries per question. The Bayesian agent averaged 1.80. That difference --- 1.25 unnecessary queries per question, across 50 questions --- accounts for the bulk of the score gap.

A question in the "reasoning" category is not well-served by `quick_search` (40% reliability) or `knowledge_base` (45% reliability, 20% coverage). The only tool with meaningful reliability for reasoning questions is `llm_direct` at 72%. A correctly calibrated agent queries `llm_direct`, gets a response, and asks: does this response push my posterior far enough to justify the submission risk? If yes, submit. If the question looks like a misconception trap --- where web search returns the popular-but-wrong answer --- the agent weights the tools accordingly and either seeks a second opinion from the knowledge base or abstains.

The LLM agent, even with strategy guidance and cross-question memory, applied a more deliberative but more expensive approach. It reasoned carefully about each tool choice --- writing out chains of thought, considering reliability, checking history --- and this careful reasoning consistently concluded that verification was warranted. The problem is not that the reasoning was wrong. The problem is that the reasoning was unpriced. The LLM has no mechanism for computing whether the expected information gain from a second query exceeds its cost. It can describe the trade-off in words. It cannot calculate it.

## The Prompting Gradient

Three LLM variants were tested, each adding a layer of prompting sophistication:

- **LLM Bare** (no guidance): -160.5 points, 43.8% accuracy
- **LLM ReAct** (reasoning traces): -15.3 points, 66.0% accuracy
- **LLM ReAct+S+H** (reasoning + strategy + history): +10.8 points, 76.4% accuracy

Each technique helps. Reasoning traces improve accuracy by 22 percentage points and score by 145 points. Strategy prompting and cross-question history add another 10 points of accuracy and 26 points of score. The gradient is real. Prompting works.

It also does not close the gap. The fully enhanced LLM variant, with the highest accuracy of any agent in the experiment, scores twelve times less than the Bayesian agent. The reason is structural: the LLM's improvements come from being more thorough, but thoroughness costs queries, and queries cost points. The enhanced agent takes 5.65 seconds per question --- 80 times longer than the Bayesian agent's 0.07 seconds --- and most of that time is spent on tool selection reasoning that admits an analytical solution.

This is the [prompting trap](/posts/eight-ways-to-prompt/). Not that prompting makes things worse --- it does not. But that prompting improves accuracy along a curve that asymptotically approaches the score ceiling from below, while the Bayesian agent starts above the ceiling because it is optimising a different quantity. No amount of prompt engineering will make a language model compute value of information. The description of a calculation is not the calculation.

## Why Benchmarks Hide This

Standard NLP benchmarks do not include tool costs, abstention options, or scoring functions that penalise wrong answers. They measure accuracy on a test set, typically in a regime where the system must answer every question and the cost of each answer is identical.

This design is not neutral. It encodes the assumption that the job of a question-answering system is to produce correct answers, not to produce *value*. The distinction matters enormously in deployment, where tool queries cost money, wrong answers cost trust, and abstaining on hard questions is often the correct decision.

The Credence benchmark is deliberately constructed to test what deployed systems actually face: heterogeneous query costs, varying tool reliability by domain, and a scoring function that punishes both errors and waste. Under these conditions, the metric that matters is expected score, and expected score is exactly what the Bayesian agent is [designed to maximise](/posts/decision-theory-agents/).

That this produces better outcomes while generating lower accuracy is not a paradox. It is arithmetic.

## What 62.6% Correct Means

When the Bayesian agent submits an answer, it has already decided that the expected score from submitting is positive. It has queried the tools that the VOI calculation identified as worth querying, updated its belief about the correct answer, and concluded that the probability of being right, times +10, minus the probability of being wrong times 5, is greater than zero.

When it achieves 62.6% accuracy on submitted answers, this means its calibration is roughly correct: for a question where submitting has positive expected value, it is right about 63% of the time. The questions where it is less confident --- it abstains on. The LLM agents submit those too. They get some of them right, which raises their accuracy percentage. They also get some of them wrong at a cost of 5 points each, plus whatever they spent querying tools to arrive at the wrong answer.

The accuracy comparison is measuring something real. The Bayesian agent *is* less accurate on the questions it attempts. That is exactly as it should be. It is attempting harder questions more selectively and easier questions more efficiently.

Benchmarking an agent on accuracy, in an environment with costs and penalties, is like evaluating a portfolio manager on the percentage of trades that made a profit, while ignoring the size of the gains and losses. You can maximise that metric by making many small profitable trades while occasionally blowing up on a large loss. The portfolio manager who makes fewer, more carefully selected trades --- each with positive expected value --- looks worse by that metric. In the only metric that matters, they win by a hundred and twenty points.

{{< callout type="note" >}}
This benchmark used text-based LLM parsing rather than native tool-calling, and the LLM agents were prompted variants of a single model. Later benchmark configurations with frontier models and native tool-calling produce different absolute numbers --- but the structural findings hold: VOI-gated abstention, calibration under cost, and the gap between accuracy and score remain the core results of the [Credence architecture](/posts/three-types/).
{{< /callout >}}

This benchmark is the headline experiment of a paper in preparation. The same decision-theoretic core that selects tools for simulated QA also [routes real LLM traffic in production](/posts/ninety-six-percent-cheaper/), with comparable results at a ninety-six percent lower cost. The mechanism travels. The arithmetic is the same arithmetic.
