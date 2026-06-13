---
title: "The Gate That Said No"
subtitle: "I built a decision-theoretic gate to decide whether to adopt my own work. It failed — at a strongly positive mean — and the failure pointed at the one number I can't honestly elicit by asking myself: how much a confident wrong answer actually costs me."
description: "A personal assistant's Ask path, done two ways: a monolithic model that always answers, and typed Bayesian machinery that abstains when it isn't sure. A decision-weighted adoption gate — a posterior over the utility difference, under uncertainty about my own utility and a finite question set — returned FAIL at P(Δ>0.05)=0.848 against a 0.90 bar, even though the typed machinery won by a mean of +2.23. The diagnosis: the typed machine answered one question in nine where the monolith answered all of them, and whether that reticence is worth it turns entirely on how much I hate being confidently wrong — a number two mechanical 'answer more' levers couldn't fake. So the gate moves only as that cost is learned from behaviour."
author: "Guy Freeman"
date: 2026-06-13
draft: true
categories: [essays, bayesian, ai, decision-theory]
---

I built a machine that decides whether to answer. Most of the time, it decides not to. Then I built a second machine to decide whether the first one was worth keeping, and it told me no. That no is the most useful thing I produced all cycle, and this post is about why.

The first machine is the Ask path of a personal assistant I am building over my own documents — a decade or so of contracts, letters, scans, medical notes, the [eleven million words](/posts/pkm-phase-1/) I have written about elsewhere. There are two honest ways to build such a thing. One is to hand a capable model the retrieved context and the question and let it write a fluent paragraph; it always answers, and it is wrong as often as the retrieval and its own confidence let it be. The other is to treat each answer as an inference: form a posterior over what the answer actually is, and then *decide* — report it, hedge it, ask a clarifying question, or abstain — by maximising expected utility. The second machine answers far less. When it is not sure, it says so, or says nothing.

The question I could not answer by taste was whether the second design is *better*. Better is not a property of an instrument; it is a property of a decision made with it, under an objective. So before adopting the typed machinery over the monolithic baseline I made myself build the thing that would tell me, honestly, whether to.

## Adoption is a decision, not a comparison

The tempting way to choose is to score both on a question set and take the higher mean. I have done versions of this for years and it quietly cheats, in two directions at once.

It cheats on the objective. A mean score weights every kind of mistake the same way, and I do not. A fluent, confident, wrong answer about something in my own files is not one unit of badness; it is the failure mode the whole project exists to avoid, because I will act on it precisely because it was confident. An abstention is a mild disappointment. If those two are scored alike, the comparison is answering a question I never asked.

And it cheats on the sample. Twenty-odd questions is not the truth; it is a draw from the truth. A mean over them comes with a standard error I usually ignore, and "A beat B by a bit on twenty questions" is frequently "A and B are indistinguishable and I got a lucky draw."

So the gate is built to refuse both cheats. It is a posterior over Δ, the expected-utility difference between the typed machinery and the monolith, and it is computed by composing the two things I am actually uncertain about. The first is my own utility: I do not know, to a number, how much I hate a confident wrong answer relative to how much I value a correct one, so I carry a distribution over it and sample. The second is the finite corpus: I do not get to see infinite questions, so I resample the ones I have with the Bayesian bootstrap — Dirichlet weights over the observed set, the proper expression of "this sample is a draw." Every Monte-Carlo draw picks a utility *and* a reweighting of the questions, scores both policies under it, and records the difference. The output is not a verdict; it is the shape of Δ under everything I do not know.

The decision rule on top of it is pre-committed and frozen before I look: adopt only if **P(Δ > δ) ≥ 0.90**, with the materiality margin δ and the level fixed blind, so that I cannot slide them to meet the result. This matters more than it sounds. The single most common way a measurement flatters the thing you built is that you decide what "passing" means *after* seeing how it did.

## It failed at 0.848

The gate ran, and it said no. P(Δ > 0.05) came out at 0.848, under the 0.90 bar.

The instructive part is the number it failed *with*. The mean of Δ was +2.23 — the typed machinery is better, clearly and by a comfortable margin, *on average*. A mean-score comparison would have waved it through without a second thought. The gate declined anyway, because a positive mean is not the question. The question is whether adopting beats not-adopting across the range of things I am unsure about, and across that range the interval on Δ still crosses zero often enough that more than one draw in ten prefers the monolith.

Why does it cross zero? Because of where the two machines disagree. On the questions that matter to the comparison — the ones where one machine answers and the other does not — the typed policy reported on about one in nine, where the monolith answered all of them. And the monolith, on exactly that disagreement set, was right less than half the time. So the entire comparison reduces to a single wager: is it better to answer everything and be wrong most of the time on the hard ones, or to answer one in nine and stay silent on the rest? That wager has no answer in the abstract. It has an answer only once you fix how bad a confident wrong answer is — and that is the number I had given the widest prior, because I had never measured it. The failure was not noise. It was the gate correctly reporting that the decision hinges on a quantity I had not earned the right to be sure about.

A timid policy that answers one question in nine did not get a free pass for being cautious. Caution is only worth it if wrongness is expensive, and the gate refused to assume that on my behalf.

