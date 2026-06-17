# Chameleon — Resume Tailor

Chameleon is a Claude Code project that tailors a master resume YAML to a specific job posting, then renders it to PDF using RenderCV. It uses two internal agents to analyze the job description and apply changes to the YAML.

## Project Goal

Given a job posting URL or pasted job description, produce a tailored, ATS-optimized PDF resume derived from a master YAML file. Each tailored resume is saved as a separate YAML under `templates/` alongside the master.

## Technology Stack

- **RenderCV** — YAML → PDF renderer (Typst backend, no LaTeX required)
  - Install: `make install-tools`
  - Render: `make render FILE=<file>.yaml`
  - Output: PDF, Markdown, HTML, PNG in `output/`
- **Claude Code skills** — `/chameleon`, `/cover-letter`, `/question`, and `/init-cv` are user-invocable command skills
- **Subagents** — `analyze-job-posting` and `update-cv-with-job-posting` run in isolated contexts

## Skills vs Agents

| Type | What it is | When it runs | Context |
|------|-----------|-------------|---------|
| **Command skill** | Instructions in `SKILL.md`, optionally with `disable-model-invocation: true` | Usually when user types `/skill-name` | Shared with main conversation |
| **Subagent** | Isolated Claude instance with own system prompt | Spawned by the skill | Own isolated context — returns summary to main |

**`/chameleon`, `/cover-letter`, `/question`, and `/init-cv`** are command skills: user-triggered, not auto-invoked. They orchestrate the workflow and delegate work to subagents when needed.

**`analyze-job-posting` and `update-cv-with-job-posting`** are subagents: spawned by the skill, run in isolation, return a summary. Isolation keeps large intermediate context (raw HTML, full YAML processing) out of the main thread.

## Codex Delegation

For Codex, keep the same two-agent split. When the user explicitly wants delegation or subagents, use `spawn_agent` so the raw JD text and YAML editing work stay out of the main thread.

- Reuse `.claude/agents/analyze-job-posting.md` as the prompt boundary for the analysis subagent. It should receive only the raw JD text and return the structured analysis fields documented below.
- Reuse `.claude/agents/update-cv-with-job-posting.md` as the prompt boundary for the editing subagent. It should receive only the structured analysis plus the resolved master YAML path.
- Do the orchestration, CV selection, rendering, and user-facing reporting in the main thread.
- Do not delegate if the user is only asking questions about the repo or workflow. Delegate when performing an actual tailoring run and isolation helps control context size.

## Skill Workflow (`/chameleon`)

1. Fetch the job posting URL or read pasted text
2. Resolve the source CV
3. Run `analyze-job-posting` on the raw JD text
4. Run `update-cv-with-job-posting` with the analysis plus the resolved CV path
5. Render the tailored YAML and report the generated PDF
6. Follow the argument handling, file naming, summary constraints, and error rules in `.claude/skills/chameleon/SKILL.md`

## CV Initialization Workflow (`/init-cv`)

Used when setting up for the first time or when the user provides an updated source resume.

1. Accept a PDF or YAML as input
2. Parse PDF input into RenderCV YAML or validate YAML input
3. Save the resulting master CV under `templates/`
4. Render it and confirm the output succeeds
5. Follow the overwrite, schema, layout, and validation rules in `.claude/skills/init-cv/SKILL.md`

## Cover Letter Workflow (`/cover-letter`)

Used when the user wants a concise, first-person cover letter tailored to a specific role from a job URL or pasted job description and a real resume YAML, especially when length, tone, greeting, or sign-off constraints matter.

1. Accept a job URL or pasted job description
2. Resolve the source resume from `--resume`, `--cv`, or a clearly relevant tailored YAML from the current thread; if multiple reasonable YAMLs exist and no source is clear, ask the user which one to use instead of guessing
3. Extract the employer name, role title, product or protocol names, mission or problem-space signals, and the strongest matching resume evidence
4. Default to exactly 2 paragraphs, start with `Hey,`, end with `Regards,` and `David`, and write in simple, direct first-person language grounded in the selected resume and job description
5. Lead with the strongest fit and one concrete impact detail when possible; do not turn the letter into a stack list, ATS keyword dump, or generic enthusiasm
6. Run a final `humanizer` pass while preserving the exact requested structure, greeting, and sign-off
7. Return only the final cover letter text

## Question Workflow (`/question`)

Used when the user wants a concise, first-person answer to an application or screening question, grounded in a real resume YAML and specific role context already provided in the thread or via a fresh job description.

