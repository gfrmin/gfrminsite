---
title: "The Tool-Call Governor"
description: "credence-pi: a Bayesian governor that sits between a coding agent and its tools, blocks the calls it wastes, asks before an injected action, and routes each turn to the cheapest model that can handle it. Four posts, from architecture to shipped plugin."
---

A coding agent makes tool calls you did not authorise and re-runs ones it already made. Both are decision problems, and both are cheap to get right if you are willing to hold a posterior over what the agent is doing.

Four posts: the body--brain split and why the brain must stay opaque to the body; what a regex cannot do that a calibrated governor can; and two releases of the resulting OpenClaw plugin --- the second of which asks you to reproduce its numbers yourself rather than take them from me.
