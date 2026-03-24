---
title: "Why We Stopped Using the Mathematics That Works"
subtitle: "Path dependence, convenience, and the quiet victory of good enough"
description: "Someone asked why decision theory stopped being widely used in AI. The answer involves ImageNet, academic departments, and the seductive power of not having to specify your objectives."
author: "Guy Freeman"
date: 2026-03-09
categories: [essays, bayesian, machine-learning, ai]
image: og-image.png
---

Someone asked a good question. I'd written [a post](/posts/agentic-ai/) arguing that what the industry calls "AI agents" are flowcharts with good marketing, and that the mathematics to do better has existed since the 1960s. A commenter on LinkedIn replied: "So why did it stop being widely used?"

I sat with this for a day. It deserved a proper answer, not least because I'd spent a decade watching it happen from inside a statistics department and had never quite articulated the mechanism to myself.

## The ImageNet Moment

In 2012, Alex Krizhevsky submitted a deep convolutional neural network to the ImageNet Large Scale Visual Recognition Challenge. It won by 9.8 percentage points over the nearest competitor. In a field accustomed to incremental improvements of fractions of a percent, this was less a result than a controlled demolition of the existing order.

What happened next was not a reasoned evaluation of competing paradigms. I want to be charitable about this, but honesty forbids it. It was a gold rush. Google hired Geoffrey Hinton. Facebook hired Yann LeCun. Baidu hired Andrew Ng. The Canadian Institute for Advanced Research, which had quietly funded neural network research through two decades of indifference, suddenly found its bet paying off spectacularly. Venture capital followed. PhD students followed the venture capital. Conference papers followed the PhD students. The causal chain had the relentless logic of a gradient descent, except that nobody was optimising for truth.

Within five years, deep learning had consumed machine learning almost entirely. Not because the methods it displaced had stopped working --- I can assure you they hadn't --- but because the money, the talent, and the prestige had moved elsewhere. The researchers who understood decision theory, Bayesian inference, and operations research didn't lose their arguments. They lost their audience. Which, in academia, amounts to the same thing.

## Disciplinary Geography

There's a structural problem that predates the deep learning boom, and it's the kind of problem that only an academic could love: the methods that constitute good decision-making under uncertainty are scattered across departments that maintain a studied indifference to each other's existence.

Decision theory sits in philosophy and economics. Bayesian statistics sits in statistics departments that spent most of the twentieth century actively hostile to it. Operations research sits in business schools and industrial engineering. Reinforcement learning, the one branch that maintained diplomatic relations with mainstream AI, drifted toward deep learning and quietly shed its decision-theoretic roots like a social climber dropping an unfashionable accent.

The result is a kind of intellectual diaspora. The ideas exist; they're published; they're mathematically mature. But no single department teaches them as a coherent toolkit, and no single conference brings their practitioners together. NeurIPS received over 28,000 submissions in 2024. The flagship OR conference gets a few thousand. The researchers haven't disappeared, but they're outnumbered perhaps fifty to one by people who've never encountered their work.

Methods that aren't taught don't get used. I keep returning to this sentence because it does more explanatory work than anything else I could write.

## The Specification Problem

There is, to be fair, a more sympathetic explanation for the shift. Decision theory asks you to do something genuinely difficult: write down what you want.

A Bayesian decision-theoretic agent needs explicit utility functions, cost models, prior distributions, and a formal description of the action space. Every assumption must be stated. Every trade-off must be quantified. This is intellectually honest and practically gruelling, rather like being asked to itemise your preferences at a restaurant that serves everything. Getting the utility function wrong doesn't just give you a bad answer; it gives you a confidently optimal answer to the wrong question, which is considerably worse.

Deep learning asks for none of this. Collect data, define a loss function (usually cross-entropy or mean squared error, chosen almost by convention), and let the model find patterns. You don't need to specify what you believe about the world; the network will learn its own representations. You don't need to enumerate your objectives; gradient descent will optimise whatever you point it at.

