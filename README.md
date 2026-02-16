# Chameleon — Resume Tailor

Chameleon is a [Claude Code](https://claude.ai/claude-code) project that tailors a master resume YAML to a specific job posting and renders it to PDF using [RenderCV](https://docs.rendercv.com/).

Tailoring a resume for every application is the difference between getting a callback and getting ignored by ATS filters — but doing it manually takes 30–60 minutes per application and creates the temptation to embellish. Chameleon does it in seconds, and by design it cannot lie.

- **ATS-optimized in seconds** — paste a job URL or description and get a tailored PDF, ready to submit
- **Honest by construction** — edits are constrained to rewording and reordering what already exists in your master resume; no invented metrics, fabricated skills, or inflated titles
- **Master resume stays untouched** — each run produces a separate, versioned YAML under `templates/`, one per application
- **Accurate language matching** — a dedicated analysis agent extracts the exact phrasing from the job description and injects it into your resume, so your experience speaks the recruiter's language
- **PDF output** — rendered via RenderCV (Typst backend) with a clean, professional layout

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
4. Render it to PDF via `make render`
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


## Output

Rendered PDFs land in `output/`. This directory is not committed.
