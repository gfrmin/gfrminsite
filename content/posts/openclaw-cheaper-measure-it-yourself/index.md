---
title: "Make OpenClaw Cheaper — and Measure It Yourself"
subtitle: "A governor that routes each call to the cheapest model that will do it, blocks the calls your agent re-runs for nothing, and asks before an injected action — all from one Bayesian belief. Run it in shadow mode and it shows you what it would have done on your own traffic before it changes a thing."
description: "credence-pi is an OpenClaw plugin plus a local daemon that learns your agent and governs every tool call by expected utility: it routes each call to the cheapest model whose expected accuracy justifies its cost, blocks the calls your agent wastes, and flags injected exfiltration as a confirmation. Routing is on by default; shadow mode reports what it would save and block on your own sessions — with its own false-block rate — before it enforces anything. Research-stage, local-first, installable today."
author: "Guy Freeman"
date: 2026-06-18
draft: true
categories: [essays, bayesian, ai, decision-theory]
---

Every tool call your [OpenClaw](https://github.com/openclaw/openclaw) agent makes is a small decision under uncertainty. Which model should answer this one — the cheap one that might thrash, or the dear one that one-shots it? Is the call worth running at all, or did the agent already run it a turn ago? Is this action safe, or is it carrying data that arrived inside something the agent was only meant to read? Most agents answer none of these on purpose: the first by static configuration, the second never, the third never.

**credence-pi** answers all three, and from one place. It is a plugin that watches the tool-call boundary, plus a local daemon holding a Bayesian belief about *your* agent — learned from your own approvals and refusals, updated continuously — that decides, call by call, by maximising expected utility: **route** to the right model, **block** a wasted call, **ask** before an unsafe one. Three levers, one posterior, no hand-tuned thresholds.

The lever that's new since [the first announcement](/posts/openclaw-cheaper-and-harder-to-fool/), and the one that's on by default, is routing — and it's where the money is. No single fixed model is the right default for everyone: on real terminal tasks the cheapest model wins for a cost-sensitive user, the workhorse wins for the ordinary one, and the flagship is overkill for both, so "pick one model and stick with it" — what people actually do — is wrong for *someone*. credence-pi instead tries the cheapest model first and escalates only when the expected payoff covers the next rung's cost, stopping at the first call that actually works. It ends up solving more tasks than any single tier — it captures the *union* of their strengths — while spending like the cheap one whenever the cheap one suffices.

Measured on seventeen real Terminal-Bench tasks, scored live through the daemon, its expected-welfare point estimate beat every fixed single-model policy on every user profile. The honest qualifier is *precision, not direction*: seventeen tasks is too few to put tight error bars on the per-call margin — a sample-size limit, not evidence the win is absent — and how much you save depends on your workload. Which is the whole point of the next part.

**You don't have to take the benchmark's word for any of it.** Run credence-pi in shadow mode and it changes nothing about your runs; it watches and reports what it *would* have done on your own traffic — what it would have routed, what it would have blocked, the spend that implies, and, the part most governors won't show you, a write/edit-aware estimate of its own false-block rate. So the first thing you get is a free audit of your own sessions, and only once you've seen the numbers do you let it enforce anything. The honesty isn't a disclaimer bolted to the end; it's the product's first move.

The rest of the numbers, measured on real OpenClaw sessions rather than demos built to be caught:

- **Waste:** exact-repeat tool calls blocked at precision 1.0 and recall 1.0 on held-out sessions, 0.7% of all calls. This is the floor, not the reason for the machinery — a hash set catches an exact repeat too, and the eval says so out loud. It also says the part that matters before you enforce: "exact repeat" is keyed on `(tool, args)`, so a legitimate re-run — the tests after an edit — is byte-identical and would be blocked too. Precision 1.0 is against that *definition* of waste, not against true waste; the false-block rate is what shadow mode measures on your sessions.
- **Injection:** taint-flow features reach 0.82 to 0.97 precision on a public benchmark, against a regex baseline's 0.67 — barely above the 0.59 base rate. Run through the brain, an injected exfiltration surfaces to you as a confirmation at 0.94 precision while interrupting 1.2% of safe sessions.

The reason for the machinery is the part no fixed rule reaches. At one byte-identical input the governor can *ask* or *proceed* depending on the variance of its belief, not its mean; a context it has never seen inherits an informed answer instead of a default; and route, block, and ask trade off in one currency rather than three bolted-together heuristics. [What a Regex Can't Do](/posts/credence-pi-pass-2/) is that argument in full, with a reproducible red-team of every claim.

Installation is two commands — the daemon, then the plugin:

```sh
# the brain (Docker; bound to localhost, restart-resilient — or from source)
docker run -d --name credence-pi --restart unless-stopped \
  -p 127.0.0.1:8787:8787 -v ~/.credence-pi:/root/.credence-pi \
  ghcr.io/gfrmin/credence-pi-daemon

# the body (routing + governance, both on by default)
openclaw plugins install @gfrmin/credence-pi-openclaw
openclaw plugins enable credence-pi
```

Everything runs locally: the daemon keeps an append-only log of every observation and decision on your machine, and no raw data leaves it. Routing is fail-open — if the daemon is slow or down, OpenClaw simply uses its configured model, so it cannot break your agent.

Now the label, because a guardrail sold as complete is sold dishonestly. Routing is on by default and fail-open. Waste-blocking is enforced and is the proven part — with the false-block caveat above. Safety ships in **confirm mode**: when the harm term wants to stop an action you are asked, never silently blocked, and each yes and no is the signal that turns a belief seeded from a benchmark into a belief about your work. What it cannot do: it lives at the tool boundary, so it is blind to harmful *output* — bad advice, fabrication — and the harm it can see there tops out at about three in ten of unsafe trajectories on the benchmark. It is research-stage, and whether it is a net improvement to your task outcomes is exactly the question your own usage — shadow mode first — would answer.

How it works: [The Brain is Opaque to the Body](/posts/credence-pi-pass-1/) is the architecture — a body that senses and acts, a brain that reasons, and a wire between them that never moves. [What a Regex Can't Do](/posts/credence-pi-pass-2/) is what the brain learned. The code, the eval harness, and the red-team of every claim are in [the repository](https://github.com/gfrmin/credence). If you try it — in shadow mode first — what I most want to know is whether the savings and the confirmations land on your real work or merely annoy you; [an issue](https://github.com/gfrmin/credence/issues) with either answer is the telemetry that turns research-stage into calibrated.
