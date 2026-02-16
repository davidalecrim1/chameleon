# Chameleon — Resume Tailor

Chameleon is a [Claude Code](https://claude.ai/claude-code) project that tailors a master resume YAML to a specific job posting and renders it to PDF using [RenderCV](https://docs.rendercv.com/).

It uses two internal agents: one to analyze the job description and extract structured signal, and one to apply targeted edits to the resume YAML. The master file is never modified — each run produces a separate tailored YAML under `templates/`.

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed and authenticated
- Python 3.10+

## Setup

```bash
git clone <your-repo-url>
cd chameleon
make install-tools
```

This creates a `.venv` and installs `rendercv` inside it.

## Workflow

### Step 1 — Import your resume

If you have an existing PDF resume, import it as the master YAML:

```
/init-cv ~/Downloads/resume.pdf
```

If you already have a RenderCV-compatible YAML:

```
/init-cv ~/Documents/my_resume.yaml
```

This parses the input, produces a RenderCV-compliant YAML at `templates/<your_name>_cv.yaml`, and does a test render to confirm everything works.

> The file under `templates/` is your master — the source of truth for all future tailor runs. It is never modified by `/chameleon`.

### Step 2 — Tailor for a job posting

Provide a job URL or paste the job description directly:

```
/chameleon https://jobs.example.com/senior-engineer-123
```

```
/chameleon "Senior Software Engineer at Acme Corp. We're looking for..."
```

If you have multiple master CVs in `templates/`, specify which one to use with `--cv <name>`, where `<name>` is the filename stem before `_cv.yaml`:

```
/chameleon --cv john_doe https://jobs.example.com/senior-engineer-123
```

This resolves to `templates/john_doe_cv.yaml`.

This will:

1. Fetch and analyze the job description
2. Rewrite the summary, reorder experience highlights, and update `bold_keywords` to match the JD
3. Save a tailored YAML to `templates/<company>_<role>_cv.yaml`
4. Render it to PDF via `rendercv`
5. Report the path to the generated PDF

### Step 3 — Re-render without re-tailoring

To re-render any existing YAML (e.g., after a manual edit):

```
/render-cv templates/acme_corp_senior_engineer_cv.yaml
```

Or run it without arguments to pick from a list:

```
/render-cv
```

## What the agents edit

| Field | Editable |
|---|---|
| `summary` | Yes |
| `experience` highlights | Yes (reword and reorder only) |
| `settings.bold_keywords` | Yes |
| `skills` section order | Yes |
| Company names, titles, dates | Never |
| `education`, certifications | Never |

No experience is fabricated. The agents only reword and reorder what already exists in the master YAML.

## Output

Rendered PDFs land in `output/`. This directory is not committed.

## Directory Structure

```
chameleon/
├── .claude/
│   ├── skills/
│   │   ├── chameleon/SKILL.md      # /chameleon entrypoint
│   │   ├── init-cv/SKILL.md        # /init-cv entrypoint
│   │   └── render-cv/SKILL.md      # /render-cv entrypoint
│   └── agents/
│       ├── analyze-job-posting.md
│       └── update-cv-with-job-posting.md
├── templates/                       # Master and tailored YAMLs
├── output/                 # Generated PDFs (not committed)
├── Makefile
└── CLAUDE.md
```
