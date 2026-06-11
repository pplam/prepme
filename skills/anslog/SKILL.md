---
name: anslog
description: Persist a worked-out interview answer into a prepme study sheet. After the candidate takes a question from their index.html, discusses it with an AI agent, and is satisfied with the result, anslog organizes the full exchange into structured answer data and appends it to the sheet's answer.data.js — without ever modifying index.html. It builds an "answer log": each saved answer becomes one entry in answer.data.js (keyed by question id) that the sheet reads to show an "answered" state, a View answer button, and the full answer rendered in-page. This is the companion to the prepme skill (prepme writes the questions; anslog saves the answers). Trigger on "log this answer", "save this answer", "save this to my study sheet", "check in this answer", "commit this answer", "anslog".
allowed-tools: Bash Read Write Edit
---

# anslog — log a worked answer into the study sheet

This skill saves a single worked-out answer back into an existing **prepme** study sheet
(`index.html` + `questions.data.js`). It is the **save / commit** half of the prepme workflow and
runs as a **separate, manually-triggered action** — it never generates questions and never edits the
shell.

The flow it completes: the candidate clicks a question in their study sheet, copies the deep-dive
prompt, works the question through with an AI agent, and — when satisfied — asks *you* to **log**
that answer. You organize the whole exchange into **structured answer data** and append it to
`answer.data.js` next to the sheet. The result is a growing **answer log**: each checked-in question
gains an "answered" accent, a **View answer** button, and its full answer rendered in-page (the
`index.html` shell already contains the answer-page layout).

You generate **data, not HTML.** You never write an HTML page — you append one JavaScript object to
`answer.data.js`. If there is no study sheet yet, this is the wrong skill — the candidate needs
**prepme** first to generate `index.html` + `questions.data.js`.

---

## What you write (and what you never touch)

- You **only** ever create or modify **`answer.data.js`** next to the study sheet. You append (or
  replace) **one entry per answer**, keyed by the question's stable **id**.
- You **never** modify `index.html` or `questions.data.js`. The link between a question and its saved
  answer is carried entirely by the id key in `answer.data.js` — so links survive even if the sheet
  is later reordered or regenerated. There are **no** per-answer HTML files and **no** `answers/`
  folder.

---

## Workflow

### Step 1 — Locate the study sheet

Find `index.html` in the working directory (or the name the user gave). If several exist or it's
ambiguous, ask which one. Read its sibling **`questions.data.js`** — you need
`window.PREPME_QUESTIONS.data` (to match the question) and `window.PREPME_QUESTIONS.meta.language`
(to write the answer in the right language).

### Step 2 — Identify the question

Match the question the candidate worked on — by its **exact text**, as it appears verbatim in the
copied prompt / the conversation — against an entry in `questions.data.js`'s `data`. Grab that
entry's `q` (exact text), `level`, and `source`. If you can't unambiguously match it, confirm with
the user before writing.

### Step 3 — Synthesize the answer

Organize the full exchange — don't just dump the transcript — into the sections the answer entry
expects, in the sheet's language:

- **Best answer** — the strong, structured answer the discussion arrived at.
- **Bonus points** — what signals seniority / would impress.
- **Discussion** — the candidate's intermediate questions and how each was resolved, reorganized
  for readability (this is the part that captures the back-and-forth).
- **Follow-ups & how to handle them** — the likely follow-ups and the answer to each.

Include **ASCII diagrams** (wrapped in `<pre>`) where they aid understanding.

### Step 4 — Compute the question id

Answers are keyed by a stable **question id** (a hash of the question text), not the raw text.
Compute it with the exact same function the page uses (`qhash`) by running it in Node on the
verbatim question:

```bash
node -e 'const s=process.argv[1];let h=0x811c9dc5>>>0;for(let i=0;i<s.length;i++){h^=s.charCodeAt(i);h=Math.imul(h,0x01000193)>>>0;}console.log("q"+h.toString(36));' "How do you guarantee message ordering in Kafka?"
# -> e.g. q1a2b3c4
```

Using the id (not the text) keeps links working even if questions are reordered or the sheet is
regenerated.

### Step 5 — Append the answer to `answer.data.js` — never edit the shell

Maintain `answer.data.js` next to the study sheet. It sets `window.PREPME_ANSWERS` to an object
mapping each answered question's **id** to its saved-answer data. Make the file **append-friendly**:
on the **first** check-in create it with the guard header, then add **one assignment statement per
answer**:

```js
window.PREPME_ANSWERS = window.PREPME_ANSWERS || {};

window.PREPME_ANSWERS["q1a2b3c4"] = {
  question: "How do you guarantee message ordering in Kafka?",  // verbatim question text
  level: "Core",                                                // Foundational | Core | Advanced (pill colour)
  why: "JD: requires Kafka → event-delivery fundamentals",      // from the question's source (optional)
  date: "2026-06-07",                                           // today
  answer: "<h2>Best answer</h2><p>…</p><h2>Bonus points</h2><p>…</p><h2>Discussion</h2><pre>…ASCII…</pre>",
  followups: [
    { q: "How does a single partition affect throughput?", answer: "<p>…how to handle it…</p>" }
  ]
};
```

Entry fields:
- `question` — the verbatim question text (so the answer view is self-sufficient).
- `level` — the question's level verbatim (`Foundational`/`Core`/`Advanced`); the shell translates
  it for the pill via the sheet's UI labels.
- `why` — optional; the question's `source`, shown as a "Why" chip.
- `date` — today's date, shown as a chip.
- `answer` — the main answer from Step 3 (Best answer / Bonus points / Discussion) as an **HTML
  string**: `<h2>` per section, `<pre>` for ASCII, plus `<p>/<ul>/<ol>/<code>/<table>` as needed.
- `followups` — an **array** of `{ q, answer }`, each a follow-up question plus how to handle it
  (HTML string). The shell renders them as a connector tree like the study sheet — you do **not**
  write any tree markup, only the data.

This is **idempotent per id**: on the first check-in create the file with the guard header; on later
check-ins for a *new* question, append another `window.PREPME_ANSWERS["<id>"] = { … };` statement;
re-logging the *same* question replaces that id's existing statement (never duplicate a key). The
study sheet loads `answer.data.js` automatically and, on reload, shows an "answered" state, a **View
answer** button (next to *Copy prompt*), and the full answer rendered in-page. `index.html` and
`questions.data.js` are left untouched.

### Step 6 — Report

Tell the user the answer was appended to `answer.data.js` and that the card now shows answered +
**View answer** after a reload.

---

## Notes

- This skill is paired with **prepme**, which generates `index.html` + `questions.data.js`. The
  `index.html` shell already loads `answer.data.js` if present, so a sheet generated before any
  answer was logged works fine — the file simply doesn't exist yet, which is harmless.
- You ship **data only** — there is no HTML template in this skill. The answer-page layout lives
  inside prepme's `index.html` shell, which renders each entry of `window.PREPME_ANSWERS` in-page.
