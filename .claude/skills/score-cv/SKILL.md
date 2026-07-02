---
name: score-cv
description: >
  Score a tailored CV against a previously saved job analysis artifact.
  Use when the user wants a grounded 0-100 match score without re-running
  job extraction.
disable-model-invocation: true
---

# /score-cv

Score a tailored CV against a saved job analysis artifact.

## Usage

```
/score-cv --analysis <path-or-id> --cv <tailored-yaml-path>
```

Examples:
- `/score-cv --analysis a7c19f2d --cv templates/david_alecrim_tempo_rust_engineer_cv.yaml`
- `/score-cv --analysis output/job_analyses/a7c19f2d__tempo__rust_engineer.json --cv templates/david_alecrim_tempo_rust_engineer_cv.yaml`

## Workflow

Follow these steps exactly in order:

### Step 1 — Resolve the saved analysis artifact

`--analysis <path-or-id>` is required.

Resolve it from the locally saved analysis artifacts under `output/job_analyses/`.

If resolution fails, report the error and stop.

### Step 2 — Resolve the tailored CV

`--cv <tailored-yaml-path>` is required.

If the file does not exist, report the error and stop.

### Step 3 — Extract CV evidence

Read the tailored YAML and extract the relevant resume evidence directly in the workflow context.

If evidence extraction fails, report the error clearly and stop.

### Step 4 — Score the CV

Spawn the `score-cv-match` agent. Pass it a JSON object with:
- `job_analysis`
- `cv_evidence`
- `scoring_rubric`

Use this exact rubric:

```json
{
  "required_skills": 40,
  "responsibilities": 25,
  "ats_keywords": 15,
  "positioning": 10,
  "preferred_skills": 10
}
```

The scoring agent must return grounded JSON only.

### Step 5 — Report

Return:
- final score
- category breakdown
- key matched evidence
- missing requirements

## Non-negotiable rules

- Never re-run `analyze-job-posting` when `--analysis` is provided.
- Never score against hidden thread context.
- Only score from the saved analysis artifact plus extracted CV evidence.
