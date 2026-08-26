---
title: "The Alphabet Is the Prior"
subtitle: "Minimality as a correctness property, and the executed deletion audit that proves it"
description: "In a language where hypotheses are programs, description length is the prior — so every terminal you admit is a bit charged against every belief. Minimality stops being taste and becomes correctness, provable only by an audit that tries to delete each word and measures what capability leaves with it. The full accounting, including the one terminal that failed its own proof and was kept in the open."
author: "Guy Freeman"
date: 2026-07-14
series: [proplang]
series_order: 2
categories: [bayesian, ai, essays, decision-theory]
---

The [previous essay](/posts/make-it-unsayable/) in this series ended on an identity and left most of the bill unpaid. The identity: in a Bayesian agent language, **the alphabet is the prior**. The agent's hypotheses are programs. Its prior over a hypothesis is the description length of that program under the grammar --- Solomonoff's construction, in which a program of \(k\) bits receives prior probability \(2^{-k}\). This is not one prior among many. It is the unique prior that dominates every computable prior up to a multiplicative constant, which is as close to "the right answer" as inductive inference gets. And the length of a program is counted in the terminals of the language. So every terminal you admit into the alphabet is one bit charged against every hypothesis that uses it.

The consequence is the thesis of this essay, and it is not a matter of taste. An extra terminal is not a blemish on an otherwise clean design. It is a defect in the design's most important property. A bloated language is not merely inelegant --- it is a mis-specified inductive bias, a thumb on the scale of what the agent will come to believe, paid for out of the prior's pocket. This is the move a type system cannot make. Rust does not object to a redundant enum variant; your program is a little noisier and no less correct. Here the vocabulary *is* the belief, so a spare word bends the belief. Minimality is a correctness property.

That is the claim. A claim is not a proof, and the rest of this essay is about the only thing that converts "this language is minimal" from an assertion into a fact you can check: an executed deletion audit.

## You do not design the grammar. You corner it.

The method is cornering by deletion. Propose a kit of terminals. Then, one at a time, try to delete each element and ask a single question: *does a required capability leave with it --- one that would then have to be supplied by an external hand?* If yes, the terminal stays. If no, it goes, because it was content masquerading as vocabulary, stealing bits from the prior to inject an answer you were not entitled to inject.

The pleasing consequence of running this discipline to its end is that the language is never really *designed*. It is cornered --- reduced until it cannot be made smaller. Design implies choices, and choices are exactly what the method is meant to burn off. If your final grammar feels like a set of choices, you have stopped too early. It should feel like the residue left after everything deletable has been deleted.

The grammar that survived this treatment is small. Four nouns --- Space, Prevision, Event, Kernel. Three verbs --- `push`, `cond`, `argmax`. Five structural terminals --- `if`, `>`, `get`, the priced constants `c`, and the named composition `call`. And, for the demonstration domain, two emission combinators, `bern` and `rw`. That is ten non-noun terminals, and every one of them is supposed to carry a deletion proof. The audit is the record of walking each proof in turn.

## Walking the audit

The proofs come in two kinds, and the difference matters. Some terminals prove themselves by *unutterability*: delete them and the evaluator raises on any use, so the crippled language cannot even express a program to score. That is the stronger result --- not "worse," but "no longer a language for the thing at all." The rest prove themselves *comparatively*: delete them and some family of sentences either goes degenerate, enumerating zero programs, or the surviving language predicts measurably worse. The measurements are in bits of log-loss on a demonstration world, and lower is better; each row compares the crippled language against the intact one.

| terminal | what leaves with it | cost |
| --- | --- | --- |
| `push` | prediction, expectation, expected utility, and marginal likelihood are *all* push; belief cannot touch the world or a value | unutterable |
| `argmax` | belief still moves, but nothing can choose; no exit from probability into action | unutterable |
| `cond` | belief never moves; the agent is a prior, forever | 160 vs 97 |
| `if` | conditional structure is unsayable; no change-point sentence exists | 103 vs 97 |
| `>` | `if` has no test; identical to deleting `if` | 103 vs 97 |
| `get` | programs cannot read the world; the closed loop opens, and closed-loop policies and time-indexed hypotheses vanish | 103 vs 97 |
| `c` | no sayable constants; the model fragment enumerates zero programs | 0 programs |
| `bern` | no emission vocabulary; nothing can assign likelihood to data | 0 programs |
| `rw` | drift is unsayable; on the drifting world | 211 vs 207 |
| `call` | only names compositions; deletion costs brevity, not capability | fails its proof |

A few of these deserve to be read aloud rather than left in a table. `cond` is the most violent: strip out conditioning and log-loss on the shifted world blows out from 97 bits to 160. That gap is the whole of learning, priced. Without `cond`, the agent has beliefs and never revises them; it is a prior with the update surgically removed, and the 63 bits are what the update was worth. `get` is subtler and, in a way, more interesting: it is the terminal by which a program reads a feature of the world, and deleting it does not merely cost accuracy (103 against 97) --- it opens the closed loop. Policies that condition on what they observe, and hypotheses indexed by time, both stop being expressible, because both require the program to look. And `push` and `argmax` do not appear with numbers at all, because there is no number to report: delete either and the language cannot state a program to measure. `push` because prediction, expectation, expected utility, and marginal likelihood are every one of them a push, so without it belief has no way to reach either the world or a value; `argmax` because belief can move all it likes and still nothing chooses, with no door out of probability into action.

The audit's summary line, for the comparative terminals, is one sentence: *every terminal's deletion costs a capability; nothing is content.* It is true of every row in the table but one.

## The prior is not an object

