# Video script format

Save as `video-script.md` in the project folder.

## Header

```
---
title: <working title>
status: draft | approved
approved: <ISO date, when approved>
revision: <number>
language: <config language>
target_length_min: <config value>
total_runtime: <computed, mm:ss>
aspect_ratio: <config value>
speaking_mode: narrator | characters | mixed
story: story.md
film_style: film-style.md
config: <config-name>
---
```

## Body

```
# <title>

## Summary
| Scene | Title | Runtime | Shots | Speaking |
|-------|-------|---------|-------|----------|
| 1 | ... | 00:45 | 8 | narrator |
Total: <mm:ss> (target <mm:ss>)
Shots: <count>. Average length: <s>. Outside 5 to 8 s: <count>. Longest: <s> (limit <max>)

## Characters, places and objects used
| Id | Name | Type |
|----|------|------|
| char-mara | Mara | character |

## New assets needed
- <id or description, scene where needed, why> or "none"

---

## Scene 1: <title>
Story beat: <which beat of the story this covers>
Location: <env id>
Time and mood: <for example: dawn, calm>
Runtime: <mm:ss>

### Shot 1.1
- Continues: <previous shot id, only for a continuation clip, otherwise omit>
- Duration: 6 s (maximum 10 s, preferred 5 to 8 s)
- Picture: <what we see, using entity ids, for example: char-mara stands at the lighthouse door, holding obj-lantern>
- Camera: <shot size>, <angle>, <movement>
- Lighting: <from the film style>
- Narration: "<text>"
- Dialogue:
  - MARA (quiet, tired): "<line>"
- Sound: <music cue, sound effects, ambience>
- Transition out: <cut | dissolve | ...>
```

Use only the narration or dialogue lines the speaking mode needs. Delete the other line type in that shot.

## Rules for writing shots

- One shot = one picture and one camera setup. A new setup is a new shot.
- Narration sentences map to shots. One short sentence per shot is fine. Several short sentences can share one shot if the picture stays the same.
- Where the story text is one sentence per line (from `long-video-story-questions`), keep each sentence as its own narration line, word for word. Give each sentence at least one shot.
- Picture descriptions use entity ids and name the exact action. Do not redescribe a character's looks. The visual bible holds that.
- Put each new location or time change in a new scene.
- Vary shot size between moments. Do not put more than 3 different moments in a row with the same size and movement. Continuation clips of one moment do not count.
- Hold on important moments. Cut faster on action and transitions. Follow the pacing in the film style.

## Timing rules

- Narration speed: about 150 words per minute in English. Adjust for other languages: slower for dense languages, faster for others. Ask the TTS preview if one exists.
- Dialogue speed: about 140 words per minute, plus 0.3 to 0.5 s between speakers.
- **Clip limit: every shot lasts at most 10 seconds. Preferred range 5 to 8 seconds.** Config values `video.max_clip_seconds` and `video.preferred_clip_seconds` override the defaults. Video generators produce short clips, so this limit is a hard rule.
- Words per shot at 150 words per minute: about 12 words in 5 s, 20 words in 8 s, 25 words in 10 s. If a narration passage or a moment is longer than the limit allows, split it into consecutive clips at a sentence, clause or action boundary. Keep the words unchanged.
- **Continuation clips.** Follow-on clips may keep the same environment, camera setup and lighting, and may show the same picture or the same action carrying on. Mark them `Continues: <previous shot id>`. Fill in every field anyway, so each clip can be generated on its own. Plan the join: the first frame of a continuation matches the last frame of the previous clip, so a later stage can use that frame as a reference. Do not invent new camera moves or new pictures just to fill the extra clips.
- Continuation clips are exempt from the rule "no more than 3 shots in a row with the same size and movement".
- Split dialogue by speaker turn. A long speech is split at natural pauses. Do not put more than one long speech in one shot.
- Silent and establishing shots obey the same limit.
- Shot duration is at least the time to speak its narration or dialogue, plus 0.5 s of air.
- Silent shots (music only) need a reason: a reveal, a transition, a moment to feel.
- Sum all shot durations per scene, then all scenes. Show both in the summary.
- Total runtime must land within 10 percent of the target length. Fix by trimming or extending holds, adding or cutting b-roll shots, or by asking the user to cut or extend the story. Never pad with filler.
- Intro: the first 15 seconds must contain the hook from the story.

## Shot and word budget guide

| Average shot length | Shots per 10 minutes |
|---------------------|----------------------|
| 8 s | about 75 |
| 6.5 s | about 92 |
| 5 s | about 120 |

Shots above 10 seconds are not allowed. Shots under 5 seconds are rare and need a reason.

Use the film style's average shot length to estimate how many shots the whole video needs. Check that the narration text fits the same total. Report the shot count and how many shots fall outside 5 to 8 seconds in the summary.

## Sound notes

- Music: name mood and when it enters, rises, drops. Respect the config's music setting.
- Ambience: one short phrase per scene.
- Effects: only the ones that matter. Respect the config's sound effects setting.
- Narration or dialogue always sits above music. Mark where the music should duck.
