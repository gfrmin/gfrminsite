---
title: "Evolution Discovers How to Think: A Philosophical Journey in Code"
subtitle: "What if the cognitive architecture itself could evolve?"
description: "Part 2 of the Bayesian agent series. We confront the question of what should be designed versus what should be allowed to emerge, and discover that it's agents all the way up and all the way down."
author: "Guy Freeman"
date: 2026-01-31
categories: [python, bayesian, evolution, simulation, philosophy]
image: og-image.png
---

In [Part 1](/posts/bayesian-agent/), I built an agent that learns which foods are safe through Bayesian inference. It starts ignorant, observes outcomes, updates its beliefs using exact conjugate mathematics, and eventually acts with something resembling competence. Clean code, sound theory, and those belief distributions converging in real-time remain genuinely satisfying to watch, in the way that all correctly implemented mathematics is satisfying to watch.

Something has been nagging at me, though.

The agent learns *what* to believe. I designed *how* it believes. I chose the variables it perceives. I specified the structure of its world-model. I set the prior hyperparameters. The agent's entire cognitive architecture --- the shape of its epistemic machinery --- came from me, handed down like tablets from a mountain. The agent had no say in the matter. As someone who spent years doing Bayesian statistics, I should know better than to treat the model structure as given. The prior over model structures is the prior that actually matters, and I skipped it entirely.

What if the agent's theory of the world is wrong? What if reality's causal structure involves temperature and texture, but I've only given the agent sensors for shape and colour? It would dutifully learn the best possible beliefs *given its flawed framework*, converging beautifully on the wrong answer. The map would be internally consistent but catastrophically divorced from the territory. Posterior consistency is cold comfort when your likelihood function is missing the relevant variables.

This is the difference between learning within a framework and learning which framework to use. Part 1 addressed the former. This post is my attempt to think through the latter --- and to see whether code can force the kind of precision that philosophical prose lets you avoid.

## The Uncomfortable Question

Here is the question that started this whole endeavour: what should be designed by me, and what should be allowed to evolve?

It sounds like a technical question about simulation boundaries. It is actually a philosophical question about the origins of cognitive structure --- and it's one that biologists have been worrying about far longer than AI researchers. When we look at biological organisms, we see creatures whose perceptual systems, representational capacities, and inferential tendencies were shaped by millions of years of natural selection. A frog's visual system is exquisitely tuned to detect small moving objects. Not because some designer decided flies were important, but because ancestral frogs with fly-detecting visual systems left more descendants than those without. The frog doesn't learn to see flies. It learns *where* the flies are, using machinery that evolution already provided.

Two timescales of adaptation, then. Within a lifetime, organisms learn: they update beliefs, acquire skills, form memories. Across generations, populations evolve: body plans change, neural architectures shift, innate behaviours emerge or disappear. The genome specifies *how* to learn; learning fills in *what* is believed. Nature provides the form; nurture provides the content. This is just hierarchical Bayesian modelling with a very slow outer loop and a mortality-based convergence criterion.

I wanted my Bayesian agents to work the same way. Implementing this forced me to confront questions I hadn't anticipated, which is presumably why one implements things.

## The Hierarchy of Fixedness

Consider all the things one might hold fixed or allow to vary in a simulation like this. They arrange themselves into a tidy hierarchy, which I find suspicious but useful.

At the bottom sits the physics of the simulated world --- grid topology, energy conservation, the basic rules of movement and consumption. These feel genuinely architectural. Varying them would mean running a different simulation entirely, and I've enough to think about with one simulation.

Above that, the representational substrate. Can agents represent probabilities at all? Do they have access to uncertainty quantification, or only point estimates? Is Bayesian inference even available as a cognitive operation, or must they make do with simpler associative mechanisms? This is the question of whether agents inhabit a universe where probability theory exists, which is a strange thing to have design authority over.

Then the model structure. Given that an agent can represent probabilities, which variables does it include in its world-model? Which dependencies does it posit between them? This is the agent's theory of causation --- its assumptions about what relates to what. In Bayesian terms, this is the DAG.

