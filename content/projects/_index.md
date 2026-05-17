---
title: "Projects"
---

A selection of research tools, open source projects, and civic tech initiatives.

<div class="project-card">
<h3><a href="https://github.com/gfrmin/credence" target="_blank">Credence</a></h3>
<p>Bayesian agent framework for principled LLM tool selection. Maintains Beta posteriors over tool reliability, computes expected value of information before each query, and maximises expected utility across a coherent objective function. Benchmarked against LangChain ReAct: scored +112 vs -8 despite lower raw accuracy. Written in Python with NumPy and SciPy.</p>
</div>

<div class="project-card">
<h3><a href="https://docavivplus.gfrm.in" target="_blank">docaviv+</a></h3>
<p>A faster, mobile-friendly discovery frontend for the Tel Aviv International Documentary Film Festival (docaviv.co.il). Bilingual Hebrew/English with RTL support, fuzzy search, day-by-day schedule grid, and per-screening ticket links. Built as a static Astro site that ingests the festival's WordPress REST API plus a small cheerio scraper that recovers metadata (synopses, runtime, trailers, ticket URLs) only exposed in the rendered HTML. Hosted on Cloudflare Pages.</p>
</div>

<div class="project-card">
<h3><a href="https://accessinfo.hk" target="_blank">accessinfo.hk</a></h3>
<p>Hong Kong's Freedom of Information request platform. Makes it easier for citizens to submit and track FOI requests to government bodies. Built on the Alaveteli platform.</p>
</div>

<div class="project-card">
<h3><a href="https://webbsite.renavon.com" target="_blank">Webb Data</a></h3>
<p>Open data platform providing 35 years of Hong Kong financial data—directors, boards, CCASS shareholding, and company registry records. Making corporate transparency accessible.</p>
</div>

<div class="project-card">
<h3><a href="https://github.com/gfrmin/scalibur" target="_blank">Scalibur</a></h3>
<p>Python tool for reading body composition data from cheap Bluetooth scales. Reverse-engineered BLE protocol, handles impedance measurements, and calculates body fat, muscle mass, and metabolic metrics. Designed to run on a Raspberry Pi for continuous data collection.</p>
</div>

<div class="project-card">
<h3><a href="https://github.com/gfrmin/jarvis-lite" target="_blank">Jarvis Lite</a></h3>
<p>A Getting Things Done (GTD) Telegram bot with natural language task parsing. Uses Claude Haiku for intent recognition, PostgreSQL for storage, and APScheduler for daily digest emails. Self-hostable.</p>
</div>

<div class="project-card">
<h3><a href="https://t.me/gtdlitebot" target="_blank">GTD Lite Bot</a></h3>
<p>Live hosted instance of Jarvis Lite. Try it out on Telegram.</p>
</div>

<div class="project-card">
<h3><a href="https://github.com/gfrmin/bayesian-agent" target="_blank">bayesian-agent</a></h3>
<p>Simulation framework for autonomous agents that learn to navigate an environment using Bayesian inference and Thompson sampling. Demonstrates online probabilistic learning and principled uncertainty quantification.</p>
</div>
