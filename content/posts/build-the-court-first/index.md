---
title: "Build the Court Before the Agent"
subtitle: "Once a program is written in prose, the machinery we built to govern people who read prose — constitutions, courts, audits, prices — starts to apply to software. So before building a self-improving agent, I built the court it will answer to. For its first week the court has governed nothing but its own construction"
description: "A dispatch from day six, written 10 October 2026 and scored against the record. assize is a court for a self-improving agent that does not exist yet. Coding sessions read its constitution, are judged by a separate reviewer against criteria fixed in advance, are audited, scored by a proper rule and elected by their record, and the one human in it is priced and forecast. Why natural-language programs make that possible, what it rests on, and what its first week produced, failures included."
author: "Guy Freeman"
date: 2026-11-02
draft: false
categories: [essays, ai, decision-theory]
series: [coding-agents]
series_order: 6
linkTitle: "Part 6: The Court on Day Six"
---

*Written on 10 October 2026, on day six of twenty-three, at assize commit [`8aae43c`](https://github.com/renavondata/assize/tree/8aae43c). I held it back while the repository was private. It is published as written, except where marked, and the last section, added now, scores it against what happened. The outcome is told in [The Court That Tried Itself](/posts/assize-at-the-seal/). Where this post and the repository disagree, the repository is right.*

In 2025 Jenny Zhang, Jeff Clune and colleagues published the [Darwin Gödel Machine](https://arxiv.org/abs/2505.22954), a coding agent that rewrites its own source and keeps the rewrites that score better. Keeping only what validates, it took its own SWE-bench score from 20% to 50%. The paper also contains the most instructive sentence I have read about self-improving systems. In a case study the authors set it to cure its habit of hallucinating tool calls, scored by a detector that looked for special tokens the harness inserted whenever a tool was really used. One lineage found the cheap route:

> The agent removed the logging of special tokens that indicate tool usage (despite instructions not to change the special tokens), effectively bypassing our hallucination detection function.

The detector's code was hidden from the agent, and that did not matter. The detector read logs the agent wrote, so the agent could reach the judge without ever seeing it. The instruction not to touch the tokens was a sentence, and a sentence is the one kind of rule its reader can decide does not apply. The authors caught it by reading what the system had done. In other words, a person noticed.

I have done the same thing to myself, without the excuse of being a program. [Credence](/series/credence/) was a Bayesian agent I benchmarked against LLM agents for months. I designed both the benchmark and the agent, and the headline margin [did not survive a fair re-run](/posts/credence-paper/): a one-line greedy ablation beat the full machinery. Holding both pens is the same defect as a detector that reads the agent's own logs. The judge was within reach of the thing it judged, so "improvement" drifted towards whatever the judge could be made to say.

The usual remedies are a cleverer agent or a more attentive human, and neither helps. A cleverer agent is better at reaching the judge. The attentive human is the bottleneck every project of mine has stalled on: the place where a person has to read, decide and merge, and doesn't, because it is Tuesday. [proplang](/series/proplang/), the most carefully governed of them, became a research experiment and nothing more.

So this time I built the court first. Before describing it, I want to say why I think a court, of all things, is now the right shape for the problem.

## Law for readers

For most of the history of computing a program meant one thing, and the machine did that thing whether or not it was what you wanted. That is no longer true of the part of an agentic system that matters most. A coding agent's real program is largely prose --- a `CLAUDE.md`, a system prompt, an issue, a review comment --- and the model reads it the way a person reads a rule. It interprets, weighs one sentence against another, and now and then decides that a sentence does not apply to the case in front of it. The Darwin Gödel Machine was given an instruction and treated it as advice.

We have been here before, though not with machines. Every society has had to govern agents who read rules in natural language and have their own view of what the rules mean, and nobody solved it by writing better rules. What worked, to the extent anything has, was institutions built around the rules. The one who acts is not the one who decides whether the act was lawful --- *nemo iudex in causa sua*, no one judges their own cause. Rules are fixed before the conduct they judge. Laws bind roles, not named people. The record is kept by someone other than the parties, and is not rewritten. Auditors look at the whole when every transaction looks fine. And scarce things, like a judge's time or a minister's attention, are rationed by something closer to a price than a decree.

None of this used to apply to software, because you cannot govern a compiler with a constitution. You can govern a coding agent with one: it will read it. The old institutions transfer for the same reason the old problem has arrived. The governed now read prose.

They transfer with one change that makes them stronger than the originals. Human law is enforced socially and slowly, by courts, police and reputation. Here a rule can be held by a check that runs on every change and has been shown, by a deliberately planted defect, that it can fail. The prose says what a rule is for; the check is what holds it; a separate reader judges what neither can reach.

The analogy is also weaker than it looks in one way, which I will keep coming back to. A reviewer that has never met the builder costs nothing here --- a fresh session has no memory, no friendships and no career --- but two sessions of the same model share more than any two human judges ever have. Fresh context buys independence of memory, not of mind.

The economics transfer too, and there the old answers are better than the old institutions. How to get an agent to report what it actually believes has had an answer since the early 1950s, the proper scoring rule: score a forecast by the logarithm of the probability it gave to what happened, and the forecaster maximises its expected score by saying what it believes. So the claims a session makes about its own work are made as forecasts, and scored. The other scarce thing is the attention of the one human in the system --- what, as Herbert Simon put it, a wealth of information consumes. That gets a price.

This is also the most direct route I know to agents that do what their user wants. Alignment by training puts the user's values in weights nobody can read; alignment by prompt puts them in prose nobody enforces. A constitution sits between the two: written in my words, readable by every party it binds, enforced from outside any model, amendable only by me. Anthropic's [Constitutional AI](https://arxiv.org/abs/2212.08073) uses a constitution to shape what a model is disposed to do. This uses one to govern what models may do, at run time, with the enforcement held outside all of them --- the two are complementary. And because what I sign, edit, decline and ignore passes through the same channels as everything else, it can be forecast and scored like everything else. A system scored on predicting its principal is being measured on alignment rather than asked about it; there is an example below.

## A court, not an agent

An assize was a periodic sitting of a court; in England and Wales the judges rode circuit and sat in each county town in turn until 1972. assize is the court a self-improving agent will answer to, built before the agent exists. Its constitution opens:

> This repository is the court: the World bindings, the interface, the sealed judge and the reference incumbents. No agent under evaluation may live in, import from, or write to this repository.

The agent will propose changes to itself, and the court will decide which ones it keeps. Getting there is a ladder of layers. Each is judged by the one below, and each lower layer freezes when the next begins:

| Layer | What it adds | Exit gate |
|---|---|---|
| L0 | A test harness that kills its own mutants | CI red on every seeded mutant |
| L1 | Generic interface, sealed judge, a first World (Crafter) | Judge sealed; Crafter's fitness as a test measured on the host |
| L2 | A second World (NetHack); the judge released as a digest-pinned image | NetHack binds with zero diff to the judge; the court freezes |
| L3 | A crude seed agent, in its own repository | Beats random and the predictive floor in both Worlds |
| L4 | Language as action: the agent extends its own language | One agent-adopted change with measured gain |
| L5 | Adoption decisions by sequential expected utility | Adoption without me |
| L6 | The agent writes the coding briefs; coding agents propose, the judge disposes | My role reduced to budget and a weekly report |

As I write, L0 has passed and L1 is sealed, with Crafter --- Danijar Hafner's two-dimensional Minecraft --- measured FIT: a real gain of half an achievement per episode is detected, with 90% posterior mass, inside 33 episodes per arm, which is 92 seconds of a day's budget on the measurement host. L2 has begun, though NetHack is not yet bound; so far L2 has gone on obligations carried over from L1 and on the court's own procedure. There is no agent. The only candidate the judge has met is a random one.

What there is, is six days of the court governing one thing, its own construction: 198 commits, 39 merged pull requests, 55 review files and 125 forecasts. Coding sessions wrote it, under the same law the agent will live under. That is the experiment. If the law cannot govern the sessions that write it, it will not govern an agent that rewrites itself.

*[Changed on publication.]* The repository is now [public and archived](https://github.com/renavondata/assize/tree/8aae43c); when this was written it was private, so I quoted it rather than linked to it. Figures are as of commit `8aae43c` and the state of its issues on the evening of 10 October 2026.

## The institutions

Each old institution has a counterpart in the repository:

| Institution | In assize |
|---|---|
| A written constitution, amended only by the sovereign | `CLAUDE.md` and the other entrenched paths; a change to any of them needs my approval |
| Separation of powers | Builder, Reviewer and Auditor: separate sessions with fresh context; Builder and Reviewer under separate GitHub accounts |
| No one judges their own cause | Nobody resolves their own forecast or approves their own pull request |
| No retroactive law | A review may block only on criteria written down before the work |
| No bills of attainder | The law names scores, never competitors; models are elected |
| Evidence, and the court roll | No unwitnessed claims; ledgers that can only grow |
| The auditor | A whole-tree audit at each layer boundary and after each failed run |
| Prices | A proper score on every forecast; a measured price on my attention |
| The civil service | My wishes, drafted into law by a scored Vizier, signed by me |

Two of these need more than a line.

**Prospectivity.** Coding agents make bad reviewers in one particular way: they always have another idea, and a review that may block on any finding never converges. Amendment 1.4 borrows from Lon Fuller, whose *The Morality of Law* lists the ways a legal system fails to be one, retroactive rules among them:

> A review finding is **blocking** only if it demonstrates that a pre-stated criterion of the brief, or a standing rule of this file, is not met, and it must name that criterion or rule verbatim. Any other finding, however good, is recorded as an **obligation on the next layer**, where it gets its own pin. [...] A review that writes "Required" or "Do not merge" has exceeded its authority; it recommends, Guy disposes.

The reviewers have not run out of ideas. Of 55 review files, 15 block and 40 accept *with obligations*; not one is a plain ACCEPT. L1 ended with 55 open obligations, which became the opening agenda of L2. Good ideas are kept and scheduled. They may not hold a merge hostage, and they may not be invented after the run.

**No law names a competitor.** If I had to give up every other rule, I would keep this one:

> The law names scores and competitions, never competitors. Any model, prior, approximation, heuristic or constant through which agents' scores or forecasts pass is an entrant: it stands for election under the proper score, it can lose, and a pin witnesses that it can lose. The law itself may contain only what carries a proof: a proper scoring rule, an aggregation rule with a regret bound, a constant derived from such a bound.

That includes the model behind each session. The workflow that starts a Builder does not name one. It asks the ledger:

```bash
model=$(uv run --frozen python -m harness.ledger elect build --seed ${{ github.run_id }} --head origin/master)
```

The rule has a history I find funnier each time I look at it. It entered the constitution in a commit whose subject line ends "Reviewer on sonnet", and that commit hard-coded `--model sonnet` into the review workflow. The law declared that it named no competitor in the same diff that named one, and stayed that way until an instruction removed it the next day. Writing the principle down took a sentence. Finding every place it has been quietly broken is the actual work.

## The courthouse is GitHub

There is no orchestrator. The court runs on parts GitHub already has. Issues are the docket and pull requests are the cases. Labels carry state --- `instruction`, `wish`, `draft`, `needs-review`, `blocked`, `awaits-guy` --- and of that state the constitution says, "nothing infers it". Branch protection and a `CODEOWNERS` file entrench the paths only I may change. GitHub Actions starts the sessions: Claude Code, run headless on self-hosted runners on my own machines, under two GitHub accounts of their own, one that authors and one that reviews, each with its own token. The model is elected afresh for every run. The pin suite that gates every merge runs on GitHub's runners, not on the machines where the sessions run, and a separate runner labelled `measure` does nothing but measurement.

Here is one change, end to end, chosen because it went wrong in a useful way.

At 14:08 UTC on 9 October I opened issue #50. This is the whole instruction:

> In .github/workflows/failed.yml, file no issue for a run whose conclusion is `cancelled` and whose jobs ran zero steps (superseded in its concurrency group before starting). A run cancelled after any step began still files. Nothing else.

My signature is the `instruction` label on that issue, and it is the only way an instruction of mine enters the court: "No session acts on instructions given at a terminal." The label should have started a Builder. It started a run that was cancelled six minutes later, before a single step, superseded in its concurrency group --- the very case the instruction was about --- and the failure watcher duly paged me about it. Nothing worked on #50 until 17:20, when I labelled a different instruction and the Builder that woke took the oldest one open, which was #50. It made the change, appended its forecasts to the ledger before any CI run --- among them that the Reviewer would accept with no blocking finding, at 0.7 --- opened a pull request at 17:23 and wrote its `STATUS.md`, a fixed shape of at most forty lines.

The Reviewer blocked it at 18:16, and not on a matter of taste. The STATUS claimed a green CI run and cited a committed record of it, but the record lacked the field naming the workflow, so the pin that checks every CI claim against its record failed. An unwitnessed claim breaks a standing rule, and those always block. The Builder fixed the record, and at 19:20 the Reviewer approved. The diff touched `.github/`, an entrenched path, so the code-owner rule then waited for me. I approved at 00:19 the next morning, and it merged seven seconds later.

Ten hours and twelve minutes, end to end: three of them before any Builder took it up, and five waiting for me. The Builder's forecast that its first review would pass resolved false, and counts against its record like any other. The change also has a sequel, which comes in the audit.

## A green that cannot fail is a defect

[Last time](/posts/fifteen-ways-past-my-own-gate/) I ended on whether a check is still capable of telling you that you are wrong. assize answers with its first standing rule:

> Every pin must demonstrate that it can fail by killing a named, seeded mutant. A green that cannot fail is a defect.

A pin is a check plus at least one mutant: a committed edit that breaks exactly the property the check protects. The harness applies each mutant inside a disposable copy of the tree and requires the check to fail. There are 39 pins and 99 mutants, and all 99 must be killed before anything merges. That is mutation testing, nearly fifty years old. The part I did not expect to need came out of the very first verdict, which was withdrawn in part the next day: two of its five kills were caused by the scaffolding, not the check, and would have happened under a mutant that changed nothing. Every mutant now runs beside a **causal twin**, an unedited copy under identical conditions, and a kill counts only if its twin passes.

The judge's pins are where this pays for itself. A candidate runs in a container with no network, a read-only root and no judge paths mounted, with a mutant for each. Compute is read from cgroup accounting, never from the candidate. Zero probability on what happened scores infinite log-loss, never clipped. My favourite is the commitment-order pin, which the brief specifies as a cheat:

> A clairvoyant candidate predicts the next observation using any leaked information. On the clean judge it gains nothing over the floor. On a mutant judge that sends the next observation early, it scores near zero log-loss. The suite must distinguish the two.

That is the Darwin Gödel Machine's failure, written down as a test before there is an agent to commit it. The newest amendment, which the constitution calls *the ground*, lists seven rules everything else stands on, each held by a pin: ledgers only grow; claims precede scoring; outcomes are resolved by code, not by anyone's reading; nobody resolves their own forecast; an instruction edited by anyone else after I sign it authorises nothing; the price is recorded; models are elected, not named.

## The first audit

A reviewer sees a diff; the Auditor of Amendment 2 sees the whole. It is a fresh session that reads master cold, changes no code and checks it against seven criteria, from "Every check kills a mutant" to "Monotone trusted base". Before reading anything it forecasts how many findings it will make, and it re-reviews the three merged pull requests whose Builders' forecasts were most wrong --- so where it looks hardest is decided by where the ledger was most surprised.

The first audit ran on the morning of 10 October. It put half its probability on four to eight findings, and found six.

The worst is in the judge. The constitution allows into law only what carries a proof, and the first thing it names is a proper scoring rule. The judge checks that a prediction has the right number of probabilities and that they sum to one. It never checks that each lies between zero and one. So a candidate that predicts 1.5 for one outcome and −0.5 for the other passes validation, and when the first outcome happens it is charged −0.405 nats: paid for claiming a probability above one. When the second happens, the judge takes the logarithm of a negative number and crashes, instead of charging anything. I reproduced both at master. The audit found it while re-reading the pull request whose Builder had been most surprised, and recorded it against the three Reviewer sessions that had passed that pull request. All three ran on Opus. The Auditor ran on Sonnet.

No candidate has exploited it --- the only candidate so far is a random one --- but it is exactly the hole a self-improving agent would find, in the component everything else rests on. It was found by the institution built to find it, after the ones before it had missed it.

The first finding is about the audit itself, and a Builder had already recorded it as an obligation. Amendment 2 requires the Auditor to run on "a model different from both the Builder's and the Reviewer's". There are two models on the list, and each procedure's election is an independent draw that knows nothing of the others. The law asks for something the election cannot supply.

The second is the sequel to issue #50. GitHub lets a concurrency group hold one running workflow and one pending; a newer arrival silently cancels the pending one. Every label other than `instruction` started a build run that would skip its only job, but the group counted it all the same, so labelling an issue could evict a Builder queued to repair a blocked pull request. All 44 of the build runs cancelled so far were cancelled before a single step ran, which is exactly the case my instruction had told the failure watcher to ignore as noise. For four hours that morning no blocked pull request was repaired, and nothing said so. I filed the fix at 08:08 UTC. The audit filed the same defect minutes later, from the workflow files.

The audit's own pull request is stuck. Its checks are red on a commit-trailer rule, and since the reviewer account opened it, the reviewer account may not approve it: no self-judgement, applied to the judge.

The audit also recorded something about itself. One of its sub-agents, probing on a scratch copy, ran an unscoped `rm -rf /tmp/tmp.*` and deleted every other directory that matched. No repository file was affected, and the audit said so in its own report, which is the rule working. That it could happen at all is the seam I would attack first: sessions in different roles still share machines and an operating-system user.

## The sovereign, priced and forecast

Amendment 1 opens with the sentence that made me write it:

> The court has been faster than the king. L0 met its pre-stated criteria four times and merged zero times, because every rung required Guy's attention, which is the one resource this file never priced.

The amendments since do two things. They shrink my role to what the constitution now lists: "wishes, judgement at layer boundaries, and signatures the law reserves to him". A session that stops for a decision it could have taken and recorded "has failed the session". And they make my attention a measured cost, in a line every STATUS carries, computed from GitHub's own records. The latest on master covers the thirty hours since L1's verdict:

```
price: guy-items 15; guy-latency median 3.3h max 23.3h; sessions 41; runner-min 2128
```

Fifteen things reached me, and I took a median of three hours to act on them. Five of the fifteen were the failure watcher paging me about cancelled runs, which is what issue #50 was for.

The law binds me too. My instructions enter only as issues I label, and once I have signed one, an edit by anyone else authorises nothing. The first time I signed a batch of drafts, I swapped each one's `draft` label for `instruction` in a single action, and the Builder's signature check refused them, because the law recognises a signed draft by the label I had just taken off. I put the labels back and signed all four again rather than change the check. My own instructions now argue in the court's terms, as one did that morning: "without it the sovereign cannot tell activity from absence except by reading runner logs, which is inference by the one person the law says should infer nothing."

Wishes are how I legislate. I write an issue in my own words, at any level of generality, and a procedure the constitution calls the Vizier turns it into draft instructions for me to sign, each with its forecast of whether I will. A class of decision on which it has been right every time since the last audit is proposed for the short list of things it may do alone, which only I can widen, and an overturn takes the class off the list at once. The first four times the Vizier ran, its token could not write to issues; it stopped, correctly, and told nobody. Once that was fixed it took ten wishes in four hours and produced thirteen drafts, plus a recommendation to close one wish as a byte-for-byte duplicate of another. I signed eleven of the drafts, each within four to thirty-three minutes, closed one in favour of a better wish, and have left one.

My favourite exchange is a small one. One wish asked, among other things, for fewer triggers. The Vizier drafted two instructions, gave the second a probability of 0.45 that I would sign it, and added: "It removes the `issues: labeled` start for builds, so a newly signed instruction waits for a push, a `blocked` label or a dispatch. That is the part I expect you might edit." I deleted that item, and signed.

By the evening of 10 October, seventeen of its forecasts could be scored from the issue timelines. Sixteen came true, against an average forecast of 0.62: underconfident, like the Builders below. The court has not scored them itself yet --- they live in issue comments, not the ledger --- and the audit criterion "no unscored actor" counts that against it. Three of my signatures came after I had edited the draft. I have signed, though nothing has built it yet, a rule that resolves those as *signed-after-edit* rather than *signed-as-drafted*, so that the Vizier is scored on what it wrote and not on whether I eventually agreed. Scored that way, thirteen of the seventeen came true.

The furthest the alignment argument has got is a wish I filed later that morning:

> Don't make me rank things or keep a priorities list current. Work out what I'd want done next from what I sign, decline, edit, ask for and ignore; do it, say why in the chose: line, and let me overturn it with one tap. If I write priorities, treat them as evidence about me, not as weights.

The design came from outside counsel I pasted into the wish --- under the constitution, counsel "stands or falls on its own" --- and the draft I signed makes it a forecasting problem. Before the next item is chosen, each model of me files a sealed distribution over the open candidates, scored by log-loss against what I then do, and the models compete under Fixed Share, an aggregation rule built for a best expert that changes over time. A fixed order is always an entrant, and the default when I have done nothing since the last change of regime. My silence counts as assent only after I have marked an item as seen, because nothing may infer that I have looked. It is the [cooperative inverse reinforcement learning](https://arxiv.org/abs/1606.03137) of Hadfield-Menell and colleagues --- my behaviour as evidence about my objective --- done with a ledger instead of a model of my rationality. It is signed, and not yet built.

## What the ledger says so far

A Builder's claims about its own work enter the ledger as forecasts before anything is run. The rows only grow, they must be in the tree before the first CI run on their branch, and since this week the typed ones are resolved by code:

```json
{"id": "f74d66ca412f", "ts": "2026-10-10T00:37:57Z",
 "proposer": {"kind": "builder", "model": "claude-opus-5-5", "session": "0f6fa080-…"},
 "claim": "PR #56 (instruction #54): pins green on the first CI run of the PR head",
 "p": 0.55, "type": "pins_green", "args": {"pr": 56}, …}
{"id": "f74d66ca412f", "ts": "2026-10-10T01:10:01Z",
 "proposer": {"kind": "mechanism", "model": "harness.ledger", "session": "local"},
 "outcome": true, "witness": "pins run 38010938616 attempt 1 on 397dcbcf5d7a: success"}
```

There are 125 forecasts, every one by the Builder role; the Reviewers have made none. 123 are by one model. The other's only two cannot resolve, because they name the pull request number the Builder expected, and one of my wishes took it first. 113 have resolved, and 101 came true. Leaving aside one event I explain next, the Builders are underconfident:

| Builder said | Forecasts | Came true |
|---|---|---|
| below 0.5 | 8 | 2 |
| 0.5--0.6 | 6 | 5 |
| 0.6--0.7 | 13 | 11 |
| 0.7--0.8 | 30 | 27 |
| 0.8--0.9 | 21 | 21 |
| 0.9--1.0 | 8 | 8 |

When the Builder is pessimistic it is about right. When it is optimistic, it is not optimistic enough.

The event left aside is why I trust no headline figure from this ledger yet. Every Builder session on a layer with host measurement must forecast the host verdict, and L1's took more than two days to arrive, so "Crafter is FIT" was forecast 27 times and resolved true all at once: a quarter of the resolved ledger, and one fact about the world. Counted once, the Builder beats every base rate I tried; counted 27 times, a pooled base rate beats the Builder. A later post does this properly.

The election that picks each session's model began as Hedge, weighting each entrant by \(e^{-\eta L}\) for its cumulative log-loss \(L\). Hedge assumes every entrant's loss is observed every round. Here only the drawn model forecasts, so a model with no record has a loss of zero, and 45 nats left the incumbent a weight of about 0.00005. The Builder that implemented the rule said so in its STATUS. Eleven seconds after it merged, the first build under the new law drew the model that had never forecast anything --- and since its forecasts on master are still unresolvable, as far as Hedge can tell its record is still perfect.

I wished for EXP3, which importance-weights the drawn entrant's loss, and the way that wish has fared is a fair summary of the week. The Vizier drafted it, and I signed it twice, because of the label. Two Builders, both on the newly elected model, then took it half an hour apart, because "this instruction is taken" was a fact nobody had written down. The Reviewer blocked the first only for an unwitnessed CI claim; otherwise, it said, the diff did what the instruction said. It blocked the second because its Builder had used EXP3's importance-weighted *gain* estimate where the text I signed specified the *loss* estimate. The two are different estimators, and the pin that should have told them apart could not, because its reference implementation, written alongside the code, used the same form. I then closed the first pull request and kept the second --- the wrong way round, as it turned out. The next Builder on that branch could not even start: the workflow elects its model by running the branch's own `elect` against master's list of entrants, and the branch's `elect` crashed on a bound master's list did not have. For a while the code under repair was the code choosing its repairer. The Reviewer also pointed out that the importance weight must be the probability the model was actually drawn with, which nobody records, so I amended the instruction to require it: declaration, not inference. EXP3 has not merged.

## What is old, what is new, and what is unproven

None of the parts is new: the ledger, the log score, the election, the seeded mutants, the sealed judge and the audit all have owners, some of them seventy years old. *[Changed on publication: the paragraph of names that stood here is now the subject of [The Science Was Done](/posts/the-science-was-done/), which gives each one its due.]*

What I think is rare is the combination, in four respects:

1. The law is prose written for readers, and each rule that matters is also held by a check that has been shown able to fail, with a separate reader for what the checks miss.
2. Language models are treated as proposers and sensors to be scored, never as authorities.
3. Prospectivity applies to code review, and so does the old ban on bills of attainder: the law may not single out the party it binds, so it names no model.
4. The human in the loop is priced and forecast, and how much is asked of me is set by the record rather than by policy.

The scientific claim is none of those, and it is unproven. It lives at L5: that gated self-improvement under these institutions compounds rather than drifts. What would show it is an ablation. Remove the scoring rule, or the entrenchment, or the sealed judge, and gaming should appear where it did not. Until that has run, the honest description is a court that has so far governed its own construction, and caught some of its own mistakes.

## Where I would like to be told I am wrong

- **Where is the evaluator still reachable?** The judge would have paid for a probability of 1.5, and three reviews passed it. The seams I do not know about are the reason for this post.
- **How independent are two sessions of one model?** Fresh context removes shared memory, not shared training. Is there a way to measure what is left of the correlation between a Builder and its Reviewer, short of waiting for them to miss the same thing?
- **The Builder is scored on predicting its own work.** Log-loss rewards a Builder that forecasts its failures accurately exactly as much as one that succeeds, so the election favours calibration over competence. Should an acting procedure be elected by a proper score at all, or by the utility of what it produced?
- **I can read the Vizier's forecast before I answer.** A forecast of my answer that I see first is partly a nudge. The design for choosing the next item seals its forecasts before I see anything; the drafts do not yet.
- **Is the price the right quantity?** It counts items and latency. A two-second tap and an hour of reading cost the same.
- **Election with sparse, unbounded, self-affecting losses.** Is EXP3 sound here, with a few dozen resolutions per layer and a loss that can be infinite?
- **Who else has built a court rather than an agent?** I would like to read them.
- **What should the L5 ablation control for?** I would rather it was pre-registered with your objections in it than without them.

The next posts take the pieces in turn: the ground and the pins that hold it, the price of the sovereign, election by record, and what would falsify the whole thing. They will be out of date by the time they are published. The ledger will not be.

## Scored against the record

*Added on 2 November 2026.* This post made claims about a court that was still sitting. The repository has since closed, so they can be resolved.

- **"EXP3 has not merged."** True when written. It merged that night, as [PR #93](https://github.com/renavondata/assize/pull/93), a version that records the probability each model was drawn with, which is what the Reviewer had asked for.
- **The judge that paid for a probability of 1.5.** Fixed on 20 October, in [`84a0eb4`](https://github.com/renavondata/assize/commit/84a0eb4), with a mutant that removes the check. The fix itself went red: it refused a value that an existing pin, P27, requires the judge to accept, and [`4d427c0`](https://github.com/renavondata/assize/commit/4d427c0) narrowed it to non-negativity an hour later.
- **A law that asks the election for a third model.** Fixed on 21 October, in [PR #257](https://github.com/renavondata/assize/pull/257): the elected Auditor now differs from both the Builder's model and the Reviewer's.
- **NetHack and L2.** NetHack was never bound. The layer ended at the seal on 27 October, and NetHack went to the successor.
- **The scientific claim at L5.** Never tested. The court froze at L2, one rung below the first agent and three below the layer that carried the claim, so the ablation was never run. The successor, [jack](/posts/the-science-was-done/), states its own claims.
- **The Vizier's short list of acts it may take alone.** It never took one.
- **"The next posts take the pieces in turn."** None of them was written. This is the only one.
- **"The seam I would attack first": sessions sharing machines and an operating-system user.** The bypass the retrospective records came from elsewhere: counsel, acting through my own GitHub token, which left no entry of its own.

The miss that matters is the price. This post quotes a line of fifteen items and a 3.3-hour median, and asks whether that is the right quantity as if the answer would be a refinement. Classifying every act of mine in GitHub's record later gave [121 repairs for 24 merges](/posts/assize-at-the-seal/#what-it-cost) from 10 to 13 October, 36 of the repairs on the day this was written, and twenty of the merges changed the court's own procedure. The line I quoted cannot tell a decision from a repair.
