---
title: "Work with me"
description: "Evaluation that decides whether an LLM or agent system ships; evidence records for agentic AI under the HKMA's ART framework and MAS's guidelines; evaluation and oversight research. Senior roles, contracts and consulting, from Hong Kong."
---

I'm a statistician who designs AI workflows and proves whether they work. That is one skill in three markets, each with its own vocabulary, so this page is written in each one's: what the problem looks like from your side, what I build, one example, and what to read. Then how an engagement runs.

## If you ship LLM or agent systems {#ship}

The usual state of a system that has reached a demo is that nobody can say whether the next change made it better. The judge prompt disagrees with the engineers, the benchmark moved when the prompt did, and the ship decision is made on a dozen examples and a feeling.

What I build is the evaluation that decides:

- **Metrics tied to the decision.** What "better" means for this system, stated before the run, with the threshold at which you ship.
- **A judge you can trust.** LLM-as-judge validated against human labels, its agreement measured and its variance decomposed, so you know how much of a score difference is the judge's.
- **Comparisons with power.** Paired comparisons and a power analysis, so a difference between two configurations is a difference and not noise; same-day A/B harnesses for what offline evaluation cannot settle.
- **Ablations.** The check that tells a real regression from an artefact of the evaluation. At Booking.com one of these showed that a "regression" was the evaluation's, not the model's.
- **Error analysis.** A failure taxonomy, counted, so next week's work is the biggest bucket.
- **The memo.** Ship or don't, with the denominators.

**Example.** At Booking.com (March to June 2026) I designed a multi-arm offline evaluation framework for an agentic LLM recommender — LLM-as-judge scoring, variance decomposition, automated prompt optimisation — and used it to compare configurations and choose models. The measurement redesigned the system: from a multi-step agentic loop to a leaner deterministic workflow, task completion up 2.7× and latency down an order of magnitude, from research prototype to production. Before that, at Slice, the document-AI pipeline I designed replaced manual onboarding: 500+ legal and financial documents in twenty minutes at 95%+ accuracy. [The CV](/cv/) has the rest.

**Read:** [Signed Before the Code Existed](/posts/signed-before-the-code-existed/) · [Make Your OpenClaw Agent Cheaper, and Measure It Yourself](/posts/openclaw-cheaper-measure-it-yourself/) · [The Ablation That Beat the Agent](/posts/credence-paper/) · [Ninety-Six Percent Cheaper and Slightly Better](/posts/ninety-six-percent-cheaper/)

## If you govern AI in a bank or insurer {#banks}