Next, model parameters: prior means, variances, learning rates. These shape how quickly beliefs change and how much weight is given to new evidence versus old convictions. The difference between an agent that updates its priors after one poisoning and one that needs five poisonings to reconsider --- that's a parameter choice, and it matters a great deal if you're the one being poisoned.

Finally, at the top, the beliefs themselves --- the actual probability distributions over states of the world. These are clearly learned, not inherited. Passing them to offspring would be Lamarckian, and we've known since Weismann that acquired characteristics don't work that way. (Though epigenetics has complicated this story somewhat. Biology has a talent for complicating stories.)

When I built the original agent, I fixed everything except the top level. The agent learned beliefs, and I supplied the rest. The question now is: how far down this hierarchy can we push the boundary? What happens when we let more of it evolve?

## The Genome as Cognitive Blueprint

I decided to give agents genomes that encode their cognitive architecture. Not their beliefs --- those remain learned --- but the *shape* of their belief-forming machinery.

A genome specifies three things.

First, **sensors**: which attributes of the world this agent can perceive. Reality in my simulation has many attributes --- shape, colour, size, texture, temperature, luminosity, sound, smell --- but any given agent might only perceive a subset. An agent with sensors for shape and colour but not temperature is, in a meaningful sense, blind to temperature. It will never form beliefs about temperature's relevance because it cannot observe temperature at all. You can't update on data you can't see, which is either a limitation of Bayesian inference or a limitation of having eyes, depending on your philosophical commitments.

Second, **Bayesian network structure**: which perceived variables the agent models as relevant to predicting outcomes. Having a sensor for texture doesn't mean the agent *uses* texture in its predictions. The BN structure encodes the agent's theory --- its assumptions about what causes what. An agent might perceive five attributes but theorise that only two of them matter. This is model selection, embedded in the genome.

Third, **priors**: the initial beliefs before any learning occurs. The prior mean (is the agent optimistic or pessimistic about unknown foods?), the prior variance (how uncertain does it start?), and the pseudo-observation count (how easily do new observations override the prior?). These are the hyperparameters I hand-set in Part 1. Now evolution gets to argue about them instead.

This separation creates a genuinely interesting dynamic. Two agents might have identical genomes but different learned beliefs, because they encountered different foods during their lifetimes. Conversely, two agents might have similar beliefs but very different genomes --- one achieving accurate beliefs despite a clumsy cognitive architecture, the other arriving at the same place more elegantly. Same posterior, different generative process. The genome doesn't say "circles are good." It says "attend to shape" and "start with moderate uncertainty." The agent then discovers whether circles are good through its own experience. But if the genome says "ignore shape entirely," no amount of experience will teach the agent about circles, because it cannot perceive them.

## Reality as the Hidden Curriculum

If genomes are going to evolve, they need something to evolve *against*. There must be a fitness landscape --- some notion of which cognitive architectures work better than others. This requires taking seriously the idea that reality has a structure that agents are trying to approximate.

So I built a "Reality" module that defines the true causal structure of the simulated world. The territory to the agents' maps. It specifies what actually determines food energy values: which attributes matter, how they interact, whether there are hidden variables agents cannot perceive.

The design philosophy was to make reality arbitrarily complex and potentially unknowable. Reality might involve variables agents can perceive, but also variables they cannot --- like the quadrant of the map where food spawned, or the phase of some hidden cycle, or (and this pleased me enormously) the actual hour of the day in my timezone. An agent doing especially well at 3am London time might owe its success to factors it could never possibly model. This felt like a suitably theological joke for someone designing a small universe.

This creates a principled gap between what agents can learn and what is true. An agent with perfect inference will converge on the best possible beliefs *given its sensors and model structure*, but if reality's causal structure involves factors outside its perceptual reach, those beliefs will be systematically wrong in ways the agent cannot detect from the inside. The posterior is exact. It's also exactly wrong.

