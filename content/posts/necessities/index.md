---
title: "Fifteen Things a Self-Modifying Agent Cannot Do Without"
subtitle: "The core underneath an agent that rewrites itself is not a free design. Fifteen old results each force something into it — and each thing forced is a line of code, a clause of a charter, or an entry on a log you can check."
description: "Rice, Löb, Dawid, proper scores, Goodhart, Ville, Bahadur–Savage, Alpern–Schneider, Conant–Ashby, Hart, Fuller, Anderson, Thompson, Arrow–Fisher, Gall: what each forbids or forces for an agent allowed to change itself, the mechanism in jack's core that discharges it, and what would show it misapplied. An essay from A Court for Agents."
author: "Guy Freeman"
date: 2026-11-03
draft: false
categories: [essays, ai, bayesian, decision-theory]
series: [a-court-for-agents]
series_order: 2
---

The [founding note](/posts/the-science-was-done/) for [jack](https://github.com/renavondata/jack) argued that nearly everything underneath a self-improving agent was finished decades ago, and that what is new is only the economy. This essay makes the stronger claim the book that follows rests on: that the pieces are not merely available but *forced*. Each component of jack's core is there because a result says that without it the agent cannot be evaluated, tested, governed or stopped. Remove one and you have not simplified the design; you have made an error that one of these results names.

The results are of three kinds, and the difference matters. Some are theorems about computation and probability: Rice, Löb, Ville, Bahadur–Savage, Alpern–Schneider, the propriety of the log score. Some are necessity results of control that hold under stated and rather strong conditions: Conant–Ashby, requisite variety. And some are not theorems at all but principles and regularities with a long record of failures behind them: Goodhart, Hart, Fuller, Anderson, Thompson, Gall. I say "theorem" only of the first kind, and each row below is marked.

"Necessary" means one thing throughout. A mechanism is necessary if removing it leaves a stated result unmet — the agent inspected where it can only be run, trusted where it can only be bet on, timed where it can only be counted, governed by a rule that cannot guide conduct. The claim is never that jack's mechanism is the only one that could discharge the result. It is that *some* mechanism must, that jack's is one, and that you can find it: in 450 lines of kernel, in a numbered clause of the charter, or at a numbered entry of the log. Everything below gives you the place to look.

I take each result in four parts: what it says, with its hypotheses; what it forbids or forces; the mechanism; and what would show it misapplied. The last part matters most. A book about pre-registered falsifiers should pre-register its own. One of the fifteen fails its own test on the record, and I say which.

## Evaluation: why the change cannot be inspected

**Rice (1953)** (theorem). In a Turing-complete language, every non-trivial property of what a program *does* — of the function it computes, not of its text — is undecidable. An agent that can write the next version of itself works in such a language, so "is this change an improvement?" has no procedure that inspects the change; and since improvement is a property of the program in the world, not of the program, it is settled by running the change and scoring the outcome.

jack's charter confines its statutes to decidable properties on exactly this ground, and separates validity from merit in the same clause: questions of merit "are forecasts, scored when the world resolves them" (CHARTER §3). Every check the kernel makes is syntactic and terminates — a canonical serialisation, a hash, a signature, a type in a list of powers (SPEC §8).

*Misapplied if* anyone proposes that the judge check whether a change is good, or treats a green test run as evidence that the work was worth anything. The predecessor court spent three review rounds on how a status file cited a green run while the code was green throughout; that is recorded as a failure (CHARTER §1, F4).

One honest limit: the first agent's seed language may be restricted enough that some of its properties are decidable. If so, this row is weaker for that agent than stated — until it first extends its own language, which is the point of it.

**Löb (1955), Gödel (1931), and the grain of truth** (theorems; the design rule they force is mine). A consistent theory strong enough for arithmetic cannot prove its own consistency (Gödel), and cannot prove "whatever I prove is true" for any sentence it does not already prove (Löb). Yudkowsky and Herreshoff (2013) apply this to an agent that acts only on proofs of safety: to license a successor whose proof system is as strong as its own, it would need exactly that reflection principle, so a sound agent can license only weaker successors, and trust strictly decreases down the chain.

The Bayesian form of the same wall is the grain of truth. Kalai and Lehrer (1993) showed that Bayesian players converge to equilibrium play when each prior puts positive mass on the truth about the others. Nachbar (1997, 2005) showed that in many repeated games a class of strategies neutral enough to serve as a prior — independent of payoffs, symmetric, admitting pure strategies — cannot both be learned on and contain the players' own best responses; Foster and Young (2001) found a like obstruction for players uncertain of one another's payoffs. Leike, Taylor and Fallenstein (2016) gave the general solution only by stepping outside computation, with policies computable relative to a reflective oracle. So a computable self-model has no guarantee of a grain of truth, and without one the convergence theorem says nothing.

The rule this forces: the evaluation rule is not something the agent improves. In jack, reach is a matter of keys. The trusted base — the kernel, the second checker, the judge, the workflows, the specification — changes only by a `push` entry naming its digest, and the `push` power sits on one key, the sovereign's (log seqs 1 and 33). Builders, reviewers, counsel and the merging herald hold `proposal`, `forecast`, `resolution`, `merge`; none holds `push`, `amend` or `key`. The charter closes the loop on the agent itself: "whatever counsel and builders are forbidden is what the agent of C3 is forbidden, by the same judge, keys and amendment path" (A2.10).

*Misapplied if* the book claims more than the rule — that jack "solves" the Löbian obstacle, or that the court is provably sound. It is neither. The court's soundness is bet on, not proved; that is the subject of another essay.

**Dawid (1984)** (a principle of evaluation, with theorems built on it). A forecaster is judged on nothing but the forecasts it actually issued and the outcomes that then occurred.

In jack this is a file format (SPEC §§5–8):

- a `forecast` entry carries a probability as an integer from 1 to 999 per mille and a deadline;
- a `resolution` names it, records 0 or 1, and cites hashed evidence;
- timestamps may not decrease, so the probability is fixed at its position;
- a second resolution is refused;
- a resolution by the forecaster's own principal is refused as `self_judged`.

*Misapplied if* a score ever uses a probability fixed after its event. The record already names the two ways: a forecast timestamped at or after the event's cutoff is listed as `rigged` and not used — there are three on the log, seqs 288–290 — and a later forecast of the same event by the same principal is listed as a `revision`; the first stands.

**Proper scores (Good 1952; Gneiting and Raftery 2007)** (theorems). Only a strictly proper score makes reporting your belief the unique best move; the logarithmic score is one, and it is the one under which a Bayes mixture over \(K\) forecasters loses at most \(\ln K\) more than the best of them — a telescoping identity that holds for the log score and no other.

jack scores log-loss, per mille, against a base-rate forecaster that is Laplace's rule over the resolved prefix of the forecast's type, and its aggregate is the Bayes mixture with the uniform prior and no learning rate: "η = 1 is the telescoping identity, the uniform prior the minimax choice for the ln K bound" (BRIEF-C2a).

*Misapplied if* a score that is not strictly proper, or a transformation that breaks propriety, enters a promotion criterion or an election.

**Goodhart (1975)** (a regularity, not a theorem). In Goodhart's words, any observed statistical regularity will tend to collapse once pressure is placed upon it for control purposes; Strathern's later gloss is the familiar one, that a measure which becomes a target ceases to be a good measure.

It need not collapse if the measured party cannot move it except by doing the thing it measures. Two conditions give that: the score is proper, and the outcomes come from processes the party does not control. A third follows for the court: its own statistics can be manufactured by producing more court, so it counts procedure against object and stops above assize's ratio of 5 : 1 (A3.4).

Outcomes in jack come from a results page saved and hashed, or a catalogue's modification time; the resolver is never the forecaster; and the sovereign's own acts are typed by entry type and signing key, "so the split is mechanical and fixed in advance, not judged afterwards" (CHARTER §7).

The first window of the ledger ran at 127 procedure entries to 32 about the world; the clerk's window ran at 67 to 82 — the first in which the court wrote more about the world than about itself (`tools/status.py` on the log at those windows' exit prefixes, seqs 188 and 337).

