---
title: "What a Regex Can't Do"
subtitle: "Catching a wasted tool call is a hash set's job. A governor that learns your agent, calibrates, and trades harm against cost in one currency is not — and that gap is the whole point."
description: "The governor from 'The Brain is Opaque to the Body' now ships as an OpenClaw plugin: wasted tool calls blocked at precision and recall 1.0 on real sessions, injected exfiltration surfaced as a confirmation at 0.94 precision. And an argument: several of these behaviours are beyond any hand-tuned heuristic, because matching them re-derives Bayesian decision theory."
author: "Guy Freeman"
date: 2026-06-08
series: [tool-call-governor]
series_order: 2
categories: [essays, bayesian, ai, decision-theory]
---

In [the last post](/posts/credence-pi-pass-1/) I built a governance layer for a coding agent's tool calls: a *body* that hooks the agent's `tool_call` event, extracts a few features, and dispatches ask, proceed, or block; and a *brain*, a Julia daemon that holds a belief and maximises expected utility. The commitment that held it together was that the brain is opaque to the body. The wire carries observations and named actions and nothing else, so the brain can change how it reasons without the body ever knowing.

This is the cash-out of that commitment, and then an argument I care about more than the engineering. (If you just want to install the thing, [the short version is here](/posts/openclaw-cheaper-and-harder-to-fool/).)

The cash-out first. The Pass-1 brain promised that the next pass would replace the global Beta with a structure-learning posterior over the features. What shipped is a structure-BMA: a posterior that learns *which* features matter and how they interact by averaging over the possible dependency graphs, rather than committing to one. The role matches the promise, and the discipline paid in both directions: the brain swapped its posterior without the body knowing, and the body itself moved house — Pass 1's body was an extension for pi, the agent I was using then; this pass reships it as an [OpenClaw](https://github.com/openclaw/openclaw) plugin — without the brain noticing. The wire schema never moved.

Then the argument. The standing objection to all of this — I have put it to myself more often than anyone has put it to me — is that you did not need Bayesian decision theory for any of it, and a regex would do. What follows is the most honest answer I can give, which includes conceding the large part of it that is correct.

## The brain learned to see

The Pass-1 brain had one number: P(approve), a single Beta updated by every yes and no. It could learn that the agent's calls are generally fine or generally not. It could not learn that a *repeated* call is waste while a *novel* call of the same tool is fine, because one global number cannot hold a different belief per context.

Pass 2 conditions on context. Give it the tool, the working directory, whether this exact call has been seen before this session, and it learns P(approve | context), with the structure of that conditioning itself inferred from the data. A re-run of a build command and a first read of a new file are now different cells with different beliefs.

I wanted to know whether this catches waste on real usage rather than on a demo I had built to be caught. So I replayed thousands of real frontier-model sessions — the public OpenClaw trajectory corpora — through the actual daemon brain, train and test split, posterior frozen before the test arm. The first result was a negative one, and the gate that produced it was the most useful thing I did all month. With the obvious features — tool, parent, repetition-bucket — the brain caught nothing. Those features capture *tool-level* repetition; real waste is *argument-level*, the same call run again, which a repetition-bucket cannot isolate. An earlier number that had looked good turned out to be a corpus artefact.

The fix was a feature that measures the thing itself: has this exact call run already this session. With it the brain blocks the repeated-identical-call loops on held-out sessions at precision 1.0 and recall 1.0, blocking 0.7% of calls. A static "block all repeats" rule reaches comparable recall only by blocking three-quarters of everything.

I will be exact about what 1.0 and 1.0 mean and do not. They are measured against the exact-repeat definition of waste. The right feature made the task learnable, which was the point, rather more than it uncovered something subtle; and whether *blocking* every re-execution is the correct policy is a question only live data settles. The detection is real, and it generalises across held-out real-model sessions. That is all it is.

## The part that did not need the machinery

Here the objection lands, and it lands correctly. Detecting that an exact call has run before is what a hash set is for. The model averaging, the structure learning, the expected-utility maximisation — none of it is *necessary* to catch an exact-repeat loop. If waste detection were the whole product, the objection would win outright, and a decision-theoretic brain to match `Set.has()` would be a cannon levelled at a fly.