## The wrong fix, twice

My first instinct was the engineer's instinct: the typed machine answers too rarely, so make it answer more, and the interval will lift off zero. I tried two mechanical levers to raise the answer rate, and the result of both is the actual lesson.

The first widened the candidate set the answerer was allowed to consider, on the theory that it was abstaining for lack of material. It did the opposite of helping: two questions the machine had been reporting on confidently — at credences around 0.85 — collapsed into abstentions, because the extra candidates were confusable near-misses and the posterior, correctly, spread out over them. Giving it more to be unsure about made it less sure. That is not a bug to be fixed; it is the posterior doing its job.

The second fused two retrieval rankings to surface more answers. It recovered one question that had been missed — and, on another, produced a fluent, confident report at credence 0.93 that was *wrong*. That is the cardinal sin, the exact failure the typed design exists to prevent, manufactured by my own attempt to make the design look better to the gate. I reverted it immediately.

Here is the concession, and it is the whole turn of the argument: there was no mechanical lever that raised the answer rate without either dispersing the posterior or inventing a confident wrong answer. The answer rate is low not because the plumbing is timid but because the machine is, correctly, unsure — and the only way to make it answer more *honestly* is to give it grounds, not nerve.

## The answer rate is the utility

Which forced the reframe I should have started from. I had been treating the answer rate as a dial to turn until the gate moved. It is not a dial. It is a readout of a belief — specifically a belief about my utility. The machine abstains exactly when the credence it holds is not high enough to clear the bar that *my* cost-of-being-wrong sets. A wide, pessimistic belief about that cost produces a high bar, which produces abstentions. The reticence and the unmeasured utility are the same fact seen from two sides.

So the gate does not move by making the machine braver. It moves when I stop guessing at how much a wrong answer costs me and start knowing. And — this is the part I kept trying to dodge — I cannot supply that number by introspection. If you ask me cold how much I hate a confident wrong answer I will say "a lot," wave my hands, and give you a figure I have no way to defend. Stated preferences about your own loss function are worth approximately nothing. The number has to come from behaviour.

## Learning what a wrong answer costs

The mechanism that learns it is older than any of this: inverse decision theory. If you can see what an agent *chose*, and you know the belief it held when it chose, you can read its decision backwards into a constraint on the utility that made that choice rational. Here the agent is the assistant, the choice is logged on every answer, and the missing observer of the utility is me — supplied, for free, by my reaction.

Concretely. When the typed machine abstains, it did so because, at the credence p it held, the expected value of reporting did not beat silence. For a point-fact answer that condition is exactly `p·u_correct + (1−p)·u_wrong > 0`, which rearranges to a threshold: it reports only when `u_wrong > −p/(1−p)`. The abstention tells me the agent believed `u_wrong` sat *below* that line. Now I react. If I say "good — glad you didn't guess," I have endorsed the abstention, and the cost of being wrong is confirmed to sit below `−p/(1−p)`: being wrong really is that bad. If I say "no, I wanted an answer, you should have ventured it," I have overruled it, and the cost sits *above* the line: silence was the expensive choice here. Either way my reaction is a measurement of `u_wrong`, located precisely at the credence the machine happened to hold. Enough of them, spread across different credences, and the distribution I had no right to be sure about tightens into one I have earned.

Two disciplines keep this from being a way to cheat, which is the only interesting question once you can move a gate with your own reactions.

The first is that I fold only the *clean* signals — reactions to abstentions, where nothing was asserted and so my "good" or "bad" can only be about whether silence was right. A reaction to a confident *report* is contaminated: a thumbs-down might mean "wrong value," but it might mean "wrong subject" or "I didn't want a report at all," and those belong to different parts of the model. Worse, that contamination would be biased in the direction that flatters the typed design. So those reactions are recorded but not yet folded; the clean abstention verdicts carry the weight.

The second is that the reactions have to be a byproduct of ordinary use, not a marking session I run because I know the gate failed at 0.848 and I want it to pass. A pass bought by sitting down and grading answers with the result in mind is a pass I faked. And because I want to be able to re-read the gate after each new reaction without the statistical sin of stopping the moment it crosses — peeking until you like the number — the re-read uses an always-valid criterion that licenses a look at any time. The prior over my utility is never tuned to a gate result. Only my behaviour moves the posterior, and only behaviour I produced without watching the dial.

## What this is, and what it is not

What I have is not an adopted system. It is a gate that declined to adopt one, a diagnosis of exactly which unmeasured quantity the decision hangs on, and a loop that measures that quantity from the only honest source — what I do when the machine stays silent. The gate will move, or it won't, as those reactions accumulate, and I have deliberately built it so that I cannot make it move any faster than my own behaviour does.

What it is not: a result that says the typed machinery is better. The mean says that, and the mean is not the bar. What it is: an instrument that refuses to let me adopt my own work on a flattering average, that names the one number standing between here and a real yes, and that can only get that number by watching me — which, for a thing meant to manage my own life, is the right place to get it.

I find I trust the no more than I would have trusted a yes. A judge you built that always rules for you is not a judge.
