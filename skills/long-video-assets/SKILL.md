---
name: long-video-assets
description: Build the visual foundation for a long video from an approved story. Extracts the recurring characters, environments and key objects, helps the user choose one art style from suggested options (10 at a time, more on request), then writes image generation prompts for every character (portrait plus character sheet), environment and object, all sharing one locked style. Can also generate the images (installed tool, API, MCP or browser) or hand the user a folder and file names to fill. Use after long-video-story is approved, or when the user asks for character, environment, object or style prompts or images.
---

# Long video assets

Next stage after `long-video-story`. Output: a visual bible and a set of image generation prompts that all share one locked style.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `story.md` with `status: approved`. If not approved, stop and run `long-video-story`.
2. Load the project config. Use `visuals.approach`, `visuals.art_direction`, `aspect_ratio`, `audience` and `tone` to narrow choices. Do not re-ask what the config answers.
3. If `visual-bible.md` already exists, ask: continue, or restart a part (list, style, or prompts).

## Step 1: Extract the entity list

Read the whole story. Build three lists. Include only items that must look the same every time they appear.

- **Characters.** Every person, animal or creature that appears in more than one scene, or is central to one important scene. Also include groups that need one consistent look (for example, a crowd of soldiers in one uniform).
- **Environments.** Every place used for more than one scene, or one long scene. Merge near duplicates (for example, "kitchen morning" and "kitchen night" are one environment with a lighting variant).
- **Objects.** Items a character handles or that drive the plot, and items visible in most scenes of a place. Skip one-time background props.

For each entry give:

- `id`: short slug, for example `char-mara`, `env-lighthouse`, `obj-lantern`
- Name
- Description: everything the story states or implies (age, build, clothing, colors, mood, materials, scale). Mark guesses as "assumed".
- Where it appears: scene or chapter references
- Why it needs consistency: one short line

Do not invent story content. Where the story is silent on a visual detail that the prompts need, propose a detail, label it "assumed", and let the user change it.

Show the lists. Ask the user to add, remove, merge or edit entries. Loop until the user confirms the lists.

## Step 2: Choose the style

Read `references/style-catalog.md` for the pool and the card format.

1. Pick 10 styles that fit this story. Weigh: genre, tone, era, audience, the config's visual approach and art direction, and what the generation tool can do consistently. Do not pick a random 10.
2. Present them numbered 1 to 10. Each card has: name, one line describing the look, one line on why it fits this story. Order by fit, best first.
3. Ask the user to pick one, combine two, describe their own, or ask for more.
4. If the user asks for more: show 10 new styles. Never repeat a style already shown. Make the new set a different direction from the first, not a variation of it.
5. Repeat until the user agrees on one style. A "maybe" is not agreement. Ask "Lock this style?" before moving on.
6. Once chosen, write the **style block**:
   - Style description: medium, line quality, shading, texture, lighting, color palette (with hex codes), composition feel.
   - Negative terms: what the style must never show (for example, photorealistic skin when the style is flat illustration).
   - Show the block to the user for approval. Allow edits.

The approved style block is the single source of style. Do not alter it later without asking the user.

## Step 3: Write the prompts

Read `references/prompt-templates.md`. Write one prompt per image, using the templates.

Images to write:

- **Each character: 2 prompts.**
  1. Character image: the character alone, full body, neutral standing pose, plain background.
  2. Character sheet: written to use image 1 as a reference. Turnaround views, face close-ups with expressions, outfit and prop details, palette.
- **Each environment: 1 prompt.** Wide establishing image of the place with no characters, plus any named lighting or time variants as short addenda.
- **Each object: 1 prompt.** The object alone on a neutral background, clear detail, with a scale note.

Consistency rules (apply to every prompt):

1. Every prompt contains the **style block verbatim**, copied, not paraphrased.
2. Every prompt uses the same aspect ratio rules, the same negative terms and the same level of detail.
3. Every character, environment and object description is written once in the bible and copied into each prompt that uses it.
4. Name each prompt with its `id` and a generation order. Generate all characters' image 1 first. Use approved results as references for the later prompts: character sheet uses character image 1, and note that environment and object prompts may use one approved character image as a style reference.
5. Keep each prompt self-contained. Do not write "same as above".
6. Write prompts for the provider in `providers.image` of the config. If none is set, write generator-agnostic prompts in plain descriptive English and say so.

## Step 4: Review

1. Show a summary table: id, type, prompt number. Show two or three full prompts as samples, then offer the rest on request.
2. Ask the user to approve or request changes. A style change returns to Step 2 and rewrites every prompt.
3. Run a self-check before saving, and fix any failure:
   - Every prompt contains the exact style block.
   - Every entity from the confirmed list has its prompts.
   - No prompt contradicts the story or the confirmed descriptions.
   - No prompt names a real living person, a trademark or a living artist's name.

## Step 5: Save

Write these files in the project folder:

- `visual-bible.md`: the confirmed entity lists and the style block.
- `prompts/<id>.md`: one file per entity, with its prompts in order.
- `prompts/index.md`: table of all prompts with the file name and the recommended generation order.
- `images/`: an empty folder for the finished images.

Every prompt header holds the expected image file name (see the templates). The names never change, so the images can always be matched to their prompts.

## Step 6: Ask what the user wants

Ask: "What do you want from this stage?"

- **Prompts only.** The user makes the images with their own tool.
- **Images.** Claude generates the images.
- **Both.** The user gets the prompts and Claude also generates the images.

The prompts are always saved. This choice decides who makes the images.

### Prompts only

1. Show the full path of the `images/` folder.
2. Tell the user: save each image in that folder, using the file name from the header of its prompt. Show one example, such as `prompts/char-mara.md` says `save as: images/char-mara_01_character.png`.
3. Say that any extension is fine (png, jpg, webp), but the base name must match.
4. Offer to check the folder later: compare the files found against `prompts/index.md` and list what is missing or misnamed.

### Images or both

Read `references/image-generation.md` and follow it. In short:

1. Find what is available on the device: saved config method, Claude tools, API keys, local generators.
2. If nothing is available, ask whether the user has an API key (as an environment variable, never pasted in chat) or an MCP server, or wants Claude to use a browser with an image generator they already use.
3. If the user chooses the browser, get explicit confirmation before starting. It is a long process: one image at a time, each generated and downloaded.
4. Generate the first character image as a style test and get approval. Then generate the rest in the order of the index. Save each file under its expected name.
5. Keep `images/status.md` current. Mark failures `needs-manual`.
6. Offer to save the working method in the config.

If generation fails or is declined, fall back to the prompts-only path for the remaining images.

## Step 7: Finish

1. Update `project.json`: `"stage": "assets-prompts-done"` after prompts are saved, and `"stage": "assets-images-done"` when every image exists and the user approves the set.
2. Tell the user the project folder path, the `images/` folder path, and anything still missing.
3. Offer to continue with `long-video-director` (film style and video script). Start it only if the user agrees. Do not start any other later stage unless the user asks and that stage exists.

## Rules

- Never start without an approved story.
- Never lock a style without an explicit yes.
- Never change the style block after approval without the user's request. If it changes, rewrite all prompts.
- Never use a living artist's name or a brand as a style reference. Describe the look instead.
- Keep chat messages short. Put full prompt text in files, and show only samples in chat.
- Never generate images before the user chose "images" or "both".
- Never start browser generation without explicit confirmation of the count, time and download folder.
- Never ask for API keys in chat. Never enter passwords or solve CAPTCHAs in a browser.
- Never rename or overwrite an image file without asking.