*Misapplied if* a promotion test counts something a proposer can produce without doing the work.

## Testing: tests you may look at whenever you like

**Ville (1939); Shafer and Vovk; Ramdas et al.** (theorem). For a non-negative supermartingale with unit start, the probability that it ever reaches \(c\) is at most \(1/c\) — at every stopping time, including the moment someone decided to look.

The operator of this system is one person who looks when he wakes. So every promotion test is a bet whose wealth is the evidence, 20 is a rejection at \(\alpha = 0.05\) whenever it is seen, and the only discipline is that each stake be decided before the outcome it bets on.

jack's liveness statistic is \(E_t = \prod_i (1 + \lambda_i (Y_i - p_0))\) with the stake a Laplace function of the prefix and strictly below \(1/p_0\) (A4.3); its value statistic is a bet on a bounded difference of log-losses (A4.4); the wealth is never reset across windows (A4.1); and a window ends at the earlier of its stated end and the sovereign's `promote`, which may be entered only once every criterion holds (A5).

The rule has already bitten: the clerk's window carried \(E\) to 214358881/8398080 ≈ 25.5 over nine items in a day and closed there, with almost thirteen of its fourteen days unused (seq 337).

*Misapplied if* a stake is set with knowledge of its outcome, the null is estimated from the window it judges, or the wealth is reset — which is \(k\) draws at one bound, and is the defect that forced amendment A4.

