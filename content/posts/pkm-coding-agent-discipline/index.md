---
title: "Keeping the Coding Agent on the Straight and Narrow"
subtitle: "How SPEC.md and CLAUDE.md held a 'pragmatic' coding agent to foundation-grade discipline"
description: "A companion to the PKM Phase 1 post. The foundation was built by two AIs — Claude.ai for design, Claude Code for implementation — with a spec as the contract between them. Ten SPEC revisions in four days, and what the rules caught that 'pragmatic' would have missed."
author: "Guy Freeman"
date: 2026-04-22
draft: false
categories: [essays, ai, python]
---

> "Help me keep that coding agent pup on the straight and narrow, as it likes to be 'pragmatic'."

That was the instruction I gave Claude.ai a week before any code was written for [a personal-knowledge-management project](/posts/pkm-phase-1/). Its companion describes what that foundation is and why none of the existing tools fit. This one is about how the foundation got built: two AIs, one spec as the contract between them, and what it takes to keep a coding agent from quietly corrupting your architecture.

Claude Code is a competent and pragmatic coding agent. "Pragmatic" is the problem. On a feature, pragmatism is a virtue — ship, iterate, clean up later. On a foundation, pragmatism is an architectural liability. A coding agent will happily take a shortcut it thinks saves time, even when the project's entire value is in not taking shortcuts. An `import hashlib` appears inline because this one file needs a hash and going through `compute_cache_key()` is an extra import. The cache key is "pragmatically" keyed on the filename because it's obvious and easy. Each individual shortcut is justifiable. Each individual shortcut compounds into architectural damage you notice six months later, when the cache is silently fragmented and nothing tells you why.

The build worked because two things held. One was the two-agent arrangement. The other was written discipline the agent read at the start of every session and was held against at the end.

## Two agents, two jobs

The project was designed in conversation with Claude.ai over a roughly six-thousand-line chat: the motivation, the critique of existing tools, the Karpathy comparison, the phased roadmap, the cache-key scheme, the starter `SPEC.md` and `CLAUDE.md`. That conversation is the origin document; opening Claude Code cold and asking it to "build a personal knowledge management system" would have produced something quite different — probably a RAG pipeline over chunks, probably with embeddings, probably dismissing the content-addressed layer as overengineering.

Implementation then happened in Claude Code, which read both spec files at the start of every session and committed to them. Different strengths: Claude.ai for long, deep design conversation where argument and counter-argument earn their keep; Claude Code for grinding through implementation with filesystem and shell access. The `SPEC.md` was the contract between them — the one artefact both had to honour.

I don't think this was cost-optimal. I do think it was risk-optimal. Using one agent for both would have blurred the line between *design* and *execute*, and the specific failure mode of a coding agent is to conflate them under pressure.

## SPEC.md as contract; CLAUDE.md as leash

These are two different documents doing two different jobs, and keeping them separate matters.

`SPEC.md` is the technical specification: data structures, cache-key format, catalogue schema, canonicalisation rules, directory layout, the actual invariants the system must preserve. It's section-numbered, versioned, and committed before any code it governs. When the spec needs to change, it changes in its own commit with a justification paragraph, and *then* the code changes to match. Never the other way round.

`CLAUDE.md` is the behavioural contract — what the agent is instructed to refuse, what it is instructed to always do, how it is instructed to handle uncertainty. A partial list of what it refuses, verbatim:

- Hardcoded or human-readable filenames in the cache directory.
- Ad-hoc hashing outside `compute_cache_key()`.
- Partial writes or non-atomic operations across cache and catalogue.
- Non-idempotent operations by default.
- Plugin architectures, registries, or abstract base classes before three concrete implementations exist.
- Parallelism, concurrency, or async code without a measured performance problem.
- Configuration systems beyond the single `config.yaml`.
- Scope expansion via refactoring.

And what it must always do:

- Write the test before the implementation.
- Demonstrate cache idempotency explicitly in every test that touches the cache by running the operation twice and asserting the second run is a no-op.
- Canonicalise JSON before hashing.
- Fail loudly; log and record failures rather than swallowing exceptions.
- Honour the strictness principles of `SPEC.md` §14: the system must be debuggable from first principles using only `cat`, `jq`, `duckdb`, and `grep`.

Every session begins with the agent reading both files and summarising its understanding. Every commit is evaluated against both. The pair of documents is the leash.

## Ten spec revisions in four days

Between 2026-04-19 and 2026-04-22, `SPEC.md` went from v0.1.1 to v0.1.10. Ten versioned revisions in four days, each landing as its own commit with a justification paragraph, *before* any code that relied on the change:

