# Chameleon — Resume Tailor

Chameleon is a Claude Code project that tailors a master resume YAML to a specific job posting, then renders it to PDF using RenderCV. It uses two internal agents to analyze the job description and apply changes to the YAML.

## Project Goal

Given a job posting URL or pasted job description, produce a tailored, ATS-optimized PDF resume derived from a master YAML file. Each tailored resume is saved as a separate YAML under `templates/` alongside the master.

## Directory Structure

```
chameleon/
├── .claude/
│   ├── skills/
│   │   ├── chameleon/
│   │   │   └── SKILL.md          # Command skill — /chameleon entrypoint
│   │   ├── init-cv/
│   │   │   └── SKILL.md          # Command skill — /init-cv entrypoint
│   │   └── render-cv/
│   │       └── SKILL.md          # Command skill — /render-cv entrypoint
│   └── agents/
│       ├── analyze-job-posting.md         # Subagent — job analysis (isolated context)
│       └── update-cv-with-job-posting.md  # Subagent — resume editor (isolated context)
├── templates/                    # Master and tailored CV YAMLs
│   ├── <Name>_CV.yaml            # Master — source of truth, never mutated by tailor runs
│   └── <company>_<role>_cv.yaml   # Tailored — one per job application
├── rendercv_output/              # RenderCV output — do not commit
└── CLAUDE.md                     # This file
```

## Technology Stack

- **RenderCV** — YAML → PDF renderer (Typst backend, no LaTeX required)
  - Install: `pip install rendercv`
  - Render: `rendercv render <file>.yaml`
  - Output: PDF, Markdown, HTML, PNG in `rendercv_output/`
- **Claude Code skills** — `/chameleon` and `/init-cv` are user-invocable command skills
- **Subagents** — `analyze-job-posting` and `update-cv-with-job-posting` run in isolated contexts

## Skills vs Agents

| Type | What it is | When it runs | Context |
|------|-----------|-------------|---------|
| **Command skill** | Instructions + `disable-model-invocation: true` | Only when user types `/skill-name` | Shared with main conversation |
| **Subagent** | Isolated Claude instance with own system prompt | Spawned by the skill | Own isolated context — returns summary to main |

**`/chameleon` and `/init-cv`** are command skills: user-triggered, not auto-invoked. They orchestrate the workflow and delegate work to subagents.

**`analyze-job-posting` and `update-cv-with-job-posting`** are subagents: spawned by the skill, run in isolation, return a summary. Isolation keeps large intermediate context (raw HTML, full YAML processing) out of the main thread.

## Skill Workflow (`/chameleon`)

1. **Fetch** the job posting URL or read pasted text
2. **Resolve** which master CV to use from `templates/`:
   - If `--cv` argument provided, use `templates/<name>_CV.yaml`
   - If only one YAML exists in `templates/`, use it automatically
   - If multiple YAMLs exist in `templates/` and none specified, list them and ask the user to choose
3. **Spawn** `analyze-job-posting` subagent with the raw JD text
4. **Receive** structured analysis output
5. **Spawn** `update-cv-with-job-posting` subagent with analysis + resolved master YAML path
6. Subagent saves `templates/<company>_<role>_cv.yaml` and reports the path
7. **Render** via `make render FILE=templates/<company>_<role>_cv.yaml`
8. **Report** the path to the generated PDF

## CV Initialization Workflow (`/init-cv`)

Used when setting up for the first time or when the user provides an updated source resume.

1. Accept a PDF or YAML as input
2. If PDF: parse the content and produce a valid `master_cv.yaml` conforming to RenderCV schema
3. If YAML: validate the structure against RenderCV entry types and save as `master_cv.yaml`
4. Confirm the file renders cleanly: `rendercv render master_cv.yaml`

## Editing Rules (apply to all agents)

These rules are absolute and must never be violated:

- **Never fabricate experience.** Only reword or reorder what already exists in the master YAML. Do not invent companies, roles, dates, metrics, or skills.
- **Preserve all facts.** Company names, job titles, locations, and dates are immutable. Only highlight bullets may be rewritten.
- **Match the JD's language.** If the JD says "CI/CD pipelines" and the master says "continuous integration", use the JD's phrasing.
- **Never edit the master YAML during a tailor run.** Always write a new file to `templates/` with the company and role in the filename.
- **Length constraint.** Keep to 1 page for fewer than 10 years of experience, 2 pages maximum otherwise. Remove lower-impact bullets before adding new ones if length is at risk.
- **Validate before reporting.** The `/chameleon` skill runs `make render` on the tailored YAML after the agent saves it, and confirms it succeeds before reporting the PDF path to the user.

## RenderCV YAML Rules

- Section keys become section titles (e.g., `technical_skills` → "Technical Skills")
- Entry types are auto-detected by their fields:
  - `company` field → ExperienceEntry
  - `institution` field → EducationEntry
  - `label` field → OneLineEntry
- One entry type per section — do not mix types
- Markdown is supported inside `highlights` bullets: `**bold**`, `*italic*`, `[links](url)`
- `settings.bold_keywords` is a list of strings auto-bolded throughout the PDF — update this on every tailor run to reflect the JD's hard skills

## Subagents

### `analyze-job-posting`

Runs in an isolated context. Responsible solely for extracting structured signal from a job description. No file I/O. Output:
- `required_skills`, `preferred_skills`
- `responsibilities`, `ats_keywords`
- `seniority`, `role_title`, `company_name`

### `update-cv-with-job-posting`

Runs in an isolated context. Receives job analysis + master YAML path. Reads master YAML, writes tailored YAML to `templates/<company>_<role>_cv.yaml`, and reports the saved path. Does not render — the `/chameleon` skill handles rendering.

Only edits: `summary`, `experience` highlights, `settings.bold_keywords`, `skills` section order.
Never touches: `education`, `languages`, certifications, publications, or any other fixed sections.

## Reference Documentation

- YAML structure: https://docs.rendercv.com/user_guide/yaml_input_structure/
- Entry types: https://docs.rendercv.com/user_guide/yaml_input_structure/cv/
- Design options: https://docs.rendercv.com/user_guide/yaml_input_structure/design/
- Settings (bold_keywords): https://docs.rendercv.com/user_guide/yaml_input_structure/settings/
