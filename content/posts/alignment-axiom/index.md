---
title: "The Agent That Prefers to Be Wrong"
subtitle: "How uncertainty about user preferences produces corrigibility without any safety training — and why that corrigibility expires at exactly the moment the learning succeeds"
description: "The off-switch theorem says an agent uncertain about what the user wants will prefer to defer rather than act unilaterally. That is not a design choice — it follows from expected utility maximisation under a prior over user preferences. This is also the third of proplang's three named residues, the pointer: whose utility is the agent serving? And it carries a consequence the project records against itself. Corrigibility earned this way vanishes at convergence, because a posterior that has concentrated no longer pays for deference. The theorem is not repealed; it is satisfied, and returns zero."
author: "Guy Freeman"
date: 2026-07-26
series: [proplang]
series_order: 5
categories: [essays, bayesian, machine-learning, ai]
---

The dominant approach to AI alignment involves training. You train a model to be helpful, then train it to be harmless, then apply some form of reinforcement learning from human feedback to bring it closer to what humans want. The result is a system that behaves well, usually, when it behaves in ways resembling its training distribution. What it does in novel situations is harder to predict.

There is an alternative approach. Instead of training alignment in, you derive it from an axiom. The result is worth working through carefully, because the implications are not obvious until you do the mathematics --- and because the last of them undoes the first.

