# Review feedback

## How the reviewer works

- The review video has the scene number and time in the top-left corner and the text "REVIEW v<N>". Reviewers quote these.
- Review quality is low on purpose. Colors, sharpness and detail will look worse than the final. Tell the client this.
- Ask for comments in the form: scene number, what to change.

## Reading a comment

1. Scene number or time. If only a time is given, find the scene whose start and end contain it (`render/edl.json`).
2. What kind of change (table below).
3. How big: one scene, a few scenes, or the whole video.
4. If it is unclear, ask one short question. Do not guess on anything that costs credits.

## Routing table

| The comment is about | Example | Where it is fixed | Cost |
|----------------------|---------|-------------------|------|
| Length or cut of a scene | "Scene 12 is too slow" | Here: change `trim_start`, shorten the hold. Duration changes that alter the script need approval | Free, fast |
| Order or removal | "Drop scenes 40 to 44" | Here for removal of whole scenes (ask first: it changes the approved script). Reordering needs `long-video-director` | Free, fast |
| Captions | "Caption in scene 8 has a typo" | Here: `captions` text | Free, fast |
| Transition | "Fade between 20 and 21" | Here: `transition_out` | Free, fast |
| Levels | "Music too loud in scene 15" | Here: stem gain, or `long-video-sound` if one cue | Free, fast |
| A sound | "Door sound is wrong in scene 7" | `long-video-sound` for that cue | Low |
| Voice delivery or pronunciation | "Name mispronounced in scene 22" | `long-video-voice` for those lines | Low to medium |
| Voice wording | "Change the line in scene 30" | Script revision (user approves), then `long-video-voice` | Medium |
| Look of a scene | "Mara looks different in scene 18" | `long-video-keyframes` for that scene's frames, then `long-video-clips` | Medium to high |
| Motion of a scene | "The camera move is too fast in 25" | `long-video-clips` prompt change and a new take | Medium |
| Story or structure | "Add a scene about the storm" | `long-video-director`, then keyframes, clips, voice, sound for the new scenes | High |

## The review log

`render/review-log.md`:

```
# Review log

## Round 1 (review v1)
| # | Scene | Request | Route | Status |
|---|-------|---------|-------|--------|
| 1 | 12 | Too slow, trim 1 s | edit | done in v2 |
| 2 | 18 | Mara looks different | keyframes + clips | take2 generated, in v2 |
| 3 | 22 | Name mispronounced | voice | waiting for user yes |

## Round 2 (review v2)
...
```

Status values: `open`, `waiting for user yes`, `done in v<N>`, `declined`.

## Rules

- Show the plan as a short table and get a yes before any step that costs credits or time.
- Group requests by route so each stage is run once.
- New takes keep the naming of their stage (`scene-018_clip_take2.mp4`). Update the edit list to use them. Never delete the old take.
- After each round, render the next review version and list what changed scene by scene.
- A request that contradicts an earlier approved decision (the story, the style): say so and ask the user to decide.
- When all requests are done and the user says the video is final, go to the final render.
