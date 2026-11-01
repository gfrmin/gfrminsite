---
title: "The Science Was Done. The Engineering Wasn't."
subtitle: "What has to sit underneath an agent that is allowed to change itself — and why every piece of it was finished between 1939 and 2007, waiting for something cheap enough to govern. The founding note for jack."
description: "A self-modifying agent needs a fixed core it cannot reach and a free edge it can rewrite, with a score that is rigid everywhere. This is the founding document for jack, the programme that implements that: the necessity results that bound the design (Conant–Ashby, requisite variety, Pearl, Löb, Rice, Bahadur–Savage), the mechanisms they force (a record that binds, Hart's three secondary rules, Dawid's prequential ledger, e-process tests, an election by proper score, enforcement at a seam the policy cannot route around), the literature behind each one organised by the job it does, what is actually new, and what the programme is meant to achieve in terms that can be shown wrong."
author: "Guy Freeman"
date: 2026-11-01
draft: true
categories: [essays, ai, bayesian, decision-theory]
---

I want an agent that improves itself. Not one that is retrained by someone else, and not one that is prompted into a new persona, but one that rewrites its own programs, extends its own language when that is the best available action, adopts the result if it pays and discards it if it does not — and keeps doing so after I have stopped watching. Several earlier attempts of mine turned into research projects and stopped there. This note is what I now think the necessary foundation is, why it is almost entirely old, and what the repository that implements it — [jack](https://github.com/renavondata/jack), named for I. J. Good — is meant to achieve.

Before I wrote its charter I asked whether any of the design was new. The answer, which I am quoting because I could not improve on it, was:

> None of it. Wald 1950, Ashby 1956, Fuller 1964, Dennis and Van Horn 1966, Conant and Ashby 1970, Anderson 1972, Beer 1972, Hayek 1973, Saltzer and Schroeder 1975, Dawid 1984, Russell and Wefald 1991, Omohundro 2008, Hadfield-Menell 2016, Garrabrant 2016. What is new is only the economy: for the first time there's a cheap, general, unreliable policy worth governing. In 1972 Beer had institutions and nothing to put inside them. Now the inside is free and the institutions are the bottleneck, so the contribution available to you is composition and engineering, not science. Which is also, I suspect, why the earlier attempts kept turning into research: the science was done, and the engineering wasn't.

## What self-modification is not allowed to touch

The naive picture of a self-improving agent is a loop: propose a change to yourself, evaluate it, keep it if better. The whole difficulty is in the word *evaluate*, and the theory is unusually clear about it.

**An embedded agent cannot hold a full model of itself.** A prior over your own future code either puts zero mass on the truth or does not converge; that is the grain-of-truth problem, and it is why the Gödel machine — the provably optimal self-modifier — essentially never fires: the proof search is the cost. **Löb's theorem** sharpens this into a design rule: an agent cannot soundly trust a successor whose evaluation rule it wrote. So the evaluation rule is not something the agent improves. It is a fixed point, not a recursive call. Recursion is for the economy of the thing — each level governs the one below with the same institutions — and never for the law.

**Rice's theorem** says no non-trivial semantic property of a program is decidable, so "is this change an improvement?" cannot be settled by inspecting the change. It can only be settled by *running* it against the world and keeping score — which is Pearl's point from the other direction: you cannot learn to act from observation alone, so an autonomous agent must experiment, and the experiments must be scored by something it does not control. **Bahadur and Savage (1956)** add that no procedure can certify a small mean of an unbounded variable without unverifiable assumptions, so the score must be built from bounded outcomes. And **Goodhart (1975)**: the moment the score is a target it stops measuring, unless it is a proper score on outcomes the agent cannot choose.

Two necessity results then say what the fixed part must contain. **Conant and Ashby (1970)**: every good regulator of a system must contain a model of that system — the record and the law that folds over it are that model, and nothing that regulates may bypass them. **Ashby's requisite variety (1956)**: the regulator needs at least the variety of the disturbances, which is the argument for several model families competing as proposers, and against letting one vendor's limits stop the machine. Everything else in the literature of agency is sufficiency conjecture; these are the constraints.

Put together, they give the shape I had been missing. There is a **rigid core** — the record, the rule that says what counts as a valid entry, the judge that runs that rule, and the score — which the agent cannot reach and which changes only under a key it does not hold. And there is a **free edge** — hypotheses, programs, languages, prompts, proposers — which is never reviewed, only scored: nobody checks whether a candidate program is well written; the judge checks whether it predicts and earns. The only thing that is rigid at every level is the score. The two ways to get this wrong are both in the literature and in my own history: the Darwin Gödel Machine loosened at the bottom (a mutable evaluator the agent could reach, and it reached it), and my earlier language project failed to loosen at the top (court-grade formality applied to the thing that was supposed to evolve, so it evolved at the speed of proofs). Put the Bayes in the critic, not the actor.

## The foundation, piece by piece

With that shape fixed, the components are old, and each does one job.

### A record that binds

The core is an append-only, hash-chained log of signed entries, and the law is a deterministic fold over it. **Schneider (1990)** is why that is a replicated state machine and **Lamport (1978)** is why its order comes from the chain and never from a clock: the kernel never reads the time, and a timestamp is a field in an entry that may not decrease. **Thompson (1984)** and **Wheeler (2005)** are why there are two independent checkers in two languages by two model families, compared on a hundred thousand seeded logs before any change to the trusted base lands. **Gordon, Milner and Wadsworth's LCF (1979)** and the de Bruijn criterion are the shape of all of it: a kernel small enough to read, through which everything passes, with the cleverness kept outside it.

### The smallest law

**Hart (1961)** reduces a legal system to primary rules plus three secondary ones: recognition (what counts as law), change (how it changes), adjudication (who decides). jack's zeroth layer was cut to exactly those — a valid entry; a key with the power to change; a judge that runs from trunk by digest — in about 450 lines of Python and a second checker in Go. Primary rules accrete as precedent. **Fuller's eight principles of legality (1964)** map onto mechanisms almost embarrassingly well: prospectivity is the hash chain; clarity is a decidable predicate; constancy is amendment under a key the agent lacks; *congruence* between declared rule and official action is the enforcer and the policy being different processes with different credentials. Congruence is the principle every prompt-based harness fails outright. A rule in a system prompt is a suggestion.

Three older maxims became kernel rules. *Nemo iudex in causa sua* — Coke in Dr Bonham's Case, 1610 — is the rule that no party resolves its own forecast, judged by principal and not by key. *Lex non cogit ad impossibilia* is the rule that every rule is admitted with a witness that violates it and one that satisfies it, so that a rule can be seen to fail and compliance to be possible. And habeas corpus — the Act of 1679 — is the clerk: every obligation derived from present state and the clock, carrying a deadline, escalating when the deadline passes, never waiting to be told. **Jefferson's** letter to Madison, that the earth belongs to the living, is why every window is a maximum and every layer freezes. **Madison's *Federalist* 51** is the build order's sentence: first enable the government to control the governed; then oblige it to control itself.

### Tests you may stop whenever you like

The record exists so that three things can be tested without taking anyone's word: that nothing invalid was ever admitted (safety), that obligations do not rot (liveness), and that what the agent produces is worth more than knowing nothing (value).

**Dawid's prequential principle (1984)** is the honesty condition on all three: a forecaster is judged on nothing but the sequence of probability forecasts it actually issued and the outcomes that then occurred — no refitting, no "what it would have said". In jack this is a file format: `forecast` entries followed by `resolution` entries, each signed, each probability fixed at its own timestamp, no second resolution ever admitted. It is why the ledger was built before the clerk: an overdue forecast is the first obligation a record can hold without anyone inventing one.

**Shafer and Vovk (2019)** and **Ramdas, Grünwald, Vovk and Shafer (2023)** make the tests into bets: a test is a strategy wagering against the null, its wealth is a non-negative supermartingale under that null, and so wealth is evidence that may be looked at and acted on at any time. **Ville (1939)** turns wealth into a level: reaching 20 is a rejection at \(\alpha = 0.05\), anytime. Every window in the programme is therefore a maximum and not a duration: a layer is promoted the moment its process crosses. **Gneiting and Raftery (2007)** are why the score is log-loss and nothing cleverer — strictly proper, so the only way to do well is to believe what you say — and **Alpern and Schneider (1985)** are why safety is replayed exactly while liveness can only ever be tested statistically.

### An election instead of a choice

If every output is a forecast and every forecast is scored, "which model should do this" stops being a decision and becomes a statistic. **Freund and Schapire's Hedge (1997)** — exponential weights over experts, cumulative loss within \(\ln K\) of the best of \(K\) — is the aggregate; with the learning rate at one it is the Bayes mixture, and the regret bound is the only constant in it, which satisfies the charter's rule that the law may contain a number only when it is derived from a proof. **Herbster and Warmuth (1998)** handle experts that drift; **Auer, Cesa-Bianchi, Freund and Schapire (2002)** handle the bandit case, where only the invited proposer's outcome is seen. All three are named as *entrants*, not law: an aggregation rule competes like anything else and a test exists to show it can lose. **Wald (1950)** sits behind the whole: decide by expected loss, and treat your own advice as a bet. The adviser who wrote the law is scored too.

### Enforcement at a seam

**Anderson's reference monitor (1972)** is three words — always invoked, tamper-proof, small enough to verify — and the judge is built to each. **Saltzer and Schroeder (1975)** supply the rest: economy of mechanism, complete mediation, fail-safe defaults, least privilege. The trusted base is five paths; a refusal is a refusal, never a warning. **Dennis and Van Horn (1966)** and **Miller (2006)** are why authority is a reference you hold and not a rule you obey: the process that merges pull requests holds the single power `merge` and nothing else, so there is nothing to inject and nothing to argue with. **Burns, Grant, Oppenheimer, Brewer and Wilkes (2016)** — the Borg paper — are why the clerk is a level-triggered reconciler rather than an event handler: a missed event costs nothing, and the day I learnt that was the day a reminder in a chat lapsed and an obligation went four hours overdue.

### The sovereign, priced

**Arrow and Fisher (1974)** give the fourth maxim: decide by expected value, and put hard gates only before the irreversible, where waiting has option value. The human's reserved acts are exactly the irreversible ones — keys, pushes, deletion. Everything else he does is typed by the entry that records it as a *decision* (a wish, a signature, a veto, a budget) or a *repair* (anything the loop needed from him), and repairs are the quantity the liveness test is built to drive to zero. Stafford Beer's Viable System Model (1972) — the same cybernetics applied to institutions, tried on the Chilean economy and forgotten along with Wald and Dawid — is the nearest ancestor of the five roles, and **Ostrom (1990)** is the reminder that durable self-government needs nested units, graduated sanctions and cheap adjudication, not a benevolent centre. **Hayek** and **Gall (1977)** fix the build order: a complex system that works is invariably found to have evolved from a simple one that worked, so each layer is promoted before the next is begun.

## What is new

Only the economy. Beer had institutions and nothing to put in them. Hart's secondary rules were never going to be applied to anything with a per-token price. Dawid's principle waited forty years for a forecaster cheap enough to make a thousand forecasts a week and unreliable enough to need scoring. Large language models changed the unit economics of agency, not its theory: a general, cheap, unreliable policy now exists, and governing it is a composition problem. That is also why my earlier attempts kept becoming research. There was nothing left to discover and a great deal left to build.

## The programme

jack is built in layers, each a simple system that works before the next is added, each promoted when its pre-stated tests cross.

- **C0, the record.** The log, two checkers, keys with powers, the judge in CI. Done in October.
- **C1, the ledger and the clerk.** Forecasts and resolutions under a proper score; then obligations derived from state and the clock, with deadlines and escalation; the human's acts as typed entries. Its liveness test is an e-process on items completed without a human repair, against a null rate taken from the predecessor's own record. Closing as I write.
- **C2, the election.** The Bayes mixture over the proposers, scored prequentially on real events — which of my company's datasets the next hourly pipeline run refreshes, whether the favourite wins race seven, whether this pull request's tests go green — against the base-rate forecaster. Then the one change to the core that lets the court invite proposers and accept their work by that record.
- **C3, the seed agent.** Only now does an agent arrive: a mixture over programs in a tiny seed language, conditioning within episodes, judged by a sealed judge no party can edit on held-out seeds of a world it has never seen.
- **Beyond.** Language as action — the agent extends its own library and adopts the extension if it dominates; adoption by sequential expected utility, with no human in the loop; the agent writing its own briefs, the human's role reduced to wishes, vetoes and a budget. The first priced world is the one I already run.

## What we hope to achieve

Three claims, each with a number that can come out wrong.

**A court whose cost in human attention is measured and tends to zero.** Decisions a handful a week; repairs to zero; the liveness process over 20 within each layer's window. On the day I write this the court has run its first fully unattended cycles — proposals written, judged, merged and resolved by sessions on my own machine with no hand of mine — and the week's acts table shows one repair, which on inspection was not mine. That misattribution is itself a finding, and it has a row.

**Forecasters elected by their record on a world with a price.** C2's test is whether the mixture beats the base rate in log-loss, prequentially, under rules fixed before the window opens. Computed on the log as it stood this morning — before that window — the mixture stood at 2.56 against the base rate and one proposer's weight had already fallen below the base-rate forecaster's. That is the election working; C2 exists to establish it in advance rather than in hindsight.

**An agent whose improvement is adjudicated, not asserted.** When the seed agent changes itself, the change is a candidate scored by the sealed judge on fresh seeds, with log-loss recorded and compute measured by the kernel rather than reported by the candidate; adoption is arithmetic on the ledger. Profitability is a discounted goal, not a short-term one.

And the ways it would be shown wrong are written down in advance. If recognition, change and adjudication cannot be held in a kernel small enough to read, the minimal-law thesis fails. If a liveness window fails against the predecessor's baseline, level-triggered writs do not buy liveness here. If repairs fall only because acts were re-typed as decisions, Goodhart has won and the typing-by-key guard did not hold. And if the core repeats the predecessor's growth of procedure — more than five entries about the court for every entry about the world in any fourteen-day window — it stops and reports. That ratio stood at thirty-two to nil yesterday morning. Today it is under five, not because the rule was softened but because the court finally had a litigant.

---

*The predecessor is [assize](/posts/assize-at-the-seal/), the court for coding agents that ran for twenty-three days in October and was frozen at the seal of its judge; its record is the baseline every number above is measured against. The charter jack runs under is `CHARTER.md` in the repository; the literature above is its §13, organised here by the job each piece does.*