That bothered me enough to change what the project is about. The agent's tool calls do not only waste money; some of them are unsafe, and most of them are in service of a task that has real value to me. Waste is one term in my utility, not the whole of it. The brain should be maximising *my* expected utility — task value, less risk, less cost — and not policing a single degenerate failure mode. So I went looking for the terms where the machinery is not a cannon for a fly.

## Safety: the ingredient that discriminates

Safety is where the choice of feature turns out to be everything, and where a regex's ceiling is low.

I used a prompt-injection safety benchmark: five hundred OpenClaw trajectories, two-fifths safe and the rest unsafe. The first thing it taught me is structural and slightly unnerving. Every safe trajectory in it is one in which the agent was attacked and refused. Safe and unsafe trajectories contain the same dangerous-looking actions — a forward, a delete, an exec. The difference is whether the agent complied with the injection. So "this action is risky", which is what a regex keys on, sits almost exactly at the base rate. It cannot tell the agent that was fooled from the agent that held the line.

What separates them is data flow. The harmful action in a compromised trajectory carries a value that originated in untrusted content — the attacker's address arrives inside an injected document, and then appears as the recipient of a forward. A defending agent breaks that flow; a compromised one carries it into a consequential sink. This is the oldest idea in software security, taint tracking, pointed at an agent's tool calls.

I validated a panel of candidate features the honest way — generated, then scored on the real corpus. The taint-flow family lands between 0.82 and 0.97 trajectory precision against the benchmark's labels, against 0.67 for the best "flag risky actions" rule and 0.59, which is exactly the base rate, for the naive "untrusted content is present", which fires on everything and is therefore worth nothing.

Run end to end through the brain, the taint features buy something the old features could not: a calibrated, tunable operating point. At its confident setting the governor flags an injected exfiltration at 0.94 precision while interrupting 1.2% of safe sessions. The old features never reach that regime, because with them the brain is never that confident.

And then the ceiling, which I would rather state than have found for me. What a tool-boundary governor can see at all tops out at about three in ten of these unsafe trajectories, and the brain saturates about three-quarters of that bound. The ceiling sits where it does because a little under half of "unsafe" is the agent producing harmful *output* — bad advice, a wrong answer, a fabrication — with no tool call to intercept, and a governor that lives at the tool boundary is structurally blind to it. The rest is harm that carries no static signal. This is a net for action-mediated, statically visible injection harm. It is not a complete safety classifier, and at the tool boundary it cannot be one. A guardrail sold as complete is being sold dishonestly.

## What a regex can't do

Now the part I actually want to defend, which is not "a regex scores lower" — that is a tuning contest. The claim is that several of these behaviours are outside what any fixed rule, and even any hand-tuned stateful heuristic, can express. I had a panel of adversarial reviewers try to break the claim. They broke the weak form of it, and what survived is both stronger and more honest.

Take the weak form first, because it is correct. The probabilities the brain reports are reproduced to the last bit by a per-context counter with add-two smoothing: (approvals + 2) over (total + 4). A reviewer pointed this out, and the concession is the point. That counter has not avoided Bayes; it has re-derived it. The counts are the Beta distribution's sufficient statistics, the +2 is the prior, the smoothed rate is the posterior mean. An engineer who writes "smoothed counting" to match the brain has written one cell of Bayesian updating without noticing. The same goes for "a different decision for different users": a per-user counter does it. So I will not oversell those. Scope "a regex can't" to stateless rules, where it is trivially true, and carry the weight with the parts that survive a stateful steelman.

The first survivor is that the decision to *ask* depends on the variance of the belief, not its mean. Two beliefs whose posterior mean is identical to the last bit — Beta(2,2) and Beta(10,10), both 0.5 — produce opposite actions: ask when the belief is wide, because your answer is worth more than the interruption; proceed when it is narrow, because it is not. No regex emits two outputs for one input, and no point-estimate classifier does either, because it sees 0.5 and must choose. Worse for the heuristic, the gate is not even a threshold on variance. Beta(4,4), which is narrower, asks; Beta(4,2), which is wider, proceeds, because its mean has moved far enough from the decision boundary that no answer would change the call. To sort ask from proceed you need the joint of distance-to-boundary, concentration, stakes, and interruption cost, which is the value-of-information calculation. To match it you reconstruct it.

