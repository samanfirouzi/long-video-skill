# Story styles

Registry of styles the user can pick when Claude writes the story. `long-video-story` reads this file.

Each style has a type:

- **ideas**: finds the topic or concept. A writer runs after it.
- **writer**: turns a topic into the finished story or script.
- **both**: does ideas and writing itself.

## Registry

| Id | Skill | Type | What it does |
|----|-------|------|--------------|
| open | built-in (no skill) | both | Claude pitches 4 ideas and writes a story in the default structure. Fits any topic |
| niche | `long-video-niche-discovery` | ideas | Finds a differentiated niche and a first topic using 7 lenses, from a niche, channel or video the user likes. Then a writer runs |
| questions | `long-video-story-questions` | writer | Narration for "questions people think are settled": second person, steelmans every side, ends by handing the question back to the viewer. One sentence per line |

## Pairing

- An **ideas** style must be followed by a **writer**. After the topic is chosen, ask the user which writer to use. Offer `open` and every writer in the table.
- A **writer** style needs a topic. If the user has none, ask for one. Do not pick one for them.
- A **both** style does everything itself.

## Skill contract

A style skill gets this from the caller:

- Project config summary: language, target length, audience, tone, format.
- Seed or topic, if the user gave one.
- Anything the user said about what to avoid.

An **ideas** skill returns: `topic`, `hook`, `audience`, `notes`.

A **writer** skill returns the finished text. The caller owns saving, approval and revisions. A writer skill must not lock or approve anything.

## Add a new style

1. Create `skills/<new-style-skill>/SKILL.md`. Follow the contract above.
2. Add a row to the registry table.
3. Commit. No other file needs to change.

## Missing skill

Before offering a style, check that its skill is installed. If it is not, say so and offer `open` instead. Do not pretend to run a skill that is missing.