This felt important to get right. Too often in AI research, we evaluate agents in environments perfectly matched to their architectures, which is rather like testing a map by checking whether it's consistent with itself. By allowing reality to be richer than any agent's model, we create genuine pressure for evolution to discover better architectures --- and genuine humility about whether any architecture is sufficient.

## The Population as Agent

Here is the insight that reframed the whole project for me, and it has the slightly alarming quality of all good reframings: the population is itself an agent.

An individual agent has beliefs --- probability distributions over food values. What does a population have? A distribution over genome types. These are the same kind of thing: probability measures over possible states. The individual agent's beliefs represent uncertainty about the world; the population's genome distribution represents "uncertainty" (in a metaphorical but not entirely metaphorical sense) about which cognitive architectures work.

An individual agent learns by updating beliefs in response to observations. A population learns by differential reproduction --- genomes that produce successful agents become more common, while genomes that produce failures become rare. Bayesian updating and natural selection are both mechanisms for concentrating probability mass on hypotheses that fit the evidence. I spent years doing the former professionally. The latter has been running somewhat longer.

An individual agent acts to maximise expected utility given its beliefs. A population... well, this is where the metaphor strains, but something selection-like is happening: the population "acts" by producing new agents, and the distribution of those agents shifts toward higher-fitness designs.

If you squint, it's agents all the way up. An individual agent. A population of agents. A meta-population of different evolutionary strategies. At each level, the same pattern: representations of uncertainty, mechanisms for updating those representations, actions that depend on current beliefs. The levels differ in their timescales and substrates, but the abstract structure rhymes. It's hierarchical Bayesian modelling with legs. Literally.

This view has a vertiginous quality. Where does it stop? Is there a top level, or do the meta-levels continue indefinitely? And if the pattern holds at every level, what does that tell us about the nature of agency itself? I don't have answers. But I find the questions more productive than most questions I encounter, which is my criterion for whether a question is worth keeping.

## On the Cost of Cognition

One decision I made early on was to reject artificial costs for thinking.

Many evolutionary simulations impose metabolic penalties on cognitive complexity: a larger brain costs more energy to maintain, so there's pressure to evolve only as much intelligence as strictly necessary. This is biologically plausible --- the human brain consumes roughly 20% of our metabolic budget --- and it creates interesting dynamics where simple heuristics can outcompete sophisticated inference if the environment is sufficiently accommodating.

But I decided against it. Imposing artificial costs requires me to decide what cognition is and how to measure its expense. Is a larger sensor suite more costly than a smaller one? Is a denser Bayesian network more expensive than a sparse one? These questions don't have principled answers in my simulation. Whatever numbers I choose would be arbitrary, and that arbitrariness would shape the evolutionary outcomes in ways that reflect my modelling choices rather than anything fundamental. I'm already playing God with the fitness function; I'd rather not also play God with the metabolic budget.

Instead, I let time be the only cost. An agent that "thinks longer" simply acts later, and the world moves on while it deliberates. If pondering every decision means missing opportunities, evolution will discover this and favour faster cognition. If hasty action leads to eating poison, evolution will discover that too. The cost of cognition emerges from the dynamics rather than being imposed by fiat.

This feels cleaner, though I'm not certain it's right. There's an argument that explicit cognitive costs are necessary to prevent evolution from discovering implausibly expensive solutions that would never be viable in resource-constrained reality. For now, I'm letting the simulation speak. It hasn't said anything obviously absurd yet.

## First Results

When I ran the simulation, I was holding my breath a little. Simulations have a talent for producing either nothing or nonsense, and either outcome would have been deflating.

The results were modest but real, which is the best kind of result.

In what I called the "simple reality" --- where shape and colour independently affect food energy --- agents evolved to model shape as the primary relevant variable. This is correct: in that reality, shape has the largest effect. The best agents had genomes that said "perceive shape, model shape as predicting energy" and had learned beliefs that correctly ranked circles above squares above triangles. Evolution discovered the right model structure, and Bayesian inference filled in the right parameters. The two timescales working together, as advertised.