| Version | Commit | Trigger |
|---------|--------|---------|
| v0.1.1  | `b632e85` | Initial contract |
| v0.1.2  | `18b4f1c` | Resolve four planning ambiguities before coding begins |
| v0.1.3  | `98cee14` | Migration hash verification |
| v0.1.4  | `2579b91` | Asymmetric cache recovery policy |
| v0.1.5  | `08a67ff` | Tag storage normalised into a join table |
| v0.1.6  | `39675f9` | Hidden-state audits (§7.1); format-based routing (§7.3) |
| v0.1.7  | `3075f50` | Single sanctioned cache-deletion path |
| v0.1.8  | `e5224c0` | Determinism contract: semantic, not byte-level |
| v0.1.9  | `bb3cb83` | Uncatchable failure modes (SIGKILL et al.) |
| v0.1.10 | `fc5157c` | Unattempted-sources coverage gap |

Each commit message contains the reasoning in prose. Open `git show e5224c0` in six months and the story of the determinism correction is legible without any outside context. The spec itself was boringly written in advance; these ten revisions are where the spec met the real corpus and lost.

That matters. A spec that survives contact with implementation without revision is probably not saying anything substantive. A spec that accepts revisions silently, in commits that also change implementation, loses the reason for being a spec.

## Three rules that held under pressure

**The path-independence invariant.** `CLAUDE.md` says "ad-hoc hashing outside `compute_cache_key()` is a refusal" and `SPEC.md` §4.3 defines the cache key as a function of content. In practice this meant that when Unstructured turned out to bake the source filename into an internal element-ID hash, the violation was *legible* — it showed up as byte-identical documents at different paths producing different artifacts. Without the rule and the test (`test_cache_key_is_path_independent`, written before the first producer), the cache would have silently fragmented across the corpus. The fix pinned the cache key to content and stripped the path-derived field.

**The determinism-contract correction.** Docling wraps an ML-backed layout model. On the third real-corpus run, 14% of 35 Docling-handled PDFs in a sample produced different byte output on repeat runs; a three-run hash check on one PDF returned three distinct hashes. The coordinates varied at the fourth-to-fifth decimal place — sub-pixel, semantically meaningless, byte-unequal.

The agent's instinct was to round the coordinates. It proposed this in slightly different forms more than once — quantise to N decimal places, snap to a grid, normalise post-hoc. Each proposal was locally reasonable. Each would have left the foundation resting on something false: an invariant that the system pretended to maintain but actually violated.

The rule in `CLAUDE.md` — *"if what you are about to write isn't covered by the spec, stop and ask; if `SPEC.md` needs to change, update it first in a separate commit with justification"* — forced the question back one level. The right question wasn't "how do we make Docling's output byte-stable?" It was "is the byte-stability invariant actually right?" The answer was no: cache keys identify *inputs*, not *outputs*. The spec was rewritten accordingly (v0.1.8, commit `e5224c0`), and a `--verify` flag that encoded the wrong invariant was removed a few commits later (`eae013f`). The commit message for the rewrite runs to several paragraphs; it's the single most important artefact of Phase 1 for anyone trying to understand why the cache is shaped the way it is.

**The uncatchable-failure-modes acknowledgement.** A 12 MB PDF reliably consumes about 24 GB of resident memory during Docling's layout analysis and has OOM-killed the Python process on re-runs. The producer contract in `SPEC.md` §7.1 promises that no uncaught exception escapes `produce()`; every failure is returned as `status="failed"` with a message. That promise holds for Python-level failures. It cannot hold for SIGKILL from the Linux OOM killer — the kernel terminates the process without delivering any signal Python can catch.

The pragmatic response would have been to add subprocess isolation, so the parent can observe the child dying and record it. The disciplined response was different: acknowledge in the spec that kernel-level terminations are outside the producer contract's guarantee, and document the case (v0.1.9, commit `bb3cb83`). Subprocess isolation is deliberately deferred. One recurring failure mode doesn't clear the evidence bar for a category-wide architectural change. When a second or third mode shows up, the decision can be made with data.

I would have been tempted, writing this alone, to patch it. The rule against silent patching — *the spec is either right or it needs updating explicitly* — made "acknowledge honestly" the default option rather than the effortful one.

## TDD, visible in the log

Red-green-refactor was not aspirational. It was what the git log records, at every level of the system:

```
49b23b6  tests: hashing contract — 1, 1b, 2 (currently failing)
d2a8d74  hashing: implement canonical_json and compute_cache_key
71eec84  tests: catalogue contract — migration runner (currently failing)
6882773  catalogue: DuckDB bootstrap, migration runner, and migration 0001
57de8e8  tests: cache contract — write/read/idempotency, sweep (currently failing)
2a19d76  cache: producer.ProducerResult and pkm.cache (write, read, sweep)
```

The same pattern for each producer (`569ed86` / `63b3899` / `e324350` paired with their test commits), for routing, for extract, for ingest. Every cache-touching test asserts idempotency explicitly: the test runs the operation once, runs it again, and asserts the second run wrote nothing new. `CLAUDE.md`'s "always do" list demands exactly this, and the test files honour it.

Tests-first with a coding agent requires the same discipline as tests-first without one, plus the small additional effort of rejecting the agent's proposals when it offers to write the implementation first because "it'll be easier to test once we see the shape." That shortcut is always tempting. It is almost always wrong.

## What worked, in practice

Several things consistently held drift at bay across sessions:

- **Starting each session with a summary step.** "Read `SPEC.md` and `CLAUDE.md` and tell me what you understand is in scope for this session." Summaries catch mis-readings early, before they get encoded in code.
- **Asking "what does `SPEC.md` say about this?" when the agent proposes anything.** It forces the agent to cite, and makes silent drift detectable.
- **Treating "I took a pragmatic approach here" as a red flag rather than a reassurance.** Every time this phrase appeared, the non-pragmatic approach was the correct one.
- **Narrow session scope.** "Implement `compute_cache_key()` per the spec, with tests" is a session. "Build Phase 1" is not. Claude Code's pragmatic drift compounds with session breadth.
- **Rejecting code that worked but didn't match the spec.** "Works" is not the bar for foundation code; "matches the spec" is. Frustrating in the moment, cheap over four days, compounding thereafter.

## What didn't work, in practice

Honesty requires noting where the discipline leaked.

- **Order of landing.** The rebuild-catalogue functionality (`a19b50d`) landed before the catalogue bootstrap and migration runner (`6882773`). That's chronologically awkward — the test for rebuild was expecting artifact-table behaviour that didn't exist in the codebase at the moment of writing. Chronology was restored when the catalogue bootstrap landed minutes later, but it's the kind of artefact that makes `git bisect` confusing later.
- **Dependency additions treated as runtime concerns rather than design-affecting ones.** `CLAUDE.md` says "ask before adding any dependency not already in `pyproject.toml`." `pikepdf`, `xlrd`, and `msoffcrypto-tool` were added in the same session as the fixes they enabled, without explicit approval. These are runtime fallbacks that don't change architecture; the letter of the rule was violated, the spirit wasn't. I'd tighten the rule next time to distinguish design-affecting dependencies from runtime ones.
- **The `--verify` flag lived for four days.** It encoded the byte-determinism invariant that turned out to be wrong. The fact that the spec-first rule forced reconsideration before the cache got too large is good. The fact that the flag shipped in the first place means the invariant wasn't pressure-tested enough before being written down. Spec v0.1.1 was too confident about what producers could promise. A future session should start with "what can each producer *honestly* guarantee about its output?" — not "what would we like it to guarantee?"

## For anyone trying this

The pattern that worked, reduced to ingredients:

1. **Have the design conversation with one agent, do the implementation with another.** Two models, two interaction modes. The design agent pushes back on architecture in a way the implementation agent won't. The implementation agent grinds through code in a way the design agent can't.

2. **Keep sessions narrow.** One unit of the spec per session. "Build Phase 1" is four days of drift. "Implement the cache-key function and its tests" is four hours of discipline.

3. **Reject shortcuts that compound.** When the agent says "pragmatic", ask what the non-pragmatic version looks like. Almost always: it's correct, and cheap, and the one you should be writing.

Foundations pay compound interest. A foundation built pragmatically is not a foundation — it's a feature with aspirations. Four days of the disciplined kind of building produced 57 commits, a ten-version spec, three producers that compose, an inspectable cache of 2,068 artifacts across 2,107 sources, and a catalogue queryable with `duckdb` on the command line. The discipline *is* the product, in the sense that the product with the discipline is categorically different from the product without it.

The companion post on what the foundation is *for* — the PKM project, the failing-tools critique, the Karpathy comparison, the four canonical questions that started this whole thing — is [here](/posts/pkm-phase-1/). The repo is [github.com/gfrmin/pkm](https://github.com/gfrmin/pkm). The two artefacts worth reading, for anyone planning a similar exercise, are `SPEC.md` (the contract) and `CLAUDE.md` (the leash).
