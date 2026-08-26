---
title: "Research"
description: "Bayesian methods, agent architecture, and decision theory under uncertainty."
---

## proplang: A Cornered Language for Bayesian Agents

A programming language in which a Bayesian decision-theoretic agent is a program, built on a single claim: an agent that adapts to a changing world needs no adaptation machinery. If the agent's hypotheses are programs and its prior over them is the description length of those programs under a grammar — Solomonoff's \(2^{-|\text{program}|}\) — then adaptivity, bounded rationality, and inductive bias are consequences of the language rather than modules bolted onto it. The corollary is the whole design method: **the alphabet of the language is the prior.** Every terminal you admit costs one bit against every hypothesis that uses it, so a superfluous terminal is not merely inelegant — it is a mis-specified inductive bias. You do not choose the vocabulary; you corner it, deleting every terminal whose removal costs no capability.

The result is four nouns (Space, Prevision, Event, Kernel), three verbs (push, condition, argmax), and a handful of structural terminals — ten in all, each carrying an *executed* deletion proof with a measured cost in bits. One terminal failed its own proof and was kept anyway, recorded in the open as a standing bug rather than quietly retained. The three inference verbs are grammar terminals, not host functions, so a program can reason about its own inference: "condition again, then decide" is a sentence the agent can write and price. And the whole artifact was built under a frozen-oracle protocol — the acceptance tests were written and cryptographically signed *before any implementation existed*, then handed to a coding agent that could not change them.

This is the same move Rust makes against C++ and TypeScript against JavaScript — make the illegal state unrepresentable — with one turn of the screw those languages cannot make: because the alphabet doubles as the prior, soundness and good epistemics become the same property, and minimality acquires a deletion test that is actually executable.

[**proplang on GitHub →**](https://github.com/gfrmin/proplang) — the frozen artifact: research brief, language design, reference implementation, and the signed custody chain.

## Credence: The Decision-Theoretic Predecessor

Before proplang there was Credence — a framework for LLM tool-using agents grounded in decision theory rather than prompt engineering. Its core insight: whether to query a tool is a decision problem, solvable with Value of Information. Credence maintains Beta posteriors over tool reliability and computes expected value of information before each query; on the benchmark as originally constructed, LangChain ReAct scored −8 (63.7% accuracy) while Credence scored +112 (59.6% accuracy).

That headline did not survive its own benchmark, and the honest amendment matters more than the number did. The comparison handed Credence each question's category as a perfect oracle. Take the oracle away and a frontier model wins on score, while a one-line greedy ablation — no value-of-information calculation at all — beats the full agent under every credit-assignment rule tested. What survived is narrower and, I think, more interesting than the victory: **the value of exploration is contingent on the quality of category attribution.** Given clean categories, horizon-aware VOI beats greedy by 27; given inferred ones, it loses by 12. Those are two points on one curve, and the curve is the finding. [The full retrospective is here](/posts/credence-paper/).

proplang supersedes Credence's *foundation*; the retrospective narrows its findings. Neither touches the part Credence got right first: it reached the right ontology ahead of its successor, rebuilding itself on de Finetti's prevision and arriving at the same four nouns. What it could not do was *enforce* its own architecture. Credence's rules live in 1,300 lines of constitutional prose, and where prose was the only guard, the source drifted: an opaque-closure escape hatch its own constitution forbids; a Measure type it announced it no longer needed, still carrying eighty-odd live methods. Its inference verbs are things a program can call but its meta-actions are not — the agent changes what it thinks about, never how it thinks. And its alphabet, declared four types and then opened, has grown to over a hundred. proplang's answer to all of this is the same answer: put the rule in the grammar, where a model — or a tired author — physically cannot write around it.

[**Credence on GitHub →**](https://github.com/gfrmin/credence)

## Published Work

**Freeman, G. & Smith, J.Q. (2011).** Bayesian MAP model selection of chain event graphs. *Journal of Multivariate Analysis*, 102(7), 1152–1165.
Chain Event Graphs — a class of graphical models more expressive than Bayesian networks for asymmetric problems — and Bayesian model selection over them. Foundational paper in the CEG literature; subsequent work on dynamic CEGs, causal algebras, and software builds on these methods.

**Freeman, G. & Smith, J.Q. (2011).** A Bayesian approach to event trees. *Bayesian Analysis*, 6(4).
Non-stationary sequential models with conjugate Bayesian updates, using an exponential forgetting mechanism to track regime change. Fifteen years later, that forgetting factor is the thing [proplang](https://github.com/gfrmin/proplang) deletes: a latent drift-rate the update rule infers matches the oracle-tuned forgetter to within a hair, and forgetting turns out to have been content smuggled in as machinery all along.

[Google Scholar →](https://scholar.google.com/citations?hl=en&user=H422hdkAAAAJ)
