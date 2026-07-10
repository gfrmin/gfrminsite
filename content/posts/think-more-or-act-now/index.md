---
title: "Think More, or Act Now"
subtitle: "Deciding how much to deliberate is just another decision --- and its regress has to terminate in the world's clock, not a threshold you tuned"
description: "Rational metareasoning made honest. In a Bayesian agent language, think-more-or-act-now is one argmax, priced by the world's impatience rather than a hard-coded budget. Plus the experiment that demonstrates it only partly: two of four rows terminate in the clock, and the essay says which two --- and why the other two do not."
author: "Guy Freeman"
date: 2026-07-10
draft: true
categories: [bayesian, ai, essays, decision-theory]
---

Ask an engineer how long an agent should deliberate before it commits, and the answer usually arrives as a number. A maximum iteration count. A step budget. A wall-clock timeout. The deliberation loop runs until the counter is spent, and then the agent acts on whatever it happens to hold. The number is so ordinary that it rarely registers as a decision at all. It looks like plumbing --- the `while` had to stop somewhere, and this is where.

But a cap on thinking is a claim about the world, made in the wrong place. Fix the budget at some number of steps and you have asserted, in advance and for every situation the agent will ever meet, that the step just past your cutoff is never worth its cost. That is a strong empirical statement about deadlines you have not yet faced, hard-coded as a constant. [The flagship essay in this series](/posts/make-it-unsayable/) describes a build gate that refuses to compile the engine if the word `throttle` appears anywhere in it, because a throttle is exactly this: a tuned scalar that stops the agent for reasons the mathematics did not supply. An iteration cap is a throttle wearing the costume of infrastructure. The agent is not deciding to stop thinking. The programmer decided, once, on its behalf, and wrote the decision into a place the agent cannot see or revise.

The alternative is to make the decision an actual decision --- to let the agent price its own thinking and stop when stopping wins, by the same rule it uses to choose anything else. This essay is about what it takes to do that honestly. It is also the most honest essay in the series, because the experiment at its centre demonstrates the claim only partly, and says so.

## Metareasoning is a decision, so make it one

The framework is old and has a name. Russell and Wefald called it rational metareasoning (1991): treat computations as actions in a meta-level decision problem, each valued by its expected improvement in the quality of the decision it informs. Thinking is neither free nor sacred; it is an action with a cost and an expected payoff, and you should do it exactly when the payoff beats the cost.

The usual way to build on that idea is to build a meta-level: a separate controller, sitting above the object-level solver, that watches it work and decides when to pull it off the problem. proplang does not do this, and the refusal is the whole point. There is no meta-level machinery. Run `condition` on another batch of evidence, enumerate deeper into the space of hypotheses, call the language-model prosthetic, act now --- these are all terms in one action space, valued by one net-value functional --- roughly \(E[\Delta\text{value} \mid \text{action}] - \text{cost}(\text{action})\) --- and selected by the same argmax that chooses ordinary domain actions. Thinking more and acting now are not on different tiers. They are options in a single list, and the agent ranks them together. Think more or act now is one argmax.

## The program that prices its own thinking

For that sentence to be more than a slogan, the verbs of inference have to be things a program can quote. In proplang they are: `push`, `cond`, and `argmax` are grammar terminals, not host functions the agent can only call blindly --- the [flagship essay](/posts/make-it-unsayable/) makes that case, and I will lean on it rather than re-run it here. Because the verbs are terminals, the agent can write a program whose options include its own deliberations. The central worked example is a policy that does precisely that:

```
('argmax', 'METAACTS',
  ('if', ('call', 'is_act', 'option'),
         ('call', 'v_act',   'B'),
         ('call', 'v_think', 'B', ('get', 'price'))))
```

Read it as a choice over meta-actions. For each option, if it is an act, score it by the value of acting now (`v_act`). Otherwise it is a deliberation, and score it by the value of thinking (`v_think`) --- with the world's `price` passed in as an argument, because thinking is going to cost something. Through the standard library, `v_think` expands into pure verb composition: for each outcome of the next batch of evidence, condition a fresh copy of the current belief on that outcome, push the value of the best act under the resulting posterior out to the reals, average those values under the predictive distribution over outcomes, and then subtract the world's price of the tick. What comes back is the expected value of conditioning once more and then acting, net of what the delay costs. The argmax ranges over that quantity and over acting now, side by side. Condition again, then decide is a sentence the agent utters about itself, and it competes on equal terms with act now.