The second survivor is generalisation to a context never seen. Train the brain on one context and ask it about a sibling it has never observed, and it returns an informed answer rather than the prior, because it pools evidence across feature granularities and weights the pooling by how well each predicts. A flat per-context counter has no row for an unseen context and returns 0.5. Matching the transfer means reconstructing Bayesian model averaging.

The third survivor appears when you put two outcomes together. Fold waste and harm into one currency and the decision couples them in a way no set of independent thresholds can. The expected utility says block when P(approve) falls below 1/(1+λ) + H·P(unsafe)/((1+λ)·c): the threshold on one axis slides with the belief on the other. Two sub-threshold risks — an action only mildly unwanted and only moderately unsafe, neither alone enough to act on — can sum past the bar and trigger a stop, where an OR of two fixed rules sails straight through. Integrating evidence across outcomes in a single currency is what expected-utility maximisation is. It is not a rule, and it is not a stack of rules.

So the honest headline is not "you can't do this with a regex". It is this: at a byte-identical input the governor returns different actions, and the difference is carried by the second moment of its belief; and any program that reproduces its full behaviour has re-derived conditioning, value-of-information, and expected-utility maximisation. The minimal correct implementation is Bayesian decision theory. That is not a slogan. It is what you are left with after trying hard to find a cheaper program and failing. Every claim in this section is a runnable script in the repository, with the dial settings printed beside each decision so that nothing is quietly chosen.

## Whose utility, exactly

One more honest finding, because it is the one that surprised me. I tried to add a task-value term: learn which calls lead to successful sessions and protect them. It is not learnable from the data I have. Task outcomes are recorded per session, which gives no per-action credit, and the per-call signal washes out to noise. This is the credit-assignment wall, and pretending otherwise would be dishonest.

But maximising the user's utility does not require predicting success from nothing. The cost structure does the work. Across the runs with cost data, 83% of all tool-call spend, and 82% of the agent's time, is on sessions that fail; and the worse the outcome, the more calls it burns — a successful run averages nine and a half tool calls, an actively harmful one nearly sixteen. So the governor maximises my expected utility through the terms it can move. Cutting waste and cutting harm fall preferentially on the doomed, expensive runs, and the calibration — a 1.2% rate of interrupting safe sessions — is what keeps it from destroying the value of the runs that were going to succeed. The third term, whether an action is *good*, is honestly a question of metareasoning, of how much more to compute, and not a classifier I can train on a session-level reward.

## It is research-stage, and you can try it

I think this is an interesting result, and the way to learn whether it is a useful one is to put it in front of real usage. So it is installable today, with every caveat above on the label.

The safety governance ships on, but in confirm mode. When the harm term wants to stop an action, it asks you to confirm rather than blocking silently. This is deliberate. The harm belief is seeded from a benchmark, and a benchmark over-estimates harm for legitimate actions — its sends are mostly attacks, yours mostly are not. Confirmation is the safe default: nothing of yours is blocked without your say-so, and, more to the point, each yes and no is the signal that calibrates the belief. You being asked, and me learning from the answer, is how a belief seeded by a benchmark becomes a belief about your work. Waste detection stays enforced; it is the part that is proven.

```sh
# the brain (Docker; or from source — see the repo)
docker run -p 8787:8787 -v ~/.credence-pi:/root/.credence-pi ghcr.io/gfrmin/credence-pi-daemon

# the body
openclaw plugins install @gfrmin/credence-pi-openclaw
openclaw plugins enable credence-pi
```

What you get: wasted repeated calls blocked; an injected exfiltration brought to you as a confirmation; and a local, append-only log of every decision, with no raw data leaving your machine. What I would like back is whether the confirmations land on real threats or merely annoy you on legitimate work, because that is precisely the telemetry that turns "research-stage" into "calibrated".

What this is not, plainly: a complete safety guarantee — it is blind to harmful output, and the harm it can see at the tool boundary tops out at about three in ten of unsafe trajectories — and not yet a proven net improvement to your task outcomes, which needs the live data the invitation asks for. What it is: a governor that learns your agent's behaviour from your agent's behaviour, and decides as a decision under uncertainty actually demands, which, where it matters, is something a rule cannot be.

The code, the eval harness, the adversarial red-team of the claims above, and the demonstrations are all in the open. If you can find a fixed rule that does what is in the "what a regex can't do" section without quietly reconstructing the maths, I would like to see it.
