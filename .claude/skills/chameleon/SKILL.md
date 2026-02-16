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
- `/chameleon --cv John_CV "Senior Engineer at Acme Corp..."`

## Workflow

Follow these steps exactly in order:

### Step 1 — Obtain the job description

If the argument is a URL, fetch its content using WebFetch. If it is pasted text, use it directly. Store the raw JD text for the next step.

### Step 2 — Resolve the master CV

Scan the `templates/` directory for files matching the pattern `*_CV.yaml`.

- If `--cv <name>` was passed, use `templates/<name>_CV.yaml`. If it does not exist, report the error and stop.
- If exactly one `*_CV.yaml` exists in `templates/`, use it automatically.
- If multiple `*_CV.yaml` files exist and no `--cv` argument was given, list them and ask the user which one to use before continuing.

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

### Step 4 — Tailor the CV

Spawn the `update-cv-with-job-posting` agent. Pass it:
1. The full structured analysis from Step 3
2. The resolved master CV file path from Step 2

Wait for the agent to confirm it has saved the tailored YAML to `templates/`. The agent does not render — it only writes the file.

### Step 5 — Render the tailored CV

This step is mandatory and must always run after Step 4 completes, even if the agent did not report errors.

Use the Makefile `render` target directly:

```
make render FILE=templates/<company>_<role>_cv.yaml
```

Where `<company>` and `<role>` come from the analysis output, lowercased, spaces replaced by underscores, special characters removed.

### Step 6 — Report to the user

If the render succeeds, report the path to the generated PDF inside `rendercv_output/`.

If the render fails, show the full error output so the user can act on it. Do not silently swallow errors.

## Error Handling

- If the URL cannot be fetched, report the error and ask the user to paste the JD text directly.
- If `rendercv` is not installed, tell the user to run `make install-tools` and retry.
- Never silently skip a step. If any step fails, stop and report what went wrong.