This is enormously convenient. And convenience is underrated as an explanatory variable in the history of ideas --- possibly the most underrated. The frequentist victory over Bayesian statistics in the early twentieth century followed a similar pattern: not because frequentist methods were better, but because they were computationally tractable with the tools available. When MCMC methods made Bayesian computation feasible in the 1990s, Bayesian statistics experienced a genuine revival. The ideas hadn't changed. The convenience had. I was there for the tail end of this revival, watching people rediscover results that Jeffreys had published in 1939, and the whole business had a faintly archaeological quality to it.

Deep learning's convenience advantage is the same phenomenon at larger scale. Why specify a prior when you can train on a million examples? Why model uncertainty when you can just make the network bigger? The answers to these questions are good answers --- genuinely good, I mean, not merely rhetorically satisfying --- but they require you to care about things the market doesn't always reward.

## Good Enough

And here we arrive at the commercial reality, which is the part that actually determines what gets built.

For most applications that generate revenue, a system that gets the answer roughly right is more valuable than a system that gets it optimally right but took three times longer to build. The gap between "approximately correct" and "decision-theoretically optimal" is real, but it lives in the tails: the edge cases, the adversarial inputs, the distributional shifts that happen at 3am on a Sunday when nobody is watching the dashboards. By the time those matter, the product has shipped and the team has moved on to a new product that will also ship before its edge cases matter.

This is the VHS-versus-Betamax dynamic, or TCP/IP versus the OSI model, or QWERTY versus every ergonomic alternative proposed since 1936. The technically superior solution loses to the solution that's easier to deploy, easier to hire for, and good enough for the use cases that pay the bills. Decision theory is Betamax: genuinely better in measurable ways that most buyers don't measure. I have made my peace with this. Mostly.

The market rarely punishes you for confusing correlation with causation. At least, not immediately. The punishment arrives later, in the form of systems that can't adapt when conditions change, recommendations that optimise engagement metrics while destroying the thing they're meant to recommend, and autonomous agents that [query every tool for every question](/posts/decision-theory-agents/) because they have no concept of whether a query is worth its cost. But these are slow-moving consequences, and quarterly earnings reports are fast-moving incentives. The discount rate on rigour is, empirically, quite high.

## Fashion in Methodology

Bayesian methods have been going in and out of fashion since Thomas Bayes himself, who derived his theorem in the 1740s and then, apparently finding the result insufficiently convincing, declined to publish it. Richard Price published it posthumously. Laplace rediscovered and extended it. Fisher attacked it with the zeal of a man who took prior distributions as a personal affront. Jeffreys defended it. The entire twentieth century was an argument about whether you were allowed to have prior beliefs, conducted with a passion that suggests the participants understood the stakes were more theological than statistical.

MCMC brought Bayesian methods back in the 1990s. Deep learning pushed them out again in the 2010s. Now, in the mid-2020s, the limitations of pure pattern-matching are becoming visible enough that probabilistic methods are creeping back: Bayesian neural networks, conformal prediction, probabilistic programming languages. The wheel turns. It has the regularity of a trigonometric function, if trigonometric functions took about thirty years per cycle.

I find this cyclical pattern more explanatory than any single technical argument. Ideas in methodology don't win or lose on merit alone. They win when there's a community to teach them, hardware to run them, problems that visibly need them, and advocates charismatic enough to attract funding. Deep learning had all four simultaneously. Decision theory had the mathematics but lacked the rest. Having the best answer and no microphone is, in practice, indistinguishable from having no answer at all.

## What Might Change

The methods never stopped working. The [Bayesian agent I built](/posts/agentic-ai/) uses nothing more exotic than Beta distributions and expected-value-of-information calculations. It outscored a LangChain agent by 120 points not because it was smarter, but because it could answer a question that LangChain cannot even pose: is the next tool query worth its cost?

Whether this matters beyond a toy benchmark remains to be seen. But the question the commenter asked --- why we stopped using these methods --- has a clear answer: not because they failed, but because something shinier came along, and the institutions that transmit knowledge reorganised themselves around the new shiny thing. This has happened before. It will happen again. The half-life of methodological fashion is shorter than most practitioners' careers, which means if you wait long enough, your unfashionable expertise becomes avant-garde.

The interesting question is whether, this time, we'll remember what we already knew. Or whether the next generation will have to rederive it from first principles, with the slight embarrassment of someone discovering that the library book they needed was on the shelf the whole time, just filed under a department they'd never visited.
