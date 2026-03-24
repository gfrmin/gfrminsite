---
title: "Three Types and a Funeral for Your Inference Library"
subtitle: "The axioms, the types, and the forbidden patterns behind an agent that learns and decides from first principles"
description: "What would it take to build an agent whose behaviour is derived from a few fundamentals the way physics is derived from conservation laws? Three types, four axioms, and a refusal to add anything else."
author: "Guy Freeman"
date: 2026-03-22
draft: true
categories: [julia, bayesian, machine-learning, ai, essays]
---

{{< callout type="note" >}}
This is Part 1 of a series. For what these principles produce in practice, see [Part 2: Teaching Zork to a Bayesian](/posts/teaching-zork/) and [Part 3: The Loop Problem](/posts/loop-problem/).
{{< /callout >}}

What would it take to build an agent that genuinely learns and decides --- not one that pattern-matches its way through tool calls, but one whose behaviour is *derived* from a few fundamentals the way physics is derived from conservation laws?

I've spent the last several months trying to answer this. The [earlier posts](/posts/agentic-ai/) on this blog laid out the critique: current "AI agents" have no beliefs, no uncertainty, no principled mechanism for deciding whether a query justifies its cost. The [companion piece](/posts/decision-theory-agents/) demonstrated that a few hundred lines of decision theory could outscore LangChain by 120 points on its own benchmark. The [Bayesian agent series](/posts/bayesian-agent/) showed conjugate priors converging in real-time. These were demonstrations. This post is the foundation they were standing on.

