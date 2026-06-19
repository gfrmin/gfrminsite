---
title: "Make Your OpenClaw Cheaper and Harder to Fool"
subtitle: "A governor that learns your agent, blocks the tool calls it wastes, and asks you first about the ones that smell of injection. Two commands to install."
description: "credence-pi is an OpenClaw plugin plus a local daemon that learns your agent's behaviour and governs its tool calls by expected utility: it blocks the calls your agent wastes, flags injected exfiltration as a confirmation at 0.94 precision on a public benchmark, and makes ask-or-proceed decisions a fixed rule provably can't reproduce. Research-stage, local-first, installable today."
author: "Guy Freeman"
date: 2026-06-09
categories: [essays, bayesian, ai, decision-theory]
---

*Update (June 2026): a lot has shipped since this post. Routing each call to the cheapest capable model is now on by default, and shadow mode will audit the savings on your own traffic before it changes anything. The current announcement is [Make Your OpenClaw Agent Cheaper, and Measure It Yourself](/posts/openclaw-cheaper-measure-it-yourself/); this one stays as a point-in-time record.*

[OpenClaw](https://github.com/openclaw/openclaw) makes tool calls all day, and two kinds of them deserve more scrutiny than they get. The first merely costs money: the agent runs a call it has already run — same tool, same arguments, same session — because nothing in its loop is keeping score. The second is worse: a prompt injection in something the agent read persuades it to carry untrusted data into a consequential action, and an address that arrived inside a document it was summarising turns up as the recipient of a forward.

I built a governor for OpenClaw that addresses both. **credence-pi** is a plugin that watches the `tool_call` hook, plus a local daemon that holds a Bayesian belief about *your* agent's behaviour — learned from your approvals and refusals, updated continuously — and decides, call by call, between ask, proceed, and block by maximising expected utility.

The numbers, measured on real OpenClaw sessions rather than demos built to be caught:

- **Waste:** exact-repeat tool calls blocked at precision 1.0 and recall 1.0 on held-out sessions, 0.7% of all calls. The obvious thing first: this is the floor, not the reason for the machinery. A hash set catches an exact repeat too, and the eval concedes it out loud — including the part that matters before you switch enforcement on: "exact repeat" is keyed on `(tool, args)`, so a legitimate re-run, the tests after an edit, is byte-identical and would be blocked too. Precision 1.0 is against that *definition* of waste, not against true waste; how often a block is a false one is unmeasured, and it is exactly what shadow mode measures on your own sessions.
- **Injection:** taint-flow features reach 0.82 to 0.97 precision on a public benchmark against a regex baseline's 0.67, which is barely above the 0.59 base rate. Run through the brain, an injected exfiltration surfaces to you as a confirmation at 0.94 precision while interrupting 1.2% of safe sessions.

The reason for the machinery is the part no fixed rule can reach. At one byte-identical input the governor can *ask* or *proceed* depending on the variance of its belief, not its mean, and a context it has never seen inherits an informed answer instead of a default. [What a Regex Can't Do](/posts/credence-pi-pass-2/) is that argument in full, with a reproducible red-team of every claim.

Installation is two commands — the daemon, then the plugin:

```sh
# the brain (Docker; or from source — see the repo)
docker run -p 8787:8787 -v ~/.credence-pi:/root/.credence-pi ghcr.io/gfrmin/credence-pi-daemon

# the body
openclaw plugins install @gfrmin/credence-pi-openclaw
openclaw plugins enable credence-pi
```

Everything runs locally. The daemon keeps an append-only log of every observation and decision on your machine, and no raw data leaves it.

Now the label, because a guardrail sold as complete is being sold dishonestly. Waste-blocking is enforced; it is the part that is proven. Safety ships in **confirm mode**: when the harm term wants to stop an action, you are asked rather than anything being blocked silently — and each yes and no is precisely the signal that turns a belief seeded from a benchmark into a belief about your work. What it cannot do: it lives at the tool boundary, so it is structurally blind to harmful *output* — bad advice, fabrication — and the harm it can see there tops out at about three in ten of unsafe trajectories on the benchmark. It is research-stage, and whether it is a net improvement to your task outcomes is exactly the question your usage would answer.

If you want to know how it works: [The Brain is Opaque to the Body](/posts/credence-pi-pass-1/) covers the architecture — a body that senses and acts, a brain that reasons, and a wire between them that never moves — and the discipline that kept a coding agent from quietly wrecking it. [What a Regex Can't Do](/posts/credence-pi-pass-2/) covers what the brain learned, and why matching its behaviour with rules ends in re-deriving Bayesian decision theory.

The code, the eval harness, and the red-team of the claims are in [the repository](https://github.com/gfrmin/credence). If you try it, what I most want to know is whether the confirmations land on real threats or merely annoy you on legitimate work — [an issue](https://github.com/gfrmin/credence/issues) with either answer is the telemetry that turns research-stage into calibrated.
