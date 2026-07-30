---
name: log-dsa-problem
description: 'Log a just-discussed DSA / LeetCode problem into the Documentation notes. Appends (or refreshes) the per-problem metadata block + a distilled takeaway using the schema in alphabet-150/template.md, filling fields from the conversation and asking only when a field is genuinely ambiguous. Also keeps the `patterns` and `mistakes` vocabularies in template.md in sync with any new tags used. Use when the user says "log this", "log the problem", "note this down", "add this to my notes", or right after finishing a DSA problem walkthrough.'
argument-hint: 'e.g. "log this problem" — run right after finishing a problem'
---

# Log DSA Problem

Capture a problem we just worked through as a structured, greppable entry in the
DSA notes — reusing what we already discussed instead of re-interviewing.

## When to Use
- Right after finishing a DSA / LeetCode problem discussion.
- User says "log this problem", "note this down", "add this to my notes".

Do **not** use for non-DSA notes, or to rewrite existing prose beyond adding or
refreshing a metadata block.

## Locations
- **Notes root:** the `Documentation` repo, at
  `personal/data-structures-and-algorithms/`. If the current working directory is
  inside that repo, use it; otherwise use `~/repositories/Documentation/personal/data-structures-and-algorithms/`.
- **Schema + tag vocabulary:** `<notes-root>/alphabet-150/template.md`.
  **Read this file first, every run** — the user edits it often. It defines the
  exact metadata-block format and the allowed values for every field. Follow it
  verbatim; never reconstruct the format from memory.

## Procedure

### 1. Read the schema
Open `alphabet-150/template.md` and load the current:
- metadata-block format (field order and syntax under **Copy-paste template**),
- controlled vocabularies for `patterns` (the **Currently used:** list),
  `structures`, `difficulty`, `status`, `confidence`, and `mistakes` (the table).

### 2. Locate the target entry
Derive the LeetCode slug from the problem URL (e.g. `longest-string-chain`), then
`rg -l "<slug>"` under the notes root.
- **Found:** that file is the target. Add or refresh the metadata block directly
  under the existing `# [Title](url)` heading, above the existing prose. Never
  duplicate the heading, and preserve the prose already there.
- **Not found:** append the entry to the **end of the file we are currently working
  through** (the user tracks problems in an external sheet whose ordering the files
  mirror, so the file is *not* chosen by pattern). The user will say when the
  active file changes. **If the target file is genuinely ambiguous, ask.**

### 3. Fill the fields from context
Populate every field from what we just discussed:
- `patterns`, `structures` — the technique(s) / data structure(s) in the accepted
  solution. `patterns` may be a pattern name (`sliding-window`) or an algorithm
  name (`dijkstra`).
- `difficulty` — the LeetCode difficulty (known, or ask).
- `reviewed` — today's date, `YYYY-MM-DD`.
- `status` — infer from how it went: solved independently → `solved`; needed
  hints / editorial / post-contest → `upsolved`; couldn't finish → `stuck`.
- `confidence` — infer from the user's fluency during the walkthrough (1–5 per the
  template's scale).
- `mistakes` — the actual slip(s) that surfaced (e.g. an off-by-one, a wrong DP
  order, missed constraints). Use `N/A` if there were none.
- **Values are wrapped in backticks** for every field *except* `confidence`, which
  is a bare number. `N/A` is also written bare.
- **Body** — see the body format below.

### 3a. Body format (strict)
The body is a short list of **terse keyword bullets**, not prose. Rules:
- No `Takeaway:` prefix, no paragraphs, no full sentences where a fragment works.
- One idea per bullet, 2–5 bullets total. Fragments, lowercase, `-` bullets.
- Use `-->` for implication and backticks for identifiers/expressions.
- Prefer the reusable trigger over problem-specific retelling.
- Nested bullets only when a point genuinely needs one qualifier.
- Never restate the solution or paste code.

Example of the target register:
```
- versioning should never duplicate data - across computer science
- for multi-operation DS, discuss tradeoff of space/time between operations
- missed property of `snap_id` - it is monotonic in nature
```
Anti-example (too verbose, prose, sentences):
```
Takeaway: when the first instinct is "repeat passes until nothing changes,"
check whether the dependency relation is a DAG — if it is, topological order
collapses the fixpoint iteration into a single pass.
```

**Ambiguity rule:** fill anything you can defend from the conversation. Ask the
user *explicitly and only* for fields you genuinely cannot infer — most often
`status`, `confidence`, and occasionally which `mistakes` tag fits. Prefer a
single short batched question over an interview.

### 4. Write the entry
Insert the metadata block (exact field order and syntax from template.md) under
the problem heading, preserving any prose beneath it.

### 5. Sync the tag vocabulary in template.md
Only `patterns` and `mistakes` are synced. For each value you used:
- **`patterns`:** under the `### `patterns`` section there is a **Currently used:**
  bullet list. If a value isn't already a bullet, append `- ``<tag>```. This list
  is meant to be the at-a-glance set of every pattern/algorithm encountered.
- **`mistakes`:** under the `### `mistakes`` section there is a markdown table. If a
  value isn't already a row, append `| ``<tag>`` | <one-line definition> |`, matching
  the existing column style.

Never remove or reword existing entries. `structures` is treated as a static
reference list — do not modify it unless the user asks.

### 6. Report
Summarize: the file touched, the block added/refreshed, and any new `patterns` /
`mistakes` tags appended to template.md. Do not commit or push.

## Quality Criteria
- The block matches template.md's format and vocabulary exactly (lowercase,
  hyphenated, comma-separated multi-values, template's field order).
- Every value except `confidence` is backtick-wrapped; `N/A` is bare.
- The body is terse keyword bullets, not prose. If any bullet reads like a
  sentence from an essay, it is wrong.
- No duplicate problem headings; existing prose preserved.
- `reviewed` is today's date.
- After the run, every `patterns` and `mistakes` value used appears in template.md
  (new ones appended — patterns to the Currently-used list, mistakes as a table row
  with a definition).
- Only genuinely ambiguous fields triggered a question.

## Anti-patterns
- Writing the body as prose/paragraphs instead of terse keyword bullets.
- Dumping the full solution into the note instead of a distilled takeaway.
- Filing the entry by pattern instead of appending to the active file.
- Reconstructing the block format from memory instead of reading template.md.
- Re-interviewing the user for details already covered in the discussion.
- Creating a new heading when one already exists for the problem.
- Touching `structures`, unrelated notes, or committing/pushing.
