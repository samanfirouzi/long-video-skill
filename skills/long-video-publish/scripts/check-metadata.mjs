#!/usr/bin/env node
// Checks YouTube metadata against common limits.
// Usage: node check-metadata.mjs <metadata.json> [--duration SECONDS]
// metadata.json: { "title": "...", "description": "...", "tags": ["a", "b"] }
// Limits are from YouTube's help pages at the time of writing. They can change: verify before relying on them.

import { readFileSync } from 'node:fs';

const args = process.argv.slice(2);
const file = args.find((a) => !a.startsWith('--'));
const di = args.indexOf('--duration');
const duration = di >= 0 ? Number(args[di + 1]) : null;
if (!file) {
  console.error('usage: node check-metadata.mjs <metadata.json> [--duration SECONDS]');
  process.exit(2);
}

const meta = JSON.parse(readFileSync(file, 'utf8'));
const errors = [];
const warnings = [];
const notes = [];
const title = String(meta.title || '');
const description = String(meta.description || '');
const tags = Array.isArray(meta.tags) ? meta.tags.map(String) : [];

// Title
if (!title.trim()) errors.push('title is empty');
if (title.length > 100) errors.push(`title is ${title.length} characters (limit 100)`);
else if (title.length > 70) warnings.push(`title is ${title.length} characters; long titles are cut off in search and on phones (aim for 60 or less)`);
else if (title.length > 60) notes.push(`title is ${title.length} characters (60 or less shows in full in most places)`);
if (/[<>]/.test(title)) errors.push('title contains < or >');
if (title && title === title.toUpperCase() && /[A-Z]{6,}/.test(title)) warnings.push('title is all capitals');

// Description
if (!description.trim()) errors.push('description is empty');
if (Buffer.byteLength(description, 'utf8') > 5000) errors.push(`description is ${Buffer.byteLength(description, 'utf8')} bytes (limit 5000)`);
if (/[<>]/.test(description)) errors.push('description contains < or >');
const firstLines = description.split('\n').slice(0, 3).join(' ');
if (firstLines.length < 40) warnings.push('the first lines of the description are very short; they appear before "show more"');
const hashtags = (description + ' ' + title).match(/(^|\s)#[\p{L}\p{N}_]+/gu) || [];
if (hashtags.length > 15) errors.push(`${hashtags.length} hashtags: YouTube ignores all hashtags when there are more than 15`);
else if (hashtags.length > 3) notes.push(`${hashtags.length} hashtags: only the first 3 show above the title`);

// Chapters
const chapterLines = description.split('\n').map((l) => l.trim()).map((l) => /^(\d{1,2}):(\d{2})(?::(\d{2}))?\s+\S/.exec(l)).filter(Boolean);
const secs = chapterLines.map((m) => (m[3] !== undefined ? Number(m[1]) * 3600 + Number(m[2]) * 60 + Number(m[3]) : Number(m[1]) * 60 + Number(m[2])));
if (chapterLines.length) {
  if (secs[0] !== 0) errors.push('chapters must start at 0:00');
  if (chapterLines.length < 3) errors.push(`chapters need at least 3 timestamps (found ${chapterLines.length})`);
  for (let i = 1; i < secs.length; i++) {
    if (secs[i] <= secs[i - 1]) errors.push(`chapter ${i + 1} is not after chapter ${i}`);
    else if (secs[i] - secs[i - 1] < 10) errors.push(`chapter ${i} is shorter than 10 seconds`);
  }
  if (duration && secs[secs.length - 1] >= duration) errors.push(`last chapter starts at ${secs[secs.length - 1]} s, at or after the end of the video (${duration} s)`);
} else notes.push('no chapters found (lines like "0:00 Intro")');

// Tags
const tagChars = tags.join(',').length;
if (tags.length === 0) warnings.push('no tags');
if (tagChars > 500) errors.push(`tags total ${tagChars} characters (limit 500, commas count)`);
const seen = new Set();
for (const t of tags) {
  const k = t.trim().toLowerCase();
  if (seen.has(k)) warnings.push(`duplicate tag: ${t}`);
  seen.add(k);
  if (/[<>]/.test(t)) errors.push(`tag contains < or >: ${t}`);
  if (t.length > 100) errors.push(`tag longer than 100 characters: ${t.slice(0, 30)}...`);
}
if (tags.length > 20) warnings.push(`${tags.length} tags; 10 to 15 focused tags are enough`);

console.log(`title: ${title.length} chars | description: ${Buffer.byteLength(description, 'utf8')} bytes | tags: ${tags.length} (${tagChars} chars) | chapters: ${chapterLines.length} | hashtags: ${hashtags.length}`);
for (const e of errors) console.log('ERROR: ' + e);
for (const w of warnings) console.log('warning: ' + w);
for (const n of notes) console.log('note: ' + n);
console.log(errors.length ? 'RESULT: fix the errors' : 'RESULT: ok');
process.exit(errors.length ? 1 : 0);