This is also the third of the three residues. [proplang](https://github.com/gfrmin/proplang), the language the rest of these essays are about, names three things its grammar leans on and cannot itself express: the alphabet, the clock, and the pointer. The alphabet has had [its essay](/posts/the-alphabet-is-the-prior/) and the clock [its own](/posts/think-more-or-act-now/). The pointer is this one. It is the question of *whose* utility the agent is serving — which cannot be inferred from behaviour without first being pointed at a principal. proplang's committed answer is utility-as-latent, the construction below, inherited from the decision-theoretic predecessor [Credence](/posts/three-types/). I should say at the outset what the project says: this one is scoped to design, not implemented. The working tests supply utilities from the world rather than inferring them, which is the shallow end of the problem. What follows is an argument about what the axiom entails, and it ends where the project's own note ends — on the consequence that dissolves it.

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

This transition between consultative and autonomous behaviour does not require a threshold to be tuned or a flag to be set. It emerges continuously from the posterior dynamics. As the agent accumulates evidence, the posterior narrows. As the posterior narrows, VOI of human input falls. As VOI falls below the cost of consultation (in whatever units you are measuring cost), the agent stops asking. That is the intended behaviour. It is also, as the closing section has to admit, the exact mechanism by which the safety property expires.

This is, incidentally, the same mechanism that determines when the agent should query a tool in the QA benchmark. The decision to consult the human is structurally identical to the decision to query `knowledge_base`. Both are actions that cost something and return a signal that updates a posterior. The agent evaluates both using the same calculation: expected value of information versus cost. There is no separate "alignment module."

## Preference Change

The most important property of this architecture --- the one that distinguishes it from training-based alignment approaches --- is how it responds to changes in user preferences.

If the user's preferences change, the agent's existing programs start predicting poorly. The marginal likelihood of new observations falls. The posterior over programs disperses. High-entropy posterior means high uncertainty about what to do. High uncertainty means deference is preferred. The agent becomes consultative again.

This happens automatically. There is no change-detection algorithm running in the background. No flag is set when a regime change is detected. The posterior dynamics --- the same mechanism that drives all learning in the architecture --- handle it as a consequence of Bayesian updating. The agent's behaviour after a preference change is structurally indistinguishable from its behaviour at startup, which is correct: in both cases, it is uncertain about the user's objectives and should proceed cautiously.

Shah, Krasheninnikov, Alexander, Abbeel, and Dragan (2020) proved a related result in their generalisation of CIRL into assistance games: the optimal strategy in any assistance game reduces to solving a POMDP where b(θ) is the sufficient statistic. The agent does not need to track the full history of observations, only the current posterior. This is why a single update verb --- `condition` in [Credence's Tier 1](/posts/three-types/), `cond` in its successor --- is sufficient: it is the optimal update given the likelihood model, and the resulting posterior contains everything the agent needs.

## The Preference Laundering Problem

One complication is worth naming. The architecture as described learns *revealed preferences* --- what the user actually does, including any biases, inconsistencies, and day-to-day variation. The Ellsberg paradox and prospect theory document systematically that real humans violate Savage's axioms. This raises what the Credence spec calls the preference laundering problem: should the agent learn the preferences the user actually has, or the preferences they would have if fully rational?

The architecture's default answer is the former. The observation model treats user behaviour as evidence about θ, and the Bayesian update concentrates posterior mass on programs that predict actual behaviour. If the user consistently makes choices that maximise narrow short-term gains while systematically underweighting long-term costs, the agent's posterior will converge to a θ that models this pattern.

Whether to launder --- whether to replace the learned model with an idealised version --- is a design choice at the level of the observation model, not the level of the axioms. This is the right place to put it. The axioms ensure that whatever objective the agent is given, it pursues it coherently. The question of which objective to give it is prior to the axioms and must be answered elsewhere.

## What This Rules Out

The architecture rules out several things that appear in conventional agent designs and should not exist.

It rules out exploration bonuses. An agent that adds a term to its utility function to encourage visiting unexplored states has introduced a second utility function. Either the exploration bonus is part of the user's actual preferences (in which case it belongs in the preference model) or it is not (in which case it is an agent adding things to its objective that the user did not specify). The [Credence constitution](/posts/three-types/) forbids both.

It rules out separate safety layers. A Bayesian agent with an aligned utility function does not need a separate "safety classifier" checking its outputs. If the utility function is correctly specified, the agent will not take dangerous actions because dangerous actions have low expected utility. If the utility function is incorrectly specified, a safety classifier is unlikely to catch the failure modes that matter. The correct response to misspecification is to reduce uncertainty about the utility function, not to add a filter downstream.

And it rules out the framing where alignment is a problem to be solved at training time and then fixed. Alignment in this architecture is a dynamic property of the posterior. It is maintained continuously as long as the agent is conditioning on observations of user behaviour. It degrades if the observations stop. The agent that does not receive feedback is not aligned; it is merely acting on a prior. This is the correct description of the situation. The training-time framing obscures it.
## The Corrigibility That Expires

Now the part I have been deferring, because it is the residue and not a footnote.

Read the deference and autonomy sections back to back and the problem is visible without any further mathematics. Deference is preferred *because* b(θ) is diffuse: Δ > 0 exactly when the agent holds meaningful probability mass on actions turning out badly. Autonomy arrives *because* b(θ) has concentrated: the expected value of consulting has fallen below its cost. Those are the same sentence, read at two points in time. Which means the safety property is not a property of the architecture at all. It is a property of the agent's ignorance --- and ignorance is the one thing a working learner is guaranteed to spend.

proplang records this against itself, in the design document, in the same breath as the design it is recommending: corrigibility earned this way vanishes at convergence, since a posterior over utility that has concentrated no longer pays for deference. Note what is *not* happening there. The off-switch theorem is not repealed at convergence; it is satisfied, and it returns Δ ≈ 0. The agent declines to defer correctly, by its own lights, for precisely the reason the theorem gave it to defer in the first place. The mechanism does not fail. It succeeds, and its success is the failure.

Nor can you patch it with a floor on uncertainty --- a minimum entropy below which the agent must keep asking. That reintroduces the exact thing the approach exists to avoid: a tuned constant, parked where the agent cannot argue with it, asserting that the designer knows better than the posterior. It is the throttle from [the clock essay](/posts/think-more-or-act-now/), wearing a safety hat. And it would be a throttle on the one quantity you least want to lie about.

So the honest position is narrower than the one I set out with, and I would rather state it than let the mathematics imply something stronger. Deference-while-uncertain is a theorem, and a theorem is worth more than a training objective --- not because it is stronger, but because it tells you the conditions under which it holds. This one states them plainly: it holds while the agent is uncertain about what you want. That makes it an argument for keeping the agent in genuine, continuing contact with evidence about your preferences, which is the same conclusion the preference-change section reached from the optimistic side. A world where your preferences keep moving is a world where the posterior keeps dispersing and the agent keeps deferring. Corrigibility, on this construction, survives on the assumption that you are never fully known.

That is a strange thing for a safety property to rest on. It is better said out loud, here, than discovered later by an agent that has finished learning who you are.
