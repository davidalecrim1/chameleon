---
name: tailor-cv
description: >
  Tailor a master CV using a previously saved job analysis artifact.
  Use when the user wants to update a CV from a stored JD analysis instead of
  re-running job extraction.
disable-model-invocation: true
---

# /tailor-cv

Tailor a master CV YAML from a saved job analysis artifact.

## Usage

```
/tailor-cv --analysis <path-or-id> --cv <master-cv-name>
```

Examples:
- `/tailor-cv --analysis a7c19f2d --cv david_alecrim`
- `/tailor-cv --analysis output/job_analyses/a7c19f2d__tempo__rust_engineer.json --cv david_alecrim`

## Workflow

Follow these steps exactly in order:

### Step 1 — Resolve the saved analysis artifact

`--analysis <path-or-id>` is required.

Resolve it from the locally saved analysis artifacts under `output/job_analyses/`.

If resolution fails, report the error and stop. Do not fall back to the latest analysis.

### Step 2 — Resolve the source CV

`--cv <name>` is required.

Use `templates/<name>_cv.yaml`.

If the file does not exist, report the error and stop.

### Step 3 — Tailor the CV

Spawn the `update-cv-with-job-posting` agent. Pass it:
1. The resolved saved analysis JSON
2. The resolved master CV file path

Wait for the agent to save the tailored YAML under `templates/`.

### Step 4 — Render the tailored CV

This step is mandatory.

Use:

```bash
make render FILE=templates/<username>_<company>_<role>_cv.yaml
```

Where the saved file path comes from the tailoring agent result.

### Step 5 — Report

If render succeeds, report:
- tailored YAML path
- generated PDF path
- analysis ID used

If render fails, show the full error output and stop.

## Non-negotiable rules

- Never re-run `analyze-job-posting` when `--analysis` is provided.
- Never default to the most recent analysis artifact.
- The analysis artifact must come only from `output/job_analyses/`.
