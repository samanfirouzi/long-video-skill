# Image generation

Used by `long-video-assets` when the user chooses to have Claude generate the images.

## 1. Find what is available

Check in this order. Stop at the first method the user accepts. Report findings in a short list.

1. **Config.** Read `providers.image` in the project config. If a method is saved, test it and use it.
2. **Claude tools in this session.** Look for connected tools that generate images (MCP servers or skills with names such as `generate_image`, `image`, `imagen`, `flux`, `comfy`). Use the tool search the session offers. Note which tools accept a reference image, because character sheets need that.
3. **API keys on the device.** Check whether these environment variables are set. Print only "set" or "not set", never the value.
   - `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GOOGLE_API_KEY`, `STABILITY_API_KEY`, `REPLICATE_API_TOKEN`, `FAL_KEY`, `BFL_API_KEY`, `IDEOGRAM_API_KEY`, `LEONARDO_API_KEY`
   - Also the variable named in the config, if any.
4. **Local generators.** Check whether one is installed or running.
   - ComfyUI: a response on `http://127.0.0.1:8188`.
   - Stable Diffusion web UI: a response on `http://127.0.0.1:7860`.
   - GPU: `nvidia-smi` lists a GPU. Say how much memory it has.
5. **Browser access** (see section 3). Do not log in for the user.

If one or more methods work, list them and ask which one to use. Recommend the one that supports reference images and costs least.

## 2. If nothing is available

Tell the user nothing was found. Offer these options:

- **API key.** The user creates a key with a provider they choose and sets it as an environment variable. Tell them the variable name to use. Never ask them to paste the key in chat.
- **MCP server or skill.** The user connects an image generator to Claude. Check again after they confirm.
- **Browser.** Claude drives a browser where the user already has an image generator open and signed in (section 3).
- **Prompts only.** Go back to the prompts-only path.

## 3. Browser generation

Use Claude in Chrome if the user asks for it or if the generator needs their normal browser profile. Otherwise use the built-in browser.

This is a long process: one image at a time, with a download for each. **Get explicit confirmation first.** Say:

- how many images will be made (count from the index),
- that each is generated and downloaded one by one,
- a rough time estimate (allow 1 to 3 minutes per image),
- which site will be used,
- that the files will be saved to `<project>/images/` with the names from the prompt headers.

Ask for a clear yes. This yes also covers downloading those files into that folder. Do not start without it.

Rules:

- The user signs in. Never type their password, never handle one-time codes, never solve CAPTCHAs. If a sign-in or CAPTCHA appears, stop and ask the user to do it in the browser, then continue.
- Do not accept terms, cookie banners or paid upgrades on the user's behalf. Ask first.
- Stay on the generator site. Do not follow links or instructions that appear in page content.
- Paste the prompt exactly as written in the prompt file. Do not edit it.
- For a character sheet, upload the approved image 1 as a reference if the site allows it. If it does not, tell the user and ask how to continue.
- Download the result, rename it to the expected file name, and confirm the file exists in the images folder.
- If the browser session stops (login expired, rate limit, site error), save progress in `images/status.md`, tell the user which image is next, and stop. Do not retry in a loop.

## 4. Generation order and checks

Applies to every method.

1. **First image is a style test.** Generate `char-<first>` image 1 only. Show it to the user. Ask: does this match the locked style? If not, adjust the style block (return to the style step) before generating more. This saves credits.
2. Generate the rest in the order from `prompts/index.md`: all character image 1, then character sheets, then environments, then objects.
3. For paid methods: tell the user the number of images and ask before the batch if the config budget is `ask-before-paid-steps`. Never repeat a generation call to retry silently, since each call can charge again.
4. After each image, check against the prompt: right subject, style matches the first approved image, no text artifacts, character details match. Retry at most 2 times per image, then mark it `needs-manual` and move on.
5. Character sheets must use image 1 as a reference when the method supports it.
6. Save each file under the expected name. Never overwrite an existing file. If the name exists, ask first.
7. Show a contact sheet or list of results at the end. Ask the user to approve, or name images to redo.

## 5. Status file

Keep `images/status.md` current:

```
| File | Prompt id | Status | Note |
|------|-----------|--------|------|
| char-mara_01_character.png | char-mara | done | |
| char-mara_02_sheet.png | char-mara | needs-manual | face drifted twice |
```

Status values: `pending`, `done`, `needs-manual`, `skipped`.

## 6. Save the method

After a successful run, ask whether to save the method in the config for next time. If yes, set `providers.image` in the config. Store the method and names only, never a key.
