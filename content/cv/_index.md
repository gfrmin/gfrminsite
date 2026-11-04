---
title: "CV"
description: "Guy Freeman — AI evaluation scientist. Statistician (Warwick PhD, 1,750+ citations) who designs AI workflows and measures whether they work; author of A Court for Agents; HSBC, Booking.com, Slice, Willis Towers Watson. Hong Kong; UK and Israeli citizen."
---

**AI evaluation scientist — LLM and agent evaluation · experimental design · Bayesian decision theory.** Hong Kong permanent resident; UK and Israeli citizen; open to Hong Kong, Singapore, London, Tel Aviv or remote. [mail@gfrm.in](mailto:mail@gfrm.in) · [LinkedIn](https://linkedin.com/in/guyfreemanstat) · [GitHub](https://github.com/gfrmin) · [Scholar](https://scholar.google.com/citations?hl=en&user=H422hdkAAAAJ). The two-page PDF is on the [contact page](/contact/).

## Summary

Statistician (Warwick PhD, Oxford BA, 1,750+ citations) who designs AI workflows and measures whether they actually work, including when the result is bad news for my own system. At Booking.com I designed the evaluation for an agentic LLM recommender and used it to redesign the system: task completion up about 2.7×, latency down an order of magnitude. At HSBC I design and measure LLM workflows for compliance and fraud. My research is on evaluating and governing autonomous AI agents — leak-proof scoring, power analysis, checks proven against adversarial candidates, and criteria signed before the code exists — and is written up as [*A Court for Agents*](/book/), in which every number can be recomputed from a public record.

## Experience

**Senior Data Scientist (contract), HSBC** — Hong Kong, August 2026 to present. Commercial banking data and analytics. Designed and measured a retrieval-augmented workflow, with guardrails, that answers third-party vendor compliance questionnaires. Designing and measuring improved address remediation to catch fraud: raw customer address data turned into signals of financial crime.

**Senior ML Scientist (contract), Booking.com** — Tel Aviv, March to June 2026. Designed a multi-arm offline evaluation framework (LLM-as-judge scoring, variance decomposition, automated prompt optimisation) to compare configurations of an agentic LLM recommender and choose models. Used it to redesign the system from a multi-step agentic loop into a leaner deterministic workflow, from research prototype to production. Separated a genuine model regression from an evaluation artefact through ablations; defined the metrics and judge design for a new itinerary-extraction feature; built judge-based metrics, trace-level observability and same-day A/B harnesses.

**Lead AI Engineer, Slice | Global Equity** — Tel Aviv, July 2025 to January 2026. Regulated fintech. Designed the document-AI pipeline (OCR with Claude and Gemini extraction) that replaced manual onboarding: 500+ legal and financial documents in 20 minutes at 95%+ accuracy.

**Machine Learning Engineer, Velotix** — Ramat Gan, October 2024 to May 2025. Designed anomaly detection that surfaced unauthorised database permissions across a million-plus tables and 50,000-plus users, replacing manual access reviews at a major Singaporean enterprise.

**Senior Data Scientist and team lead, Willis Towers Watson** — remote, May 2022 to October 2024. Led the data science behind an LLM product that automates job evaluations against WTW's grading methodology, deployed to enterprise clients. Early GPT-3 adopter; led a distributed team.

**Earlier** — Hong Kong and Tel Aviv, 2011 to 2022. Data Scientist, Entrée Capital (a deal-sourcing model found three pre-seed startups before announcement, all later funded); Business Analytics Senior Manager, HSBC; founder of Data Guru, a Hong Kong open-data company; Prudential Asia; EY; Postdoctoral Fellow, University of Hong Kong (causal inference, Mendelian randomisation).

## Research

**A Court for Agents, and jack** (2026). A court for a self-modifying agent: a signed, append-only record; a 450-line checker any party can replay; every suggestion a forecast under a proper score; promotion between layers by anytime-valid betting tests on pre-registered criteria. The monograph recomputes every figure from the public record. [The book](/book/) · [the founding essay](/posts/the-science-was-done/).

**assize** (2026). The predecessor court for coding agents: every check proven able to fail against a planted fault (81 of 81 at the seal), a sealed judge measured on a host with a Bayesian power analysis (a half-achievement improvement in Crafter detectable at 33 episodes per arm), AI builder, reviewer and auditor sessions whose forecasts are scored by log-loss and whose models are elected by their record. [The account](/posts/assize-at-the-seal/).

**Pre-registered evaluation of AI-built software** (2026). Acceptance tests signed before any code exists, so an AI builder cannot fit the checks; a red team that found fifteen ways past my own verification gate, each turned into a seeded failure the gate must catch; a pre-committed adoption gate that refused to adopt my own tool. [Signed Before the Code Existed](/posts/signed-before-the-code-existed/) · [Fifteen Ways Past My Own Gate](/posts/fifteen-ways-past-my-own-gate/) · [The Gate That Said No](/posts/the-gate-that-said-no/).

**Credence** (2024 to 2026). Decision-theoretic tool selection for LLM agents. When a one-line greedy ablation beat the full agent under fair conditions, I withdrew the planned paper and [published what survived](/posts/credence-paper/): the value of exploration depends on attribution quality. Applied spin-offs: a governor for a coding agent's tool calls that flagged an injected data exfiltration at 0.94 precision while interrupting 1.2% of safe sessions, and a model router at 96% lower cost than always using one premium model.

**doorplate.dev** (2026). Bayesian resolution of Hong Kong addresses, in English or Chinese, to the government gazetteer: 89.5% right and 3.8% wrong on real-world text.

## Education and publications

PhD and MSc (Distinction) in Statistics, University of Warwick; BA in Mathematical Sciences, University of Oxford. 1,750+ citations, including *BMC Medicine* (2013) and the *International Journal of Epidemiology* (2013); the chain event graph papers in the *Journal of Multivariate Analysis* and *Bayesian Analysis* (2011). English (native), Hebrew (advanced), Cantonese and Mandarin (basic).

## Skills

Evaluation design: offline evaluation frameworks, LLM-as-judge, variance decomposition, ablations, paired and A/B comparisons, power analysis, pre-registration, error analysis, proper scoring rules, ship/no-ship decisions. Statistics: Bayesian inference, causal inference, decision theory, value of information, sequential and anytime-valid testing. Tools: Python, SQL, R, Julia; Claude, GPT, Gemini; Arize, Langfuse.
