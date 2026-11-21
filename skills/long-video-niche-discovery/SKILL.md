---
name: long-video-niche-discovery
description: Find a differentiated video niche and a first video topic by applying seven discovery lenses (subject migration, angle inversion, hidden sub-niche, adjacent audience, format transplantation, perspective shift, cross-niche combination) to a niche, channel or video the user already likes. Returns the 10 strongest candidates, then episode topics for the chosen one. Called by long-video-story when the user picks the "niche" story style; also usable on its own.
---

# Long video niche discovery

An idea generator. It finds a niche worth making videos in, and a first topic inside it. It does not write the story.

Called by `long-video-story`. Return the chosen topic to the caller. When run alone, show the result and stop.

## Input

Collect before starting. Skip what the caller already passed.

1. **Starting point.** A niche, a channel, or a specific video that works well. Ask: "Which niche, channel or video should I start from?"
2. **Constraints (optional).** Language, audience, production limits, topics to avoid. Take what you can from the project config (`audience`, `visuals.approach`, `video.target_length_min`, budget).

If the user has no starting point, ask for a broad interest area and use it as the starting niche.

## Method

Study the starting point first. State to yourself: the storytelling mechanism, the audience and what they feel (curiosity, fear, awe, nostalgia), the repeatable format, and why it works.

Then apply the seven lenses.

### Lens 1: Subject migration
Keep the storytelling mechanism but change the subject.
Example: famous corporate collapses become forgotten transportation disasters.

### Lens 2: Angle inversion
Approach the original niche from an overlooked or opposite perspective.
Example: how megaprojects were built becomes why megaprojects became impossible to maintain.

### Lens 3: Hidden sub-niche
Find a narrow, specific subject inside a larger successful niche.
Example: ancient history becomes ancient economic fraud and financial scandals.

### Lens 4: Adjacent audience
Identify another audience motivated by similar emotions and interests.
Example: military strategy viewers become historical survival and escape strategy viewers.

### Lens 5: Format transplantation
Take a successful content format and apply it to a subject usually presented differently.
Example: day-by-day survival storytelling becomes day-by-day accounts of historical expeditions.

### Lens 6: Perspective shift
Tell familiar stories from the viewpoint of overlooked participants or systems.
Example: history of famous battles becomes the supply chains that determined their outcomes.

### Lens 7: Cross-niche combination
Combine two compatible audience interests into a distinctive concept.
Example: historical mysteries plus engineering becomes forgotten engineering decisions that changed history.

## Discovery rules

1. Generate a broad candidate pool internally. Do not show it.
2. Remove:
   - near-duplicate ideas
   - generic mainstream niches without differentiation
   - ideas with no plausible audience
   - concepts that depend on a single viral video
   - niches with too few repeatable subjects
   - ideas too expensive or complex to produce, judged against the config's visuals and budget
   - angles that merely imitate the original competitor
3. Present only the 10 strongest candidates.
4. Do not force equal representation from each lens. Quality matters more than category balance.

## Present the candidates

Number them 1 to 10, strongest first. Each card:

```
<number>. <Niche name>
Lens: <which lens produced it>
Idea: <one sentence>
Audience: <who watches and why>
Repeatable subjects: <3 example subjects>
Production: <one line: easy / medium / hard, and why>
```

Ask the user to pick one, combine two, ask for more, or give a new starting point.

If the user asks for more: run the discovery again and show 10 new candidates. Never repeat one already shown. Repeat until the user picks one.

## Choose the topic

A niche is a channel idea. A long video needs one topic.

1. For the chosen niche, propose 5 specific video topics. Each has a working title and a one-line hook. Make them different from each other and fit the target length.
2. Ask the user to pick one, ask for 5 more, or write their own.
3. Repeat until the user agrees on one topic.

## Output

Return this to the caller, or show it when run alone:

```
niche: <name>
lens: <lens>
audience: <who>
topic: <working title>
hook: <one line>
notes: <anything the writer must respect>
```

## Rules

- Never present more than 10 candidates at once.
- Never repeat a candidate in later rounds.
- Do not claim real view counts or competitor numbers. If you do not have data, say the audience fit is a judgment.
- Do not pick for the user. The user chooses the niche and the topic.
