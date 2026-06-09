---
title: "The Brain is Opaque to the Body"
subtitle: "Building a Bayesian governance layer for a coding agent's tool calls, and the discipline that keeps it honest"
description: "A first-pass body-brain architecture for governing a coding agent's tool_call hook with a Bayesian decision-theoretic brain. The wire schema is fixed by what Pass 1 ships; Pass 2 swaps the posterior representation without disturbing it. Plus what credence-lint and a precedent system caught at the eleventh hour."
author: "Guy Freeman"
date: 2026-05-05
categories: [essays, bayesian, ai, decision-theory]
---

There is a coding agent — *pi*, the AI tool I use to write code — and it makes tool calls all day. It runs `bash`, edits files, opens HTTP requests, queries databases. Most of what it wants to do is fine. Some of it isn't. The question I have been circling for months is: who decides which is which, and how, and on what basis?

The current answers are unsatisfying. The agent's own RLHF disposition decides — but I have no visibility into the function it's optimising. A static rules file decides — but a static file cannot improve from observation. A human (me) decides — but a human cannot stay in the loop on every tool call without becoming the bottleneck. None of these are *learning* about the agent's behaviour from the agent's behaviour. None of them treat the question as what it actually is: a sequential decision problem under uncertainty about the agent's intent and its capacity to do harm.

What I built in this past round of work is a first-pass governance layer that does treat it as that. The architectural commitments matter as much as the implementation, so they get the most space below.

## Body and brain

The architecture has a body and a brain.

The **body** is a TypeScript extension that hooks into pi's `tool_call` event. When pi proposes to run a tool, the body extracts a small number of declared features — what tool, working directory relative to the project, parent tool call name, recent repetition count, time since the user spoke last — and posts an event to the brain. When the brain emits a signal back, the body dispatches it: ask the user, allow the call to proceed, refuse it. The body has tentacles, and the tentacles are exactly what pi's hook surface plus the SDK's UI permit. That's it. Three of them.

The **brain** is a Julia daemon that loads five small BDSL files at startup. BDSL is the credence-project's S-expression DSL, designed to do mathematical computation over declared spaces and nothing else. The five files declare: the body's effector manifest (the three tentacles); the brain's sensory vocabulary (the five features); a Beta(2,2) prior over P(approve); a Bernoulli observation kernel; and a decision program. The decision program calls `optimise` over the action-space under preferences over (action, observation-of-approval); the value of asking is computed inline from the textbook EVPI formula, with no magic numbers. At cold-start the posterior is uninformative, EVPI is positive and exceeds the symmetric expected utilities of proceed and block, so *ask* wins by computation. As observations accumulate, the posterior concentrates and proceed or block become live by the same computation. The behaviour falls out of the maths.

The single architectural commitment that holds it all together is the title of this post: *the brain is opaque to the body*. The body has no idea whether the brain is holding a single Beta posterior, or a tree of conditional Betas, or a continuous Gaussian process over an embedding space. The wire carries observations and named actions; nothing else. This is the only commitment that makes future versions architecturally invisible to today's body. The next pass will replace the global Beta with a structure-learning posterior over the features; the wire schema doesn't change, the body doesn't change, the discipline pays its price now and rebates it forever. The symmetry holds in the other direction too: Pass 2 ports the body itself from pi to OpenClaw, and the brain never notices. A stable wire is indifferent to which side of it gets replaced.

It also happens to be the architecture you would draw on a whiteboard if you imagined the body as a sensorimotor periphery and the brain as a cortex. The body senses (extracts features), the body acts (allows or blocks tool calls), the brain reasons. The eye is not the cortex, the muscles are not the cortex, and the wire between them is the optic and motor nerves. Things you would not put across the optic nerve (raw photons, tool call arrays, ISO-8601 timestamps) are not on the wire.

## What Pass 1 ships

The deliverable, in numbers:

