---
name: prepme
description: Generate a tailored set of likely interview questions from a candidate's resume (CV) and a job description (JD), output as an interactive HTML study sheet. Each question is clickable to copy an AI deep-dive prompt and mark itself as processed. Takes two file inputs — CV and JD; the output language is auto-detected from those documents. Trigger on "prepare interview questions", "interview prep", "mock interview questions", "prepme".
allowed-tools: Bash Read Write
---

# Interview Preparation

Turn a candidate's **resume (CV)** and a **job description (JD)** into a focused, interactive set of likely interview questions. The deliverable is a single self-contained HTML file the candidate studies from: every question is clickable to (1) copy a ready-to-paste AI prompt that requests a deep-dive analysis of that question, and (2) mark the question as processed so the candidate can track progress.

The goal is **breadth of realistic coverage**, not a domain encyclopedia. The question set is built in **two distinct halves**: one driven by the **JD** (the common technical knowledge the role requires) and one driven by the **CV** (the candidate's actual projects and the technologies they claim). Keep these two halves separate — they are generated from different sources and probe different things.

---

## Inputs

Two file inputs are required. Gather any that are missing before proceeding:

1. **CV file** — path to the candidate's resume (PDF, Markdown, txt, docx). Read it.
2. **JD file** — path to the job description (any text format). Read it.

The **output language is auto-detected** — do not ask for it. Use the JD's dominant natural language for all output (questions, follow-ups, labels, the copy prompt), falling back to the CV's language if the JD's is unclear, but always keep technology names, tools, and acronyms in their original form. An explicit language in the user's request overrides detection; only ask if no language can be determined at all. Record the resolved language in `META.language`.

If a file path is ambiguous or unreadable, ask the user for the correct path rather than guessing. PDFs can be read directly with the Read tool.

---

## Principles

These shape *which* questions you generate. Read them before drafting.

1. **Two sources, two halves.**
   - **JD half — common required knowledge.** From the JD, extract the underlying tech, skills, and concepts the role requires, then ask questions about *that knowledge in general*. Do **not** weld the company's specific domain or product onto each question — a "real-time payments platform using Kafka" JD should yield a clean question about Kafka delivery semantics or event-driven design, not "how would you build our payments pipeline with Kafka." Test whether the candidate owns the transferable fundamentals the role depends on.
   - **CV half — experience & claimed tech.** From the CV, ask about the candidate's actual projects, decisions, and the specific technologies they list. These questions *are* grounded in the candidate's own work: probe what they built, why, the tradeoffs they made, and whether their claimed depth in each listed tech is real.

2. **General over hyper-specific (JD half especially).** Favor widely transferable technical and conceptual knowledge — fundamentals, design tradeoffs, debugging approach, system thinking. Avoid obscure, company-internal, or narrow domain trivia. A good question is one a competent practitioner *should* be able to answer and that reveals real understanding.

3. **Full coverage, no padding.** Every meaningful JD knowledge area and every substantial CV project/technology should map to at least one question. Track this explicitly (see Coverage Map). Do not invent questions for things absent from both documents.

4. **Anticipate the follow-up.** Real interviews drill down. Each question carries 2–4 likely follow-ups the interviewer would ask next — these reward depth and expose hand-waving.

5. **Honest difficulty.** Tag each question's level (Foundational / Core / Advanced) so the candidate budgets study time well.

---

## Workflow

### Step 1 — Read and extract

Read both files fully. Produce two internal lists (you don't have to show them, but reason through them):

- **JD knowledge set**: the underlying technologies, skills, and concepts the role requires — distilled into *general knowledge areas*, deliberately stripped of the company's specific product/domain framing.
- **CV claims**: each project, role, achievement, technical decision, and specific technology the candidate asserts.

Also note the **role level** (junior / mid / senior / lead) since it sets question difficulty, and **resolve the output language** per the Inputs rules. Use that language for everything that follows.

### Step 2 — Design the two question sets

Generate **20–35 questions total**, split into the two halves below, each organized into **2–4 categories**. Order the JD categories first, then the CV categories, so the HTML reads as two clear sections.

**Set A — JD-driven (common required knowledge).** Cover the knowledge areas the role depends on, as *general* questions per Principle 1. Typical categories (adapt — don't force-fit):
- Core technical fundamentals (language / runtime / CS basics the role implies)
- Tools, frameworks & paradigms named in the JD (asked generically, not bolted to the company's product)
- System / architecture / design thinking
- Practices the role demands (testing, debugging, collaboration, process)

**Set B — CV-driven (experience & claimed tech).** Ground every question in the candidate's own résumé:
- Project deep-dives (one or more per substantial project — what, why, tradeoffs, outcomes, what they'd change)
- Depth probes on specific technologies the CV lists (confirm real mastery vs. buzzword)
- Role/impact & ownership (scope, decisions, collaboration on their stated work)

For **each question**, decide:

| Field | What goes in it |
|-------|-----------------|
| `q` | The question, phrased exactly as an interviewer would say it, in the target language. |
| `level` | `Foundational` \| `Core` \| `Advanced` |
| `source` | One short clause: which set it belongs to and what it maps to — e.g. "JD: requires Kafka → event-delivery fundamentals" or "CV: owned the billing-service rewrite". This is the coverage justification. |
| `followups` | 2–4 likely interviewer follow-ups, in the target language. |

Spread across difficulty levels appropriate to the role level.

### Step 3 — Build the coverage map

Before generating, confirm in your own reasoning that every JD knowledge area is covered by a Set A question and every substantial CV project/technology is covered by a Set B question. The HTML's coverage summary has two columns — `coverage.jd` (the general knowledge areas from the JD) and `coverage.cv` (the projects/tech from the résumé) — fill each from the matching set. If a JD area can't be covered with a *general* question, note it briefly rather than inventing trivia.

### Step 4 — Generate the HTML

1. Read the template at `assets/template.html` (in this skill's directory).
2. Replace the placeholders:
   - `__TITLE__` — e.g. "Interview Prep — <Role> — <Company>" in the target language. Use the company name and/or job title from the JD; **never** put the candidate's name in the title. If the company isn't stated in the JD, use just the role (e.g. "Interview Prep — <Role>").
   - `__META__` — a JSON object: `{ "role": "...", "candidate": "...", "language": "...", "generated": "YYYY-MM-DD", "coverage": { "jd": ["req 1", "req 2", ...], "cv": ["area 1", ...] } }`. Strings in target language; use today's date.
   - `__PROMPT_TEMPLATE__` — the deep-dive prompt **in the target language**, containing the literal tokens `{{QUESTION}}` and `{{FOLLOWUPS}}` where the question text and its follow-up list will be substituted at click time. See "The copy prompt" below for required content.
   - `__DATA__` — a JSON array of category objects:
     ```json
     [
       { "category": "Category name in target language",
         "questions": [
           { "q": "...", "level": "Core", "source": "...", "followups": ["...", "..."] }
         ]
       }
     ]
     ```
   - `__UI__` — a JSON object of UI label strings in the target language (keys listed in the template's comment, e.g. progress/filter/copied labels). Translate each value.
3. Write the result to the user's working directory as `interview-prep.html` (or a name the user requested). Use the Write tool.
4. Validate the JSON you inject is well-formed (no trailing commas, properly escaped quotes). Then tell the user the file path and a one-line summary (N questions across M categories).

### The copy prompt (`__PROMPT_TEMPLATE__`)

This is what gets copied to the clipboard when a question is clicked. Written in the target language, it must instruct an AI to deliver a **detailed analysis** of the question and must request all of:

- **Best answer** — what a strong, structured answer looks like.
- **Bonus points** — what would impress the interviewer / signal seniority.
- **Anticipated follow-ups + how to answer them** — pre-empt where the interviewer drills next. Seed these with the question's own `{{FOLLOWUPS}}`.
- **ASCII diagrams** — instruct the AI to include ASCII diagrams to explain architecture, flow, or data structures *where it aids understanding*.

It must include the tokens `{{QUESTION}}` (the question text) and `{{FOLLOWUPS}}` (its follow-up list) so the page can fill them in per question. Keep it copy-paste ready for any chat AI.

---

## HTML behavior (provided by the template — don't reimplement)

The template already implements all interactivity; you only inject data. It provides:

- **Clickable question cards.** Clicking a card copies the filled-in deep-dive prompt to the clipboard **and** toggles the card to a "processed" state (greyed/checked) so the candidate tracks what they've drilled. A small toast confirms "copied". A separate small control lets the user un-mark if they misclicked.
- **Progress tracking.** A progress bar / counter shows processed vs total. State persists in `localStorage` (keyed per file) so progress survives reloads.
- **Filters.** By category, by level, and a "hide processed" toggle.
- **Self-contained.** No external network calls, no CDN, inline CSS+JS. Works by opening the file directly in a browser. Clipboard uses the async Clipboard API with a `document.execCommand('copy')` fallback for `file://`.

If the template file is missing, recreate an equivalent self-contained HTML using the same placeholder contract.

---

## Quality bar

- The set is clearly split: Set A (JD) questions are general/knowledge-revealing and free of the company's specific domain framing; Set B (CV) questions are grounded in the candidate's actual projects and listed tech.
- Every JD knowledge area and substantial CV item is traceable to a question via its `source` field.
- JD-half questions are general, not obscure or company-internal trivia (Principle 1–2).
- Difficulty matches the role level.
- Follow-ups are realistic next-drill questions, not restatements.
- The HTML opens and works offline; clicking copies a correct, language-correct prompt and marks processed.
- All visible text (questions, labels, prompt) is in the requested language.
