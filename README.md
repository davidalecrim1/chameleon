# Chameleon — Resume Tailor

Chameleon is an AI project that works with [Claude Code](https://claude.ai/claude-code), [Codex](https://openai.com/codex/), and OpenCode. It tailors a master resume YAML to a target job description, while saving the intermediate job analysis locally for later reuse.

It is designed for one job: start from a truthful master CV, adapt the wording to match a target job description, and produce a ready-to-submit PDF without inventing experience.

## What It Does 🛠️

- Keeps your master CV unchanged
- Saves a separate job-analysis JSON artifact for each application
- Creates a separate tailored YAML for each application
- Rewrites only allowed parts of the resume to match the job description's language
- Renders the tailored YAML to PDF with RenderCV
- Scores a tailored CV against a saved job analysis artifact
- Works with Claude Code, Codex, and OpenCode

## Constraints 🔒

- No fabricated experience, skills, metrics, titles, or dates
- Only rewording, reordering, and emphasis changes are allowed
- The master CV is never modified during a tailoring run

## Prerequisites

- Python 3.10+
- [Claude Code](https://claude.ai/claude-code), [Codex](https://openai.com/codex/), or OpenCode

## Installation

```bash
git clone https://github.com/davidalecrim1/chameleon.git
cd chameleon
make install-tools
```

This creates a `.venv` and installs `rendercv` inside it.

## Quick Start

### 1. Start Claude Code, Codex, or OpenCode

All project commands are exposed as slash commands:

- `/init-cv`
- `/chameleon`
- `/tailor-cv`
- `/score-cv`
- `/render-cv`

Claude Code:

```bash
claude
```

Codex:
```bash
codex
```

OpenCode:
```bash
opencode
```

### 2. Import your master CV once

If your source resume is a PDF:

```bash
/init-cv ~/Downloads/david-alecrim.pdf
```

If you already have a RenderCV-compatible YAML:

```bash
/init-cv ~/Documents/david-alecrim.yaml
```

This creates a RenderCV-compatible master file under `templates/` and runs a render check.

### 3. Tailor for a job posting

Pass either a job URL:

```bash
/chameleon --cv david_alecrim https://jobs.example.com/senior-engineer-123
```

Or pasted job description text:

```bash
/chameleon "Senior Software Engineer at Acme Corp. We're looking for..."
```

If you have more than one master CV in `templates/`, specify which one to use with `--cv <name>`, where `<name>` is the filename stem before `_cv.yaml`:

```bash
/chameleon --cv david_alecrim https://jobs.example.com/senior-engineer-123
```

The `/chameleon` flow will:

1. Fetch and analyze the job description
2. Save a JSON artifact under `output/job_analyses/<analysis_id>__<company>__<role>.json`
3. Rewrite the summary, reorder experience highlights, reorder skills, and clear `settings.bold_keywords` if present
4. Save a tailored YAML to `templates/<username>_<company>_<role>_cv.yaml`
5. Render it to PDF via `make render`
6. Report the analysis ID, saved JSON path, tailored YAML path, and generated PDF path

### 4. Score a tailored CV against a saved analysis

```bash
/score-cv --analysis a7c19f2d --cv templates/david_alecrim_tempo_rust_engineer_cv.yaml
```

This flow will:

1. Resolve the saved analysis from `output/job_analyses/`
2. Extract structured evidence from the tailored YAML
3. Score the CV against the saved analysis
4. Report the final score, breakdown, and missing requirements

## Local Files

Chameleon stores its working files locally in two main folders:

- `templates/`: local CV YAML files
- `output/`: local generated artifacts

Within those folders:

- `templates/<name>_cv.yaml` is treated as a master CV when you pass `--cv <name>`
- Tailored CVs are written as `templates/<username>_<company>_<role>_cv.yaml`
- Saved job analyses are written as `output/job_analyses/<analysis_id>__<company>__<role>.json`
- Rendered PDFs, HTML, Markdown, Typst, and image output land in `output/`
- `output/` is not committed

Additional local file rules:

- Chameleon does not use RenderCV `settings.bold_keywords`; keep it absent or empty so certifications and other fixed sections are not auto-bolded
- If RenderCV is missing, run `make install-tools`

### Example

The following is the master template CV rendered to PDF:

![Master template — page 1](docs/example/master_template_1.png)
![Master template — page 2](docs/example/master_template_2.png)

## License

MIT — see [LICENSE](LICENSE).
