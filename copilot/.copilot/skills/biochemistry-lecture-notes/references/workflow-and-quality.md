# Workflow and Quality Standard

## 1. Discover and Map the Course Context

Extract Word files directly or with `python-docx`; use PDF text extraction or
OCR as necessary.

Create an internal map containing:

- exact syllabus wording;
- contact hours;
- unit CO and official Bloom expectations;
- prescribed text and edition;
- current draft coverage;
- missing content, excess content, and scientific corrections;
- likely part and lecture boundaries.

Do not expose a long planning questionnaire when these values are available in
the files.

## 2. Audit Sources Before Drafting

- Verify the edition from the title page rather than the filename.
- Check whether a PDF is searchable and whether it carries unauthorised-release
  markings.
- Treat the syllabus as the scope authority.
- Treat the prescribed textbook as the primary scientific reference only when
  it is a lawful copy.
- Use authoritative open sources to clarify terminology, current nomenclature,
  or claims not handled well by the prescribed text.
- Maintain a source-to-topic map so the bibliography is genuine.

## 3. Build an Internal Blueprint

Allocate:

- teaching time by part;
- approximate word and page budget;
- necessary tables and equations;
- no more than a restrained set of figures;
- summary coverage;
- preliminary CO/BL assessment distribution.

Do not ask for outline approval by default. The approved preference is to review
the complete unit and revise it afterwards.

## 4. Draft for the Actual Student Level

The content must be neither a simplified school handout nor a postgraduate
review.

For every concept:

- define the key term before using it heavily;
- connect molecular structure to biochemical consequence;
- add one representative example when an abstract definition is insufficient;
- explain environmental context such as water, pH, ionic strength, or molecular
  shape when it changes the conclusion;
- remove tangential general chemistry that does not support the syllabus.

## 5. Prevent Common Scientific Errors

Apply these checks whenever relevant:

- Bond formation lowers the energy of the bonded state; breaking a bond requires
  energy. Do not say that bond breaking releases stored energy by itself.
- Distinguish covalent bonds from noncovalent interactions.
- Explain biological ionic interactions as charge–charge interactions in water,
  not only as metal-to-nonmetal electron transfer in a dry crystal.
- Explain hydration, dielectric screening, pH, and ionic strength where they
  affect electrostatics.
- Define hydrogen bonds through donor, hydrogen, acceptor, geometry, and
  environment.
- Treat van der Waals effects as distance-dependent attraction and steep
  short-range repulsion; do not call them temperature-independent.
- Explain the hydrophobic effect as solvent-driven. Never present a
  "hydrophobic bond" as a conventional direct bond.
- Do not imply that DNA stability comes from hydrogen bonds alone; include base
  stacking, hydration, and ionic environment where appropriate.
- Evaluate chirality for the whole molecule. A stereogenic carbon does not
  guarantee that a molecule with multiple stereocentres is chiral.
- Keep D/L, R/S, and (+)/(−) optical rotation distinct.
- Avoid mixing whole-body, wet-cell, dry-mass, or tissue percentages without
  naming the basis of comparison.

## 6. Make the Prose Feel Faculty-Written

Remove signs of generic generated prose:

- repetitive sentence openings;
- excessive headings or micro-sections;
- repeated "key takeaway" boxes;
- artificial guiding questions;
- symmetric paragraphs that repeat the same pattern;
- vague claims such as "plays a crucial role" without explaining how;
- inflated applications not required by the syllabus.

Read the complete unit continuously once, not only section by section. Improve
transitions and remove duplicated explanations.

## 7. Review Independently

Use a separate review pass or subagent to check:

- scientific accuracy and misleading simplifications;
- level calibration;
- syllabus omissions and scope drift;
- terminology and citation quality;
- tables that will be unreadable on A4;
- diagrams that a first-year student or teacher could not readily explain.

Incorporate high-confidence corrections before document generation.

## 8. Generate the Four DOCX Files

Create the student notes first. Derive questions from the final content. Build
the teacher key and two assessment papers using the approved schema.

Keep answers out of student-facing files.

## 9. Validate Before Completion

At minimum:

- open every DOCX with a document library;
- test the DOCX ZIP container for corruption;
- count the assessment items and confirm the required distribution;
- confirm every question has the correct CO and BL tag;
- verify that quiz and surprise-test items are distinct;
- search for unresolved placeholders such as `[REF:]`, `[[FIGURE:]]`, TODO, or
  temporary text;
- confirm figures are embedded and captions are present;
- verify that no source watermark, piracy marker, or copied textbook footer
  entered the deliverables;
- inspect representative rendered pages when rendering tools are available;
- check that wide tables, page breaks, and references remain readable;
- ensure the final deliverables directory contains only the four DOCX files.

