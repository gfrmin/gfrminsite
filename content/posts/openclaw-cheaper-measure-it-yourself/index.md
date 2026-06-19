---
title: "Make Your OpenClaw Agent Cheaper, and Measure It Yourself"
subtitle: "One Bayesian governor for OpenClaw that does two things from a single belief: it routes each turn to the cheapest model that can handle it, and it watches every tool call to block the ones your agent re-runs for nothing and ask before an injected action fires. Run it in shadow mode and it shows you the savings on your own traffic before it changes a thing. Early research, two commands, all local."
description: "credence-pi is an OpenClaw plugin plus a local daemon that learns your agent and acts at two points by expected utility: it routes each turn to the cheapest model whose expected accuracy justifies its cost, and it governs each tool call your agent proposes, blocking the wasted ones and flagging injected exfiltration as a confirmation. Routing is on by default; shadow mode reports what it would save and block on your own sessions, with its own false-block rate, before it enforces anything. Early-stage research that wants the community's help; local-first, installable today."
author: "Guy Freeman"
date: 2026-06-19
draft: false
categories: [essays, bayesian, ai, decision-theory]
---

Your [OpenClaw](https://github.com/openclaw/openclaw) agent makes a small decision on every tool call, and right now it makes most of them badly. It sends each call to whichever model you hard-coded, whether the task needed the dear one or the cheap one. It re-runs calls it already ran a turn ago, and pays for them again. And when a prompt injection rides in on a document it was only meant to read, nothing stands between that and a real action. Most agents handle the first by static configuration, the second never, the third never.

**credence-pi** handles all three, automatically, from one belief. It is an OpenClaw plugin plus a small local daemon that holds one Bayesian belief about *your* agent, learned from your own approvals and refusals and updated as you work. It plugs into two points in the loop: when OpenClaw is choosing which model to call, and when your agent is about to make a tool call. At both, it maximises expected utility and does three things you are currently paying for by hand:

- **Routes to the cheapest model that will do the job.** It tries the cheap model first and escalates only when the expected payoff covers the next model's cost, stopping at the first call that actually works. It ends up solving more tasks than any single model while spending like the cheap one whenever the cheap one is enough. This is on by default, and it is where the money is.
- **Blocks the calls your agent wastes.** Same tool, same arguments, same session: gone, before you pay for them a second time.
- **Asks before an injected action fires.** An exfiltration that arrived inside untrusted data surfaces to you as a confirmation instead of simply happening.

Three levers, one posterior, nothing to tune: the first chooses the model, the other two govern the tool call. No thresholds, no rules table, no magic numbers.

You do not have to trust any of this on faith, and you should not. Run credence-pi in **shadow mode** and it changes nothing about your runs. It watches, and it reports what it *would* have done on your own traffic: what it would have routed, what it would have blocked, the dollars that implies, and the part most governors will not show you, its own false-block rate. The first thing you get is a free audit of your own sessions. You switch on enforcement only once the numbers have convinced you.

## Try it now

You need OpenClaw and Docker. Then it is three steps.

**Start the brain.** A local daemon on `127.0.0.1:8787`, restart-resilient:

```sh
docker run -d --name credence-pi --restart unless-stopped \
  -p 127.0.0.1:8787:8787 -v ~/.credence-pi:/root/.credence-pi \
  ghcr.io/gfrmin/credence-pi-daemon
```

**Install the body, then restart OpenClaw.** Governance and routing are both on by default:

```sh
openclaw plugins install @gfrmin/credence-pi-openclaw
openclaw plugins enable credence-pi
# restart the OpenClaw gateway so it loads the plugin, then confirm:
openclaw plugins list   # credence-pi should read "loaded"
```

That is the whole install, and both artifacts are published and public, so it works as written today.

**Audit before you enforce.** This step is optional, but it is the one I would actually do first. Set `shadowMode: true` in the plugin config so credence-pi observes without changing anything, use your agent normally for a while, then read back what it would have done:

```sh
curl http://127.0.0.1:8787/report
```

Everything runs locally: the daemon keeps an append-only log of every observation and decision on your machine, and no raw data leaves it. Routing is fail-open, so if the daemon is slow or down OpenClaw simply uses its configured model and your agent keeps working. The full install notes, a from-source path for the daemon if you would rather not run Docker, and every config key are in [the plugin README](https://github.com/gfrmin/credence/tree/master/apps/credence-pi/openclaw-plugin).

## What it actually does, measured

On real OpenClaw sessions and a live benchmark run, not on demos built to be caught:

- **Routing.** Across seventeen real Terminal-Bench tasks scored live through the daemon, trying-cheap-then-escalating beat every fixed single-model choice for every kind of user: the cost-sensitive one, the balanced one, and the quality-obsessed one. That is the whole point. No single model is the right default for everyone, so picking one and sticking with it, which is what almost everyone does, is wrong for *someone*. The escalation policy captures the union of the models' strengths, and one of those strengths is not where you would guess: on this benchmark the mid-tier model beats the flagship at reasoning, so on a quality-first profile the router sometimes routes reasoning to the *cheaper* model. No fixed rule expresses that.
- **Waste.** Exact-repeat tool calls blocked at precision 1.0 and recall 1.0 on held-out sessions, about 0.7% of all calls.
- **Injection.** Taint-flow features reach 0.82 to 0.97 precision on a public benchmark, against a regex baseline's 0.67 that barely clears the 0.59 base rate. Run through the brain, an injected exfiltration surfaces to you as a confirmation at 0.94 precision while interrupting 1.2% of safe sessions.

The reason for the machinery, the part no fixed rule reaches: at one byte-identical input the governor can *ask* or *proceed* depending on the variance of its belief, not its mean, and a context it has never seen inherits an informed answer instead of a default. [What a Regex Can't Do](/posts/credence-pi-pass-2/) is that argument in full, with a reproducible red-team of every claim.

## What it is, and what it is not

credence-pi is early-stage research, not a finished product, and I would rather make it correct than pretend it already is. I am actively looking for help to improve it. The honest fine print belongs in one place rather than smeared across every sentence:

- The routing result is a **point estimate** on seventeen tasks. The direction is consistent and the win is real, but seventeen tasks is too few to put tight error bars on exactly how much you will save. Your own workload sets that number, which is exactly what shadow mode is for.
- "Waste" is keyed on identical `(tool, args)`, so a legitimate re-run, like your test suite after an edit, looks identical and would be blocked too. Precision 1.0 is against that *definition* of waste, not against true waste. The real false-block rate is the thing shadow mode measures on you before you enforce anything.
- Safety lives at the tool boundary, so it is blind to harmful *output* like bad advice or fabrication, and the harm it can see there tops out at about three in ten of the unsafe trajectories on the benchmark. It ships in **confirm mode**: when the harm term wants to stop an action you are asked, never silently blocked, and each yes and no is the signal that turns a belief seeded from a benchmark into a belief about your work.

None of this is bolted on at the end. Shadow mode exists precisely so the fine print is something you measure rather than something you take on trust.

## How it works

[The Brain is Opaque to the Body](/posts/credence-pi-pass-1/) is the architecture: a body that senses and acts, a brain that reasons, and a wire between them that never moves. [What a Regex Can't Do](/posts/credence-pi-pass-2/) is what the brain learned, and why matching its behaviour with rules ends in re-deriving Bayesian decision theory. The code, the eval harness, and the red-team of every claim are in [the repository](https://github.com/gfrmin/credence).

This is research, and it gets better with use I do not have. If you try it, in shadow mode first, the thing I most want to know is whether the savings and the confirmations land on your real work or merely annoy you: where it over-blocks, where the routing misjudges your models, where the belief is simply wrong. An [issue](https://github.com/gfrmin/credence/issues), a measurement from your own traffic, or a [pull request](https://github.com/gfrmin/credence) is exactly the help that turns research-stage into something calibrated. I would like the community to build this with me.
