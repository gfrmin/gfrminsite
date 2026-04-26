---
title: "Ninety-Six Percent Cheaper and Slightly Better"
subtitle: "A drop-in OpenAI-compatible proxy that decides which model to call by computing expected utility"
description: "Credence-proxy sits between an agent and its LLM providers, learns which model is good for which category, and routes accordingly. On an OpenClaw benchmark it cut cost by 96% and latency by 52% while raising quality by 1.24 points. The mechanism is one equation."
author: "Guy Freeman"
date: 2026-04-14
publishDate: 2026-04-30
categories: [essays, bayesian, machine-learning, ai]
---

The production question about LLM agents, once you have gotten past whether they work at all, is how much they cost. A customer-service agent that answers well but costs eight cents per turn is not a customer-service agent; it is a charity. The conventional answer is to pick a cheaper model and hope it is good enough. The less conventional answer is to treat model selection as a decision problem.

Credence-proxy is the latter approach, shipped as a Docker container. It presents an OpenAI-compatible `/v1/chat/completions` endpoint. You send a request with `"model": "auto"`. It picks a model --- from whatever set you have configured, across whatever providers --- and returns the response. It also updates its beliefs about which model is good for which kind of query, so the next decision is marginally better informed.

On a 50-query [OpenClaw](https://github.com/open-claw) benchmark, compared against an always-Sonnet baseline, it produced:

- **Quality: +1.24** (7.80 vs 6.56, on a 0--10 scale judged by a separate model)
- **Latency: --52%** (7.2s vs 14.9s per request)
- **Cost: --96%** ($0.024 vs $0.001 per request)

These numbers are surprising in the direction they are surprising. The cheaper routing is not slightly worse. It is measurably better.

## How the Decision Works

The proxy maintains a joint belief over (quality, concentration) for every (model, category) pair. Quality is a Beta posterior over a reliability parameter θ in [0,1]. Concentration is a Gamma posterior over the noise of the judge that scores responses post-hoc. Together these give a full distribution over expected quality per model per category, not a point estimate.

When a request arrives, the proxy classifies it into a category (code, reasoning, creative, factual, chat), then for each available model computes:

$$\text{EU}(a) = R \cdot \sum_c w_c \cdot \mathbb{E}[\theta_{a,c}] - \text{cost}(a)$$

where *R* is the reward per quality point (default $1.00), $w_c$ are the category weights from the classifier, and $\theta_{a,c}$ is the Beta posterior over model *a*'s reliability in category *c*. Latency enters indirectly through the search routing domain (which adds a $W \cdot \text{latency}$ penalty) and through the `CREDENCE_LATENCY_WEIGHT` configuration, but the core LLM routing decision is quality versus cost. The proxy picks the model with the highest expected utility and makes the call. After the response, a separate judge model scores the result, and the posterior updates.

There is no epsilon-greedy exploration. There is no decay schedule. There is no thresholded reliability cutoff. Exploration happens because the Beta posterior on an unused model is wide, which inflates the variance of its expected quality, which sometimes makes its EU higher than a well-understood alternative. This is the right amount of exploration, under the agent's own objective, and the amount of exploration falls as beliefs sharpen. The math does the job that in other systems is done by a tuned hyperparameter.

## What the Router Learned

The most interesting fact about the OpenClaw experiment is what the router did not do. It did not learn an intricate mapping between task types and model capabilities. It learned that one cheap model --- gpt-4o-mini --- was sufficient for forty-nine out of fifty queries, including categories that the conventional wisdom would route to a larger model.

The mechanism is straightforward. The OpenClaw agent decomposes problems into narrow, well-scoped sub-queries. Narrow well-scoped sub-queries are precisely what small models handle well. The router, evaluating each query on its own merits rather than applying a global heuristic, discovered that the problem the agent was actually posing was not "solve a hard reasoning task" but "execute a simple step in a decomposition." For that, mini is fine.

The cost savings are therefore not strategic --- no clever abstention, no sophisticated cascading. They are the result of replacing Sonnet with mini on the queries where mini is adequate, and doing so on the basis of measured performance rather than priors about model capability. Price goes down by a factor of thirty-five per request. Quality, measured by a separate judge, goes up by 1.24 points. Latency halves, because smaller models are faster.

## The Knobs That Matter

The proxy exposes two configuration parameters, `CREDENCE_REWARD` and `CREDENCE_LATENCY_WEIGHT`, which together define the agent's utility function. There are suggested presets:

- **Quality-first**: reward 1.0, latency-weight 0.001. Used when you do not care about a few extra seconds.
- **Cost-optimised**: reward 0.5, latency-weight 0.01. The default. Treats quality as worth 50 cents per point, latency as worth 1 cent per second.
- **Latency-critical**: reward 0.5, latency-weight 0.1. For real-time UIs where a two-second delay is a problem.

These are not magic numbers. They are prices. If you believe a quality point is worth a dollar, set reward to 1.0. If a second of latency costs you ten cents of user patience, set latency-weight to 0.1. The proxy then optimises the thing you said you wanted. This is less satisfying than a model selector that promises to just handle it, and more honest.

## Why This Is Not a Heuristic

The natural objection is that a hand-tuned rule --- "use mini for simple queries, Sonnet for hard ones" --- would produce similar results with less infrastructure. This is sometimes true and sometimes not, and the distinction is worth being precise about.

A hand-tuned rule requires you to know in advance which queries are simple. Agent systems produce queries by decomposition; the shape of the decomposition depends on the problem, which you do not know in advance. A rule that worked for one agent architecture will misroute queries from another. A rule that worked on last week's traffic distribution will misroute on this week's.

The proxy does not require you to know anything in advance. It begins with uninformative priors over every (model, category) pair and updates them from observation. When a new model is added, or a new category appears, or the traffic distribution shifts, the posterior updates accordingly. The infrastructure burden of maintaining "use mini for simple, Sonnet for hard" as agent architectures evolve is exactly the burden that Bayesian updating removes.

There is a separate objection, which is that a well-tuned heuristic plus occasional manual review is cheaper to maintain than a probabilistic system that nobody understands. This is sometimes true and sometimes not. The proxy exposes `/state` and `/metrics` endpoints; you can see which model is winning on which category and why. The beliefs are explicit. The utility function is configurable. The decisions are auditable. It is not a black box. It is a calculator.

## What This Is For

The shipped [credence-proxy](https://github.com/gfrmin/credence) is the concrete answer to a question the [accuracy paradox post](/posts/accuracy-paradox/) raised in the abstract: can a Bayesian agent, given the same tools as a language model, deploy them more efficiently? On a 50-question benchmark with four simulated tools, the answer was yes by a factor of twelve. On a 50-query OpenClaw benchmark with real LLM providers, the answer is yes by a factor of thirty-five in cost, two in latency, and slightly more than one in quality.

The proxy is shipped as a Docker image. The evaluation is reproducible. The utility function is configurable. The architecture is the same one the [Three Types post](/posts/three-types/) described, with the decision-theoretic layer deciding which external sensor to query and the LLMs serving as the sensors.

It is, at this point, the most deployable argument for the framework. A research benchmark can be dismissed as benchmark-specific. A production proxy saving ninety-six percent of your inference budget is more difficult to argue with.
