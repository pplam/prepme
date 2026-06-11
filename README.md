<div align="center">

<pre style="background:#0d1117; color:#3fb950; padding:16px 22px; border-radius:8px; display:inline-block; text-align:center; line-height:1.25;">
 ____  ____  ____  ____  __  __  ____
(  _ \(  _ \(  __)(  _ \(  \/  )(  __)
 ) __/ )   / ) _)  ) __/ )    (  ) _)
(__)  (__\_)(____)(__)  (_/\/\_)(____)

┌────────────────────────────────────────┐
│ $ prepme  --  CV + JD loaded           │
│ > your questions ready                 │
│ > cracking the interview ........      │
└────────────────────────────────────────┘
</pre>

</div>

# prepme

> Feed it your résumé and the job description. Walk into the interview already knowing the questions.

**prepme** is an agent skill — drop it into any AI agent that supports skills — that turns a **CV** + **JD** into a focused, interactive study sheet of the questions you're most likely to be asked, then hands you a one-click AI deep-dive for each one.

It's the interview equivalent of getting the exam paper the night before, except entirely legal and you still have to do the studying.

It ships as **two skills that loop**: `prepme` writes the questions, `anslog` files your worked-out answers back into the same sheet.

---

## How it thinks

No "tell me about yourself" filler. prepme predicts what *this* interviewer asks *this* candidate, in **two deliberate halves**:

- **The JD half — the knowledge they're hiring for.** It strips the company's product fluff off each requirement and asks about the *transferable fundamentals* underneath. A "real-time payments platform on Kafka" JD becomes a clean question about Kafka delivery semantics — not "design our payments pipeline," because nobody learns event ordering from a job ad.
- **The CV half — the work you actually did.** It mines your projects and the tech you listed, then politely calls your bluff: what you built, why, the tradeoffs, and whether the word "expert" on line 12 can survive three follow-ups.

Every question is tagged **Foundational / Core / Advanced**, justified by *why* it gets asked, and pre-loaded with the **2–4 follow-ups** an interviewer reaches for the moment they smell hand-waving.

## What you get

A small **offline study sheet** — no server, no CDN, no spinner. One static `index.html` shell renders everything at runtime from two sibling data files: `questions.data.js` (written by prepme) and `answer.data.js` (appended by anslog). Open `index.html` in any browser and:

- **Tree-structured layout** — questions branch into their follow-ups, so the "and then they'll ask…" chain is obvious at a glance.
- **Click to copy** — one click drops a ready-to-paste, language-matched deep-dive prompt onto your clipboard (best answer, bonus points, follow-up handling, ASCII diagrams) for any chat AI.
- **Answer-driven progress** — a card flips to *done* only once you've actually saved an answer for it. The bar counts understanding, not how many buttons you clicked.
- **Answers live in-page** — saved answers render right inside the sheet behind a **View answer** button; no second tab, no loose files.
- **Filters** — by category, by difficulty, or hide everything you've already conquered.
- **Speaks your language** — output language is auto-detected from your documents. Interview in 中文? You get 中文, with the tech terms left mercifully untranslated.

## The loop

```
  you ─"prepme — CV + JD"─▶ ┌────────┐
                            │ prepme │  designs the questions
                            └───┬────┘
                                ▼
              index.html + questions.data.js   ◀── your study sheet
                                │
        1. click [Copy prompt]  │  ──▶  deep-dive prompt on your clipboard
                                ▼
                         ┌────────────┐  2. paste into any chat AI, discuss,
                         │  AI agent  │     sharpen until you're happy
                         └─────┬──────┘
        3. "log this answer"   │
                               ▼
                          ┌────────┐  appends one entry to answer.data.js
                          │ anslog │  (never touches index.html)
                          └───┬────┘
        4. reload index.html  │
                              ▼
                   [ ✓ answered · View answer ]  ◀── progress bar ticks up
```

| Step | You do | What happens |
|------|--------|--------------|
| 1 | `prepme — CV: resume.pdf  JD: job.txt` | Generates `index.html` + `questions.data.js` |
| 2 | Click **Copy prompt** on a card | Deep-dive prompt copied to clipboard |
| 3 | Paste into your AI agent, work the answer out | A strong, follow-up-proof answer |
| 4 | `log this answer` | **anslog** appends it to `answer.data.js` |
| 5 | Reload `index.html` | Card shows **answered** + **View answer**; progress advances |

Repeat 2–5 until the bar is full. That's the whole game.

> **Why two data files?** The shell never gets rewritten — prepme and anslog only emit *data*, so saving an answer is a quick append, not a full-page regeneration. anslog keys every answer to a stable question id, so your saved work survives even if you regenerate the questions.

## Usage

Point your agent at the two files:

```
prepme — CV: ~/Documents/resume.pdf   JD: ~/jobs/acme-backend.txt
```

…or just ask in plain English: *"prepare interview questions from this resume and job description."* Out come `index.html` + `questions.data.js` — open the HTML and start drilling.

When you've nailed a question with your AI, log it:

```
log this answer        (or: "save this answer to my study sheet")
```

## Install

Via the `skills` CLI (guided skill + agent selection):

```bash
npx skills add pplam/prepme
```

Or locally from a clone — copies both skills into `~/.claude/skills/` (and `~/.codex/skills/` if Codex is set up):

```bash
./install.sh
```

## What's inside

| File | Role |
|------|------|
| `skills/prepme/SKILL.md` | The brains — how questions are designed and `questions.data.js` is built. |
| `skills/prepme/assets/index.html` | The static, light-themed shell — renders the study sheet **and** the in-page answer view from the two `*.data.js` files. Copied verbatim; never regenerated. |
| `skills/anslog/SKILL.md` | The **answer log** — appends a worked-out answer to `answer.data.js`. |
| `install.sh` | Local installer for both skills. |

---

*Good luck. Go get the offer — then come back and star it out of gratitude.*
