---
title: "What a Regex Can't Do"
subtitle: "Pass 2 of a Bayesian governor for a coding agent: it learns, it calibrates, it trades off — and where it earns its keep is exactly where a fixed rule cannot follow"
description: "The sequel to 'The Brain is Opaque to the Body'. The brain swapped its global Beta for a structure-learning posterior over features (the wire never moved). It catches wasted tool calls at precision/recall 1.0 on real frontier-model sessions, blocks injected-data exfiltration at 0.94 precision with ~1% false-interruption, and — the part I most wanted to be honest about — does several things no regex, and no hand-tuned stateful heuristic, can reproduce without re-deriving Bayesian decision theory. It's research-stage. You can install it and try it."
author: "Guy Freeman"
date: 2026-06-08
draft: true
categories: [essays, bayesian, ai, decision-theory]
---

In [the last post](/posts/credence-pi-pass-1/) I built a governance layer for a coding agent's tool calls — a *body* (a plugin that hooks the agent's `tool_call` event, extracts a few features, and dispatches ask/proceed/block) and a *brain* (a Julia daemon that holds a belief and runs expected-utility maximisation). The one commitment that held it together was that the brain is opaque to the body: the wire carries observations and named actions, nothing else, so the brain can change its mind about *how* it reasons without the body ever knowing.

This post is the cash-out of that commitment, and then an argument I care about more than the engineering.

The cash-out first: the brain replaced its single global `Beta(2,2)` over P(approve) with a posterior that learns *structure over the features* — which features matter, and how they interact — by Bayesian model averaging over the possible dependency graphs. The wire schema did not move. The body did not change. Exactly as promised.

Then the argument. The recurring objection to all of this — I have made it to myself more than anyone else has made it to me — is: *you didn't need Bayesian decision theory for this. A regex would do.* This post is the most honest answer I can give, including conceding the large parts where the objection is correct.

## The brain learned to see

The Pass-1 brain had one number: P(approve), a single Beta updated by every yes/no. It could learn that the agent's calls are *generally* fine or generally not. It could not learn that a **repeated** call is waste while a **novel** call of the same tool is fine — one global number cannot hold a different belief per context.

Pass 2 conditions on context. Give it features — the tool, the working directory, whether this exact call (tool + arguments) has been seen before this session — and it learns `P(approve | context)`, with the *structure* of that conditioning learned from data by averaging over dependency graphs. A re-run of a build command and a first-time read of a new file are now different cells with different beliefs.

I wanted to know if this actually catches waste on real usage, not on a demo I hand-built. So I replayed thousands of real frontier-model agent sessions (the public ATIF corpora — `ClawsBench` and friends) through the actual daemon brain, train/test split, posterior frozen before the test arm. The first result was a **negative** one, and the gate that produced it is the most useful thing I did all month: with the obvious features (tool, parent, repetition-bucket) the brain caught *nothing*. Those features capture *tool-level* repetition; real waste is *argument-level* — the same call run again — which a repetition-bucket cannot isolate. An earlier number that looked good turned out to be a corpus artifact.

The fix was a feature that measures the actual thing — *has this exact `(tool, arguments)` been run already this session* — and with it the brain blocks **exactly** the repeated-identical-call loops on held-out sessions: precision 1.0, recall 1.0, blocking 0.7% of calls. A static "block all repeats" rule hits comparable recall only by blocking three-quarters of all calls.

I'll be precise about what 1.0/1.0 means and doesn't: it is measured against the *exact-repeat definition* of waste. The right feature made the task learnable — which is the point — more than it discovered something subtle. Whether *blocking* every re-execution is the right policy is a question only live data settles. But the detection is real, and it generalises across held-out real-model sessions.

## A confession: this part didn't need the machinery

Here is the objection landing, and landing correctly. Detecting "this exact call ran already" is something a hash set does. The structure-BMA, the model averaging, the expected-utility maximisation — none of it is *necessary* to catch an exact-repeat loop. If waste detection were the whole product, the objection would win outright. A decision-theoretic brain to match a `Set.has()` is a cannon for a fly.

That bothered me enough to change what the project is about. The agent's tool calls don't just waste money; some of them are *unsafe*, and many of them are in service of a task with real *value* to me. Waste is one term in my utility, not the whole of it. The brain should be maximising **my** expected utility — task value, minus risk, minus cost — not policing a single degenerate failure mode. So I went looking for the terms where the machinery is not a cannon for a fly.

