---
title: "A Content-Addressed Foundation for Personal Knowledge"
subtitle: "Phase 1 of a personal-knowledge-management project: why the existing tools don't fit, and what a pipeline over your own documents can look like when it's built properly"
description: "Eleven million words of personal documents, four canonical questions none of Khoj, Paperless-ngx, Obsidian, or Karpathy's LLM Wiki can answer, and a content-addressed extraction foundation that takes content-addressing seriously. Phase 1 of a multi-phase build."
author: "Guy Freeman"
date: 2026-04-22
draft: false
categories: [essays, data, ai, python]
---

I have about eleven million words of personal documents. Contracts, invoices, court filings, medical notes, research papers, travel itineraries, conversation transcripts, CVs of various vintages, takeaway menus from restaurants that have since closed. A decade of Syncthing directories and Dropbox archives and email attachments saved twice because I wasn't sure which copy was authoritative.

I would like to ask questions about this corpus. Not vague questions — specific ones:

- *When did I last see my doctor?*
- *What did Velotix pay me in September 2024?*
- *Which of my subscriptions auto-renew in the next sixty days?*
- *What's the warranty status on the water heater?*

Each of these fails on a different existing tool, for a different reason.

## Why the existing tools don't fit

**Khoj and the RAG-over-documents family** index files and do semantic search over them. The pipeline is fixed: parse, chunk, embed, store, query. That's the wrong shape for *"what did Velotix pay me in September 2024"* — which is a fact lookup in a specific document, not a similarity match across the corpus. Once you've committed to chunking and embedding as your only extractions, you can't later ask the system to materialise a new extraction layer (say, "extract all monetary amounts from invoices") without reingesting the whole corpus. The architecture doesn't have a seam for it.

**Paperless-ngx** manages documents beautifully — OCR, tags, full-text search, a pleasant web UI, the lot. It solves the "where is that document" problem decisively. It does not reason about the content. *"Which subscriptions auto-renew in the next sixty days?"* is a structured-extraction question about a specific document class; Paperless will help you find the invoices, but not answer the question.

**Obsidian, Logseq, SiYuan** are authoring tools. They index what you write, not what you receive. *"What's the warranty status on the water heater?"* is a question about a receipt and a warranty PDF you were sent, not a note you took. Asking an authoring tool to be a retrieval system for documents you've accumulated is asking it to be something it isn't.

**Karpathy's LLM Wiki**, which went viral in April 2026, is the closest thing to a coherent vision in the space.

## What Karpathy's wiki does, and what it doesn't

The pattern is: raw sources go into `raw/`, an LLM "compiles" them into structured, interlinked wiki articles in `wiki/`, and an index file lets the LLM navigate at query time without loading everything into context. For research — Karpathy's own wiki on a single topic grew to roughly 100 articles and 400,000 words — it works well. The key claim is that RAG's problem (chunking losing context) disappears when the articles are already human-readable summaries written by an LLM that read the full context.

It does one thing beautifully. But it does one thing. Five differences between Karpathy's wiki and what I want:

1. **Fixed compilation vs. pluggable transforms.** The wiki pattern has one transform: "compile to wiki article." Every raw document contributes to the same flat `wiki/concepts/` namespace. What I want is a system where the same `contract.pdf` can be extracted by Pandoc, by Docling (with layout and tables), by Unstructured (for email and odd formats), *and* by future transforms — date extraction, entity extraction, subscription detection — that don't exist yet. Karpathy's architecture has one seam; I need many.

2. **No dependency tracking vs. content-addressed cascading invalidation.** When a raw source changes in the wiki, you recompile manually. The architecture I want keys every artifact on `(input_hash, producer_name, producer_version, producer_config_hash)`. Bump Docling's version, and every downstream transform that used its extraction misses the cache automatically. No explicit "invalidate everything downstream" logic is needed — hash-based keys do it.

3. **Thematic coherence vs. heterogeneous corpus.** The wiki pattern works when your raw folder is "papers on attention mechanisms" — *attention* means one thing, gets one article, accumulates refinements. It breaks when your raw folder is "everything about my life", because *contract* means one thing in a legal document, something else in a work document, and nothing in a takeaway menu. The LLM over-merges (collapsing distinct concepts into mush) or over-splits (`concepts/contract-legal`, `concepts/contract-employment`, `concepts/contract-service`, at which point the index is a mess). My corpus is 2,107 documents spanning PDFs, Word files, emails, spreadsheets, HTML archives, LaTeX manuscripts, Org-mode notes, old-format `.doc` files. No thematic coherence to be had.

