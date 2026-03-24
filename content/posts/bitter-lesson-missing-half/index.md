---
title: "The Bitter Lesson Has No Utility Function"
subtitle: "On being told I disagreed with an essay I hadn't read"
description: "I wrote about decision theory fading from AI. Hacker News said I was annoyed at Rich Sutton's Bitter Lesson. I wasn't. But the misreading proves the point."
author: "Guy Freeman"
date: 2026-03-12
lastmod: 2026-03-13
categories: [essays, bayesian, machine-learning, ai]
---

I wrote [an essay](/posts/why-decision-theory-lost/) arguing that decision theory had been quietly abandoned by mainstream AI --- not because it stopped working, but because deep learning absorbed all the oxygen. I posted it to [Hacker News](https://news.ycombinator.com/item?id=47306334). A commenter informed me I was "annoyed at the Bitter Lesson."

I hadn't read the Bitter Lesson. This proved awkward for approximately forty-five seconds, after which it proved illuminating.

So I read it. Rich Sutton's [essay](http://www.incompleteideas.net/IncIdeas/BitterLesson.html), published in 2019, argues that general methods leveraging computation consistently beat methods built on hand-crafted human knowledge. Chess: deep search beat hand-tuned evaluation. Go: self-play beat human strategy. Speech recognition: statistical methods beat phoneme engineering. Computer vision: neural networks beat edge detectors. The pattern, he argues, has held for seventy years:

> We should build in only the meta-methods that can find and capture this arbitrary complexity. Essential to these methods is that they can find good approximations, but the search for them should be by our methods, not by us.

He's right. Or at least he's right about everything he addresses, which turns out to be a smaller territory than his readers seem to think. I said as much in the original essay: deep learning won on genuine merits --- convenience, scalability, and the brute fact that it works astonishingly well at perception tasks. I am not relitigating whether AlphaGo should have used hand-crafted Go heuristics. It shouldn't have. That debate is over, and I rather wish people would stop inviting me to reopen it.

## What I Actually Argued

My essay wasn't about perception. It was about decision-making. These are related in the way that eyesight is related to choosing a restaurant.

Decision theory doesn't compete with deep learning for the same job. It doesn't offer an alternative way to classify images or transcribe speech. It answers a different question entirely: given uncertainty about the world and finite resources, what should you *do*?

Is the next API call worth its cost? Which experiment should you run next? Should you gather more information or act on what you have? These are resource-allocation problems under uncertainty, and they have a mathematical framework that predates neural networks by decades: prior distributions, utility functions, expected value of information. Pattern recognition cannot answer them, no matter how much compute you feed it, for the same reason that a very powerful telescope cannot tell you where to point it.

The Bayesian agent I built didn't outperform a LangChain agent because it was better at reading text. It outperformed it because it could answer a question LangChain cannot even pose: *is the next tool query worth its cost?*

## The Category Error

Hacker News, in its infinite wisdom, sorts AI arguments into two camps:

- **Camp A**: Hand-crafted domain knowledge --- symbolic AI, expert systems, feature engineering
- **Camp B**: General methods plus compute --- deep learning, scaling, the Bitter Lesson

Sutton says Camp B wins. [Commenters filed my essay under Camp A.](https://news.ycombinator.com/item?id=47355077) But decision theory doesn't sit on this axis. It's not a competing method for perception. It's a framework for action. Filing it under "hand-crafted knowledge" is like filing double-entry bookkeeping under "calligraphy" because both involve writing things down.

Think of the Bitter Lesson as saying "money solves everything." Money does solve a lot --- the historical pattern is real, and I'd be a fool to deny it. But money doesn't tell you what to spend it on. That's what's missing: the Bitter Lesson has no utility function. "Leverage computation" --- toward what end? Sutton's essay is entirely about capability, about which method wins the benchmark. It is silent on purpose. Magnificently, comprehensively silent.

And money, famously, is finite. Sutton's argument rests on Moore's Law making computation abundant, but training runs still cost millions. The question "is this next dollar of compute worth spending?" is itself a decision-theoretic problem --- one that more compute cannot answer, because you need a utility function to evaluate whether the next unit of computation buys enough to justify its cost. It's rather like trying to determine whether your holiday was value for money by going on another holiday. The question lives outside the Bitter Lesson's frame entirely.

Then there is the matter of whose values get encoded. If you don't specify your objectives, you haven't removed human judgement from the system. You've buried it in the loss function, the training data, the deployment context --- which is to say, in places where it can do the most damage while being the least examined. Decision theory forces you to state what you want. In a world increasingly and justifiably worried about what AI systems are optimising for, that might be the most important feature a framework can have.

## The Self-Proving Point

The [Hacker News thread](https://news.ycombinator.com/item?id=47355077) made my argument better than I did, which I find slightly galling but mostly gratifying. Technically sophisticated readers --- people who understand gradient descent, who can discuss AlphaGo's architecture in detail, who've read Sutton --- heard "mathematics that isn't deep learning" and reached for the only frame available. They assumed I was arguing for Camp A. Of course they did. If your taxonomy has two categories, everything gets sorted into one of them.

I wasn't arguing for Camp A. I was pointing at a question the Bitter Lesson doesn't address. The mistake wasn't disagreeing with me --- reasonable people can disagree about all sorts of things --- it was not recognising that the argument occupied different ground entirely. One commenter noted that symbolic AI did try to handle uncertainty: MYCIN used certainty factors in the 1970s. Fair point --- but those certainty factors were ad hoc and mathematically inconsistent, as Heckerman demonstrated rather thoroughly. Symbolic AI attempted the mathematics and got it wrong. That's a different problem from never asking what to optimise for. Confusing the two is like confusing bad navigation with not having a destination.

That distinction --- between getting the mathematics wrong and skipping it altogether --- is precisely what vanished from the field's working memory. Methods that aren't taught don't get used. And apparently, they don't get recognised when someone describes them, either.

The wheel turns. Bayesian methods have gone in and out of fashion since Bayes himself declined to publish his theorem, which remains one of history's better demonstrations of prior uncertainty about one's own work. The question is whether we'll remember them or have to rediscover them from scratch.

{{< callout type="note" >}}
## Editorial note
This essay was revised on 13 March 2026 in response to [feedback on Hacker News](https://news.ycombinator.com/item?id=47355077), particularly on the false boundary I originally drew between symbolic AI and decision theory.
{{< /callout >}}

## Postscript: On Process

Several commenters suggested the original essay was written by an LLM. They were half right, which as a Bayesian I find an acceptable posterior. Both that essay and this one were written with Claude as a drafting partner. I directed the argument; the LLM helped with prose. I mention this not as confession but as demonstration: the human brought the utility function, the machine brought the compute. If that division of labour bothers you, I'd suggest the discomfort says more about the Bitter Lesson than about my writing process.
