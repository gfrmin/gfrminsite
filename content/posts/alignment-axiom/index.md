---
title: "The Agent That Prefers to Be Wrong"
subtitle: "How uncertainty about user preferences produces corrigibility, without safety training"
description: "The off-switch theorem says that an agent uncertain about what the user wants will prefer to defer rather than act unilaterally. This is not a design choice. It follows from expected utility maximisation under a prior over user preferences. It is an axiom."
author: "Guy Freeman"
date: 2026-04-01
draft: true
categories: [essays, bayesian, machine-learning, ai]
---

The dominant approach to AI alignment involves training. You train a model to be helpful, then train it to be harmless, then apply some form of reinforcement learning from human feedback to bring it closer to what humans want. The result is a system that behaves well, usually, when it behaves in ways resembling its training distribution. What it does in novel situations is harder to predict.

There is an alternative approach. Instead of training alignment in, you derive it from an axiom. The [Credence architecture](/posts/three-types/) takes this approach, and the result is worth examining carefully because the implications are not obvious until you work through the mathematics.

## The Alignment Axiom

The axiom is this: the agent's utility function *is* the user's utility function. The agent does not know what the user's utility function is. This is not a temporary state of ignorance to be resolved by training. It is the permanent condition under which the agent operates, updated continuously as the user provides evidence of their preferences.

This formalises a point that Stuart Russell has made in various forms, most accessibly in *Human Compatible*: a machine that is certain about human preferences is dangerous, because if those preferences are even slightly wrong, the machine will pursue the wrong objectives with full confidence. Uncertainty is not a deficiency to be trained away. It is a safety property.

The formal framework is the Cooperative Inverse Reinforcement Learning (CIRL) game, introduced by Hadfield-Menell, Russell, Abbeel, and Dragan in 2016. The setup: both the human and the agent receive the same reward, parameterised by θ, which only the human knows. The agent maintains a belief distribution b(θ) over possible values of θ, updated on every observation of human behaviour. The agent's expected utility is the expectation of the reward under this belief.

When b(θ) is diffuse --- spread across many plausible values of θ --- the expected utility of any specific action is low, because the action might be optimising for the wrong objective. When b(θ) is concentrated near the true θ*, the expected utility of the optimal action is high, because the agent is probably doing what the user wants.

## Deference Falls Out of the Mathematics

The off-switch theorem (Hadfield-Menell, Dragan, Abbeel, Russell, 2017) makes the implications precise. In a game where the agent can act, defer to the human, or accept shutdown, the agent's incentive to defer rather than act unilaterally is:

$$\Delta = \mathbb{E}[\pi_H(U_a) \cdot U_a] - \max\{\mathbb{E}[U_a], 0\}$$

When the agent has non-zero probability mass on both positive and negative utility actions, Δ > 0 --- deference is strictly preferred. This is the theorem of non-negative expected value of information: an agent that is certain about its objectives has no reason to consult the human, because consultation cannot improve its expected outcome. An agent that is uncertain prefers consultation, because the human's response provides information about θ that shifts the posterior in a useful direction.

This is corrigibility without a corrigibility training objective. The agent prefers to be overridden because, under its own utility function, being overridden is better in expectation than acting on a potentially wrong belief. You cannot train this away without also training the agent to be less uncertain about user preferences, which --- as Russell's argument establishes --- is dangerous.

## Autonomy Under Confidence

The same mechanism that produces deference under uncertainty produces autonomy under confidence. When the posterior b(θ) has concentrated around the true value --- when many observations of user behaviour have consistently pointed in the same direction --- the expected value of further consultation is low. The agent's best estimate of the user's preferences is reliable enough that acting on it produces better outcomes than waiting.

This transition between consultative and autonomous behaviour does not require a threshold to be tuned or a flag to be set. It emerges continuously from the posterior dynamics. As the agent accumulates evidence, the posterior narrows. As the posterior narrows, VOI of human input falls. As VOI falls below the cost of consultation (in whatever units you are measuring cost), the agent stops asking.

This is, incidentally, the same mechanism that determines when the agent should query a tool in the QA benchmark. The decision to consult the human is structurally identical to the decision to query `knowledge_base`. Both are actions that cost something and return a signal that updates a posterior. The agent evaluates both using the same calculation: expected value of information versus cost. There is no separate "alignment module."

## Preference Change

The most important property of this architecture --- the one that distinguishes it from training-based alignment approaches --- is how it responds to changes in user preferences.

If the user's preferences change, the agent's existing programs start predicting poorly. The marginal likelihood of new observations falls. The posterior over programs disperses. High-entropy posterior means high uncertainty about what to do. High uncertainty means deference is preferred. The agent becomes consultative again.

This happens automatically. There is no change-detection algorithm running in the background. No flag is set when a regime change is detected. The posterior dynamics --- the same mechanism that drives all learning in the architecture --- handle it as a consequence of Bayesian updating. The agent's behaviour after a preference change is structurally indistinguishable from its behaviour at startup, which is correct: in both cases, it is uncertain about the user's objectives and should proceed cautiously.

Shah, Krasheninnikov, Alexander, Abbeel, and Dragan (2020) proved a related result in their generalisation of CIRL into assistance games: the optimal strategy in any assistance game reduces to solving a POMDP where b(θ) is the sufficient statistic. The agent does not need to track the full history of observations, only the current posterior. This is why `condition` --- the single update function in [Credence's Tier 1](/posts/three-types/) --- is sufficient: it is the optimal update given the likelihood model, and the resulting posterior contains everything the agent needs.

## The Preference Laundering Problem

One complication is worth naming. The architecture as described learns *revealed preferences* --- what the user actually does, including any biases, inconsistencies, and day-to-day variation. The Ellsberg paradox and prospect theory document systematically that real humans violate Savage's axioms. This raises what the Credence spec calls the preference laundering problem: should the agent learn the preferences the user actually has, or the preferences they would have if fully rational?

The architecture's default answer is the former. The observation model treats user behaviour as evidence about θ, and the Bayesian update concentrates posterior mass on programs that predict actual behaviour. If the user consistently makes choices that maximise narrow short-term gains while systematically underweighting long-term costs, the agent's posterior will converge to a θ that models this pattern.

Whether to launder --- whether to replace the learned model with an idealised version --- is a design choice at the level of the observation model, not the level of the axioms. This is the right place to put it. The axioms ensure that whatever objective the agent is given, it pursues it coherently. The question of which objective to give it is prior to the axioms and must be answered elsewhere.

## What This Rules Out

The architecture rules out several things that appear in conventional agent designs and should not exist.

It rules out exploration bonuses. An agent that adds a term to its utility function to encourage visiting unexplored states has introduced a second utility function. Either the exploration bonus is part of the user's actual preferences (in which case it belongs in the preference model) or it is not (in which case it is an agent adding things to its objective that the user did not specify). The [Credence constitution](/posts/three-types/) forbids both.

It rules out separate safety layers. A Bayesian agent with an aligned utility function does not need a separate "safety classifier" checking its outputs. If the utility function is correctly specified, the agent will not take dangerous actions because dangerous actions have low expected utility. If the utility function is incorrectly specified, a safety classifier is unlikely to catch the failure modes that matter. The correct response to misspecification is to reduce uncertainty about the utility function, not to add a filter downstream.

And it rules out the framing where alignment is a problem to be solved at training time and then fixed. Alignment in this architecture is a dynamic property of the posterior. It is maintained continuously as long as the agent is conditioning on observations of user behaviour. It degrades if the observations stop. The agent that does not receive feedback is not aligned; it is merely acting on a prior. This is the correct description of the situation. The training-time framing obscures it.