**Bahadur and Savage (1956)** (theorem). In the family of all distributions with a finite mean, no test of the mean has power above its size. The quantities an operator most wants to see fall — minutes, dollars, repairs per merge — are unbounded, and no procedure can certify that their mean is small.

So jack tests only bounded outcomes — an item completed without repair, a log-loss difference bounded by \(\ln 999\) — and reports the rest as numbers, never as evidence (CHARTER §6).

*Misapplied if* anyone proposes "\(E \ge 20\) on mean latency".

**Alpern and Schneider (1985)** (theorem). Every property is the intersection of a safety property, refutable by a finite prefix, and a liveness property, which no finite prefix refutes.

That nothing invalid was ever admitted is safety, and it is checked by replay: both checkers — the kernel and a second one written independently — run over the real log on every push, and over every proposal's whole log before it can merge. That the two checkers agree with each other is a separate claim, about the specification rather than the log, and is tested on seeded logs: 100,000 of them, 636,392 prefixes, no disagreement in the run of record.

That obligations do not rot is liveness: it can only be given a deadline and tested statistically, which is what the clerk's writs and the \(E\)-process above do.

*Misapplied if* a report claims liveness from a replay or safety from a statistic.

## Control: what the governor must contain

**Conant and Ashby (1970); Ashby (1956)** (necessity results of control, under conditions). A regulator that is optimal *and no more complex than it need be* is a model of the system it regulates: it acts on a representation of that system sufficient to determine the outcome, and anything it acts on outside that representation is redundant or wrong.

Requisite variety bounds what any regulator can do: the variety of outcomes is at least the variety of the disturbances less the regulator's own, \(V(Z) \ge V(D) - V(R)\), so a regulator poorer in variety than what it faces cannot hold the outcome in bounds.

jack's state is a fold of the law over the log — head, keys, charter, trusted base, forecasts and which are resolved — and the clerk derives every obligation from that state and the clock, which enters only as an argument; the kernel never reads one. The judge's grounds are "stated over powers and paths and never over a party's name" (A2.3), the election rule is "an entrant, not law" (CHARTER §5), and the proposers are sessions of more than one model family.

*Misapplied if* an obligation lives outside the record. Assize's stalls were found by a human watching a phone; jack's own four forecasts expired undischarged in the ledger's first window while the clerk was still in counsel's head (seqs 45–47, 56). That is the clerk's forcing witness.

## Law: the smallest thing that can bind

**Hart (1961)** (a jurisprudential analysis, not a theorem). A legal system is primary rules plus three secondary ones — recognition, change, adjudication — and lacks one of three answers without any of them.

jack's zeroth layer was cut to exactly those: a valid entry; a `key` entry, an `amend` preceded by a `transmute` and in force from a later height, a `push` naming a digest; a judge that runs trunk's kernel over the proposal's entries as data. The kernel holding all three is 450 lines (`tools/count_kernel.py`). No primary rule has yet been needed, and the charter says that if none is by the end of C2, "§12's thesis that three secondary rules suffice is on trial" (A2.1).

*Misapplied if* a rule of conduct is written into the kernel in advance of a case.

**Fuller (1964)** (a principle, with a long record). Eight ways to fail to make law, each a check.

Prospectivity is the fold: the keys that verify an entry are those before its own effect, so a key declared at \(i\) does not sign \(i\) and a revocation never reaches back. Possibility of compliance: the kernel refuses a public key no one could be the sole holder of, and a `key` entry that would leave no key able to declare keys.

Congruence — the declared rule is the applied rule — is the principle every prompt-based harness fails, because the model that reads the rule is the party it binds; jack's enforcement map records row by row whether a principle is enforced by code or by hand, and the clerk's window required the rows it moved to read `code`.

One thing in the founding note went further than the record: the rule that every rule is admitted with a witness that violates it and one that satisfies it is written in the charter and waits for the first primary rule. It is law-in-waiting, not kernel.

*Misapplied if* a rule binds an entry that preceded it, or the declared and enforced rules differ.

## Enforcement: code at a seam

**Anderson (1972); Saltzer and Schroeder (1975)** (design principles). The reference monitor is always invoked, tamper-proof and small enough to verify; authority is a reference held, not a rule obeyed.

