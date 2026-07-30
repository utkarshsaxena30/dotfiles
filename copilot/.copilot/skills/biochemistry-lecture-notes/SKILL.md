---
name: biochemistry-lecture-notes
description: Create or revise syllabus-aligned biochemistry, biotechnology, and life-science lecture-note packages for B.Tech and related university courses. Use for unit notes, student handouts, teacher keys, quizzes, surprise tests, source audits, or converting syllabus/textbook material into polished DOCX teaching packs. Automatically discovers syllabi, prior approved units, source PDFs, drafts, course outcomes, Bloom levels, and contact hours before drafting.
argument-hint: 'e.g. "create the Unit II lecture-note package from the files in this folder"'
---

# Biochemistry Lecture Notes

Create accurate, self-contained university lecture notes and their assessment
package without repeating the full requirements interview.

Before starting, read every file in this skill's `references/` directory. Treat
those files as the user's approved defaults unless the current prompt or
official syllabus clearly overrides them.

## Start With Automatic Context Discovery

Do not begin by asking a questionnaire.

1. Inventory the current working directory and relevant child directories.
2. Look for:
   - official syllabus files (`*syllabus*.docx`, PDFs, spreadsheets);
   - existing unit drafts (`Unit*.docx`, notes, handouts);
   - prescribed textbooks or chapter extracts;
   - files or messages containing public source URLs;
   - completed `Unit * - Deliverables` directories;
   - sample examinations, rubrics, or preferred teaching material.
3. Extract the exact course title, code, programme, semester, unit scope,
   contact hours, course outcome, prescribed Bloom levels, and source hierarchy.
4. If a completed unit package exists, inspect it and treat it as the golden
   design, density, tone, and assessment template. Reuse its conventions, not
   its unit-specific scientific content.
5. Audit any rough draft as source material rather than assuming it is correct.
6. Ask only one focused question if a genuinely blocking requirement cannot be
   inferred. Never repeat the original exhaustive interview.

For this course, an approved `Unit I - Deliverables` directory is the canonical
example whenever it is available in the workspace.

## Apply the Approved Defaults

Use `references/approved-defaults.md` for audience, depth, tone, visual,
language, citation, and packaging choices.

Use `references/assessment-spec.md` for every assessment deliverable.

Use `references/docx-layout.md` for Word formatting and filenames.

Use `references/workflow-and-quality.md` for source handling, scientific review,
drafting, and final validation.

## Required Deliverables

Unless the user explicitly changes the package, create one directory per unit:

```text
Unit <Roman numeral> - Deliverables/
├── Unit <Roman numeral> - Student Notes.docx
├── Unit <Roman numeral> - Teacher Key.docx
├── Unit <Roman numeral> - Quiz.docx
└── Unit <Roman numeral> - Surprise Test.docx
```

Keep intermediate manuscripts, scripts, extracted images, preview PDFs, and
temporary files outside the deliverables directory. The final directory should
contain only the four requested DOCX files.

## Default Execution Model

1. Build an internal syllabus-to-content blueprint; do not ask the user to
   approve it unless a major scope conflict exists.
2. Draft the complete unit before requesting revisions.
3. Correct scientific problems in a rough draft silently.
4. Use a separate scientific review pass before finalising the documents.
5. Create the student notes first, then derive assessments from the completed
   unit so every question is genuinely covered.
6. Validate the final package completely before reporting completion.

## Source and Copyright Rules

- Source priority is: official syllabus, legally supplied prescribed text,
  authoritative open sources, then the rough draft.
- Verify a textbook's title page, edition, metadata, and provenance; do not
  trust the filename alone.
- Never retrieve or use unofficial scans or files carrying piracy,
  unauthorised-release, torrent, or similar markings.
- Public availability does not by itself establish reuse permission.
- Prefer original simplified diagrams or openly licensed figures. Use a direct
  textbook figure only when the source is official and the user's permitted
  educational use clearly covers reproduction; provide a citation.
- Never copy textbook prose at length. Synthesise original teaching prose.

## Completion Standard

Do not finish with a plausible-looking draft. Finish only when:

- every syllabus phrase is covered at the correct depth;
- the notes are self-explanatory for the target cohort;
- scientific claims and nomenclature have been independently checked;
- the diagrams are simple enough for the teacher to explain;
- all four DOCX files open successfully and contain no placeholders;
- assessment counts, CO tags, Bloom tags, answers, and keys match the approved
  schema exactly;
- the output directory contains only the final deliverables.