## The clock, not the threshold

Now the hard question. Every account of when to stop deliberating has to say where the regress bottoms out, and most of them cheat. They bottom out in a threshold: keep thinking until the expected gain drops below \(\epsilon\), for some \(\epsilon\) the designer picks. But \(\epsilon\) is the throttle again, relocated. A scalar that stops the agent thinking is smuggled content --- a designer's belief about the value of time, hard-coded where the agent cannot argue with it --- and smuggling content is the precise failure this whole project exists to prevent.

So the termination cannot be a number sitting inside the agent. It has to be physical. The world interrupts. Events arrive on their own schedule. Opportunity accrues to whoever acts and drains from whoever waits. An anytime computation is cut off from below not because a counter expired but because waiting has a price, and the price is set by the environment, not the designer. The agent thinks exactly as long as thinking beats acting --- and beats is well-defined precisely because the world, by charging for delay, has made the two commensurable. There is no separate rule for how long to think. There is only the same argmax, run against a cost the world supplies.

This is also what defuses the obvious infinite regress. If deciding how much to think is itself a decision, must the agent decide how much to think about how much to think, and so on up the tower? In principle yes, and each level is a genuine meta-action with its own cost. But each level is also more expensive than the last and buys less, so the argmax at some rung prefers to stop climbing and act --- not because a designer capped the tower, but because compute is dear and the answers thin out. The tower is finite because compute is dear and the world is impatient.

That gives the design its acceptance test, and it is a demanding one. Given a hard problem and a short deadline, the agent must choose to think less and act sooner --- and you must be unable to point to the line of code that made it lazy. If you can point to the throttle, it is a shortcut; remove it and try again. The exercise succeeds when there is nowhere left to point.

## The lazy genius

Here is the experiment that tried to clear that bar. The agent is estimating the bias of a coin. The true bias is \(\theta_\text{true} = 0.52\) --- deliberately near fair, so that telling heads from tails is genuinely hard and more evidence genuinely helps. Evidence arrives in batches of three, drawn from a buffer of thirty-six observations. The decision loop is, in full, `while argmax([act, think]) == think`. There is no iteration cap and no threshold constant anywhere in it. The agent keeps thinking for exactly as long as the argmax prefers thinking.

Then the same agent, running the same code, is dropped into four different worlds. The worlds differ in one thing only: the price charged per tick of delay. Count the thinking ticks the agent takes before it acts:

| Per-tick price | Thinking ticks before acting |
| --- | --- |
| 0.3 | 1 |
| 0.05 | 3 |
| 0.005 | 12 |
| 0 | 12 |

Make delay expensive and the agent turns decisive, acting after a single tick. Make it cheap and the agent grows patient, thinking a dozen times before it commits. Nobody edited the agent between rows. The only thing that changed was the world's impatience, and the agent's diligence tracked it. The regress terminated in the clock.

## The two rows that don't

And now the part I refuse to bury, because it is the reason to trust the rest. The clock terminated the regress in two of those four rows. Not four. Two.

Look again at the bottom of the table. At a price of 0.005 the agent takes twelve ticks; at a price of zero it also takes twelve. Those two numbers are equal, and they are equal for a reason that has nothing to do with the clock: the agent ran out of evidence. Twelve batches of three is thirty-six observations --- the whole buffer. The agent did not stop because deliberating had stopped being worth it. It stopped because there was nothing left to condition on. The clock did not bite; the buffer did.

The zero-price row is worse, and more instructive. At a price of zero, thinking is free, and an agent that stops deliberating when deliberating costs nothing demands an explanation. The explanation is a known bias of the cheap approximation the agent uses to value thinking. With a linear utility, the myopic value of information --- the worth of one more batch, assuming you will then act --- is exactly zero whenever no single next batch could change which act comes out on top. When the decision is already locked against any one further batch, one-step lookahead sees no reason to look, even though the clock is charging nothing. So the agent can stop when thinking is free, for the wrong reason. This is not a defect concealed in the implementation. The surrogate is a recorded simplification, not a hidden one --- written down where the agent's arithmetic is defined, precisely so that a reader knows not to over-read the table.

So the honest scoreboard reads: two rows genuinely clock-bound, two rows buffer-bound. The experiment demonstrates that the regress can terminate in the clock. It does not yet demonstrate that it always does, and the two rows where it doesn't are labelled as such. A later increment --- making the depth of enumeration itself a rung the agent must pay for, rather than a fixed buffer it merely drains --- partly repairs the gap, by giving the clock something to bite on after the evidence is exhausted. Partly. The claim earns exactly the two rows it earns, and no more.