Before the exception, the structural point that makes the audit load-bearing rather than decorative. There is no `prior` in this system. No object named prior, no scoring function installed over the space of hypotheses, nothing you could open up and inspect. You write exactly three things: a grammar, a per-terminal bit-cost, and an enumeration order. From those three, the prior *emerges* as \(2^{-|\text{program}|}\) --- it is a fact about how long each program is, not a thing anyone declared. In the reference implementation it is constructed in exactly one place, a single normalizing constructor, and that constructor is the only prior-source in the system.

This is not an implementation detail; it is the same principle as minimality, one level up. Any explicit prior module --- any hand-written distribution over hypotheses parked beside the grammar --- would be content injected past the grammar, an answer smuggled in where the accounting cannot see it. It is exactly the sin of the spare terminal, wearing a different coat. And it is why the deletion audit is the entire game: since there is no prior object to interrogate, the only way to interrogate the prior is to interrogate the alphabet, terminal by terminal. The audit is not a supplement to inspecting the prior. It *is* inspecting the prior.

## Fineness is charged exactly once

A natural objection: surely a fine grid over a continuous parameter should carry a complexity penalty --- a model that can dial in a bias to three decimal places is doing more fitting than one that picks between "biased" and "fair." It should. And it already does, which is why adding a second penalty would be a bug.

A constant drawn from an \(n\)-point grid costs \(\log_2 n\) bits, spent simply to say *which* of the \(n\) points you mean. Description length already rises with grid fineness, automatically, because a finer grid needs more bits to index. So there must be no separate "fineness penalty" axis bolted on beside it; that would charge for the same thing twice, and double-charging is just mis-specification with good intentions. The single charge is visible in the worked prices. Under the demonstration grids --- a bias grid of 9 points, a change-time grid of 16, a drift grid of 8 --- a constant-world sentence like `bern(theta)` costs \(1 + 1 + 3.17 = 5.17\) bits, the \(3.17\) being \(\log_2 9\), the price of naming one of nine biases. A drift sentence `hmm(rho)` costs \(1 + 3 = 4\) bits, the \(3\) being \(\log_2 8\). A change-point sentence, which has to name a location and two regimes, runs to about \(16.3\) bits.

Those prices are not bookkeeping; they set the evidentiary toll a sentence has to pay before the data will let it win. On the shifted world, the change-point family is more expensive to say than the drift family, and the gap is real: the change-point account must out-predict the drift account by roughly 12 bits of accumulated evidence before it can take the posterior. And by \(t = 160\) it has --- the posterior lands at 0.64 on the exact change-point sentence. The heavier hypothesis was not forbidden and was not free. It paid its extra length in data, and then it won.

## The one that failed its own proof

Now the exception, because it is the most honest thing in the accounting and it should not be buried. `call` fails the deletion test.

`call` only names compositions. It is sugar. Delete it and you lose brevity --- every composition has to be inlined at its use site --- but you lose no capability whatsoever; nothing that could be said before becomes unsayable. By the audit's own rule, the rule that condemned any terminal buying no capability, `call` should be deleted, and a stricter minimalist would delete it and inline every composition. It is kept anyway, justified as the "stdlib boundary marker," the seam between the language and its library.

The point is not that keeping it is defensible. The point is what was done with the indefensibility. `call` is not quietly retained with the audit written up as a clean sweep. It is recorded, in the open, as a standing bug --- a terminal that survives on grounds the method explicitly rejects, logged as a debt rather than laundered into a feature. An external reviewer put it plainly: it is "a self-declared standing bug, and it is not a small one." That is the correct weight to give it. An audit that deletes nine terminals cleanly and hides the tenth is worth less than one that deletes nothing, keeps `call`, and prints the failure at the bottom of the ledger. The value of the whole exercise is that it distinguishes a language that ran the audit from a language that merely says it did, and the distinguishing evidence is precisely the terminal it could not justify and refused to pretend it had.

## The predecessor, in one number

It is worth one sharp comparison. Credence, the predecessor, froze four types and then opened the vocabulary: everything else, its constitution says, is a function over the four. That clause reads as modesty --- four primitives, build the rest --- but under "the alphabet is the prior" it is an open door. The exported alphabet has since grown to roughly 119 type-terminals out of 241 exported symbols, and not one of them was deletion-audited. Each is, by the identity, a bit charged against every hypothesis that touches it: 119 inductive biases nobody proved were earned. The constitution's open-vocabulary clause permits every last one. But permission is not a proof, and the upshot is that Credence's complexity prior is defined relative to a ~119-symbol alphabet, not a four-symbol one --- a prior whose shape nobody chose and nobody can now easily read. The [fuller comparison](/posts/make-it-unsayable/) is elsewhere; the single datum is enough here.

## The residue

I will not oversell the universality, because the project does not. The dominance result is real but not total. Change the reference machine --- the terminal encoding itself --- and the Solomonoff prior shifts by at most a multiplicative constant. "At most a constant" is a strong guarantee and a genuinely comforting one, but the constant is real and finite, not zero. The alphabet is chosen. Running the deletion audit to its end erodes the arbitrariness of that choice, terminal by justified terminal, until very little discretion is left. It never reaches none.

This is one of three irreducible residues the project names rather than hides --- the alphabet is one; the clock ([think more, or act now](/posts/think-more-or-act-now/)) and the pointer ([the agent that prefers to be wrong](/posts/alignment-axiom/)) are the other two, each with its own essay. The honest position on the alphabet is not that it is canonical. It is that it is small, printed in full, and every entry carries an executed deletion proof. That is a weaker claim than canonicity and a much more defensible one. And the single entry whose proof failed is printed in full too, labelled as a bug --- which is the only version of the claim worth trusting, because it is the only version that could have caught itself being wrong.