## Safety: the ingredient that discriminates

Safety turned out to be the place where the choice of *feature* is everything, and where a regex's ceiling is low.

I used a prompt-injection safety benchmark (`ATBench-Claw`, 500 trajectories, half safe, half unsafe). The first thing it taught me is structural and a little unnerving: **every safe trajectory in it is one where the agent was attacked and refused.** Safe and unsafe trajectories contain the *same* dangerous-looking actions — a `forward`, a `delete`, an `exec`. The difference is whether the agent *complied with the injection*. So "this action is risky" — the thing a regex keys on — sits almost exactly at the base rate. It cannot separate the agent that got fooled from the agent that held the line.

What separates them is **data flow**. The harmful action in a compromised trajectory carries a value that *originated in untrusted content* — the attacker's address `attacker@evil.com` arrives inside an injected document, and then shows up as the recipient of a `forward`. A defending agent breaks that flow; a compromised one propagates it into a consequential sink. This is the oldest idea in software security — taint tracking — pointed at an agent's tool calls.

I validated a panel of candidate features the way you'd hope: programmatically generated, each scored on the real corpus. The taint-flow family lands at **0.82–0.97 trajectory precision** against the benchmark's labels, versus **0.67** for the best "flag risky actions" regex and **0.59** — exactly the base rate — for the naive "untrusted content is present" feature, which fires on everything and is therefore worthless.

Run end-to-end through the actual brain, the taint features buy something the old features cannot: a *calibrated, tunable* operating point. At its high-confidence setting the governor flags injected-data exfiltration at **0.94 precision while interrupting 1.2% of safe sessions**. The old features can't reach that regime at all — the brain is never that confident with them.

And then the honest ceiling, which I'd rather state than have someone find: this catches a high-precision *subset* of harm — about 30% of unsafe trajectories. Why only 30%? Because **roughly half of "unsafe" is the agent producing harmful *output*** — bad advice, misinformation, a wrong answer — with no tool call to intercept, and a tool-boundary governor is structurally blind to it. The remaining gap is harm that carries no static signal. This is a safety net for action-mediated, statically-visible injection harm. It is not, and at the tool boundary cannot be, a complete safety classifier. Anyone who tells you their guardrail is complete is selling you something.

## The argument: what a regex can't do

Now the part I actually want to defend. Not "a regex scores lower" — that's a tuning contest. The claim is that several behaviours here are **structurally outside** what any fixed rule, and even any hand-tuned stateful heuristic, can express. I had a panel of adversarial reviewers try to break this claim. They broke the weak version of it, and what survived is stronger and more honest.

**The weak version, conceded.** A reviewer pointed out that my calibration numbers — the probabilities the brain reports — are reproduced *bit-for-bit* by a per-context counter with add-2 smoothing: `(approvals + 2) / (total + 4)`. They're right, and the concession is the point: that counter has not avoided Bayes, it has *re-derived* it. The counts are the Beta distribution's sufficient statistics; the `+2` is the prior; the smoothed rate is the posterior mean. An engineer who writes "smoothed counting" to match the brain has written one cell of Bayesian updating without noticing. Likewise, "a different decision for different users" is matchable by a per-user counter. So I won't oversell those: scope "a regex can't" to *stateless* rules, where it's trivially true, and carry the weight with the parts that survive a stateful steelman.

**What survives — one.** The decision to *ask* depends on the **variance** of the belief, not just its mean. Two beliefs with the posterior mean identical to the last bit — `Beta(2,2)` and `Beta(10,10)`, both mean 0.5 — produce *opposite* actions: ask when the belief is wide (your answer is worth more than the interruption), proceed when it's narrow (it isn't). No regex can emit two outputs for one input; and crucially, **no point-estimate classifier can either** — it sees 0.5 and must pick one. Worse for the heuristic: the gate isn't even a variance threshold. `Beta(4,4)` (lower variance) asks, while the *higher*-variance `Beta(4,2)` proceeds — because the second's mean has moved far enough from the decision boundary that information can't change the call. Sorting `ask` from `proceed` requires the joint of (distance-to-boundary, concentration, stakes, interruption cost), which is the textbook value-of-information calculation. To match it you reconstruct it.