- **Brain side:** five BDSL files, two Julia daemon files (a HTTP server with `POST /sensor` and `GET /signals` SSE endpoints, plus an append-only JSONL observation log with replay-on-startup and `fsync`-after-each-append durability), four test files with 54 assertions covering closed-form Bayesian correctness, log round-trip, and end-to-end HTTP/SSE flow.
- **Body side:** a TypeScript extension for pi with five test files, 42 tests covering manifest parsing, feature bucketing, SSE+POST behaviours, per-effector dispatch, and the full hook flow under a mocked agent and daemon.
- **Architectural commitments held:** zero pragma escapes in production code; thirteen pragmas in tests, all asserting closed-form Bayesian correctness against an analytical oracle.
- **Forward compatibility:** the observation log already collects `tool-completed` events that Pass 1's BDSL doesn't read, so the secondary-signal observation model lands without a data backfill in Pass 2. The five features are kebab-case strings whose values are members of declared Finite spaces, so the moment the brain replaces its global Beta with a structure-learning posterior over features, the body needs no change.

That's the substance. The discipline is what made it possible.

## The discipline that kept it honest

A coding agent left to its own devices will write code that works but does not respect a project's invariants. It will reach into a struct's private fields when an accessor is one keystroke further away. It will reimplement an axiom-constrained primitive in the host because the host has the data right there. It will silently replace exact inference with an approximation when a test gets slow. Each individual shortcut is justifiable. Each individual shortcut compounds into architectural damage.

Three things prevented this on credence-pi. None of them is a tool. All of them are written discipline that the agent reads at the start of every session and is held against at the end.

**SPEC.md** is the binding specification for the project, written before any code. It declares the body-brain split as a *commitment*, not a suggestion. It declares that BDSL is for mathematical objects only — anything that requires knowing about the world's physical or computational structure is sensory or motor system, owned by the body. It enumerates the wire schema and forbids inventing new fields. It also declares a **lint pragma policy**: code under `apps/credence-pi/` must land with zero `# credence-lint: allow` pragmas, with two narrow pre-sanctioned exceptions. If the agent is ever tempted to add a pragma, it must stop and report rather than proceed.

**credence-lint** is the project-wide static analysis that enforces these invariants. It is two passes: first a same-line regex over names that come from the DSL's axiom-constrained functions; then a stateful taint analysis that propagates DSL-derived values through assignments, tuple unpackings, and `for`-loop targets, flagging any arithmetic or comparison on the propagated values that isn't routed through the canalised stdlib. It catches real bugs — the sweep at the end of this very pass flagged twelve violations that had survived per-step review, of which more below.

**Per-step cadence** is the rule that the spec carves the work into bite-sized steps with conversation review between each one. Each step ends in a working commit; each step has a stop-and-report contract that names what acceptance looks like; the agent is forbidden from running ahead. This is what keeps the agent's local optimisation pressure from compounding into architectural drift.

These three together are not the same thing as careful prompting. Careful prompting tells the agent what to do *this turn*. The discipline tells the agent what *not* to do across all turns, and gives it a written rule it can read again in the next session. The agent doesn't have to remember anything; the project remembers for it.

## The constitutional moment

The most interesting thing that happened in this round was at step 8, the final step.

Step 8 is supposed to be plumbing: add the new tests to CI, write README files, polish. I had instructed the agent to run the lint sweep manually before adding it to CI — exactly the kind of low-risk verification that gets skipped at the end of a project.

The lint flagged twelve violations.

Six were trivial: `# Role:` headers that should have been on each Julia file at creation time and weren't. Mechanical fix. Worth a memo for next time.

One was sanctioned: an `@assert eu_ask == 0.0` in the test suite, asserting that a particular expected utility is exactly zero because the preference function returns the literal `0.0` for that action. The lint flagged it because it looks like arithmetic on a DSL return value. The pre-sanctioned `precedent:test-oracle` exception covers it. Trivial.

Five were a constitutional question.

The pattern was `@assert p.alpha == 3.0 && p.beta == 2.0` after a Beta-Bernoulli conjugate update. The test is asserting that conditioning a Beta(2,2) on an observation produces a Beta(3,2). It is reaching into the posterior's representation parameters to assert structural equality of the closed-form result. Production code under `apps/credence-pi/` is forbidden from doing this categorically — the lint slug is `expect-through-accessor`, and it exists because in production code reading `.alpha` from a Beta posterior is a single-responsibility violation, betraying assumptions about the parameterisation that only the type system should know.

