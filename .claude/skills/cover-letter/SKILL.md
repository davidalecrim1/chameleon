---
name: cover-letter
description: >
  Use when the user wants a concise, first-person cover letter tailored to a
  specific role from a job URL or pasted job description and a real resume
  YAML, especially when length, tone, greeting, or sign-off constraints matter.
---

# /cover-letter

Write a concise cover letter tailored to a job posting.

## Usage

```
/cover-letter <job-url-or-paste> [--cv <master-cv-name>] [--resume <yaml-path>]
```

Examples:
- `/cover-letter https://example.com/jobs/123 --cv david_alecrim_cv`
- `/cover-letter --resume templates/david_alecrim_semiotic_labs_rust_engineer_cv.yaml "Rust Engineer at Semiotic Labs..."`

## Workflow

Follow these steps exactly in order:

### Step 1 — Obtain the job description

If the argument is a URL, fetch its content using WebFetch. If it is pasted text, use it directly.

### Step 2 — Resolve the source resume

Use the strongest available resume source for the letter.

- If `--resume <yaml-path>` was passed, use that exact YAML file.
- If `--cv <name>` was passed, use `templates/<name>_cv.yaml`. If it does not exist, report the error and stop.
- If the current thread already produced a tailored YAML for the same role, prefer that tailored YAML.
- In all other cases, list the candidate `*_cv.yaml` files and ask the user which one to use. Never guess silently when multiple reasonable options exist.

### Step 3 — Pull the writing inputs

From the job description, extract:
- employer name
- role title
- product or protocol names
- mission or problem-space signals
- the most important requirements and responsibilities

From the selected resume YAML, extract:
- the strongest matching summary points
- the most relevant experience bullets
- one or two concrete impact details or metrics
- any grounded product, mission, or domain fit

### Step 4 — Write the cover letter

Use these rules:

- Default to exactly 2 paragraphs unless the user asks for a different length.
- Start with `Hey,`
- End with:

```
Regards,
David
```

- Write in the first person.
- Use simple, direct language.
- Keep it concise.
- Make it eye catching by leading with the strongest fit for the role, not with a stack list.
- Avoid generic throat-clearing openings like `I'm a strong fit for this role` or `I believe I am a good match`. Start with concrete experience, scope, or impact instead.
- Use assertive framing when the resume supports it. Sell strongly without inventing.
- Ground every claim in the selected resume or the job description.
- Use the company name correctly. If the posting mentions a product or protocol, do not confuse it with the employer.
- Prefer one strong metric or impact detail over a long list of technologies.
- Mention mission, product, or domain motivation only when the job description and resume support it.
- Do not turn the letter into a resume summary or ATS keyword dump.

### Human quality bar

The letter must feel human-written.

- Avoid inflated language, generic enthusiasm, and abstract filler.
- Avoid em dashes.
- Avoid phrases that sound like sales copy or AI copy.
- Prefer natural sentence rhythm over overly tidy structure.
- Use plain statements like `I built`, `I improved`, `I want`, and `I’d be excited to`.

### Paragraph guidance

For the default 2-paragraph format:

- Paragraph 1: why I fit this role, using the strongest relevant experience and one concrete result when possible.
- Paragraph 1 should open with concrete work context or impact, not a generic claim that I fit the role.
- Paragraph 2: why I want this company, product, or problem space, and what I would bring.

### Step 5 — Humanize the draft

Run the draft through the `humanizer` skill before returning it.

- Keep the exact requested structure after the humanizer pass.
- If the user asked for `one paragraph`, the final result must still be one paragraph.
- If the user asked for `two paragraphs`, the final result must still be two paragraphs.
- Preserve the exact greeting and sign-off format after the humanizer pass.
- Keep the language simple, direct, and grounded in the resume and JD.

### Step 6 — Report only the final letter

Return only the final cover letter text. Do not include analysis, notes, bullets, or alternative drafts unless the user explicitly asks for them.

## Non-negotiable rules

- Never fabricate experience, metrics, skills, or motivation.
- Never confuse the company name with the product name.
- If the user asks for `one paragraph`, write one paragraph.
- If the user asks for `two paragraphs`, write exactly two paragraphs.
- If the user gives a greeting or sign-off format, preserve it exactly.