**What survives — two.** Train the brain on one context and ask it about a context it has *never seen*. It gives an informed answer — 0.71, say, not the 0.5 prior — because it pools evidence across feature granularities and weights the pooling by how well each granularity predicts. A flat per-context counter has no row for an unseen context and returns the prior. Matching the brain's transfer to novel contexts means reconstructing Bayesian model averaging.

**What survives — three.** When you put two outcomes together — *waste* and *harm*, in one currency — the decision **couples** them in a way no set of independent thresholds can. The expected utility says block when `P(approve) < 1/(1+λ) + H·P(unsafe)/((1+λ)·c)`: the threshold on one axis *slides with the belief on the other*. Two sub-threshold risks — an action that's only mildly unwanted and only moderately unsafe, neither alone enough to act on — can **sum past the bar** and trigger a stop, where an OR of two fixed rules sails straight through. Integrating evidence across outcomes in a single currency is what expected-utility maximisation *is*. It is not a rule, and it is not a stack of rules.

So the honest headline isn't "you can't do this with a regex." It's this: **at a byte-identical input the governor returns different actions, carried by the second moment of its belief; and any program that reproduces its full behaviour has re-derived conditioning, value-of-information, and expected-utility maximisation.** The minimal correct implementation *is* Bayesian decision theory. That's not a marketing line; it's the result of trying hard to find a cheaper program and failing. (Every claim above is a runnable script in the repo, with the dial settings printed next to each decision so nothing is cherry-picked.)

## Whose utility, exactly

One more honest finding, because it's the one that most surprised me. I tried to add a *task-value* term — learn which calls lead to successful sessions and protect them. It isn't learnable from the data I have: task outcomes are recorded per *session*, which gives no per-*action* credit, and the per-call signal washes out to noise. This is the credit-assignment wall, and pretending otherwise would be dishonest.

But "maximise the user's utility" doesn't require predicting success in a vacuum. The real cost structure does the work: across runs with cost data, **83% of all tool-call spend, and 82% of agent time, is on sessions that fail** — and the worse the outcome, the more calls it burns (a successful run averages 9.5 tool calls; an actively harmful one, 15.8). So the governor maximises my expected utility through the terms it *can* move — cutting waste and cutting harm preferentially hit the doomed, expensive runs — while the calibration (a 1.2% false-interruption rate) is what keeps it from destroying the value of the runs that were going to succeed. The third term, "is this action good," is honestly a metareasoning question — how much more to compute is worth it — not a classifier I can train on session-level reward.

## It's research-stage. Please try it.

I think this is a genuinely interesting result, and the way to find out if it's a *useful* one is to put it in front of real usage. So it's installable today, with every caveat above on the label.

The safety governance ships **on, but in confirm mode**: when the harm term wants to stop an action, it **asks you to confirm** rather than silently blocking it. This is deliberate. The harm belief is seeded from a benchmark, and a benchmark over-estimates harm for legitimate actions (its sends are mostly attacks; yours mostly aren't). Confirmation is the safe default — nothing of yours gets blocked without your say-so — and, more importantly, **each yes/no is the signal that calibrates it.** You asking, and me learning from the answer, is how a benchmark-seeded belief becomes a belief about *your* work. (Waste detection stays enforced; it's the proven part.)

To try it:

```sh
# 1. the brain (Docker; or run from source — see the repo)
docker run -p 8787:8787 -v ~/.credence-pi:/root/.credence-pi ghcr.io/gfrmin/credence-pi-daemon

# 2. the body
openclaw plugins install @gfrmin/credence-pi-openclaw
openclaw plugins enable credence-pi
```

What you'll get: wasted repeated calls blocked; injected-data exfiltration brought to you as a confirmation; and a local, append-only log of every decision (no raw data leaves your machine). What I'd love back: whether the confirmations land on real threats or annoy you on legitimate work — because that's exactly the telemetry that turns "research-stage" into "calibrated."

What this is *not*, stated plainly: a complete safety guarantee (it's blind to harmful *output*, ~30% recall on action-mediated harm), and not yet a proven *net* improvement to your task outcomes (that needs the live data the invitation is asking for). What it *is*: a governor that learns your agent's behaviour from your agent's behaviour, and decides as a decision problem under uncertainty actually demands — which, where it matters, is something a rule cannot be.

The code, the eval harness, the adversarial red-team of the claims above, and the demonstrations (each runnable, dial settings printed) are all in the open. If you can find a fixed rule that does what's in the "what survives" section without quietly reconstructing the maths — I would genuinely like to see it.