But this is a test of the reasoner. Tests of the reasoner need an oracle stronger than what production code may use. And asserting `mean(p) ≈ 0.6` would be weaker than asserting `p.alpha == 3.0 && p.beta == 2.0`, because the mean is non-injective on the parameters: Beta(3,2) and Beta(6,4) share a mean. The coarser accessor would lose the very invariant the test exists to assert.

The agent stopped and reported. It correctly identified that `precedent:test-oracle` was the existing carve-out, but framed only for *value equality* on a posterior's expected value — not for *structural equality* on its representation parameters. It proposed three resolutions and recommended one: not a sibling precedent, but a widening of the existing precedent to admit both equality forms, with the same justification ("tests of the reasoner need an oracle stronger than production code") explicitly extended to the structural form.

This was the right call. But it was not the call I would have anticipated. The original SPEC.md exception list was written before step 2 surfaced what conjugate-correctness tests actually need. The widening doesn't loosen the policy; it makes the policy say what it always meant. If a future pass surfaces a third equality form — joint distribution equality on factors, or equality on the structure posterior itself, or whatever — the same framing extends naturally without needing yet another precedent.

The constitutional moment is the one where the rules turn out to need amendment, the agent notices, and the amendment is *narrower* than the path of least resistance. The path of least resistance was to add a pragma and move on. The path actually taken was to ratify a constitutional clarification. The cadence's discipline is what made that path visible.

## The reconstruction

At step 8 the agent inherited a worktree where steps 2 through 7 were uncommitted — the prior session had left them sitting as a single un-staged blob. The natural thing to do would have been to make one giant commit. The cadence-respecting thing was to carve the worktree along step boundaries and reconstruct seven commits.

The reconstruction is at one level a fiction — those commits were never made at the time. At another level it's the most honest record available, because the work *was done* in that sequence, with stop-and-report review between each step. The git history now matches the cadence; it tells the same story the SPEC sequencing tells. A future archaeologist running `git log --reverse` can walk through the same seven moments the project actually moved through.

This was tedious. It was worth it. The discipline of preserving structural seams in git pays the same kind of dividend the discipline of preserving structural seams in code does: it lets the next pass start from a known good shape, not a blob.

## What ships, what waits

What ships: a body-brain governance loop with opaque-brain discipline, three-effector EU-maximisation with an inline EVPI gate, five declared kebab-case features, BDSL-driven action and feature spaces, an append-only observation log with replay durability, SSE+POST wire transport, fail-open semantics under daemon outage, and zero production-side lint pragmas.

What waits: the structure-learning machinery that makes the brain do what it could do but currently doesn't. The Pass-1 brain has a single global Beta over P(approve), no feature conditioning at decision time. Pass 2 will replace it with a structure-learning posterior that conditions on features as evidence accumulates, with the dependency structure itself a thing the brain reasons over and updates. The wire schema doesn't change; the body doesn't change. The whole point of Pass 1 was to make Pass 2 architecturally invisible.

There's a `PASS-2-NOTES.md` file in the project that collects the breadcrumbs surfaced during Pass 1: the unbounded growth of an in-memory correlation table on long sessions, the `tool-completed` JSON round-trip not exercised by the replay test, the test directory layout asymmetry between Julia (co-located with daemon) and TypeScript (one level up from extension), the local-dev `Pkg.instantiate()` hint that ought to be in the daemon README, the precedent-widening framing for any third equality form, the effector signal action-space guard that's correct under extension. None of these is a Pass-1 bug. All of them are things the next person opening this branch will appreciate having found in writing.

This is the discipline that makes a multi-pass project actually multi-pass. The first pass leaves enough behind that the second pass starts from a known good shape, with the open questions named, the constitutional clarifications made, and the wire schema stable. Pass 1 closed; Pass 2 will open on a fresh branch when the time comes. The brain is opaque to the body. The body has tentacles. The maths does the rest.