1. Treat the main argument as the exact question to answer
2. Accept an optional job URL or pasted job description, or reuse clear role, JD, or tailored-YAML context already present in the thread when it is relevant to the same application
3. Resolve the strongest available source resume from `--resume`, `--cv`, or the current thread; if multiple reasonable YAMLs exist and no source is clear, ask the user which one to use instead of guessing
4. Extract what the question is really testing, the strongest role-specific angle, and the best matching resume evidence
5. Default to exactly 1 paragraph, answer the question directly in the first sentence, and write in simple, direct first-person language grounded in the selected resume, thread context, and job description
6. Use assertive framing when supported, prefer one strong impact detail over a stack list, and avoid turning the answer into a cover letter, resume summary, or ATS keyword dump
7. Run a final `humanizer` pass while preserving the exact requested structure and any requested simplicity or casualness
8. Return only the final answer text

## Editing Rules (apply to all agents)

These rules are absolute and must never be violated:

- **Never fabricate experience.** Only reword or reorder what already exists in the master YAML. Do not invent companies, roles, dates, metrics, or skills.
- **Preserve all facts.** Company names, job titles, locations, and dates are immutable. Only highlight bullets may be rewritten.
- **Match the JD's language.** If the JD says "CI/CD pipelines" and the master says "continuous integration", use the JD's phrasing.
- **Never edit the master YAML during a tailor run.** Always write a new file to `templates/` with the `<username>_<company>_<role>_cv.yaml` naming convention, where `<username>` comes from the selected master CV filename without the trailing `_cv`.
- **Length constraint.** Keep tailored resumes to 2 pages maximum, ideally. Remove lower-impact bullets before adding new ones if length is at risk.
- **Validate before reporting.** The `/chameleon` skill runs `make render` on the tailored YAML after the agent saves it, and confirms it succeeds before reporting the PDF path to the user.

## RenderCV YAML Rules

- Section keys become section titles (e.g., `technical_skills` → "Technical Skills")
- Entry types are auto-detected by their fields:
  - `company` field → ExperienceEntry
  - `institution` field → EducationEntry
  - `name` field → NormalEntry
  - `label` field → OneLineEntry
- One entry type per section — do not mix types
- Project entries must use plain text names, not Markdown links, and must not include `start_date`, `end_date`, or `date`
- Markdown is supported inside `highlights` bullets: `**bold**`, `*italic*`, `[links](url)`
- Do not use `settings.bold_keywords` in this repo. Leave it absent or empty so global auto-bolding does not bleed into fixed sections like certifications.
- Default classic-theme typography in this repo uses `design.typography.line_spacing: 0.8em`, `design.typography.font_size.body/headline/connections: 9.5pt`, and `design.sections.space_between_regular_entries: 0.2cm` to keep dense resumes closer to two pages without changing section order.

## Subagents

### `analyze-job-posting`

Runs in an isolated context. Responsible solely for extracting structured signal from a job description. No file I/O. Output:
- `required_skills`, `preferred_skills`
- `responsibilities`, `ats_keywords`
- `positioning_signals`, `summary_angle`
- `seniority`, `role_title`, `company_name`

### `update-cv-with-job-posting`

Runs in an isolated context. Receives job analysis + master YAML path. Reads master YAML, writes tailored YAML to `templates/<username>_<company>_<role>_cv.yaml`, and reports the saved path. Does not render — the `/chameleon` skill handles rendering.

Only edits: `summary`, `experience` highlights, clearing `settings.bold_keywords` when present, and `skills` section order.
Never touches: `projects`, `education`, `languages`, certifications, publications, or any other fixed sections.

Summary guidance for tailor runs:
- The summary must read like a resume summary, not a recruiter recommendation, and must not just mirror the JD's stack.
- Lead with the strongest positioning signal supported by the master CV, such as product mindset, customer impact, ownership, or cross-functional fluency.
- Use only the most important JD keywords in the summary; keep broader technology coverage in the skills section.
- The first sentence should establish seniority and the strongest relevant strengths without using reviewer language such as `strong fit`, `should be shortlisted`, or `this candidate`.
- Connect expertise to customer, business, or real-world impact when the master CV supports that framing.
- If the master CV and JD support it, surface grounded motivation for the problem space, product, or mission instead of writing a purely technology-led summary.
- Write resume summaries in third-person-neutral resume style focused on experience and strengths. Do not use `I`, and avoid pronoun-led phrasing when a direct skills-first sentence is cleaner.
- Keep the summary to at most 2 paragraphs.

## Reference Documentation

- YAML structure: https://docs.rendercv.com/user_guide/yaml_input_structure/
- Entry types: https://docs.rendercv.com/user_guide/yaml_input_structure/cv/
- Design options: https://docs.rendercv.com/user_guide/yaml_input_structure/design/
