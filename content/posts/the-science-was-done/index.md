---
title: "The Science Was Done. The Engineering Wasn't."
subtitle: "Everything jack is built from was finished between 1939 and 2007 — the prequential principle, e-processes, Hart's secondary rules, reference monitors, capabilities, the good-regulator theorem. Nobody had anything cheap enough to govern with them. Now the inside is free and the institutions are the bottleneck."
description: "jack is the successor to assize: a forty-entry governance core for autonomous agents, built to be run by a sovereign whose attention is the scarcest input. This post is the literature it stands on, organised by the job each piece does, the motivation for building it rather than another harness, and what it is meant to achieve — a court whose cost in human attention is measured and tends to zero, forecasters elected by their record on a priced world, and finally an agent judged by a judge no party can edit."
author: "Guy Freeman"
date: 2026-11-01
draft: true
series: [coding-agents]
series_order: 6
linkTitle: "The Science Was Done"
categories: [essays, ai, bayesian, decision-theory]
---

[The last post](/posts/assize-at-the-seal/) ended with a court that worked and a bill made out to me: 149 repairs in a week, twenty procedure merges for every four of substance, and the observation that every protection resting on my attention had failed in the same way. The successor is [jack](https://github.com/renavondata/jack), named for I. J. Good. Before writing its charter I asked the question any statistician asks of a design that looks too neat: is any of this new?

The answer, which I am quoting because I could not improve it, was this:

> None of it. Wald 1950, Ashby 1956, Fuller 1964, Dennis and Van Horn 1966, Conant and Ashby 1970, Anderson 1972, Beer 1972, Hayek 1973, Saltzer and Schroeder 1975, Dawid 1984, Russell and Wefald 1991, Omohundro 2008, Hadfield-Menell 2016, Garrabrant 2016. What is new is only the economy: for the first time there's a cheap, general, unreliable policy worth governing. In 1972 Beer had institutions and nothing to put inside them. Now the inside is free and the institutions are the bottleneck, so the contribution available to you is composition and engineering, not science. Which is also, I suspect, why the earlier attempts kept turning into research: the science was done, and the engineering wasn't.

That is the thesis of this post and of the repository. What follows is the literature, organised not by field but by the job each piece does in the mechanism; then what we are actually trying to achieve, in terms that can be shown wrong.

## The tests: how anything earns the right to exist

Start with the hardest problem, which is not getting an agent to act but knowing whether anything it did was any good, without taking its word for it.

**Dawid's prequential principle (1984)** says a forecaster is to be judged on nothing but the sequence of probability forecasts it actually issued and the outcomes that then occurred. No model of the forecaster, no refitting, no "what it would have said". In jack this is not a philosophy but a file format: an append-only, hash-chained log of `forecast` entries followed by `resolution` entries, each signed, where a forecast's probability is fixed at its own timestamp and no second resolution is ever admitted. It is also why the ledger was built *before* the clerk that issues obligations — an overdue forecast is the first obligation a record can hold without anyone inventing one.

**Shafer and Vovk (2019) and Ramdas, Grünwald, Vovk and Shafer (2023)** turn testing into betting. A test is a strategy that wagers against the null; the bettor's wealth is a non-negative supermartingale under that null; so wealth *is* evidence, and — the part that matters operationally — you may look at it whenever you like and stop whenever you like. **Ville's inequality (1939)** converts wealth into a level: reaching 20 is a rejection at \(\alpha = 0.05\), at any time. Every window in jack is therefore a maximum, not a duration: a layer is promoted the moment its e-process crosses, and Amendment A5 says so in those words. Last week's C1a window was closed on day six.

**Bahadur and Savage (1956)** supply the discipline that keeps this honest: no test can certify a small mean of an unbounded variable. So jack tests only bounded outcomes — did this item complete without a human repair, did this forecast beat the base rate — and merely *reports* the unbounded ones: repairs per merge, minutes, dollars. **Gneiting and Raftery (2007)** are why the score is log-loss and nothing cleverer: strictly proper, so the only way to do well is to believe what you say.

## The election: how a proposer is weighed

If every output is a forecast and every forecast is scored, then "which model should do this" stops being a decision and becomes a statistic. **Freund and Schapire's Hedge (1997)** — exponential weights over experts, cumulative loss within \(\ln K\) of the best of \(K\) experts — is the aggregate; with the learning rate at one it is simply the Bayes mixture, and the regret bound is the only constant in it, which satisfies the charter's rule that the law may contain a constant only when it is derived from a proof. **Herbster and Warmuth (1998)** handle experts that drift; **Auer, Cesa-Bianchi, Freund and Schapire (2002)** handle the bandit case, where you only observe the expert you invited. All three are named in the charter as *entrants*, not law: an aggregation rule competes like anything else, and a pin exists to show it can lose.

Behind this stands **Wald (1950)**: decide by expected loss, and treat your own recommendations as bets. Counsel's advice to me — "prepare the next layer now", "push the cap" — enters the log as a forecast of my answer and is scored when I give it. The adviser who is usually wrong is weighed accordingly, and that includes the adviser who wrote the law.

## The law: the smallest thing that binds

**Hart (1961)** reduces a legal system to primary rules plus three secondary ones: recognition (what counts as law), change (how it changes), adjudication (who decides a breach). jack's zeroth layer was cut to exactly those three — a valid entry, a key with the power to change, a judge that runs from trunk by digest — in about 450 lines of Python and a second checker in Go. Everything else accretes as precedent. **Fuller's eight principles of legality (1964)** map onto mechanisms almost embarrassingly well: prospectivity is the hash chain, clarity is a decidable predicate, constancy is amendment under a key the agent does not hold, and *congruence* between declared rule and official action is enforcer and policy being different processes with different credentials. Congruence is the one every prompt-based harness fails outright. Rules in a system prompt are suggestions.

Three older maxims became kernel rules. *Nemo iudex in causa sua* — Coke in Dr Bonham's Case, 1610 — is `self_judged`: no party resolves its own forecast, judged by principal, not by key. *Lex non cogit ad impossibilia* is the rule that every rule is admitted with a witness that violates it and one that satisfies it. And habeas corpus — the Act of 1679 — is the clerk: every obligation derived from present state and the clock, carrying a deadline, escalating when the deadline passes, and never waiting to be told. **Madison** supplies the build order's sentence: "you must first enable the government to control the governed; and in the next place oblige it to control itself." C0 and C1 enable. C2 obliges.

## Enforcement: why the law is code at a seam

**Anderson's reference monitor (1972)** is three words — always invoked, tamper-proof, small enough to verify — and the judge in CI is built to each of them. **Saltzer and Schroeder (1975)** give the rest: economy of mechanism, complete mediation, fail-safe defaults, least privilege. The trusted base is five paths. A refusal is a refusal, never a warning. The herald that merges pull requests holds one power, `merge`, and nothing else, because **Dennis and Van Horn (1966)** and **Miller (2006)** taught that authority should be a reference you hold rather than a rule you obey: a party that does not hold the capability cannot act, so there is nothing to check and nothing to inject. The week this was written the herald's key moved from a cloud session to my own machine; that was not a policy change but a change of who held the reference, and it immediately exposed a defect the shortcut had hidden.

**Thompson (1984)** and **Wheeler (2005)** are why there are two checkers in two languages by two model families, compared on a hundred thousand seeded logs before any trusted change lands. **Alpern and Schneider (1985)** are why safety is replayed exactly while liveness can only be tested statistically. **Lamport (1978)** is why the kernel never reads a clock. And **Burns, Grant, Oppenheimer, Brewer and Wilkes (2016)** — the Borg and Kubernetes paper — are why the clerk is a level-triggered reconciler and not an event handler: a missed event costs nothing, and the day I learnt that was the day a reminder in a chat session lapsed and an obligation went four hours overdue.

## Control: why the whole is a loop

**Conant and Ashby (1970)**: every good regulator of a system must contain a model of that system. The fold of the law over the log is that model; the clerk is the controller; the checker is a safety filter no action bypasses; the election is adaptation. **Ashby's requisite variety (1956)** is the argument for several model families as proposers and for not letting one vendor's outage stop the court. Stafford Beer took the same theorem into institutions in 1972, applied it to the Chilean economy, and was forgotten along with Wald and Dawid; his five systems are recognisably the five roles. **Arrow and Fisher (1974)** supply the fourth maxim: decide by expected value, and put hard gates only before the irreversible, where waiting has option value. The sovereign's reserved acts are exactly the irreversible ones — keys, pushes, deletion.

## What is new, then

Only the economy. Beer had institutions and nothing to put in them. Hart's secondary rules were never going to be applied to anything with a per-token price. Dawid's principle waited forty years for a forecaster cheap enough to make a thousand forecasts a week and unreliable enough to need scoring. What large language models changed is not the theory of agency but its unit economics: a general, cheap, unreliable policy is now available, and governing it is a composition problem. That is also, I think, why my own earlier attempts kept turning into research. There was nothing left to discover and a great deal left to build.

## What we hope to achieve

Three things, each with a number that can come out wrong.

**A court whose cost in human attention is measured and tends to zero.** The charter types every act of mine by the entry that records it: a *decision* is a wish, a signature, a veto, a budget; a *repair* is everything else the loop needed from me. Repairs are to tend to zero; decisions to a handful a week. The liveness test is an e-process on "items completed with no repair by Guy" against a pre-stated null rate taken from assize's own record. On the day I write this the court has run its first fully unattended cycles — proposals written, judged, merged and resolved by sessions on my machine with no hand of mine — and the week's acts table shows one repair, which turned out on inspection to be counsel's, under my login. That misattribution is itself a finding, and it has a row.

**Forecasters elected by their record, on a world with a price.** C2's test is whether the Bayes mixture over the proposers beats the base-rate forecaster in log-loss, scored prequentially on real events: which of Renavon's datasets the next hourly pipeline run refreshes, whether the favourite wins race 7 at Happy Valley, whether this pull request's tests go green. Computed on the log as it stood this morning, before the window opened, the mixture sat at 2.56 against the base rate and one proposer's weight had already fallen below the base-rate forecaster's — which is the election working, and the thing C2 must establish under pre-stated rules rather than in hindsight.

**An agent, last.** Only when a record binds, obligations discharge themselves and forecasters are weighed by their results does the seed agent arrive, judged by the judge assize sealed and no party can edit. Profitability is a discounted goal, not a short-term one; the first priced world is the one I already run.

And the ways it would be shown wrong are written down in advance. If recognition, change and adjudication cannot be held in a kernel small enough to read, the minimal-law thesis fails. If the liveness window fails against assize's baseline, level-triggered writs do not buy liveness here. If repairs fall only because acts are re-typed as decisions, Goodhart has won and the typing-by-key guard did not hold. And if the core repeats assize's procedure growth — more than five entries of procedure for every entry about the world in any fourteen-day window — it stops and reports. That last ratio stood at thirty-two to nil on Saturday morning. By Sunday evening it should be under five, not because the rule was softened, but because the court finally had a litigant.
