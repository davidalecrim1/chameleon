---
name: init-cv
description: >
  Onboard a new master CV from a PDF or YAML file. Use when the user wants to
  set up or replace the master resume. Accepts a file path as the argument.
disable-model-invocation: true
---

# /init-cv

Onboard a new master CV from a PDF or YAML file.

## Usage

```
/init-cv <path-to-pdf-or-yaml>
```

Examples:
- `/init-cv ~/Downloads/resume.pdf`
- `/init-cv ~/Documents/my_resume.yaml`

## Workflow

Follow these steps exactly in order:

### Step 1 — Determine input type

Read the file at the provided path. Determine whether it is a PDF or a YAML file by its extension (`.pdf` vs `.yaml` / `.yml`).

If the file does not exist or the extension is unrecognised, report the error and stop.

### Step 2 — Parse or validate

**If PDF:**
Read the PDF content and extract all resume data. Produce a RenderCV-compliant YAML with the following structure:

```yaml
cv:
  name: "Full Name"
  email: "email@example.com"
  phone: "+1 555 000 0000"
  location: "City, Country"
  website: "https://..."
  social_networks:
    - network: LinkedIn
      username: username
  sections:
    summary:
      - "..."
    experience:
      - company: "..."
        position: "..."
        location: "..."
        start_date: "YYYY-MM"
        end_date: "YYYY-MM"  # or "present"
        highlights:
          - "..."
    education:
      - institution: "..."
        area: "..."
        degree: "..."
        start_date: "YYYY"
        end_date: "YYYY"
    skills:
      - label: "Category"
        details: "Skill 1, Skill 2, Skill 3"

design:
  theme: classic
  page:
    show_footer: false
  header:
    connections:
      phone_number_format: international
  section_titles:
    space_above: 0.8cm
  entries:
    date_and_location_width: 3cm
    highlights:
      space_above: 0.2cm
  sections:
    show_time_spans_in: []
    space_between_regular_entries: 0.3em
  templates:
    experience_entry:
      main_column: "**COMPANY**, POSITION — LOCATION\nSUMMARY\nHIGHLIGHTS\n"
      date_and_location_column: "DATE"
    education_entry:
      main_column: "**INSTITUTION**, DEGREE in AREA — LOCATION\nSUMMARY\nHIGHLIGHTS"
      degree_column: null
      date_and_location_column: "DATE"

settings:
  bold_keywords: []
```

Follow RenderCV entry type rules:
- Use `company` field for experience entries (ExperienceEntry)
- Use `institution` field for education entries (EducationEntry)
- Use `label` field for one-line entries (OneLineEntry)
- Do not mix entry types within a section

Follow layout rules (see Layout Rules section below).

**If YAML:**
Read the file and validate it conforms to RenderCV structure. Check that:
- Top-level keys include `cv` and optionally `design` and `settings`
- `cv.name` is present
- Each section uses a consistent entry type
- Dates follow YYYY-MM or YYYY format

Report any structural issues found. If the YAML is valid, proceed to Step 3.

### Step 3 — Confirm overwrite if needed

Check whether `templates/<name>_cv.yaml` already exists (where `<name>` is the person's name, lowercased, spaces replaced by underscores).

If it does, ask the user to confirm before overwriting:
> `templates/<name>_cv.yaml` already exists. Overwrite it? (yes/no)

Do not proceed until the user confirms.

### Step 4 — Save the master CV

Save the parsed or validated YAML to `templates/<name>_cv.yaml`, where `<name>` is the person's name from the CV, lowercased, with spaces replaced by underscores (e.g., `templates/david_alecrim_cv.yaml`).

### Step 5 — Verify it renders

Use the Makefile `render` target, which delegates to `scripts/render.py` to handle rendering cross-platform — output always lands in `./output/`:

```
make render FILE=templates/<name>_cv.yaml
```

If the render succeeds, report the path to the generated PDF and confirm setup is complete.

If the render fails, show the error output and list what needs to be fixed. Do not delete the saved `master_cv.yaml` — let the user fix and re-run.

## Layout Rules

These rules prevent common rendering issues in the classic theme and must be applied when producing YAML from a PDF or validating an existing YAML:

**Experience entries:**
- Use the `summary` field for a one-line company description (rendered as italic text under the position). Do not put the company description in `highlights`.
- Do not add "Stack:" or "Technologies:" bullets to `highlights`. Technology context belongs in the `skills` section.
- Keep each highlight to 1–2 lines of text. Overly long bullets break column alignment.

**Education entries:**
- Keep `degree` short: use abbreviations like `BSc`, `MSc`, `Specialization`, `PhD`.
- `area` holds the field of study (e.g., `Computer Science`, `Software Engineering`).
- Always include the `design.templates.education_entry` block to prevent degree column overflow and hyphenation. The `degree_column: null` moves `DEGREE` inline into the main column, and location is placed inline via the main_column template:
  ```yaml
  design:
    theme: classic
    templates:
      education_entry:
        main_column: "**INSTITUTION**, DEGREE in AREA — LOCATION\nSUMMARY\nHIGHLIGHTS"
        degree_column: null
        date_and_location_column: "DATE"
  ```

**Skills entries:**
- Keep each `details` value under ~80 characters. Long comma-separated lists wrap badly.
- Split into multiple `label` entries rather than cramming everything into one line.
- Avoid parenthetical expansions like `AWS (EKS, RDS, S3, ...)` inline — list the services separately if needed.

**Certifications:**
- Use one `OneLineEntry` per certification. `label` is the full cert name; `details` is the date (required by RenderCV):
  ```yaml
  - label: "AWS Certified Solutions Architect – Professional"
    details: "May 2024"
  - label: "Certified Kubernetes Administrator (CKA) – CNCF"
    details: "Aug 2023"
  ```
- Do not group by issuer. Full cert names as proper nouns are clearer and avoid awkward comma-separated lists.

## Notes

- The output YAML under `templates/` becomes the source of truth for all future `/chameleon` runs.
- If `rendercv` is not installed, tell the user to run `make install-tools` before retrying Step 5.
