---
title: "The Court That Tried Itself"
subtitle: "Twenty-three days, 364 issues and pull requests, 870 commits, one sealed judge and one verdict. I built a constitution for coding agents, gave it machine accounts and a ledger, and let it run. It worked. The bill was me."
description: "assize is a court for coding agents: a constitution in a CLAUDE.md, pins that must kill a seeded mutant, a forecast ledger scored against base rates, builder and reviewer sessions that never share a context, and a judge sealed as a container image by digest. It passed its own gates and produced a measured verdict. What it also produced was 149 of my acts in one week, twenty procedure merges for every four of substance, and a deadlock no component could see. This is the account, the lessons, and why its successor is forty entries long."
author: "Guy Freeman"
date: 2026-10-27
draft: true
series: [coding-agents]
series_order: 5
linkTitle: "The Court That Tried Itself"
categories: [essays, ai, bayesian, decision-theory]
---

The four earlier posts in this series each add one guard around a coding agent: a spec it cannot renegotiate, an adoption gate allowed to say no, an answer key signed before the first line, and a standing assumption that every guard is dead until something has tried to kill it. In October I put all of them into one repository and took myself out of the loop as far as I could. The repository is [assize](https://github.com/renavondata/assize) — the old English word for a court that sits, hears, and moves on — and it ran from the 4th to the 27th of October 2026. It is now frozen, by its own law, at the point it was built to reach. This is what it did, what it cost, and what survived.

## What a court for agents is

The constitution is a `CLAUDE.md` of 191 lines, six amendments included. It names no model and no vendor. It names scores and competitions.

A few of its rules are worth stating, because each one is a mechanism and not a request. **Every check must kill a mutant**: a pin exists only with a seeded defect it catches and a twin it admits, so a green that cannot fail is a defect by definition. **The accused does not write its own test**: builder sessions may not touch the pin registry, and a pull request is judged by the pins on trunk, never its own. **Claims precede scoring**: every session appends a forecast — `pins` green on this head, the reviewer accepts, the host verdict — before it runs anything, and the ledger scores it against the base rate for that claim type; a late row is late. **No self-judgement**: a resolution's proposer differs from its forecast's, and a pull request is approved by an account that did not author it. **The signature binds its text**: my instructions enter only as issues I label `instruction`, and an issue whose body anyone else edits after the label authorises nothing. **Append-only**: reports, review files and the ledger only ever gain lines. And, from the first amendment on, **the price of the sovereign**: my own acts are typed as decisions or repairs and counted weekly, because the first week showed the court could run itself only as long as I kept running it.

Around that law sat three machine accounts, two self-hosted runners, and five procedures — Builder, Reviewer, Auditor, Vizier, and a resolver that settles forecasts by code. Builder and Reviewer never share a context. The Auditor is a fresh session on a third model family that reads the whole repository cold and must forecast its own finding count before it starts. Models are elected per procedure by Hedge over their cumulative log-loss, not chosen.

## What it did

The ladder had three layers, each frozen when the next began.

L0 was the scaffold: a harness that kills its own mutant, and a CI split so that the pins run from trunk. It met its pre-stated criteria four times and merged zero, because every rung needed my attention and the attention was unpriced. That is Amendment 1's opening sentence, and it is the most important thing in the repository.

L1 built the World interface, the Crafter binding, and the judge, then sealed it. The verdict was measured on the host — the one machine whose numbers count, under rootless Podman with the network off — and came back **FIT**: a difference of half an achievement per episode detected with 90 % posterior mass at 33 episodes per arm, 92 seconds of an 86,400-second budget.

L2 was meant to be NetHack. It ended instead at the seal: the judge released as a container image pinned by digest, pulled back by that digest, its tree hash re-derived on the host, and the Crafter verdict measured again *under the sealed image*: **FIT**, at 46 episodes per arm, 200 of 200 episodes recorded. That verdict landed on master this morning as the last layer-boundary merge. NetHack and the MiniHack ladder are carried, not done; I filed the wish that ended the layer there myself, and Amendment 6 records why.

So the court produced what it was built to produce: a judge no party can edit, a verdict with its transcript, and a repository that will not accept a change without a mutant dying first.

## What it cost

The ledger is less flattering, and it is the part I trust most.

In the week of 7–13 October I performed 100 decisions and 149 repairs for 41 merges — 3.6 repairs per merge — where a *decision* is a wish, a signature, a first approval, and a *repair* is anything else the loop needed from me: a stop issue closed, a workflow re-dispatched, a label re-applied, a pull request closed unmerged, an approval re-given because a push had dismissed the first. Of 24 merges in the four busiest days, four discharged an obligation of the brief and twenty changed the court's own procedure. The week after Amendment 1 priced me, the figures fell to 17, 40 and 45 — 0.9 repairs per merge — and the repair *share* rose, which is the honest reading: the volume of attention fell, not its mix.

Some of the repairs were the court finding real defects in itself, which is the point. One draft signed without a `Price:` line turned every branch red at once, because the pin that checks drafts reads live issue bodies. A review spent three rounds on how a status file should cite a green run while the code was green throughout. For most of a week no session was ever sent to a red or stuck pull request, because the loop routed on labels and a conflicted pull request fired nothing; the stalls were found by a human looking at a phone. The Vizier, which held a list of acts it could take alone, took none of them. The final verdict took four host runs in a day, each stopped by a different piece of host state that had drifted from code merged after the host was set up: a full `/tmp`, a private file at mode 644, a seed store written before the rule that every seed record names the interpreter that keyed it. The judge's storage checks refused each one correctly. Nothing had declared the host's facts before the run, so the court discovered them one gate at a time.

And one thing the ledger could not show at all: the acts I took through a chat with counsel rather than through the court. A late-night rebase, a key found and re-declared, a session launched from a terminal — none of it left an entry, and a week of them is not in the 149.

## What survived

Six of my earlier systems ended the way assize did not: with no record in their own repository of the decision that stopped them, and the reason written only in the successor's founding text. assize is the first whose ending is in its own ledger — a wish, an amendment, a verdict line — and that difference is most of what it taught.

The successor is [jack](https://github.com/renavondata/jack), named for I. J. Good, and it is deliberately small: an append-only, hash-chained, signed log; two checkers written from the specification alone by two model families, agreeing on 100,000 seeded logs; a judge that admits a pull request from trunk; and, since this week, a ledger of forecasts and resolutions under a proper score, with self-judgement refused in the kernel rather than by rule. Its charter is built from assize's record, and its first section is the table above. The lessons it carries are specific:

- **The record, not the conversation.** Everything that is not an entry does not exist. The acts that bypassed the court were the ones that cost most and showed least.
- **Procedure must not outgrow the object.** Twenty procedure merges to four of substance is now a stop-rule: more than 5 : 1 in a window halts the layer and reports.
- **Price the sovereign first.** My acts are typed by entry and key, not classified afterwards, and the liveness test of each layer is the share of items completed with no repair by me — against a null rate taken from assize's own weekly series.
- **Stop by evidence, not by date.** A layer is promoted when a betting e-process against that null crosses 1/α, at any time Ville's inequality allows; a window is a budget, not a criterion, and a failed window continues the same wealth rather than starting fresh.
- **Nothing is built unless a measurement forces it**, which is the one rule every one of my previous systems arrived at and none kept.
- **The sealed judge stays.** assize's image is jack's judge of last resort; the repository remains as the measurement host, frozen.

## What is left to trust

The question this series started with was: if you did not write the code and cannot read all of it, what is left to trust? The earlier answers were the environment — the contract, the gate, the sealed key, the planted violation. assize's answer is the same one, extended to the people. A court whose owner is outside its loops is not a court; it is a very elaborate way of generating work for him. The thing I now trust is not the judge, which is only as sound as the pins that tried to break it, and not the models, which are elected weekly and can lose. It is the ledger in which my own forecasts, my own hours and my own restarts are scored by the same rule as everyone else's — and the fact that, for the first time, the record of why a system of mine ended is in the system.

Whether any of it was worth the hours is now a forecast on that ledger, with a date. I put it at 0.6.
