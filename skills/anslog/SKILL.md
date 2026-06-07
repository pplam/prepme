---
name: anslog
description: Persist a worked-out interview answer into a prepme study sheet. After the candidate takes a question from their interview-prep.html, discusses it with an AI agent, and is satisfied with the result, anslog organizes the full exchange into a formatted, self-contained answer page and links it back into the study sheet — without ever modifying the sheet itself. It builds an "answer log": each saved answer becomes a page under answers/ and is registered in a manifest the sheet reads to show an "answered" state and a View answer button. This is the companion to the prepme skill (prepme writes the questions; anslog saves the answers). Trigger on "log this answer", "save this answer", "save this to my study sheet", "check in this answer", "commit this answer", "anslog".
allowed-tools: Bash Read Write Edit
---

# anslog — log a worked answer into the study sheet

This skill saves a single worked-out answer back into an existing **prepme** study sheet
(`interview-prep.html`). It is the **save / commit** half of the prepme workflow and runs as a
**separate, manually-triggered action** — it never generates questions and never edits the study
sheet itself.

The flow it completes: the candidate clicks a question in their study sheet, copies the deep-dive
prompt, works the question through with an AI agent, and — when satisfied — asks *you* to **log**
that answer. You organize the whole exchange into a formatted answer page under `answers/` and
register it in a small manifest the study sheet reads. The result is a growing **answer log**: each
checked-in question gains an "answered" accent and a **View answer** button in the sheet.

If there is no study sheet yet, this is the wrong skill — the candidate needs **prepme** first to
generate `interview-prep.html`.

---

## What you write (and what you never touch)

- You **only** ever create or modify files inside the `answers/` folder next to the study sheet:
  the per-answer pages (`answers/<slug>.html`) and the manifest (`answers/answers.js`).
- You **never** modify `interview-prep.html`. The link between a question and its saved answer is
  carried entirely by the manifest, keyed by a stable question **id** — so links survive even if the
  sheet is later reordered or regenerated.

---

## Workflow

### Step 1 — Locate the study sheet

Find `interview-prep.html` in the working directory (or the name the user gave). If several exist
or it's ambiguous, ask which one. Read it — you need its `DATA` (to match the question) and
`META.language` (to write the answer in the right language).

### Step 2 — Identify the question

Match the question the candidate worked on — by its **exact text**, as it appears verbatim in the
copied prompt / the conversation — against an entry in the sheet's `DATA`. Grab that entry's
`level`, `source`, and `followups`. If you can't unambiguously match it, confirm with the user
before writing.

### Step 3 — Synthesize the answer

Organize the full exchange — don't just dump the transcript — into the sections the answer template
expects, in the sheet's language:

- **Best answer** — the strong, structured answer the discussion arrived at.
- **Bonus points** — what signals seniority / would impress.
- **Discussion** — the candidate's intermediate questions and how each was resolved, reorganized
  for readability (this is the part that captures the back-and-forth).
- **Follow-ups & how to handle them** — the likely follow-ups and the answer to each.

Include **ASCII diagrams** (wrapped in `<pre>`) where they aid understanding.

### Step 4 — Write the answer file

Read the answer template at `assets/answer.html` (in this skill's directory). Create an `answers/`
folder next to the study sheet if needed (`mkdir -p`), and write the filled page to
`answers/<slug>.html`, where `<slug>` is a short kebab-case slug derived from the question (ASCII,
lowercase, dash-separated; keep it stable so re-logging the same question overwrites the same file).
Replace the placeholders (the template's top comment shows the exact markup each expects):

- `__TITLE__`, `__QUESTION__` — the question text.
- `__SHEET__` — relative path back to the study sheet (e.g. `../interview-prep.html`, matching its
  actual filename). `__BACK__` — a "Back to study sheet" label in the sheet's language.
- `__LEVEL__` — the question's `level` verbatim (`Foundational`/`Core`/`Advanced`, sets the pill
  colour); `__LEVEL_LABEL__` — that level translated for display.
- `__META__` — chips for the root card (e.g. a `<span class="chip"><b>Why:</b> …</span>` from the
  question's `source`, and a date chip).
- `__ANSWER__` — the main answer from step 3 (Best answer / Bonus points / Discussion) as HTML,
  using `<h2>` per section and `<pre>` for ASCII.
- `__FU_LABEL__` — the follow-ups heading; `__FOLLOWUPS__` — one tree node per follow-up in the
  exact node/card shape documented in the template comment (each is a follow-up question plus how to
  handle it). This renders the follow-ups as a clean connector tree like the study sheet.

Keep the page self-contained (no network) and in the sheet's language.

### Step 5 — Register the link via the manifest — never edit the study sheet

Answers are linked by a stable **question id** (a hash of the question text), not the raw text.
Compute the id with the exact same function the page uses (`qhash`) by running it in Node on the
verbatim question:

```bash
node -e 'const s=process.argv[1];let h=0x811c9dc5>>>0;for(let i=0;i<s.length;i++){h^=s.charCodeAt(i);h=Math.imul(h,0x01000193)>>>0;}console.log("q"+h.toString(36));' "How do you guarantee message ordering in Kafka?"
# -> e.g. q1a2b3c4
```

Then maintain a manifest at `answers/answers.js` (next to the study sheet) that sets
`window.PREPME_ANSWERS` to an object mapping each answered question's **id** to its relative path:

```js
window.PREPME_ANSWERS = {
  "q1a2b3c4": "answers/kafka-ordering.html",
};
```

Create this file on the first check-in; on later check-ins, add or replace the entry for this id
(**idempotent** — never duplicate a key). The answer **filename** can stay a readable slug of the
question; only the manifest *key* must be the id. The study sheet loads this manifest automatically
and, on reload, shows an "answered" state and a **View answer** button (next to *Copy prompt*) for
any question whose id is present. The original `interview-prep.html` is left untouched. Using the id
(not the text) keeps links working even if questions are reordered or the sheet is regenerated.

### Step 6 — Report

Tell the user the answer file path and that the card now links to it.

---

## Notes

- This skill is paired with **prepme**, which generates the study sheet and its question data.
  prepme's template already loads `answers/answers.js` if present, so a sheet generated before any
  answer was logged works fine — the manifest simply doesn't exist yet, which is harmless.
- If the answer template `assets/answer.html` is missing, recreate an equivalent self-contained HTML
  using the same placeholder contract documented above.
