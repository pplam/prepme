<div align="center">

<pre>
 ____  ____  ____  ____  __  __  ____
(  _ \(  _ \(  __)(  _ \(  \/  )(  __)
 ) __/ )   / ) _)  ) __/ )    (  ) _)
(__)  (__\_)(____)(__)  (_/\/\_)(____)

    +-------------------------------------------+
    |  CV  +  JD   -->   [?]   [?]   [?]        |
    |                     click -> copy -> done |
    +-------------------------------------------+
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
- **Progress tracking** — clicking also marks the card done; a progress bar and `localStorage` remember what you've drilled, so the page won't pretend you're starting fresh every reload.
- **Filters** — by category, by difficulty, or hide everything you've already conquered.
- **Speaks your language** — output language is auto-detected from your documents. Interview conducted in 中文? You get 中文, with the tech terms left mercifully untranslated.

## Usage

In your AI agent, point it at your two files:

```
prepme — CV: ~/Documents/resume.pdf   JD: ~/jobs/acme-backend.txt
```

…or just ask in plain English: *"prepare interview questions from this resume and job description."*

Out comes `interview-prep.html`. Open it. Start drilling. Try not to peek at the follow-ups first.

## Install

```bash
./install.sh
```

Copies the skill into `~/.claude/skills/` (and `~/.codex/skills/` if it finds one).

## What's inside

| File | Role |
|------|------|
| `SKILL.md` | The brains — how questions are designed and the HTML is assembled. |
| `assets/template.html` | The self-contained, light-themed study-sheet template. |
| `install.sh` | Drops the skill into your skills directory. |

---

*Good luck. Go get the offer — then come back and star it out of gratitude.*
