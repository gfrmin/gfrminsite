---
title: "Research"
description: "Bayesian methods, agent architecture, and decision theory under uncertainty."
---

## Credence: Principled Bayesian Agent Architecture

A framework for LLM tool-using agents based on decision theory rather than prompt engineering. The core insight: whether to query a tool is a decision problem, solvable with Value of Information. The core finding: optimising for accuracy alone is counterproductive when queries have costs.

Credence maintains Beta posteriors over tool reliability and computes expected value of information before each query. On a benchmark task, LangChain ReAct scored -8 (63.7% accuracy) while Credence scored +112 (59.6% accuracy). The agent that answered fewer questions correctly won decisively — because it knew which questions were worth asking.

This connects directly to open problems in agent alignment: an agent that maximises a coherent utility function under uncertainty is more controllable than one that maximises a proxy metric. The accuracy paradox is a toy demonstration of Goodhart's Law in agent architectures.

- [GitHub](https://github.com/gfrmin/credence)
- [Agentic AI Is Neither Intelligent Nor an Agent](/posts/agentic-ai/) — the benchmark result
- [How Decision Theory Cuts Your AI Agent's API Bill in Half](/posts/decision-theory-agents/) — the implementation
- [The Bitter Lesson Has No Utility Function](/posts/bitter-lesson-missing-half/) — why scale alone doesn't solve the decision problem

*arXiv preprint: forthcoming.*

## Published Work

**Freeman, G. & Smith, J.Q. (2011).** Bayesian MAP model selection of chain event graphs. *Journal of Multivariate Analysis*, 102(7), 1152–1165.
Chain Event Graphs — a class of graphical models more expressive than Bayesian networks for asymmetric problems — and Bayesian model selection over them. Foundational paper in the CEG literature; subsequent work on dynamic CEGs, causal algebras, and software builds on these methods.

**Freeman, G. & Smith, J.Q. (2011).** A Bayesian approach to event trees. *Bayesian Analysis*, 6(4).
Non-stationary sequential models with conjugate Bayesian updates. The exponential forgetting mechanism for regime change prefigures methods now used in adaptive agent architectures.

[Google Scholar →](https://scholar.google.com/citations?hl=en&user=H422hdkAAAAJ)
