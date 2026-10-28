---
title: "The Bitter Lesson for Persons"
subtitle: "Compute replaces capability. It cannot supply the objective, the world, or the outcome — and those are positions, not skills."
description: "Fourteen briefs of the mathematics I argue for — a verifier sound by grammar, belief propagation over crossing letters, calibrated commitment, value-of-computation search — solved 17 of 40 cryptic crosswords. One call to a frontier model, handed the whole puzzle, solved 30 at 28 cents a grid. It is the second time this has happened to me. What survived both times is the same thing, and it points at what compute cannot manufacture: whose loss it is, what has been observed, and what the world said back."
author: "Guy Freeman"
date: 2026-10-28
draft: false
categories: [essays, ai, bayesian, decision-theory]
---

In March I wrote that [the Bitter Lesson has no utility function](/posts/bitter-lesson-missing-half/). I meant it as a point about frameworks: Rich Sutton's [essay](http://www.incompleteideas.net/IncIdeas/BitterLesson.html) says general methods that leverage computation beat methods built on human knowledge, and says nothing about what the computation is for. I stand by that. I have since spent $300 and three days of agent time learning that it is also a point about me.

## Fourteen briefs, one call

[ximenes](https://github.com/gfrmin/ximenes) is a cryptic crossword solver I built in October with three coding agents, under the discipline I now run everything under: one pre-registered measurement per brief, a decision rule written before the data exists, evaluation puzzles that post-date every model's knowledge cutoff and are read once, and a mechanical gate in CI that refuses numeric literals in the kernel.

It was, deliberately, the mathematics this site argues for. A typed domain-specific language for wordplay and a verifier that walks the parse as an AST and executes nothing, so that no parse can be accepted that does not account for every word of the clue, link words aside, exactly once; it admits none of roughly three thousand mutant parses. A posterior over candidate answers fitted on held-out data, so that "committed" means a calibrated 0.9 rather than a hopeful one. Loopy belief propagation over the grid's crossing letters. A value-of-computation controller that buys the next model call only when its expected information is worth its price. Fourteen briefs of it, each one measured, and the decision layer worked: the verifier was sound, the posterior calibrated to within three points on single clues, committed answers were right 98–99% of the time, and value of computation beat attempting everything. On forty daily cryptics from the Guardian, the Independent and the FT, all published after the models' cutoffs, the full solver filled seventeen grids with every answer correct.

Brief fifteen asked the question I should have asked at brief zero. What does the frontier model do if you simply hand it the whole puzzle --- the clues, the enumerations, which square crosses which --- and let it think? One call per grid, no machinery, structured output. Claude Opus 5.5 at high effort filled thirty of the same forty grids, at 28 cents each. Paired on the same puzzles, there were fifteen grids only the direct call solved and two only my solver did. On forty grids no agent or person had read before, it got thirty-five. On Times dailies and Telegraph Toughies, which are harder, twenty-eight of thirty-six. Across everything, ninety-three of 116, with no fitted parameter anywhere, for about the price of a postage stamp a grid.

I had built fourteen briefs of machinery around a baseline I had measured only clue by clue, with a small model, at brief zero. Brief fourteen had already given the warning: a frontier model fed through my calibration and the crossing letters, with no verifier at all, edged the full solver by eight grids to seven of twenty. Brief fifteen took the machinery away entirely, and it won.

## The second time

I would like to say this was a surprise, but it is the second time. [Credence](/posts/credence-paper/) was a Bayesian agent for tool selection that scored twelve times the best LLM agent I set against it, on a benchmark of my own construction. Redesign the benchmark to remove the worst of its asymmetries, and a frontier model beats it on score; run a one-line greedy ablation with no value-of-information calculation at all, and that beats the full Bayesian agent too, under every credit-assignment rule I tried. I retracted the headline in August. The retrospective is the direct origin of the pre-registration discipline that ximenes ran under, which is how ximenes came to retract its own headline in two days rather than four months. That is progress of a sort.

Two projects in a year, the same shape: the decision-theoretic machinery I argue for, built carefully and measured honestly, loses on accuracy to the model asked directly. Anyone who writes about Bayesian agents and does not have this experience has not run the baseline.

## What the lesson is about, and what it is not

So what is Sutton actually claiming, and what did he leave out? He is precise, and his readers are not. The Bitter Lesson is a claim about *methods*: given an objective, data, and feedback, general methods that scale with compute beat the human's encoded knowledge of the domain. His second lesson, the one fewer people quote, extends it to the world model itself: do not build in space, objects, agents, symmetries; build meta-methods that discover them. ximenes confirmed both. My grammar of wordplay was encoded domain knowledge; one call beat it. The grid I so carefully enforced as crossing constraints turned out to be something the model reconciles perfectly well on its own: handed the grid along with the clues, across seventy-six fresh grids, it produced not one crossing conflict. So the last brief took the grid away. Given the clues alone, told nothing about which squares cross, it filled twenty-five of thirty grids against twenty-four with the grid on the same puzzles --- no difference anyone should claim, on a paired test written in advance --- and its clue-by-clue answers disagreed on a shared letter in one grid of thirty. What the grid bought was thinking time: 28 cents a grid with it, 47 without. The world I was supplying was one the model already owned.

But a learning system is a function of four inputs: an objective, a world to observe, outcomes arriving over time, and compute. Write it as \(V = f(\text{compute}, \text{data}, \text{objective}, \text{feedback})\). The Bitter Lesson says \(\partial V / \partial(\text{human knowledge}) \to 0\) as compute grows: our contribution to the *function* is swamped. It says nothing whatever about the inputs, and compute manufactures exactly one of them.

**The objective.** Compute optimises; it does not prefer. Whose loss is being minimised is a fact about who is the principal, not a result anyone can compute. Models infer preferences very well, so this is not a point about inference. It is a point about standing.

**The world.** Information that has not been observed cannot be computed into existence. The registry, the present, the private: these have to be collected, and collecting them takes presence, permission, trust and capital. Machines with sensors collect too, so what stays human here is not the collecting but the permission and the ownership, which are social facts rather than technical ones.

**The outcome.** Truth arrives at the speed of time. Calibration is bounded by feedback, not by thought: no amount of deliberation tells you whether you were right until the world says so. And consequences attach to persons. A model cannot yet be sued, fined, or struck off.

What compute replaces is the fourth thing, which is everything in between: inference, search, synthesis, craft. That is most of what we used to call skill, and it is the part the labour market priced. It is also, I note with some discomfort, the part I had been building.

## What survived

Two things survived both projects, and they are the same two things.

The first is calibration. In ximenes, the frontier model's raw confidences had an expected calibration error of 0.177 across a grid's slots; the full solver, with a posterior fitted on held-out data, had 0.064, and committed 495 slots where the frontier model alone committed 341. When I fed the direct call's own answers through the same machinery --- a calibrated probability per answer, belief propagation, then high-effort re-asks of the open slot with the most known letters --- it gained one grid in each of two runs, 36 against 35 of forty and 29 against 28 of thirty-six, and never lost one. By the rule I had written in advance that is not an accuracy claim, and I am not making one. But it took the model's stated confidence from an ECE of about 0.07 to 0.003. The machinery's product turned out to be not better answers but honest probabilities attached to the same answers; and, in the full solver, where the verifier ran, a statement for each committed answer of what it rests on. In Credence, what survived was narrower still, and of the same kind: the value of exploring depends on how well you can attribute outcomes to causes. Both are statements about the inputs, not the function.

The second is the decision of what to buy. Value of computation did not beat a heuristic in ximenes; it tied one. But the question it asks --- is this next call worth its price, and which measurement changes a decision --- is the one I should have put to the project itself at brief zero. Asked of the baseline, it would have bought the eleven-dollar measurement that ended the project before the fourteen briefs that preceded it. The mathematics did not win the crossword. Its durable use is to say when to stop building and measure.

Here is the pattern I would offer anyone building around these models. **Measure the strongest simple baseline before you build anything**: the frontier model given the whole problem, allowed to think, with its cost. Then build only what it demonstrably lacks, in the order of measured value: the world it cannot see, the exactness it cannot hold, the calibration it cannot have, the loss it does not know. In ximenes the grid turned out to be a world it already had, the letters something it could hold, and calibration the one thing it lacked. A cryptic crossword's world is the English language and a century of setters' conventions, all of it in the training data. The lesson is not that supplying the world is worthless; it is that I chose a problem where there was no world to supply, and did not find out until brief eighteen.

One more number from that last brief, because it reprices every small result above it. Two near-identical conditions --- the same call, with and without the grid --- disagreed on seven grids out of thirty for a net difference of one. The hybrid's one-grid gains in two separate runs sit comfortably inside that noise. I reported them as no claim at the time, by a rule written beforehand, and I am glad I did.

## Comparative standing

The economists have an answer to "what is left for people", and it is worth taking seriously before replacing it. Noah Smith's [case](https://www.noahpinion.blog/p/plentiful-high-paying-jobs-in-the-ff9) is that comparative advantage keeps humans employed even if the machine is better at everything, because compute is finite at any moment: the machine's time is scarce, its best uses crowd out the rest, and the rest falls to us. The critique, put most sharply in a post called [Why comparative advantage does not help horses](https://www.lesswrong.com/posts/3Rx4YCuepAb9oBBfR/why-comparative-advantage-does-not-help-horses), is that Ricardo assumes each party can refuse to trade and has somewhere else to stand; horses could not, and the theorem is silent about a party that can take the land as well as the labour. Smith himself concedes the mechanism depends on energy and compute staying scarce and on the owners of the machines not bidding people out of electricity.

I think both are arguing about the wrong noun. Comparative *advantage* is a claim about capabilities, and every capability is on Sutton's conveyor belt. The thing that is left is not a capability but a **position**: the principal whose loss it is, the owner of the world being observed, the bearer of the outcomes, and the subject who experiences the utility. Call it comparative standing. It is not something a model can be better at, because it is not an ability; it is a role defined by the rules of the game.

Which is the honest caveat. Three of those four positions are held up by institutions --- property, consent, liability, the rules about who may sign --- and the strongest recent argument in this literature, [*The Intelligence Curse*](https://intelligence-curse.ai), is precisely that those institutions weaken when people are no longer needed for production, because states and firms look after what they depend on. Only the fourth position is analytic: utility is had by subjects, and a model cannot be happy on my behalf. Smith's compute scarcity probably holds for the next several years, which buys time. Beyond that, whether the positions stay ours is a collective question, not a personal one, and I am not going to pretend an essay settles it.

## The next five years, as a decision rule

I run a data business, [Renavon](https://renavon.com), which sells Hong Kong's primary-source data, scraped from the registries, the exchange and the racecourse: who holds what licence, which director disclosed which stake, which company is registered where. Six months ago I thought of it as the dull part of my work and the agent research as the interesting part. The ximenes result inverts that. The registries are a world the model cannot see; the licences to collect and resell them are standing; the daily deltas are outcomes. The solver was capability, and capability is selling at list price, 28 cents a grid and falling.

So here is the rule I now apply to my own choices, and it is the same loop as the briefs. For any action, split its expected value into a *position* term, which is durable, and a *capability* term, which depreciates at whatever rate frontier capability is growing, and weight across the scenarios in which compute stays scarce and in which it does not. Five questions settle most cases:

1. Does it increase what I own of the world --- data, relationships, distribution, legal standing?
2. Does it make me the principal, or the signatory: the one whose loss it is, or the one who bears the consequence?
3. Does it generate outcome feedback that calibrates me, rather than opinions that do not?
4. Is its value in the doing?
5. How long until the frontier model matches it unaided?

Prefer actions heavy in the first four. Buy information cheaply before building: twenty instances, the model asked directly, before any architecture. Keep options open across the scenarios, because the honest probability on either is not small.

Applied to work: own the world rather than the craft, and be the party that signs. The verifier in ximenes was worth nothing as accuracy and everything as the sentence "this answer rests on these two judgements and this string operation", because that sentence is what an auditor, a regulator or a client is paying for, and it is a sentence a bare model does not produce. Applied to skills: before a year's investment in any capability, ask question five, and if the answer is "about two years", rent it instead. Applied to money: the complements of intelligence --- energy, compute, distribution, trust --- rather than intelligence itself, which is being commoditised in front of us. That is the shape of an argument, not advice.

Applied to happiness, the rule is kinder than it looks. Question four is the one the machine cannot touch. Opus solving four Times cryptics in five changes nothing about the pleasure of the fifth, any more than the car ruined the hundred metres. The championship was never about the filled grid.

## What infinite compute cannot replace

Take compute to infinity and see what is left of the function. It is undefined without an objective, and the objective is the principal's. It is bounded by data, and there is no free lunch: what has not been observed is unavailable at any price. It is bounded by feedback, which arrives at the rate the world turns and not one tick faster. And its output is a number that means nothing until someone experiences the outcome it priced.

So the asymptotic human share is not a skill the machines happen not to have yet. It is choosing objectives, owning observation, bearing outcomes, and being the one for whom any of it matters. Everything I built in ximenes that did not survive was an attempt to do the model's job better than the model. Everything that did survive was one of those four. I suspect that is general.

I called the March essay *The Bitter Lesson Has No Utility Function*. The lesson for persons is the same sentence read the other way round: the utility function has no Bitter Lesson. Nobody is going to out-compute you at being the one whose loss it is.

## Postscript: on process

As with the March essay, this was drafted with Claude. The division of labour was the one the essay describes, with one twist I did not plan: one of the builder agents that wrote ximenes's briefs also ran the experiment that beat them, and another Claude drafted the account of losing. I supplied the objective, the data, the decision rules and the money. It supplied the compute. I find that I am entirely comfortable with the arrangement, which is either the thesis or a symptom.
