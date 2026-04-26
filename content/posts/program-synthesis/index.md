---
title: "The Agent That Invents Its Own Rules"
subtitle: "Bottom-up enumeration, posterior subtrees, and the grammar that rewrites itself"
description: "Most agents are given a fixed set of decision rules. Credence's second tier generates candidate rules from sensor features, scores them by complexity, and lets the posterior decide which structures are worth keeping. This is program synthesis as Bayesian inference."
author: "Guy Freeman"
date: 2026-04-01
publishDate: 2026-04-30
categories: [julia, essays, bayesian, machine-learning, ai]
---

The [previous post in this series](/posts/three-types/) described what I called Tier 1 of the Credence architecture: a DSL for Bayesian decision agents with three types, four axioms, and a constitution forbidding everything else. That post ended with a program the user had to write by hand --- a short S-expression encoding a hypothesis about what the environment was like and how to act in it.

Hand-written programs have a well-known limitation: they are only as good as whoever wrote them.

Tier 2 of the architecture addresses this. Given a set of sensor features --- numbers that arrive at every timestep from the environment --- it automatically generates candidate decision programs, assigns each a prior probability based on its complexity, and lets Bayesian conditioning determine which programs best explain the agent's history of observations and rewards. The agent does not need to be told which features matter or how to combine them. It discovers this from data.

This is a specific instance of a more general idea: program synthesis as Bayesian inference. The hypothesis space is a space of programs. The prior is weighted by description length. The likelihood is determined by how well each program predicts what actually happened. The posterior is the standard result of conditioning on these two. Nothing new is happening --- only the hypothesis space is unusual.

## Building the Space of Programs

The hypothesis space is generated bottom-up, in three phases.

**Phase 1: Atoms.** For each sensor feature --- say, `relative_x`, `relative_y`, `has_prize` --- the system generates comparison predicates against a fixed set of thresholds: 0.1, 0.3, 0.5, 0.7, 0.9. So from a feature called `relative_x`, you get ten atoms: `relative_x > 0.1`, `relative_x > 0.3`, and so on, plus the five less-than variants. These are the building blocks: the smallest meaningful claims the agent can make about its situation.

**Phase 2: Predicates.** Atoms are combined using logical connectives --- AND, OR, NOT --- to form compound predicates. `AND(GT(relative_x, 0.5), LT(relative_y, 0.3))` is a predicate asserting that the agent is in the right half of the space and close to the top. Each combinator adds one to the expression's complexity: an AND of two atoms has complexity 3 (one node for AND, one for each atom).

**Phase 3: Programs.** Predicates are inserted into decision rules: IF *predicate* THEN *action* ELSE *action*. A complete program is a mapping from situations to actions, structured as a tree of conditional tests. A program containing a single predicate has depth 2. Nesting conditionals raises depth --- and complexity --- further.

The prior probability of each program is $2^{-k}$ where $k$ is the program's complexity. This is Solomonoff's universal prior: a maximum-entropy distribution over the terminal alphabet, where each symbol costs one bit regardless of what it does. Simpler programs are exponentially more probable under this prior. A program of complexity 10 is 32 times less likely than one of complexity 5, before any data is seen.

## The Tautology Filter

Not all predicates are informative. A predicate that is always true --- `OR(GT(x, 0.5), NOT(GT(x, 0.5)))` --- contains no information about the environment. The system detects such tautologies by evaluating each candidate predicate against the current belief and checking whether its posterior sum equals its prior sum. If the predicate fails to update the posterior, it is discarded before entering the program space.

This sounds like a minor optimisation. In practice it prunes a substantial fraction of the generated candidates, particularly for compound predicates formed by combining atoms in logically degenerate ways. The tautology filter is not a heuristic --- it is a decision-theoretic criterion. A predicate that cannot update beliefs cannot increase expected utility. It has no reason to exist.

## Grammar Induction from the Posterior

After the agent has observed some data and the posterior over programs has concentrated, something interesting becomes available: the structure of the high-weight programs.

If several high-posterior programs all contain the subexpression `AND(GT(relative_x, 0.5), LT(relative_y, 0.3))`, this is evidence that this particular compound predicate is doing genuine discriminative work. It is not a coincidence that it appears in multiple programs that explain the data well. It is a regularity.

The system extracts this regularity via `analyse_posterior_subtrees`, which walks each program's expression tree, collects all subtrees of complexity ≥ 2, weights each occurrence by the program's posterior probability, and returns a frequency table sorted by aggregate weight. The top entries in this table are the expressions that most consistently appear in programs that predict well.

These extracted subtrees become *nonterminals* in a revised grammar. Instead of building every program from scratch out of atoms, the next round of enumeration can refer to a named subexpression --- effectively compressing frequently-useful structure into a reusable symbol. A grammar perturbation then adds, removes, or modifies these nonterminals based on the posterior analysis, producing a refined search space biased towards structures the data has endorsed.

This is the learning loop: enumerate programs → observe outcomes → compute posterior → extract structure → refine grammar → enumerate again. Each cycle, the grammar adapts to what has been useful. The prior still penalises complexity, so the system does not simply memorise history --- it generalises. Nonterminals that appear in many high-posterior programs survive. Those that appear in none are pruned.

## Why This Is Not Neural Architecture Search

The obvious comparison is to methods that learn model structure --- neural architecture search, evolutionary algorithms, genetic programming. These methods do something similar in spirit: they search a space of structured hypotheses for one that fits the data.

The distinction is in the search criterion. Gradient descent, evolutionary fitness, and cross-validation accuracy are all surrogates for a quantity you actually care about. They can be gamed. A program that achieves high training accuracy by memorising will score well under cross-validation if the training set is large enough. An evolved architecture that overfits will dominate a population in short episodes.

The Bayesian criterion --- posterior probability --- cannot be similarly gamed, because it integrates fit and complexity simultaneously. The complexity penalty (the prior $2^{-k}$) is not a regularisation coefficient tuned by hand. It is the prior probability of the program's existence under a maximum-entropy distribution over programs. The posterior is the uniquely correct update of this prior given the observed data. There is no hyperparameter to tune and no threshold to set.

This is the same argument that applies to [Credence's Tier 1](/posts/three-types/): the mathematics forces a unique answer. You do not choose the Solomonoff prior because it has nice properties. You use it because it is the maximum-entropy distribution over descriptions, and any other prior either assumes more structure than you have or violates Cox's consistency axioms.

## What the Agent Discovers

Running the grid-world agent through several episodes, the program space tier discovers what a domain expert would write: rules that respond to the relative position of obstacles, the location of the goal, and the sequence of recent actions. The grammar perturbation promotes subexpressions involving spatial proximity comparisons because these consistently appear in programs that predict well.

The agent was not told that spatial reasoning matters. It was given raw sensor features and a reward signal. The grammar it ends up with --- after posterior analysis and refinement --- encodes spatial reasoning because that is what the data rewarded.

This is, in miniature, the argument for learning over hard-coding. Not because hard-coded rules are wrong --- they may be exactly right --- but because a system that derives its rules from data can adapt when the rules change. The grid world occasionally changes its dynamics. When it does, the programs that predicted well stop predicting well. Their posterior weights fall. The grammar loses the nonterminals they contributed. New structures, appropriate to the new regime, rise.

No change-detection algorithm is running. No flag is set when a regime change occurs. The posterior dynamics handle it automatically. This is what it means to have a [principled learning mechanism](/posts/three-types/) rather than a collection of heuristics.
