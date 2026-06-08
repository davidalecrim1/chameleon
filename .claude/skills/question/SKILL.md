---
name: question
description: >
  Use when the user wants a concise, first-person answer to an application or
  screening question, grounded in a real resume YAML and a specific role or job
  description, including cases where the resume or job context is already in
  the current conversation, especially when the answer should stay to one
  paragraph and use simple, natural language.
---

# /question

Write a concise answer to a job application or screening question.

The skill may use resume and job context that is already established in the
current conversation. Do not force the user to restate it when the thread
already makes the context clear.

## Usage

```
/question <question-text> [--job <job-url-or-paste>] [--cv <master-cv-name>] [--resume <yaml-path>]
```

Examples:
- `/question "Why are you interested in this position?" --job https://example.com/jobs/123 --cv david_alecrim_cv`
- `/question --resume templates/david_alecrim_semiotic_labs_rust_engineer_cv.yaml --job "Rust Engineer at Semiotic Labs..." "Why do you want to work here?"`

## Workflow

Follow these steps exactly in order:

### Step 1 — Resolve the question and job context

- Treat the main argument as the exact question to answer.
- If `--job <job-url-or-paste>` was passed and it is a URL, fetch it using WebFetch.
- If `--job <job-url-or-paste>` was passed as pasted text, use it directly.
- If `--job` was not passed but the current thread already has a clear role context, pasted JD text, or tailored YAML for the same application, reuse that context.
- If no job context is available and the question clearly depends on the role, ask the user for the job description or role context before continuing.

### Step 2 — Resolve the source resume

Use the strongest available resume source for the answer.

- If `--resume <yaml-path>` was passed, use that exact YAML file.
- If `--cv <name>` was passed, use `templates/<name>_cv.yaml`. If it does not exist, report the error and stop.
- If the current thread already makes the source CV clear, reuse that CV context instead of asking the user to restate it.
- If the current thread already produced a tailored YAML for the same role, prefer that tailored YAML.
- In all other cases, list the candidate `*_cv.yaml` files and ask the user which one to use. Never guess silently when multiple reasonable options exist.

### Step 3 — Pull the writing inputs

From the question and job description, extract:
- employer name
- role title
- product or domain signals
- the requirement or trait the question is really testing
- the strongest role-specific angle for the answer

From the selected resume YAML, extract:
- the strongest matching summary points
- the most relevant experience bullets
- one concrete impact detail or metric when it helps
- any grounded mission, product, or domain fit

### Step 4 — Write the answer

Use these rules:

- Default to exactly 1 paragraph unless the user asks for a different length.
- Write in the first person.
- Answer the question directly in the first sentence.
- Use simple, direct language.
- Keep it concise.
- Lead with the strongest fit for the question, not with a stack list.
- Use assertive framing when the resume supports it. Sell strongly without inventing.
- Ground every claim in the selected resume, the current thread context, or the job description.
- Use the company name correctly. If the posting mentions a product or protocol, do not confuse it with the employer.
- Prefer one strong metric or impact detail over a long list of technologies.
- Mention mission, product, or domain motivation only when the job description and resume support it.
- Do not turn the answer into a cover letter, resume summary, or ATS keyword dump.
- Use plain terms and natural rhythm.
- When the user wants it more human or casual, allow subtle English mistakes, but keep them small and readable.
- Do not add a greeting or sign-off unless the user explicitly asks for one.

### Human quality bar

The answer must feel human-written.

- Avoid inflated language, generic enthusiasm, and abstract filler.
- Avoid em dashes.
- Avoid phrases that sound like sales copy or AI copy.
- Prefer natural sentence rhythm over overly tidy structure.
- Use plain statements like `I built`, `I improved`, `I liked`, `I want`, and `I’d be a good fit`.

### Step 5 — Humanize the draft

Run the draft through the `humanizer` skill before returning it.

- Keep the exact requested structure after the humanizer pass.
- If the user asked for `one paragraph`, the final result must still be one paragraph.
- If the user asked for `two paragraphs`, the final result must still be two paragraphs.
- If the user asked for simple terms or subtle English mistakes, preserve that request after the humanizer pass.
- Keep the answer direct, grounded, and natural.

### Step 6 — Report only the final answer

Return only the final answer text. Do not include analysis, notes, bullets, or alternative drafts unless the user explicitly asks for them.

## Non-negotiable rules

- Never fabricate experience, metrics, skills, or motivation.
- Never confuse the company name with the product name.
- If the user asks for `one paragraph`, write one paragraph.
- If the user asks for `two paragraphs`, write exactly two paragraphs.
- If the user asks for simple terms or subtle English mistakes, keep the wording natural and the mistakes light.