## One currency, two fidelities

There is a second thing the agent must decide how much of, and it exposes a subtler structure in the same idea. A Bayesian agent whose hypotheses are programs has two ways to improve its stock of hypotheses, and they feel like different activities. It can compress: re-describe the hypotheses it already holds more compactly, promoting a subprogram it keeps reaching for into a nonterminal of its grammar. Or it can explore: change what is sayable at all, adding a feature or refining a threshold so that hypotheses it could not previously express come into range.

These look like two currencies. They are one. Both moves are priced in the same unit --- change in log-evidence, \(\Delta\) log-evidence --- and they differ only in where they act and how expensive the pricing is.

Compression acts through the prior. Promoting a frequent subprogram to a nonterminal shortens the description of every hypothesis that uses it, which reshuffles the prior mass; it does not change which hypotheses exist. Because nothing new becomes sayable, its value can be read off cheaply --- at depth one, from the grammar and a count of how often each subprogram appears, with no re-conditioning required. On a world that has shifted under the agent, the cheap drift sentence (four bits to say) holds the posterior against the more expensive change-point sentences (about sixteen bits) until the evidence gap between them exceeds the prior gap --- a competition settled entirely in description lengths.

Exploration acts through the likelihood. Adding a feature changes what the agent can say about how the world produces data, and its value cannot be seen from the prior at all. It has to be measured, by re-enumerating hypotheses and re-conditioning them against exactly the places the current model mispredicts. In the reference implementation this is priced by the myopic preposterior surrogate --- Russell and Wefald's expected best value after conditioning, minus cost --- the cheap fidelity, carrying the same linear-utility blind spot the coin experiment exposed. The expensive fidelity is the exact expected \(\Delta\) log-evidence over policies, and pricing that exactly is a named open problem, not something the project claims to have solved.

So compression and exploration are not two mechanisms. They are one currency --- \(\Delta\) log-evidence --- at two fidelities: a cheap prior-only surrogate and an expensive re-conditioned lookahead. And which fidelity to use is not a fixed policy either. It is itself an expected-utility decision, priced and chosen by the same argmax as everything above it.

This is the same lesson the [predecessor essay on the three types](/posts/three-types/) drew about value of information: VOI is not a primitive verb the language hands you. It is the expected utility of observe-then-act minus the expected utility of act-now, a composition of push, cond, and argmax. Ask the user is the same kind of thing --- not a special mechanism but an ordinary action whose payoff routes through the world, and which wins the argmax exactly when the belief is uncertain enough to make the interruption worth its cost. Nothing about deliberation, information-gathering, or self-interruption needs its own machinery. It all falls out of pricing actions and taking the max.

## The clock as a residue

There is a boundary all of this runs into, and it deserves to be named as plainly as the two failed rows. The clock is not something the language contains. It is one of a small number of residues the project admits it cannot dissolve --- irreducible things the grammar leans on but cannot itself express. The alphabet is one, handled in [its own essay](/posts/the-alphabet-is-the-prior/); the pointer --- the designation of *whose* utility the agent is serving, which cannot be inferred from behaviour without first being pointed at a principal --- is another, which the project treats at length and these essays only gesture at. The clock is the third. It is not a scalar you set; it is a rhythm the environment imposes. The metareasoning regress terminates in it by design, which is exactly why the design cannot also own it.

And there is a limit past even that. The agent can quote its own deliberations, price them, and choose among them --- but it cannot say its own executor. The host loop that takes the chosen action, fires it into the world, and advances the clock is machinery the language cannot see. The argmax can rank act now against condition again; it cannot reach down and describe the hand that carries out the winner, or the tick that follows. That is the same reflexive-closure limit the flagship essay names about the verbs themselves --- the agent's self-model is real but not total --- and it is better stated than hidden.

The bad answer to when should it stop thinking was a number in the code. The good answer is no number at all: an argmax over acting and deliberating, priced by a cost the world supplies, terminating when the world's impatience makes further thought a losing move. The experiment shows that answer working --- in two rows of four, with the other two honestly marked buffer-bound, and one of those resting on an approximation whose blind spot is written down where anyone can find it. That is less than a proof and more than a promise. The agent thinks exactly as long as thinking beats acting, the world decides what beats means, and where the mechanism does not yet reach, the map says so.