4. **Reference work vs. multi-view.** Karpathy's output is an encyclopaedia: *"tell me what I know about X."* Of the four questions I opened this post with, not one is encyclopaedia-shaped. *"When did I last see my doctor?"* wants a timeline. *"What did Velotix pay me in September 2024?"* wants a specific invoice with fields intact, not a concept article summarising "Guy received payments from Velotix." Compressing to a wiki loses exactly the structure that makes these questions answerable.

5. **One LLM pass vs. LLM as compiler throughout a DAG.** The wiki's LLM is invoked once per article. In the architecture I want, an LLM is both the transform factory (when a query needs something the existing transforms can't answer, the LLM proposes a new one) and the planner (does this question justify materialising a new view across the corpus, or should I answer it directly from the raw documents?). Karpathy validates *LLM as compiler over documents* in one shape. I want to generalise it to a compilation graph.

None of which is to dismiss the wiki. It's a useful *component* of what I'm trying to build — specifically, the "Reference" view, the one that produces concept articles from a thematically-coherent subset of documents. Phase 2 could absolutely implement Karpathy's compilation as one transform among many. It's a feature of the system, not the system.

## What I built

The foundation layer — Phase 1 — is a content-addressed extraction cache with a DuckDB catalogue on top. The data flow is:

```
ingest → route → extract → (cache + catalogue)
```

Sources are files on disk, identified by the SHA-256 of their byte content. Producers are named, versioned pieces of code that consume inputs and produce outputs; Phase 1 ships three (Pandoc, Docling, Unstructured), and LLM-driven transforms in Phase 2 will also be producers. Artifacts are producer outputs stored at content-addressed paths.

The cache key for an artifact is:

```
sha256({
  input_hash: <sha256 of source file>,
  producer_name: "docling",
  producer_version: "2.14.0",
  producer_config_hash: <sha256 of canonicalised config>,
})
```

Two byte-identical documents at different paths produce the same cache key. A different producer, a bumped version, or a changed config produces a different key. There is exactly one function in the codebase that constructs cache keys — `compute_cache_key()` in `src/pkm/hashing.py` — and every code path goes through it.

The catalogue is a DuckDB database indexing the cache: what exists, produced by whom, when, with what status. It's mutable, and rebuildable from the cache with one command. (The source of truth is on disk; the catalogue is the index.) Queries against the corpus are `duckdb` on the command line, with no UI in the way.

If all of this sounds like Nix or Bazel applied to personal documents, that's the right analogy. The primitives are standard; the work is in composing them for a personal-scale corpus and refusing to compromise them under pressure.

## What content-addressing actually demands

Two things surfaced during the real-corpus runs that deserve naming — both cases where the architecture forces an honest answer where one could have fudged.

**The path-independence invariant.** Unstructured's extractor bakes the source filename into an internal element-ID hash. It turns out that byte-identical documents at different paths produce different artifacts — the cache would have silently fragmented across the corpus, producing "duplicate" entries that weren't duplicates. The test `test_cache_key_is_path_independent` caught it: the cache key must be a function of content, not path. The fix pinned the cache key to content and stripped the path-derived field. *Taking content-addressing seriously means the producer's inputs must be reducible to bytes.* Any leak of the source path into a downstream identifier is a bug.

**What "deterministic" means when ML is in the pipeline.** Docling wraps a neural-net layout model. On the third real-corpus run, 14% of the 35 Docling-handled PDFs in a sample produced different byte-level output on repeated runs; a three-run hash check on one such PDF returned three distinct hashes. The coordinates varied at the fourth-to-fifth decimal place — sub-pixel and byte-unequal. The obvious temptation is to round. The correct answer is that **cache keys identify *inputs*, not *outputs***. What matters for a cache is that re-running the producer on the same input is a cache hit — not that the output would be bit-identical if you did re-run it. ML-backed producers can't honestly promise byte-level reproducibility; they can promise that their output is semantically equivalent for their downstream consumers. The spec was rewritten accordingly (§7.1 determinism contract, v0.1.8). This matters because Phase 2's LLM-driven transforms will inherit exactly these semantics: their outputs will vary stylistically between runs, and the cache has to be keyed on inputs to tolerate that without collapsing.

Both of these would have been hard to see without the invariants written down ahead of time. The architecture is unforgiving in the right way: a hidden path in an identifier, or a cache key that claims more than it can deliver, shows up as a test failure rather than a mystery six months later.

## The runs and the numbers

Four runs at increasing scope: 100 sources, then 499, then 990 (stratified by top-level directory and extension, seeded at `20260422`), then the full corpus. The full extraction processed **2,107 sources** into **2,068 artifacts** (2,045 success, 23 failed) in about **41 minutes**. The cache weighs **888 MB**; the catalogue **5.3 MB**.

The failure rate is 1.1%. The failures break down as:

- **18 encrypted PDFs.** Password-protected; Docling returns a bare `ConversionStatus.FAILURE` for these, indistinguishable from corruption or bugs. A `pikepdf` pre-flight now categorises them explicitly: `PDF is encrypted (no password support) on <filename>`, so the catalogue carries a real reason rather than the vacuous status code.
- **3 malformed CSVs.** One parser error (`Expected 6 fields in line 27238, saw 7`) and two `TypeError`s from Unstructured on files that are broken at collection time. The catalogue message names the offending line where there is one.
- **2 Pandoc sixty-second timeouts** on two text files (one being a genuine stress test, one a `.txt` of unusual shape). The timeout is there to prevent pathological cases from consuming unbounded resources; the rejection is the correct behaviour.
- **1 LaTeX syntax error** — my CV, from around 2011, with an unterminated `\begin{document}` on line 47. The catalogue records the actual error message Pandoc emitted.

A further 39 sources were registered but not extracted by any producer. Inspection shows 37 are Android resource XMLs under `msccs/mobiledev/` (layouts, strings, `AndroidManifest.xml`), one is an Ant `build.xml`, one is a FoxyProxy browser-extension configuration. None are document content in any meaningful sense, which is why no producer claims them. The coverage gap is cosmetic; adding an XML producer would earn nothing here.

A few individual cases surfaced cleanly from the same runs: a 12 MB PDF that reliably consumes ~24 GB of resident memory during Docling's layout analysis and has OOM-killed the process on re-runs; sixteen `.org` files that were silently skipped by routing because Pandoc's extension map didn't list the extension (one-line fix, commit `4d7c6a5`); five `.xls` files that needed an optional Unstructured dependency I hadn't installed (`xlrd`, commit `49002a8`). Each of these produced either a spec addition, a configuration change, or an acknowledged deferral to Phase 2.

## What the foundation gives you

Every cached artifact lives at a content-addressed path and is inspectable with `cat`, `jq`, and `file`. The catalogue is a DuckDB file queryable directly with the `duckdb` CLI. Logs are JSONL, one file per day, queryable with `jq`. The configuration is a single `config.yaml` — no hierarchical includes, no environment-variable overrides, no magic.

Every operation is idempotent: running any command twice produces the same result as running it once. Every test that touches the cache demonstrates this explicitly by running the operation twice and asserting the second run is a no-op. Migrations are hash-verified — editing a landed migration in place aborts the next run. The catalogue can be rebuilt from the cache in one command, and there's a test that proves it.

Failures are first-class. A document that fails extraction is recorded as a cache entry with `status="failed"` and an explicit error message, so re-running the extractor on the same input is a cache hit returning the failure, not a repeated attempt.

None of these properties are individually novel — they're the disciplines anyone writing a Nix derivation or a Bazel rule knows by heart. Applying them to a personal-scale system for personal documents is mildly unusual. How the repo's `SPEC.md` and `CLAUDE.md` held a coding agent to these properties is the subject of a [companion post](/posts/pkm-coding-agent-discipline/).

## Phase 2 and beyond

With the foundation stable, Phase 2 is where it gets interesting: transforms that materialise on demand when a query asks for something the existing cache can't answer. The vision is that an LLM acts as a query planner, proposing new transforms (entity extraction, date normalisation, subscription detection, whatever the question requires), and either running them across relevant document subsets or answering from existing cached derivations. Cheap transforms that serve many queries run eagerly across the corpus; expensive ones that might serve one query run lazily when a question justifies the cost. A Bayesian layer decides which is which, and the human — me — approves proposed new transforms before they run, until the system has enough observed history to begin relaxing that.

Further phases — retrieval interfaces, the sharper end of the Bayesian planner, whatever else turns out to matter — will come when Phase 2 has stabilised.

Phase 2 is more speculative than Phase 1. The foundations worked because the invariants were clear, the tests were mechanical, and the success criteria were well-defined. Phase 2's success criteria — *"does this help me navigate my knowledge?"* — are fuzzier, more evaluative, harder to test against. The architecture will have to be built iteratively with me in the loop, asking real questions and seeing what the system does.

But I'll be doing it on a foundation that's strict, rigorous, and debuggable from first principles. The cache holds the corpus in a form I can query with `duckdb` and `jq`. The catalogue tells me what's in it, where it came from, and what it cost to produce. Nothing is hidden. Nothing silently degrades. When something breaks — and in Phase 2 things will break — I'll be able to trace exactly what went wrong by reading files on disk with standard tools.

Code: [github.com/gfrmin/pkm](https://github.com/gfrmin/pkm). The `SPEC.md` and `CLAUDE.md` at the root are the contract and the behavioural rules; the `PHASE1.md` retrospective is the handoff document.
