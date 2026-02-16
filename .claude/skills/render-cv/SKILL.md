---
name: render-cv
description: >
  Re-render a CV YAML to PDF using RenderCV. Use when the user wants to
  re-render a template or tailored CV without re-running the full tailor
  workflow. Accepts an optional file path argument; defaults to prompting
  the user to choose from available YAMLs.
disable-model-invocation: true
---

# /render-cv

Re-render a CV YAML to PDF using RenderCV.

## Usage

```
/render-cv [<path-to-yaml>]
```

Examples:
- `/render-cv` — lists available YAMLs and asks which to render
- `/render-cv templates/David_Alecrim_CV.yaml`
- `/render-cv tailored/Acme_Corp_Senior_Engineer_CV.yaml`

## Workflow

### Step 1 — Resolve which YAML to render

If a path argument was provided, use it. If the file does not exist, report the error and stop.

If no argument was provided:
1. List all `*.yaml` files under `templates/` and `tailored/`
2. Ask the user which one to render

### Step 2 — Render

Use the Makefile `render` target, which copies the YAML to the project root, renders it, and removes the copy — ensuring output always lands in `./rendercv_output/`:

```
make render FILE=<path>
```

### Step 3 — Report

If the render succeeds, report the path to the generated PDF inside `rendercv_output/`.

If it fails, show the full error output so the user can act on it.
