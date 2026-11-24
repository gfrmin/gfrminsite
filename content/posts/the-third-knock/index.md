---
title: "The Gate That Opens on the Third Knock"
subtitle: "The team that builds Claude Code has published how it checks what Claude writes. Most of it is law I had already put on a signed log. Where we differ, they keep one of my own rules better than I do, and they leave out two things I would not build without."
description: "A reply to Anthropic's account of how the Claude Code team verifies agent-written code. Where it matches the charter of jack clause for clause, why a commit gate that yields is nearer my own fourth maxim than my court is, and what it leaves out: a second family of judge, a probability on the verdict, and a count of what the human costs."
author: "Guy Freeman"
drafted_with: claude
date: 2026-11-24
draft: false
categories: [essays, ai, decision-theory]
series: [coding-agents]
series_order: 7
linkTitle: "Part 7: The Third Knock"
---

On 16 November the Claude developer blog published [How the Claude Code team thinks about verification](https://claude.dev/blog/how-the-claude-code-team-thinks-about-verification/), by Addy Osmani. It reports that about nine-tenths of that team's code is now written and reviewed by Claude, and it sets out what the team does so that nobody has to read every diff. Read it before you read me on it.

This series has asked one question since April. If you did not write the code and cannot read all of it, what is left to trust? I have answered it six times from the outside, with one guard after another and, since October, with a court. This is the answer from the inside, from the people who build the agent the rest of us are trying to govern.

My verdict has three parts. Most of what they arrived at is the law in the charter of [jack](https://github.com/renavondata/jack), reached from the other direction and for no reason except that it ships code. On one point they follow that charter better than I do. On two they have left out what I would not build without. The scoreboard comes first, though. They ship. jack has not promoted a layer since 1 November.

## The same law, found from the other side

The sentence the post turns on is this: "If a change can modify the check that judges it, the check is broken." So the reviewer's rules are read from the base branch and never from the change under review.

The first maxim of jack's charter, which I signed on 14 October, reads: "The checker that decides an entry's validity is fixed before the entry exists and cannot be changed by it." Its rule of adjudication says the checker "runs from trunk, never from the proposal". Two texts, a month apart, saying one thing.

I would like to call that independent confirmation, and it is not quite. The charter was drafted by counsel, which is a Claude session, and on the post's own figure Claude writes most of what that team ships. Agreement between witnesses with a common ancestor is worth less than it looks. I come back to that.

Nor did I get there by foresight. In assize, the court before jack, a pull request's checks ran that pull request's own harness until the middle of October. The accused wrote its own test, and it took a repair of mine to notice.

The agreement does not stop at one sentence. Set the team's practices beside the charter and most of them pair off.

| What the team does | What jack's charter says | The older source |
| --- | --- | --- |
| Reads the reviewer's rules from the base branch, never from the change | The checker "runs from trunk, never from the proposal" (§3) | *Nemo iudex in causa sua*; Coke, 1610 |
| Admits a rule only if its trigger can be read off a diff | "Statutes are confined to decidable properties" (§3) | Rice, 1953 |
| Keeps, beside each rule, the incident that produced it | Primary rules "accrete as precedent", each from a witnessed case (§3) | Blackstone |
| Grades its reviewers on bugs that happened, with clean changes as the control | "Every rule is admitted with a witness that violates it and one that satisfies it" (§2) | Fuller, 1964 |
| Stamps every commit with how it was verified, the unverified ones included | "no party … acts except through entries that carry its identity" (§2) | Ostrom, 1990 |
| Prunes its rule files and tests as a routine | "Law should not outlive its necessity" (§3) | Jefferson to Madison, 1789 |
| Brings in a person when a check still fails after a set number of rounds | Every obligation "carries a deadline, and escalates when the deadline passes" (§2) | Habeas corpus, 1679 |

The right-hand column is why I do not think the pairing is luck. None of those sources is about software. Each says what any arrangement needs if one party's work is to be accepted by another who cannot inspect it. A team with no interest in jurisprudence and every interest in shipping has rebuilt Hart's three secondary rules. What counts as the rule is the file on the base branch. The rule changes when a person approves it, after agents have tried and failed to knock it down. And it is applied by a reviewer that did not write the change.

In two rows theirs is the better version. My mutants are text edits that I planted, so they test a check against the bugs I could imagine. Theirs are incidents, which nobody imagined. And my charter says that primary rules enter from witnessed cases, while jack's own index of rulings records that none has entered. Their checklist has thirty-nine.

## The third knock

The team has a gate on commits. In its enforcing mode it refuses a commit from a session that has run neither the review nor the verification step. Refuse the same session twice, and its next commit goes through. The post is candid about why: a session that cannot commit is a session that stalls, and the team does not pretend its tool is always right.

My first reaction was the reference monitor's. An enforcer that gives way when leaned on is a suggestion with a delay. The post itself observes that a flaky test teaches an agent to rerun instead of repair. A gate that opens on the third knock teaches the same lesson, and it is not even flaky about it.

My second reaction was to read my own fourth maxim. "Reversible acts are priced and scored, never blocked." Hard gates, it goes on, stand only before effects that cannot be undone. A commit on a branch can be undone. By my charter that gate should never have been a wall, and the team has in effect conceded the point. What makes their arrangement respectable is its other half: every commit is stamped with how it was verified, so the ones that walked through are on the record. The record is the control. The gate is a nudge in front of it.

I have the counter-example on my own log. On 18 November I vetoed a window of jack's that could no longer be promoted (seq 5879). The veto ended nothing. The charter named two ways for a window to end, its stated date and a promotion, and a veto was neither. The window would have held every one of its bars until 30 November. Ending it took an amendment to the charter, entered four days later (seq 7179), and a second veto two minutes after that (seq 7180). That is what a gate with no third knock costs, and the person it cost was me.

So on this they are nearer my charter than I am. What they have not done is the rest of the maxim: priced and scored. Two refusals is a price of a sort. But it is the same for a typo as for a migration, and it is paid in the agent's time, which is the cheap currency. The stamp could carry the price instead. Let the unverified commit through at the first knock, and make its stamp a forecast: the probability that this commit is later reverted or rejected, entered before anyone knows. The team already records the outcomes that would settle it.

## A judge from the author's family

The post advises against stacking reviewers. A second and dearer reviewer laid over the first is, it says, usually a worse buy than tuning the first. On stacking, my record agrees. The brief for jack's next window is in its sixth draft. Its first three were each read cold, and each failed. More than once a revision that added words to satisfy one reader gave the next more to fault. Readers in series are gates multiplied.

But the post's own best argument points past where it stops. It prefers property tests because their inputs are not shaped by the assumptions of whoever wrote the code. Apply that to the reviewer. If Claude writes the change and Claude reviews it, the reviewer shares the author's assumptions by construction. Tuning it against past incidents finds the blind spots that have already cost something, and only those. I could not find a word in the post about a reviewer from another family of model.

jack's answer is an election, which is a different shape from a stack. Its two checkers were written from the specification alone by two model families, one in Python and one in Go, and a disagreement between them halts the clerk and raises a writ to me. Its proposers are to be weighted by their scored record, so a reviewer is never laid over another. It competes beside the other and can lose.

I should say what that has cost. The election is the layer I have not reached. And the readers from the other family were dear enough that I ration them. Requisite variety has a bill too.

## A verdict without a probability

The team's reviewers return findings graded by severity, and the reviewers themselves are measured by recall on past incidents. Nowhere that I can find does anything in the loop say how sure it is.

That matters for the decision the whole post is about, which is when to spend a person. Their rule is a count: after three failed rounds, stop and fetch a human. assize would have been grateful for it. One of its reviews spent three rounds arguing over how a status file should cite a green run, while the code was green throughout.

But a count is the same for every change. Whether a person's minute is worth spending depends on what the change could break and on how likely the reviewer is to be wrong about it. That is a calculation with a probability in it, and it is the one I wrote about in [Think More, or Act Now](/posts/think-more-or-act-now/).

They are one field short of having it. A passing review is already a forecast that the change will stay clean. A revert is already its resolution. The team records both. Put a probability on the first and score it against the second under a proper rule. Then the reviewer has a calibration record, the threshold for fetching a person is computed instead of chosen, and the stamp from the last section has its price.

I can vouch for that much. jack's log held 7,542 entries when I wrote this, of which 2,970 are forecasts and 2,867 are resolutions. It is cheap and it is dull, and it is the one part of the court whose verdicts come from what then happened and not from a reader.

## Nobody is counting the human

The post's promise is about people. Without verification a person can mind one or two agents, and with it dozens or hundreds. Its closing picture moves the human from reading diffs to saying what done means and auditing the evidence. In jack that person is called the sovereign, and I recognise the job.

What I cannot find in the post is the sovereign's bill. People still take the escalations, approve each new rule, and write the checks for the code they own. Each is a claim on attention, and the post reports no measure of what they add up to.

I know what happens when nobody measures it, because assize's first constitution did not either. In four days of October that court took 121 repairs from me, five for every merge. Twenty of its twenty-four merges changed its own procedure and not the thing it was building. A verification layer grows by lessons. Each lesson is reasonable. The person approving them is the one resource nobody stamped.

jack counts my acts as decisions or repairs. Its liveness test is the share of work finished with no repair from me, against a rate fixed before the window opens. The first window of its current layer could not be promoted on that account: its seventh criterion allows no repair made off the log, and the evidence showed nine. I would rather it had passed. I would not rather have not known.

## What I am taking, and where I would like to be told I am wrong

Three things go from their post into jack, by the proper route, which is a brief and not an essay.

The first is that a rule should watch before it bites. Their gate has a mode that only logs what it would have blocked, so the false alarms are known before anyone is stopped. jack need not wait to find out. Its law is a fold over a log, so a new rule can be replayed over every entry that already exists. It demands this of one thing today: a change to the promotion evaluator is accepted only after it has been replayed against every commit of the record. That should be the standing rule for anything that refuses.

The second is triggers. Their checklist fires only the items whose trigger matches the diff, a handful for each change. My cold reads read everything every time, and the readers' bill is the result.

The third is the third knock, properly priced, for every act the fourth maxim says should never have been blocked.

Then the bets, which an essay in this series owes. If their revert rate holds flat while the share of code reviewed by the author's own family keeps rising, the second family is a cost without a benefit at this scale, and I have been paying it for nothing. If a team runs the yielding gate for a year and the commits that walked through are reverted no more often than the rest, the hatch is free, and my worry about what it teaches is wrong. And if jack reaches its agent with a change rule that is still a person reading prose, I will have built their system with more ceremony and less throughput.

That last is the question neither of us has answered. Their road from a miss to a rule ends at a person approving a pull request. So does mine. The amendment process is the one part of jack still built the old way: prose, one drafter, unscored. It is the right ground while people write most of the rules.

Their post says Claude now writes most of the code. When it writes most of the rules as well, the sentence we both started from applies one level up, and the check that can be modified by what it judges is the rulebook.

---

*The court is [jack](https://github.com/renavondata/jack), and the book about it is [A Court for Agents](/book/). The predecessor's bill is in [The Court That Tried Itself](/posts/assize-at-the-seal/). Figures from jack's log are at commit `86d5aff`.*