The answer turns out to be three types and four axioms. Everything else --- tool selection, exploration, when to ask for help, when to stop --- falls out of the mathematics. I built a DSL called [Credence](https://github.com/gfrmin/credence) to enforce this, and the enforcement is the interesting part. Not "here is a nice framework." Here is a constitution, and here is why violations are mathematical errors.

No existing framework occupies this position. Every probabilistic programming language takes the probability calculus as given rather than deriving it. Every POMDP solver assumes a fixed model class. Every LLM agent framework lacks principled decision theory entirely. The gap between axiomatic foundations and practical implementation has been well-documented for decades. It has not, until now, been filled.

## The Four Axioms

These are not design choices. They are theorems, established by Cox, Savage, Bayes, and de Finetti across a couple of centuries of work that the AI industry appears not to have read.

**A1. Beliefs are probability measures.** Cox (1946) proved that any system of beliefs satisfying basic consistency requirements --- if you believe A more than B, and B more than C, then you believe A more than C --- must be representable as probabilities. Not "could be." Must be. The alternative is incoherence: a bookmaker can construct a set of bets that guarantees you lose money. (Halpern (1999) showed the proof breaks in certain finite domains. The practical significance is limited --- the counterexamples require increasingly pathological constructions as domain size grows --- but intellectual honesty requires noting it.)

**A2. Rational action maximises expected utility.** Savage (1954) showed that if your preferences over actions satisfy six axioms (completeness, the sure-thing principle, and four others that amount to "don't be absurd"), there exists a unique probability measure and a utility function such that you act as if maximising expected utility. The utility function isn't imposed. It's *implied* by coherent preference.

**A3. Learning is conditioning on evidence.** Bayes' rule is the unique update rule satisfying diachronic coherence: no sequence of bets can extract guaranteed money from an agent that updates this way. Amarante (2022) proved something stronger --- Bayes' rule is the unique rule for which updating and computing the predictive commute. Any other update rule either loses information or introduces inconsistency.

**A4. One learning mechanism. One decision mechanism.** Dutch book coherence again. If you maintain two ways of updating beliefs, or two ways of selecting actions, a sufficiently clever adversary can construct a set of bets that guarantees your ruin. This is the axiom that does the most work, and the one that current AI architectures violate most enthusiastically.

These four axioms aren't one principled approach among many. Wald's complete class theorem (1950) establishes that under mild regularity conditions, any admissible decision procedure --- any procedure not dominated by another across all possible states of nature --- must be a Bayes rule with respect to some prior. The alternative to Bayesian decision theory is not a different theory. It is inadmissibility.

## Three Types

The DSL has exactly three kinds of object. These are the ontology of Bayesian decision theory, and they are not original to this project. A survey of seven major probabilistic programming languages --- Hakaru, monad-bayes, LazyPPL, Gen.jl, Stan, Pyro, WebPPL --- reveals the same convergent structure: spaces, distributions over spaces, and conditional distributions between spaces. Fritz (2020) formalised this as Markov categories. Every PPL approximates this ontology. None of them enforces it. Credence enforces it. The three types do not change.

```julia
abstract type Space end    # a set of possibilities
abstract type Measure end  # a probability distribution over a space
struct Kernel              # a conditional distribution between two spaces
    source::Space
    target::Space
    generate::Function     # h → distribution spec
    log_density::Function  # (h, o) → log P(o|h)
end
```

A **Space** is a set of possibilities. It might be finite (five hypotheses about a coin's bias), an interval (the real line between 0 and 1), a product of other spaces, or a simplex (probability vectors that sum to one).

A **Measure** is a probability distribution over a space. Not an approximation, not a sample, not a point estimate --- a distribution, encoding both what the agent believes and how uncertain it is. The DSL provides several: categorical (finite discrete), Beta (continuous on \[0,1\]), Gaussian, Dirichlet, Normal-Gamma, and their products and mixtures.

A **Kernel** is a conditional distribution between two spaces. It is the agent's theory of how hypotheses generate data --- for each hypothesis, what distribution over observations does the agent expect? A kernel is a morphism in the Markov category, which is a fancy way of saying it's the right mathematical object for the job. It declares its source space, its target space, and its generative structure. This declaration matters: it's what allows the system to detect conjugate structure and select the right computational backend.

Everything else --- every operation, every combinator, every named concept --- is a function over these three types.

## The Axiom-Constrained Functions

Four functions implement the axioms. Their *behaviour* is frozen. Their interfaces and computational strategies are negotiable.

**`condition`**: Bayesian inversion. The ONE learning mechanism.

$$P(h \mid o) \propto P(o \mid h) \cdot P(h)$$

In code, `condition` dispatches on the types of its arguments. When a Beta measure meets a Bernoulli kernel, it recognises conjugate structure and returns a new Beta with incremented parameters --- exact, closed-form, no approximation:

```julia
function condition(m::BetaMeasure, k::Kernel, observation)
    if observation == true
        BetaMeasure(m.space, m.alpha + 1.0, m.beta)
    else
        BetaMeasure(m.space, m.alpha, m.beta + 1.0)
    end
end
```

When conjugacy isn't available, it falls back to grid approximation or importance sampling. The DSL user never sees the difference. The interface is `condition(belief, kernel, observation)`. Always. The computational strategy is invisible.

No other function may modify a measure's weights. This isn't a convention. It's the only function whose type signature permits it.

**`expect`**: Integration against a measure.

$$\mathbb{E}_m[f] = \int f(x) \, m(dx)$$

This is what a measure *is*: a thing that assigns expected values to functions. Expected utility, value of information, predictive probability --- all are expectations. The entire decision-theoretic apparatus reduces to calling `expect` with different functions.

**`density`**: The kernel's log-density at a point. What `condition` needs to compute the likelihood ratio.

**`push_measure`**: Composition. Given a distribution over hypotheses and a kernel to another space, produce the induced distribution on the target. `expect` is `push_measure` to the real line.

Four functions. Three types. That's the frozen layer. Everything built on top of this --- and there's quite a lot --- is stdlib.

## The Standard Library in 74 Lines

The entire decision-theoretic apparatus is derived from the axiom-constrained functions. Here is `optimise` --- the ONE decision mechanism --- in S-expression syntax:

```scheme
(define optimise
  (lambda (m actions pref)
    (first (fold (lambda (best candidate)
                   (if (> (second candidate) (second best))
                     candidate
                     best))
                 (map (lambda (a)
                        (list a (expect m (lambda (h) (pref h a)))))
                      (support actions))))))
```

Argmax over actions of `expect(measure, preference)`. That's it. No special machinery. No planning algorithm. Just: for each action, compute the expected utility under the current beliefs, pick the highest.

Here is `voi` --- value of information:

```scheme
(define voi
  (lambda (m k actions pref possible-obs)
    (let current-val (value m actions pref)
      (let total-weight (fold + (map (lambda (o) (predictive m k o))
                                     possible-obs))
        (- (fold + (map (lambda (o)
                          (* (/ (predictive m k o) total-weight)
                             (value (condition m k o) actions pref)))
                        possible-obs))
           current-val)))))
```

How much would one observation from kernel `k` improve the decision? Enumerate possible observations, weighted by their predictive probability. For each, condition the beliefs and compute the resulting optimal EU. Subtract the current optimal EU. The difference is what the observation is worth. If this exceeds the observation's cost, query. Otherwise don't.

The [API Bill post](/posts/decision-theory-agents/) showed the Python implementation of this calculation beating LangChain by 120 points. The calculation itself is nine lines of stdlib, composed entirely from `condition`, `expect`, and `density`. The remaining functions --- `value` (optimal EU), `eu` (expected utility of a specific action), `predictive` (marginal probability of an observation), `net-voi` (VOI minus cost) --- are equally terse compositions. The standard library, including a self-test that verifies VOI of a flat kernel is zero, is 74 lines.

## The Coin

The DSL in its entirety, applied to learning a biased coin:

```scheme
; Three spaces
(let H (space :finite 0.1 0.3 0.5 0.7 0.9)    ; hypothesis space
  (let O (space :finite 0 1)                     ; observation space
    (let A (space :finite 1 0)                   ; action space

      ; The kernel: for each bias θ, Bernoulli(θ) over {0,1}
      (let k (kernel H O
                (lambda (theta)
                  (lambda (obs)
                    (if (= obs 1)
                      (log theta)
                      (log (- 1.0 theta))))))

        ; Start with maximum ignorance
        (let prior (measure H :uniform)

          ; Observations arrive: H H T H
          (let posterior
            (condition (condition (condition (condition prior k 1) k 1) k 0) k 1)

            (do
              (print (weights posterior))

              ; Preference: bet on heads pays 2θ-1, tails pays 1-2θ
              (let pref (lambda (theta action)
                          (if (= action 1)
                            (- (* 2.0 theta) 1.0)
                            (- 1.0 (* 2.0 theta))))

                (do
                  (print (optimise posterior A pref))
                  (print (value posterior A pref))

                  ; VOI: should we flip once more before betting?
                  (print (voi posterior k A pref (list 0 1))))))))))))
```

Forty-six lines. Define three spaces. Build a kernel. Condition on four observations. Print the posterior. Optimise. Compute VOI. The VOI tells you whether one more coin flip would improve your bet enough to justify watching it. The entire DSL is here: types, axiom-constrained functions, stdlib compositions. There is nothing else.

The syntax is S-expressions, after McCarthy (1960). The syntax is the AST. Programs can manipulate programs, which matters when your hypotheses *are* programs --- but that's Tier 2, and a story for another post.

## The Forbidden Patterns

Here is where the constitution earns its keep. Each of these is a mathematical error, not a style preference. Violating any of them produces an agent that is provably inadmissible --- there exists another agent that does at least as well in every state of nature and strictly better in some.

**No second learning mechanism.** Only `condition` modifies beliefs. Any function that produces a measure with altered weights without conditioning on an observation violates A4. This includes: forgetting, exponential decay, exploration bonuses applied to beliefs, ad-hoc reweighting, and "curiosity" mechanisms that inflate the posterior probability of unexplored states. If the world changes, the correct response is to include drift-rate in the hypothesis space, not to hack the update rule. Every shortcut here is a Dutch book waiting to happen.

LangChain has no learning mechanism at all, which is a different kind of violation --- it achieves coherence the way a stopped clock achieves accuracy, by not attempting the relevant operation.

**No second decision mechanism.** Only EU maximisation (via `expect` + `argmax`) selects actions. Epsilon-greedy, UCB bonuses, softmax temperature, and similar heuristics are not forbidden as *concepts*. They may emerge as EU-maximising strategies when computational cost enters the utility function. But they must not be hard-coded as mechanisms outside of EU maximisation. The difference matters: a hard-coded exploration bonus cannot be turned off when exploration becomes wasteful. An EU-maximising agent that accounts for computational cost will naturally stop exploring when the expected gain drops below the cost, because that's what "maximise expected utility" means.

**No opaque likelihood functions.** Likelihoods are kernels, not bare lambdas. A kernel declares its source space, its target space, and its generative structure. This allows the system to detect conjugate structure (Beta-Bernoulli, Dirichlet-Categorical, Normal-Normal) and select exact inference where available. A bare `(lambda (h o) ...)` discards this information, forcing the system to treat every problem as non-conjugate. It is the computational equivalent of refusing to show your working.

**Heuristics are EU maximisation, not approximations.** When computational cost enters the utility function, a faster approximate strategy may have higher EU than the exact Bayesian computation. This is not an approximation of the correct answer. It IS the correct answer. The right framing is not "we approximated inference for speed" but "we maximised expected utility over a decision space that includes computational strategy." The DSL specification doesn't change. The Julia execution layer implements alternative strategies; the agent selects among them by the same mechanism it uses for everything else.

**Indifference implies exploration.** When the EU of interacting equals the EU of waiting (both zero), interact. Indifference means the VOI from the interaction outcome is positive --- you'll learn something. The threshold is $\geq 0$, not $> 0$. This is a theorem, not a tie-breaking rule. Do not "fix" it to strict inequality.

## The Host Boundary

The DSL is pure. No side effects, no IO, no mutation. The host provides observations and executes actions. This separation is load-bearing.

`draw` --- the only source of randomness in the system --- lives in the Julia host, not the DSL. The DSL constructs mathematical objects (measures, kernels, expectations). The host realises them (samples values, executes actions, drives loops). This is why Thompson Sampling works cleanly: the DSL computes the posterior via `condition`. The host calls `draw()` to sample from it. Ordinary arithmetic picks the action with the highest sampled value. Three steps, three different layers, zero special cases. The [Bayesian agent post](/posts/bayesian-agent/) showed this working in a grid world. The mechanism is not "Thompson Sampling, the algorithm." It is "Bayesian inference, followed by sampling, followed by argmax" --- three operations that already exist, composed in the obvious way.

This also explains why a `(thompson-sample m actions pref)` primitive was proposed and rejected: sampling is randomness, randomness is a side effect, the DSL is pure. Construct the posterior in the DSL, call `draw()` in the host. Conflating the two layers is not a convenience. It is a category error.

## What the Axioms Produce

The existing posts on this blog were demonstrations of a system the reader hadn't seen yet.

The VOI computation in [How Decision Theory Cuts Your API Bill in Half](/posts/decision-theory-agents/) --- the one that beat LangChain by 120 points --- is `stdlib.bdsl`'s nine-line `voi` function, composed from `condition`, `expect`, and `density`. The Thompson Sampling in [Building a Bayesian Learning Agent That Teaches Itself to Eat](/posts/bayesian-agent/) is `condition` in the DSL followed by `draw` in the host. The evolutionary cognitive architecture in [Part 2](/posts/bayesian-agent-part2/) is the hierarchy-of-fixedness question: which levels of the agent's architecture should be learned (via `condition`) and which should be evolved (via a population-level analogue of the same operation)?

Three types. Four axioms. Seventy-four lines of stdlib. Everything else these posts described falls out of the mathematics. Not because the mathematics is clever, but because the mathematics is correct, and the alternative --- adding special-case mechanisms for exploration, for tool selection, for when to stop querying --- is provably worse.

The next two posts in this series apply these principles to domains where the consequences are visceral. [Part 2](/posts/teaching-zork/) puts a Bayesian agent in a text adventure, where over-querying is impossible and the LLM is explicitly a sensor, not a commander. [Part 3](/posts/loop-problem/) confronts the most universal failure mode of RL agents --- the loop --- and eliminates 98.5% of them by representing state properly. Both are applications. This post is the reason they work.

Code: [github.com/gfrmin/credence](https://github.com/gfrmin/credence)