More interestingly, in the "interaction reality" --- where certain shape-colour combinations have synergistic effects --- some agents evolved to model only colour. This initially surprised me. Doesn't colour capture less information than the full shape-colour combination? But on reflection, it makes sense: green is correlated with the best outcome (the green-circle synergy), and modelling colour alone is simpler than modelling the full interaction. The agent found a heuristic that works well enough without capturing the true structure. A statistician would call this model misspecification that happens to have low predictive loss. A biologist would call it adaptation.

In the "hierarchical reality" --- where temperature and texture interact in ways that shape and colour don't capture --- the agents struggled. They couldn't discover the true causes because those causes involved attributes outside their initial sensor suites. Evolution would need to first expand their perceptual capacities before they could form accurate theories. You can't infer what you can't observe, no matter how long you run the Markov chain.

This last result points to a limitation of the current framework. Sensor suites can mutate, but the mutations are random. There's no directed search toward sensors that would be useful; evolution just tries things and sees what survives. In a reality where the relevant attributes are rare in genome-space, it might take a very long time for evolution to stumble upon them. This is either a flaw in my simulation or a fairly accurate description of actual evolution, depending on one's level of ambition.

## The God's-Eye View

There's one more dimension to this project I haven't mentioned: I'm not just an observer. I'm the designer of the fitness function.

When I talk about agents "succeeding" or "failing," what I mean is that they perform well or poorly according to criteria I've specified. Currently, that criterion is net energy gain --- the agent's foraging success. But there's nothing sacred about this. I could define fitness as "time spent in the northwest quadrant" or "number of red triangles eaten" or anything else I can compute from the agent's behaviour. The agents would dutifully evolve to satisfy whatever objective I imposed, with no capacity to question whether it was a sensible one.

This reframes what the simulation is doing. The agents aren't evolving to succeed in some absolute sense; they're being bred to satisfy my objectives. Natural selection, in this context, is a mechanism for aligning agent behaviour with designer intent. This is, if you think about it for more than a few seconds, exactly what we're trying to do with AI alignment, except that evolution is doing the alignment and taking its time about it.

The implications are ones I'm still thinking through. If I wanted agents that maximise my wealth (as I mentioned in the conversation that prompted this project), I'd need to define a fitness function that rewards wealth-generating behaviour. The agents would then evolve cognitive architectures suited to that objective. But --- and this is the crux --- they'd have no understanding of *why* they're doing what they're doing. They'd be executing evolved heuristics that happen to correlate with my utility. Correlation without comprehension.

Is this a bug or a feature? On one hand, agents optimised for proxy objectives might Goodhart's Law their way into behaviours that satisfy the letter of the fitness function while missing its spirit. On the other hand, we're not pretending the agents have goals of their own. They're tools, shaped by selection to serve purposes they cannot comprehend.

I find this more intellectually honest than approaches that try to give agents explicit utility functions and then align those functions with human values. The alignment here is implicit, embedded in the selection process itself. Whether it's more practical for real-world applications is another question --- one that my toy simulation is magnificently unqualified to answer.

## What I Still Don't Know

This project has raised more questions than it's answered, which I take as evidence that the questions are real rather than artefacts of my implementation.

**Can the evolutionary process itself evolve?** I've fixed the mechanism of variation (mutation) and selection (fitness-based reproduction). But in biological evolution, these mechanisms are themselves products of evolution. Sexual reproduction, mutation rates, developmental plasticity --- all of these evolved. Could I set things up so that not only do agents evolve, but the mutation operators and selection pressures evolve too? Meta-evolution. I don't yet know how to implement it without the whole thing collapsing into infinite regress, which would be philosophically appropriate but computationally unhelpful.

**What's the minimal fixed point?** I've been asking what should be designed versus what should evolve, but there's a deeper question: what's the minimal kernel from which everything else can emerge? Fix too much and you've prejudged the solution. Fix too little and you get primordial soup that never organises. Somewhere between is a Goldilocks zone of generative constraints. Finding it feels like the genuinely hard problem --- harder than any of the inference problems the agents face.

