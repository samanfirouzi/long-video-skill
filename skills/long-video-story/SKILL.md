---
name: long-video-story
description: Agree on the story for a long video. The user either supplies a story or asks Claude to write one. When Claude writes, it first asks which story style to use (for example niche discovery, or a provocative-questions narration), runs that style's skill, and revises until the user approves. Use after long-video-setup, or when the user says "story for my video", "give me an idea", or wants to change an unapproved story. Ends only when the user explicitly approves the story.
---

# Long video story

Stage 2 of the long video workflow. Output: an approved `story.md` in the project folder.

This stage ends only when Claude and the user agree on the story. No later stage starts before that.

## Before you start

1. Find the active project: `~/.long-video/projects/<slug>/project.json`. If the user has several, ask which one.
2. If no project exists, run `long-video-setup` first.
3. Load the project's config from `~/.long-video/configs/<config-name>.json`. Use it for length, language, audience, tone, format and visual approach. Do not re-ask what the config answers.
4. If `story.md` already exists with status `draft`, offer to continue it. If status is `approved`, ask whether to reopen it.

## Step 1: Ask the entry question

Ask: "Do you have a story, or do you want me to write one?"

- **I have a story.** The user pastes or describes it. Go to Step 5.
- **Write one for me.** Go to Step 2.
- **I have a rough idea.** The user gives a seed (topic, theme, a line). Keep it, then go to Step 2.

## Step 2: Ask for the story style

Always ask this when Claude writes the story. Do not skip it, and do not pick a style for the user.

1. Read `references/story-styles.md`. Check which style skills are installed.
2. Show the available styles, each with its one-line description. Always include `open`.
3. Ask the user to pick one. They can also describe their own style. If they do, treat it as `open` with their description as extra instructions.
4. Save the choice in `project.json` as `"story_style": "<id>"`.

## Step 3: Get the topic

Follow the chosen style's type.

- **ideas** (for example `niche`): call the style skill. Pass the config summary and any seed. It returns a topic. Then ask which writer to use (Step 4 pairing rule in the registry).
- **writer** (for example `questions`): if the user has a topic or seed, use it. If not, ask for one. Do not suggest topics.
- **open**: pitch ideas, as below.

### Open style: pitch ideas

1. If there is no seed, ask at most 3 short questions: topic area or interests, something to avoid, any real events or sources to use.
2. Write 4 pitches that fit the config. Each pitch has: title, one-sentence logline, the first 15 seconds as a hook, and why it works for this audience.
3. Make the 4 pitches clearly different from each other.
4. Ask the user to pick one, combine two, ask for more, or give a new direction. Repeat until the user picks.

## Step 4: Write the story

Call the writer.

- **A writer skill** (for example `long-video-story-questions`): call it with the topic, the target duration, the language and the config summary. Its own output format wins. Do not reshape it into the default structure.
- **open**: write the default structure below.

### Default structure (open style)

Match the target length in the config. Spoken narration runs about 150 words per minute, so a 15 minute video needs about 2,250 spoken words. Do not write the final script now. Write the story: what happens, in order, with enough detail for the user to judge it.

1. **Title** (working).
2. **Logline.**
3. **Hook.** The opening 15 to 30 seconds.
4. **Story outline.** Acts or chapters. For each: what happens, the turning point, rough share of runtime.
5. **Full story.** Prose retelling, beginning to end.
6. **Ending and call to action.**
7. **Facts to verify.** List every factual claim that needs a source. Write "none" for pure fiction.

Rules for the open style:

- Do not invent facts for a non-fiction story. Mark unknowns in "Facts to verify".
- Do not copy existing works. Use original structure and wording.
- Keep language and tone from the config.

### Save the draft

Save to `story.md` with this header, status `draft`:

```
---
title: <working title>
status: draft
revision: 1
style: <style id>
writer: <writer id or "open">
config: <config-name>
---
```

Put the text below the header. Show the story in chat.

## Step 5: Confirm or revise

If the user brought their own story in Step 1, save it first as `story.md` with the header above (`style: user`).

Ask: approve, or request changes. Ask in a new message after the story. Do not put the question inside a writer skill's output.

- **Changes requested.** Apply them. If a writer skill made the text, keep its rules (format, tone, honesty) while editing. Increase `revision`. Show what changed in two or three lines, then show the updated story. Ask again.
- **Question or doubt.** Answer it. Offer a change if the answer shows a problem.
- **Wants a different story.** Go back to Step 2. Keep the old file as `story.rev<N>.md`.
- **Approve.** Needs an explicit yes. Silence, "looks fine so far" or "ok but..." is not approval. If unclear, ask one direct question: "Lock this story?"

Loop until approved. Do not rush the user.

## Step 6: Lock

1. Set `status: approved` in `story.md` front matter. Add `approved: <ISO date>`.
2. Update `project.json`: set `"stage": "story-approved"`.
3. Tell the user the file path. Say the story stage is done.
4. Offer to continue with `long-video-assets` (characters, environments, objects and style). Start it only if the user agrees.

## Rules

- Never mark a story approved without an explicit yes.
- Never change an approved story silently. Reopening needs the user's request, and sets status back to `draft`.
- Never skip the style question when Claude writes the story.
- Never call a style skill that is not installed.
- Keep pitches and revisions short. Show full text only for the story itself.