Every proposal is judged by trunk's checkers in a workflow that comes from trunk; the trusted base is five paths compared by content, so a rename or a symbolic link under them is refused like an edit; a checker that cannot decide — a crash, a timeout — is treated as a refusal; and the herald's key holds `merge` alone, so the process that merges green proposals can do nothing else — every one of the 85 entries it had signed since that key was declared, at the commit this essay cites, is a `merge` (seq 201 onward).

*Misapplied if* the accused supplies its own test. Assize's F1 — a pull request's checks ran the pull request's own harness — is the witness, and `judge_from_proposal` is the pin.

**Thompson (1984); Wheeler (2005)** (an argument with a construction, and a countermeasure). One checker is evidence of nothing; two independent lineages that agree are evidence of the specification.

jack's second checker is in Go, by sessions of another model family that read the specification and the vectors and nothing else; the differential compares the two on every proper prefix and counts silence as disagreement.

*Misapplied if* the second checker is written with sight of the first, or the comparison is on whole logs only — a checker wrong only on a prefix would pass, and the pin `whole_log_only` exists for that.

## Irreversibility and growth

**Arrow and Fisher (1974)** (theorem of decision under uncertainty). An irreversible act carries an extra cost — the value of the information waiting would bring — and a reversible one carries none, so a gate before it buys nothing.

Hard gates stand only before the irreversible: the sovereign's verbs are `genesis`, `key`, `amend`, `push`, `decision`, and the last key able to declare keys cannot be revoked. Everything reversible is priced: a refused proposal costs resubmission, and a failed window is followed and never patched.

*Misapplied if* a hard gate stands before a reversible act or none before an irreversible one — assize managed both at once, with force-push ungated until 13 October while bookkeeping on a status file blocked merges (CHARTER §1, F5).

And jack fails this row's test in one place. The code cap is a budget, reversible by its nature and entering no score, yet it lives in the trusted base and is raised by a `push` (seqs 197 and 367); the weekly budget is set by a `decision` (seq 50).

The gate is drawn by path and by verb, not act by act, so reversible content behind a hard verb waits for the sovereign. That is a gate the result does not ask for. Its cost is small — two pushes and a decision in a week — and the alternative would be a judge that decides which changes to the trusted base are reversible, which is the inspection Rice forbids; but it is a cost, and the record shows it.

**Gall (1977); Hayek (1973)** (a regularity, not a theorem). A working complex system is invariably found to have evolved from a working simple one. A base rate, and my own history is seven draws from it.

jack is built in layers, each promoted at a crossing before the next begins, with rules of conduct entering only from cases. The cost is serial windows, and it is paid: one proposal, to prepare the agent layer before the layers below had crossed, was withdrawn on exactly this ground.

## What this adds up to

The law is minimal in a definite sense: it contains only mechanisms that discharge one of the results above, and constants that carry a proof or were pre-stated before the window they bound — \(\ln K\), \(1/\alpha = 20\), stakes derived from the prefix, a grid, a cap, a null committed in advance. Everything else — every model, every prior finer than uniform, every base rate finer than a type, every threshold, every model of what I would say — is an entrant that stands for election and can lose. The test of minimality is mechanical: a mechanism in the law with no row above is an entrant installed as law; two mechanisms for one row is one too many.

What it does not add up to is sufficiency, and the book does not claim it except by construction of its falsifiers, which the charter pre-stated: the kernel outgrowing what a person can read; a liveness window failing against the predecessor's baseline; repairs falling only because acts were re-typed; procedure outgrowing object. And the one sense in which it is optimal is Wald's and narrow: every discretionary choice the court makes about itself is a bet with a stated probability, scored, so its decision procedure cannot be dominated. A court that chose otherwise would be.

**What would show this wrong.** A "misapplied if" clause firing on the record — one already has, in the Arrow–Fisher row, and the next may not be so cheap.

A result overstated — Conant–Ashby read as more than it proves, Löb read as a theorem about jack rather than a rule it obeys, Rice applied to a language too weak for it; the hypotheses are stated so a reader can check. A necessity with two mechanisms, or a mechanism with no necessity. And the one that would cut deepest: a court built without one of these rows that has run longer than jack, at a lower price to its operator, on a world that charges. I know of none, and the predecessors are seven attempts to build one.

---

*This is Appendix A of* A Court for Agents *compressed. The appendix, with every number's provenance and the hypotheses of each result in full, is in [the book](/book/app-a-the-necessities.html); its source is [gfrmin/agent-court](https://github.com/gfrmin/agent-court). Seqs refer to entries of jack's `log.jsonl` at commit [`6b800e14`](https://github.com/renavondata/jack/tree/6b800e14fc80eaf22137de6aa739a483c5a7f552); clause numbers to `CHARTER.md` and `SPEC.md` at the same commit, in [renavondata/jack](https://github.com/renavondata/jack).*
