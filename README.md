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

---

## How it thinks

No generic "tell me about yourself" filler. prepme predicts what *this* interviewer would actually ask *this* candidate, and it does it in **two deliberate halves**:

- **The JD half — the knowledge they're hiring for.** It strips the company's product fluff off each requirement and asks about the *transferable fundamentals* underneath. A "real-time payments platform on Kafka" JD becomes a clean question about Kafka delivery semantics — not "design our payments pipeline," because nobody learns event ordering from a job ad.
- **The CV half — the work you actually did.** It mines your projects and the tech you listed, then politely calls your bluff: what you built, why, the tradeoffs, and whether the word "expert" on line 12 of your résumé can survive three follow-up questions.

Every question is tagged **Foundational / Core / Advanced**, justified by *why* it gets asked, and pre-loaded with the **2–4 follow-ups** an interviewer reaches for the moment they smell hand-waving.

## What you get

A single **self-contained HTML file** — no server, no CDN, no "please wait while we load." Open it in any browser and:

- **Tree-structured layout** — questions branch into their follow-ups, so the "and then they'll ask…" chain is obvious at a glance.
- **Click to copy** — one click drops a ready-to-paste, language-matched deep-dive prompt onto your clipboard (best answer, bonus points, follow-up handling, ASCII diagrams) for any chat AI.
- **Answer-driven progress** — a card only flips to *done* once you've actually saved an answer for it (via `anslog`, below). The progress bar counts answered questions, so it reflects real understanding — not how many buttons you clicked.
- **Filters** — by category, by difficulty, or hide everything you've already conquered.
- **Speaks your language** — output language is auto-detected from your documents. Interview conducted in 中文? You get 中文, with the tech terms left mercifully untranslated.

## Usage

In your AI agent, point it at your two files:

```
prepme — CV: ~/Documents/resume.pdf   JD: ~/jobs/acme-backend.txt
```

…or just ask in plain English: *"prepare interview questions from this resume and job description."*

Out comes `interview-prep.html`. Open it. Start drilling. Try not to peek at the follow-ups first.

### Logging your answers — `anslog`

Once you've worked a question through with an AI agent and you're happy with the answer, ask your
agent to **log** it:

```
log this answer   (or: "save this answer to my study sheet")
```

That fires the companion **anslog** skill, which writes a clean, self-contained answer page under
`answers/` and links it back into your study sheet — the card flips to an *answered* state with a
**View answer** button on reload. anslog only ever writes inside `answers/`; it never touches
`interview-prep.html`, so links survive even if you regenerate the sheet. prepme writes the
questions; anslog keeps the answers.

## The full loop

Two skills, one feedback loop. **prepme** writes the questions; you drill each one with an AI;
**anslog** files the answer back into the sheet — which is exactly what flips the card to *done*.

```
   you ──"prepme — CV + JD"──▶  ┌──────────┐
                                │  prepme  │  designs the questions
                                └────┬─────┘
                                     ▼
                          interview-prep.html
                          (your study sheet)
                                     │
          ┌──────────────────────────┼──────────────────────────┐
          ▼                          ▼                           ▼
   [ Q: Kafka          ]     [ Q: your billing  ]        ...more questions
   [   delivery sem... ]     [   service rewrite ]
   [  [ ] not answered ]     [  [ ] not answered ]
          │
          │  1. click [Copy prompt]   ──▶  deep-dive prompt on clipboard
          ▼
   ┌───────────────┐   2. paste into any chat AI, discuss,
   │   AI agent    │      sharpen the answer until you're happy
   └───────┬───────┘
           │  3. "log this answer"
           ▼
      ┌──────────┐   writes answers/<id>.html  +  updates answers/answers.js
      │  anslog  │   (never edits interview-prep.html)
      └────┬─────┘
           │  4. reload the sheet
           ▼
   [ Q: Kafka          ]
   [   delivery sem... ]
   [  [x] answered     ]  ◀── card greys out, progress bar ticks up,
   [  [View answer]    ]      and a View answer button appears
```

**At a glance:**

| Step | You say / do | What happens |
|------|--------------|--------------|
| 1 | `prepme — CV: resume.pdf  JD: job.txt` | Generates `interview-prep.html` |
| 2 | Click **Copy prompt** on a card | Deep-dive prompt copied to clipboard |
| 3 | Paste into your AI agent, work the answer out | You get a strong, follow-up-proof answer |
| 4 | `log this answer` | **anslog** saves the answer page + links it |
| 5 | Reload `interview-prep.html` | Card shows **answered** + **View answer**; progress advances |

Repeat 2–5 until the progress bar is full. That's the whole game.

## Install

Use the `skills` CLI:

```bash
npx skills add pplam/prepme
```

This follows the standard `skills` install flow and lets the CLI guide skill and agent selection interactively.

Or, for a local install straight from a clone:

```bash
./install.sh
```

Copies the skill into `~/.claude/skills/` (and `~/.codex/skills/` if Codex is set up).

The installable skill lives under `skills/prepme/`, so the repository README stays at the repo root and is not part of the installed skill payload.

## What's inside

| File | Role |
|------|------|
| `skills/prepme/SKILL.md` | The brains — how questions are designed and the HTML is assembled. |
| `skills/prepme/assets/template.html` | The self-contained, light-themed study-sheet template. |
| `skills/anslog/SKILL.md` | The **answer log** — saves a worked-out answer back into the study sheet. |
| `skills/anslog/assets/answer.html` | Template for a saved-answer page (anslog fills it in). |
| `install.sh` | Local installer — copies both skills into your skills directory. |

---

*Good luck. Go get the offer — then come back and star it out of gratitude.*
