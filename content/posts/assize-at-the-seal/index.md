---
title: "The Court That Tried Itself"
subtitle: "Twenty-three days, 364 issues and pull requests, 906 commits, one sealed judge and one verdict. I built a constitution for coding agents, gave it machine accounts and a ledger, and let it run. It worked. The bill was me."
description: "assize was a court for coding agents: a constitution in a CLAUDE.md, checks that must catch a planted bug, a forecast ledger, builders and reviewers that never share a context, and a judge sealed as a container image. It reached its seal and a measured verdict. It also cost 121 of my repairs in four days, and twenty merges on its own procedure for every four on the thing it was building."
author: "Guy Freeman"
date: 2026-10-28
draft: false
series: [coding-agents]
series_order: 5
categories: [essays, ai, bayesian, decision-theory]
---

The last post in this series ended on a forecast. The foreseeable end state of a programme like the one it described, I wrote, was "arriving in October with a beautiful generated artefact, an armed ratchet, four reports, and the same three silent seams." It is October. This is the account of another programme of mine, which arrived with a sealed artefact, a measured verdict, and a bill.

The four earlier posts each add one guard around a coding agent: a spec it cannot renegotiate, an adoption gate allowed to say no, an answer key signed before the first line, and a standing assumption that every guard is dead until something has tried to kill it. In October I put all of them into one repository and took myself out of the loop as far as I could. The repository is [assize](https://github.com/renavondata/assize), after the old English courts that sat, heard, and moved on. It ran from the 4th to the 27th of October 2026. It is now public, archived, and frozen at the point it was built to reach.

## What the court was for

The court was not the point. The point was the thing it would judge: an agent that improves itself, living in another repository and allowed to keep a change to its own code only when an impartial measurement says the change helped. That needs a judge no party can edit. So the first job was to build one: a program that runs an agent in a game world, scores it, and is then frozen as a container image identified by its hash. The worlds were [Crafter](https://github.com/danijar/crafter), a small survival game whose score is the number of distinct achievements in an episode, and later NetHack. An agent's builders cannot touch the judge. They can only submit to it.

assize was the court that built and sealed that judge, and coding agents ran it under a constitution.

## What a court for agents is

The constitution is a `CLAUDE.md` of 191 lines, six amendments included. It names no model and no vendor. It names scores and competitions.

A few of its rules are worth stating, because each one is a mechanism and not a request.

- **Every check must kill a mutant.** A check here is called a *pin*. A pin exists only with a *mutant*, a deliberately planted defect it must catch, and a *twin*, the same copy without the defect, which it must pass. A green that cannot fail is a defect by definition.
- **Claims precede scoring.** Every builder session appends a forecast for each claim (the pins go green on this head, the reviewer accepts, the host verdict) before it runs anything. A forecast row that first appears later is late.
- **No self-judgement.** A forecast is resolved by a different session from the one that made it, and a pull request is approved by an account that did not author it.
- **The signature binds its text.** My instructions enter only as issues I label `instruction`. An issue whose body anyone else edits after the label authorises nothing.
- **Append-only.** Reports, review files and the forecast ledger only ever gain lines.
- **The price of the sovereign.** This came from the first amendment on. Amendment 1 opens: "The court has been faster than the king." The rest of it puts a price on my attention, which the original text never priced.

Around that law sat three machine accounts, self-hosted runners on my own machines, and five procedures:
- **The Builder** does the next unfinished item of the brief.
- **The Reviewer** is a separate session with fresh context, which approves the work or records a blocking finding. The same session never plays both roles.
- **The Auditor** is a fresh session on a different model from both. It reads the whole repository cold, and must forecast its own finding count before it starts.
- **The Vizier** turns my wishes into draft instructions for me to sign. It recommends, with a probability attached, and may take a short list of acts alone.
- **The resolver** settles forecasts by code.

Models were elected per procedure by a bandit rule over their scored record, not chosen. Outside all of it sat *counsel*: a chat session with Claude where I thought the project through. It drafted text for me to sign, and the constitution lists it as a kind of proposer.

## What it did

The work came in layers, and each layer was frozen when the next began.

**L0, the scaffold.** A pin harness that kills its own mutant, and CI split between the cloud, where the pins run, and one machine of mine, where the numbers are measured. It met its pre-stated criteria four times and merged zero times, because every rung needed my attention and the attention was unpriced. That is the second sentence of Amendment 1, and it is the most important thing in the repository.

**L1, the judge and Crafter.** It built the interface between agents and worlds, bound Crafter to it, and sealed the judge. The verdict was measured on *the host*, the one machine whose numbers count as evidence, running the judge under rootless Podman. It came back **FIT**. That is the court's word for a judge that can detect a half-achievement improvement in an agent within a day of the host's compute. Here it took 33 episodes per arm, 92 seconds of an 86,400-second budget, at 90% posterior mass.

**L2, meant to be NetHack.** It ended instead at the seal. The judge was released as a container image pinned by digest, its hash was re-derived from the source on the host, and the Crafter verdict was measured again under the sealed image. It came back **FIT** at 46 episodes per arm, with 200 of 200 episodes recorded. That verdict was merged on 27 October, as the last layer-boundary merge. NetHack and the MiniHack ladder, the NetHack-based tasks that were to follow, are carried to the successor, not done. I filed the wish that ended the layer there myself, and Amendment 6 records what it ended.

So the court produced what it was built to produce: a judge no party can edit, a verdict with its transcript, and a repository that will not accept a check without a mutant dying first.

## What it cost

The ledger is less flattering, and it is the part I trust most.

For the four days from 10 to 13 October, the first with comparable records, a script classified every act of mine in GitHub's record of the repository:

| | 10 Oct | 11 Oct | 12 Oct | 13 Oct | 4 days |
|---|---:|---:|---:|---:|---:|
| decisions | 27 | 35 | 14 | 12 | 88 |
| repairs | 36 | 22 | 32 | 31 | 121 |
| merges to master | 3 | 5 | 6 | 10 | 24 |
| repairs per merge | 12.0 | 4.4 | 5.3 | 3.1 | 5.0 |

A *decision* is a wish filed, a draft signed or declined, an instruction filed or withdrawn, or a first approval. A *repair* is anything else the loop needed from me:
- a stop issue closed;
- a run re-fired;
- a pull request closed unmerged;
- an approval re-given because a push had dismissed the first.

Four of the 24 merges discharged an obligation of the brief. Twenty changed the court's own procedure. Across the whole week of 7 to 13 October I made 147 repairs. In the week after, once Amendment 1 had priced me, I made 40.

Some of the repairs were the court finding real defects in itself, which is the point:
- **The accused wrote its own test.** Until mid-October a pull request's checks ran that pull request's own harness. From mid-October the pins on trunk judged it too.
- **One unpriced signature turned every branch red.** A single draft was signed without a `Price:` line, and the pin that checks drafts reads live issue bodies.
- **A review argued about bookkeeping.** It spent three rounds on how a status file should cite a green run, while the code was green throughout.
- **Stalled work fired nothing.** For most of a week no session was ever sent to a conflicted pull request, because the loop routed on labels and a label on a conflicted pull request fired nothing. The stalls were found by a human looking at a phone.
- **The Vizier never acted alone.** It held a list of acts it could take without me, and took none of them.

The final verdict was the fourth measurement on the host on the same code.
- **Two refusals.** The judge's own storage checks refused two of the earlier runs before a single episode. The first found a private file at mode 644. The second found a seed store whose keys predated the rule that every seed record names the interpreter that keyed it.
- **A FIT on the wrong commit.** The third came back FIT, but on a commit that was not the pull request's head, so by the court's own rule it could not stand.
- **A full disk before that.** An earlier run had died on a full `/tmp`.

Nothing had declared the host's facts before the runs, so the court discovered them one gate at a time.

And one thing the ledger could not show at all. Counsel acted through my GitHub token: a late-night rebase, a key found and re-declared, a session launched from a terminal. None of it left an entry of its own. The script counts those acts as mine where GitHub records them at all, and edits to an issue's body it cannot see. Before 10 October, sessions were often started by hand and left no record. The 121 is a floor.

## What survived

Before the successor's first line, a fresh session read every system that preceded it, cold. There were seven of them over eight repositories: Credence and its governor, life-agent, proplang, tannen, and the three wald repositories. Its synthesis has a sentence I would not have written about myself: no repository carries its own reason for stopping. Proplang ends on unposted drafts, Credence on a merge, tannen on a version sitting, and each reason appears in the successor's founding text.

I had taken assize for the exception, because its ending is in its own record: a wish, an amendment, a verdict line. An earlier draft of this post said so. The record does not bear it out. Amendment 6 says what ended and my wish gives no reason, and the reader, given assize, put it in one line: "The reason for jack is written in jack's charter, not in assize's: the pattern above, once more."

So the reason goes here. By 13 October the court had shown two things. It could produce a sealed judge and a measured verdict. And each merge was costing me five repairs, with four merges in five changing the court rather than the thing it was building. The charter counsel drafted for the successor that day proposed that assize finish its layer, freeze, and become the new project's judge of last resort. On 24 October I cut the layer at the seal.

The successor is jack, named for I. J. Good, and it is deliberately small. It has four parts:
- an append-only, hash-chained, signed log;
- two checkers for that log, written from the specification alone by two model families, Claude in Python and Codex in Go, which agree on 100,000 seeded logs;
- a judge that runs trunk's checker over every pull request;
- since 25 October, a ledger of forecasts and resolutions under a proper score, with self-judgement refused in the kernel rather than by rule.

Its charter's first section of evidence is the table above. The lessons it carries are specific:

- **The record, not the conversation.** Anything that is not an entry does not exist. The acts that bypassed the court were the ones that cost most and showed least.
- **Procedure must not outgrow the object.** Twenty procedure merges to four of substance is now a stop rule: more than 5 : 1 in any fourteen-day window stops the layer and reports.
- **Price the sovereign first.** The liveness test of each layer is the share of items completed with no repair by me. It is measured against a null rate committed before the window opens and taken from the incumbent's record, not estimated from the window it judges.
- **Stop by evidence, not by date.** A layer is promoted when a betting e-process against that null reaches 20, which at \(\alpha = 0.05\) is \(1/\alpha\). It may stop at any time, as Ville's inequality allows. A window is a budget, not a criterion, and a failed window continues the same wealth rather than starting fresh.
- **Nothing is added unless a measurement forces it.** It is the one rule about when to stop building that turns up, in one form or another, across my previous systems. jack's amendments now cite what forced them.
- **The sealed judge stays.** assize's image is jack's judge of last resort.

## What is left to trust

The question this series started with was: if you did not write the code and cannot read all of it, what is left to trust? The earlier answers were the environment: the contract, the gate, the sealed key, the planted violation. assize's answer is the same one, extended to the people.

A court whose owner is outside its loops is not a court. It is a very elaborate way of generating work for him.

What I now trust is not the judge, which is only as sound as the pins that tried to break it. Nor is it the models, which are elected and can lose. It is a ledger in which my own forecasts, my own hours and my own restarts are scored by the same rule as everyone else's. And, for once, the reason a system of mine ended is written down where the next reader will look. As that reader would point out, it is in the successor's charter and in this post, not in the system. One out of two.

Whether any of it was worth the hours is a forecast I should put on that ledger, with a date. I would put it at 0.6.