Two regulators moved in October 2026. The HKMA's [ART framework](https://www.hkma.gov.hk/eng/news-and-media/press-releases/2026/10/20261015-3/) — Accountability, Resilience, Trust; 15 October — came with updated supervisory guidance on responsible AI and announced a discussion paper on a supervisory framework for agentic AI that will explore intent-anchored accountability, a registry of material AI agents and effective intervention mechanisms, after a sandbox cohort in which more than 60% of use cases were agentic. MAS's [Guidelines on AI Risk Management](https://www.mas.gov.sg/news/media-releases/2026/mas-sets-out-supervisory-expectations-on-responsible-ai-adoption-by-financial-institutions) — 7 October, in force from 7 October 2027 — ask for an inventory of AI use at a granularity that matters, testing and monitoring across the life cycle, and accountability for AI a third party built, with agentic guidance to be consulted on in 2027.

Both ask the same question of an agent: what did it do, under which rule, and who could have stopped it? That is the question [jack](https://github.com/renavondata/jack) answers by construction, and its three mechanisms translate directly:

- **The record** ([chapter 3](/book/ch-03-the-record.html)). An append-only, hash-chained, signed log of every act, and a 450-line checker any party can replay. The audit trail a registry of agents needs, with the replay as the assurance.
- **The clerk** ([chapter 5](/book/ch-05-the-clerk.html)). Obligations derived from the record and the clock — what is due, from whom, by when — rather than from anyone's memory. The inventory and the sign-offs, derived from the log instead of kept beside it.
- **The law changes under itself** ([chapter 9](/book/ch-09-the-law-changes-under-itself.html)). Amendment with a delay, the irreversible named, lapse. Change control for the rules that govern the agent, with the intervention built in: the rule the agent cannot reach.

What I do for a bank or insurer: evaluate a vendor's or an in-house GenAI system against pre-stated criteria, with guardrail precision and recall measured rather than asserted; design the evidence record for an agentic use case, so that the registry entry, the accountable person's sign-off and the intervention path all derive from one log; and write the validation report in the regulator's terms.

**Example.** At HSBC, in commercial banking data and analytics, I design and measure LLM workflows for third-party vendor compliance (a retrieval-augmented workflow, with guardrails, that answers compliance questionnaires) and for fraud (improved address remediation: raw customer address data turned into signals of financial crime). Financial crime is where this started for me, and [doorplate.dev](https://doorplate.dev) is the open version of the address problem: Bayesian resolution of any Hong Kong address, in English or Chinese, to the government gazetteer — 89.5% right and 3.8% wrong on real-world text, with an honest refusal for the rest.

**Read:** [Build the Court Before the Agent](/posts/build-the-court-first/) · [The Court That Tried Itself](/posts/assize-at-the-seal/) · the book's [chapter 3](/book/ch-03-the-record.html), [chapter 5](/book/ch-05-the-clerk.html) and [chapter 9](/book/ch-09-the-law-changes-under-itself.html)

## If you do evaluation or oversight research {#research}

The court's vocabulary is precise but not searchable, so here is the work in the field's terms.

| What I built | In the field's terms |
|---|---|
| [assize](/posts/assize-at-the-seal/) | Pre-registered, held-out evaluation of self-improving agents with mutation testing (30 checks, 81 planted faults, all caught at the seal); proper scoring rules (log-loss) on every builder's and reviewer's forecast; a Bayesian power analysis, with a half-achievement improvement in Crafter detectable at 33 episodes per arm. |
| [jack](https://github.com/renavondata/jack) | A tamper-evident audit log with independent replay; a trusted base — a 450-line kernel and a judge — that the policy cannot write to, which is AI control made structural; promotion between layers gated by anytime-valid sequential tests (e-values, Ville's inequality) on pre-registered criteria. |
| [The frozen-oracle protocol](/posts/signed-before-the-code-existed/) | Acceptance tests hashed and signed before any code exists and handed to a coding agent that cannot change them: pre-registration, made binding. A red team found [fifteen ways past the gate](/posts/fifteen-ways-past-my-own-gate/); each became a seeded failure the gate must catch. |
| [credence-governor](/posts/credence-pi-pass-2/) | A runtime monitor for a coding agent's tool calls: injected data exfiltration flagged at 0.94 precision while interrupting 1.2% of safe sessions. |
| [The Credence retraction](/posts/credence-paper/) | A one-line greedy ablation beat the full agent under fair conditions, so the paper was withdrawn and the reason published. What survived is a contingency law: exploration beats greedy only under perfect attribution (about +27), and loses under the best attribution a deployed agent gets (−12). |

What a lab or institute gets from me: methodological red-teaming of evaluation claims, which I have done to my own and published; experimental design for control evaluations against a planted adversary, which is what assize's pins are; and a book-length, recomputable argument for why each piece of a self-modifying agent's core is forced rather than chosen. Papers in preparation: the frozen-oracle trust protocol; the exploration-attribution contingency law.

**Read:** the book's [chapter 2](/book/ch-02-every-suggestion-a-bet.html), [chapter 6](/book/ch-06-testing-by-betting.html), [chapter 13](/book/ch-13-the-evidence.html) and [chapter 10](/book/ch-10-the-lock.html) · [The Science Was Done. The Engineering Wasn't.](/posts/the-science-was-done/) · [Fifteen Things a Self-Modifying Agent Cannot Do Without](/posts/necessities/)

## How an engagement runs {#how}

- **Criteria first.** What counts as working, and the threshold, written down before the run. Afterwards they don't move.
- **A report with denominators.** Every rate says what population it covers. Nothing is dropped silently.
- **Numbers you can recompute.** The harness and the data stay with you; the book holds itself to the same rule.
- **No when it's no.** I withdrew my own paper when an ablation beat it. I'll tell you the same about your system.

The shapes it takes:

- **Evaluation audit.** A few weeks. Your evaluation, your judge, your numbers, re-run and re-checked, and a report on what it can detect, what it cannot, and what to change.
- **Evaluation design and build.** The framework for one system, from metric to memo, handed over with the harness.
- **Fractional evaluation lead.** A day or two a week across a team's systems, owning the evidence behind its ship decisions.
- **The stuck project.** An AI system that was supposed to be finished. An honest measurement and a decision: fix, cut or ship.

Contracts run under my own name, as Booking.com's and HSBC's did. I'm also open to research and senior scientist roles in AI evaluation, oversight and assurance — Hong Kong, Singapore, London, Tel Aviv or remote. The [two-page CV](/cv/) is on the site; [write to me](/contact/).