**Does this tell us anything about real minds?** I'm wary of overclaiming. Simulations like this are toys, and biological cognition is unfathomably more complex. But there's something compelling about the idea that the *structure* of cognition --- not just its contents --- is subject to optimisation pressure. If that's true for evolved minds, it might inform how we think about designing artificial ones. Might. I'm hedging deliberately.

**What about structure learning within a lifetime?** Currently, the Bayesian network structure is fixed by the genome. An agent is born with a theory of what matters and never revises that theory, only the parameters within it. But sophisticated learners --- humans, say --- can revise their ontologies. We don't just update beliefs within a framework; we sometimes discard the framework and adopt a new one. Thomas Kuhn wrote a famous book about this. Allowing within-lifetime structure learning would be more powerful but substantially harder to implement. It's on the list.

## The Code

The implementation is a few hundred lines of Python, no ML frameworks required. Four modules.

**reality.py** defines the true causal structure of the world. Which attributes exist, how they combine to determine food energy, whether there are hidden variables or external dependencies (like real-world time). Several preset realities are included for experimentation.

**cognitive_genome.py** defines the heritable specification of cognitive architecture. It encodes sensors, Bayesian network structure, and priors, with mutation and crossover operators for evolution.

**bayesian_agent.py** implements agents that learn within their lifetimes. Each agent uses its genome to determine what it perceives and how it models the world, then does exact Bayesian inference to update beliefs based on experience.

**simulation.py** orchestrates the evolutionary process. It runs generations, applies selection, produces offspring, and tracks statistics over evolutionary time.

Running it looks like this:

```python
from simulation import run_experiment

sim = run_experiment(
    reality_type='simple',      # or 'interaction', 'hierarchical', 'temporal'
    num_generations=50,
    population_size=30,
    verbose=True
)

# What did evolution discover?
best = sim.best_ever
print(f"Sensors: {best['sensors']}")
print(f"BN structure: {best['bn_structure']}")
print(f"Learned beliefs: {best['beliefs']}")
```

Typical output shows evolution converging on sensible architectures --- agents that model the variables that actually matter and learn correct (or at least useful) beliefs about them.

The code is on [GitHub](https://github.com/gfrmin/bayesian-agent), alongside the original Part 1 implementation. Fork it, break it, extend it. The framework is modular enough to support experimentation with different realities, different genome structures, different selection pressures. I'm curious what others will find.

## Where This Leaves Me

I started this project wanting to understand what happens when cognitive architecture itself can evolve. I ended up thinking about the fractal nature of agency, the gap between map and territory, the relationship between optimisation and alignment, and the question of what should be designed versus what should be discovered. The usual trajectory: you set out to answer one question and return with several better ones.

The code works --- agents evolve, beliefs are learned, fitness improves over generations. But the code was always a vehicle for thinking, not an end in itself. You write the simulation to discover what you think, and then the simulation tells you things you hadn't thought.

Friston talks about the free-energy principle: all adaptive systems minimise surprise through a combination of updating beliefs and acting on the world. Hinton and Nowlan wrote about how learning can guide evolution, allowing plastic individuals to survive in novel environments long enough for selection to consolidate their gains. Baldwin proposed this over a century ago, and biologists are still working out the implications. I don't think my toy simulation adds much to that serious scientific work. But building things clarifies my thinking in ways that reading alone does not. The act of specifying data structures for genomes and beliefs and realities forces a precision that philosophical discourse permits you to evade. And when the simulation produces results you didn't expect, it's a useful corrective to the conviction that you understood your own model.

The agents in my simulation are not conscious, do not understand what they're doing, and serve purposes they cannot comprehend. In that sense, they're nothing like us. But in another sense --- in the sense that they adapt on multiple timescales, that their cognitive structures are shaped by forces outside their awareness, that they navigate a gap between what they can model and what is true --- perhaps they're more like us than we'd prefer to admit.

I'll keep tinkering.
