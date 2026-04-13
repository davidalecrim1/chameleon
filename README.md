# Chameleon — Resume Tailor

Chameleon is a [Claude Code](https://claude.ai/claude-code) and [Codex](https://openai.com/codex/) project that tailors a master resume YAML to a specific job posting and renders it to PDF using [RenderCV](https://docs.rendercv.com/).

Tailoring a resume for every application is the difference between getting a callback and getting ignored by ATS filters — but doing it manually takes 30–60 minutes per application and creates the temptation to embellish. Chameleon does it in seconds, and by design it cannot lie.

## Why use Chameleon?

- ⚡ **ATS-optimized in seconds** — paste a job URL or description and get a tailored PDF, ready to submit
- 🔒 **Honest by construction** — edits are constrained to rewording and reordering what already exists in your master resume; no invented metrics, fabricated skills, or inflated titles
- 📁 **Master resume stays untouched** — each run produces a separate, versioned YAML under `templates/`, one per application
- 🎯 **Accurate language matching** — a dedicated analysis agent extracts the exact phrasing from the job description and injects it into your resume, so your experience speaks the recruiter's language
- 📄 **Clean PDF output** — rendered via RenderCV (Typst backend) with a professional layout, no LaTeX required
- 🤖 **Fully automated** — two specialized Claude agents handle analysis and editing in isolated contexts, keeping the workflow fast and focused

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) or [Codex](https://openai.com/codex/) installed and configured
- Python 3.10+

## Setup

```bash
git clone https://github.com/davidalecrim1/chameleon.git
cd chameleon
make install-tools
```

This creates a `.venv` and installs `rendercv` inside it.

## Workflow

### Step 1 — Start your agent

All commands (`/init-cv`, `/chameleon`, `/render-cv`) are available in both Claude Code and Codex:

Claude:
```bash
claude
```

Codex:
```bash
codex
```

Then proceed with the steps below.

### Step 2 — Import your resume

If you have an existing PDF resume, import it as the master YAML:

```
/init-cv ~/Downloads/david-alecrim.pdf
```

If you already have a RenderCV-compatible YAML:

```
/init-cv ~/Documents/david-alecrim.yaml
```

This parses the input, produces a RenderCV-compliant YAML at `templates/david_alecrim_cv.yaml`, and does a test render to confirm everything works.

### Step 3 — Tailor for a job posting

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

### Step 4 — Re-render without re-tailoring

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

### Example

The following is the master template CV rendered to PDF:

![Master template — page 1](docs/example/master_template_1.png)
![Master template — page 2](docs/example/master_template_2.png)

## License

MIT — see [LICENSE](LICENSE).
