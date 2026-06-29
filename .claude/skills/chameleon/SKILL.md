---
name: chameleon
description: >
  Tailor the master resume for a specific job posting and render it to PDF.
  Use when the user provides a job URL or pastes a job description and wants
  a tailored CV generated. Provide a job URL or paste the job description as
  the argument.
disable-model-invocation: true
---

# /chameleon

Tailor a master CV YAML to a specific job posting and render it to PDF.

## Usage

```
/chameleon <job-url-or-paste> [--cv <master-cv-name>]
```

Examples:
- `/chameleon https://example.com/jobs/123`
- `/chameleon --cv john_doe "Senior Engineer at Acme Corp..."`

## Workflow

Follow these steps exactly in order:

### Step 1 — Obtain the job description

If the argument is a URL, fetch its content using WebFetch. If it is pasted text, use it directly. Store the raw JD text for the next step.

### Step 2 — Resolve the master CV

Scan the `templates/` directory for files matching the pattern `*_cv.yaml`.

- If `--cv <name>` was passed, use `templates/<name>_cv.yaml`. If it does not exist, report the error and stop.
- In all other cases — whether one file exists or many — list all found `*_cv.yaml` files and ask the user which one to use before continuing. Never auto-select silently.

### Step 3 — Analyze the job description

Spawn the `analyze-job-posting` agent. Pass it the full raw JD text. Wait for the structured analysis output before proceeding.

The agent will return a structured object with these fields:
- `company_name`
- `role_title`
- `seniority`
- `required_skills`
- `preferred_skills`
- `responsibilities`
- `ats_keywords`
- `positioning_signals`
- `summary_angle`

### Step 4 — Tailor the CV

Spawn the `update-cv-with-job-posting` agent. Pass it:
1. The full structured analysis from Step 3
2. The resolved master CV file path from Step 2

Wait for the agent to confirm it has saved the tailored YAML to `templates/`. The agent does not render — it only writes the file.

### Summary Quality Bar

The tailored summary must read like a resume summary, not a recruiter recommendation.

- Lead with the candidate's actual experience and strengths, not with a long stack list.
- Never use recruiter-facing evaluation language such as `strong fit`, `ideal candidate`, `should be shortlisted`, `for this role`, or `this candidate`.
- Write in third-person-neutral resume style focused on the person's experience and skills. Do not use `I`, and avoid pronoun-led phrasing when a direct skills-first sentence is cleaner.
- Show relevant expertise, but connect it to customer, business, or real-world impact whenever the master CV supports that framing.
- If the master CV and JD support it, surface genuine motivation for the problem space, product, or mission in concrete language rather than generic enthusiasm.
- Keep the first paragraph focused on technical fit and strongest role-relevant strengths.
- Use the second paragraph for motivation and broader impact, and include at least one concrete metric grounded in the master CV when one is available.
- Keep the summary to at most 2 paragraphs.
- Keep the broader stack coverage in the skills section instead of forcing it into the summary.

### Layout Defaults

Tailored resumes should preserve the master CV's `design` block unchanged. In this repo, the compact classic-theme defaults include `design.typography.line_spacing: 0.8em`, `design.typography.font_size.body/headline/connections: 9.5pt`, and `design.sections.space_between_regular_entries: 0.2cm`.

### Step 5 — Render the tailored CV

This step is mandatory and must always run after Step 4 completes, even if the agent did not report errors.

Use the Makefile `render` target directly:

```
make render FILE=templates/<username>_<company>_<role>_cv.yaml
```

Where `<username>` comes from the selected master CV filename with the trailing `_cv` removed, and `<company>` and `<role>` come from the analysis output. Lowercase all parts, replace spaces with underscores, and remove special characters.

### Step 6 — Report to the user

If the render succeeds, report the path to the generated PDF inside `output/`.

If the render fails, show the full error output so the user can act on it. Do not silently swallow errors.

## Error Handling

- If the URL cannot be fetched, report the error and ask the user to paste the JD text directly.
- If `rendercv` is not installed, tell the user to run `make install-tools` and retry.
- Never silently skip a step. If any step fails, stop and report what went wrong.
