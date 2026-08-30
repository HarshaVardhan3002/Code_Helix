# Leitlinien-Lern-App — Vision

## What this is, in one paragraph

A daily teaching case for German gastroenterologists. Every morning there is one
new endoscopic image with one question at Facharzt level. You commit to an
answer before you see anything else. Then you get the answer, why every option
was right or wrong, and the DGVS guideline recommendation it rests on. That's
the whole ritual, sixty seconds, then it's done until tomorrow.

Behind it, the society's own members write the cases. An AI screens each
submission against the cited guideline, a physician editor approves, and it
enters the rotation.

**One line:** Wordle's cadence, Instagram's surface, a guideline's answer key.

## What it is NOT

- not a social network. Nobody follows anyone, nobody likes anything
- not a course. No syllabus, no levels, no completion
- not a question bank. Those exist and nobody opens them daily
- not an AI that answers medical questions. AI screens, humans approve
- not childish. The idea owner ruled that out in writing

---

## Three surfaces

### 1. Heute — the daily
The landing screen. Full-bleed image, question overlaid at the bottom.
**Quiz first, always.** You cannot read your way to the answer.

```
image (no caption that gives it away)
  → question + 4 options
  → you commit
  → reveal: right/wrong, rationale on EVERY option,
            the cited recommendation, the image credit
  → "Das war's für heute. Morgen gibt's einen neuen Fall."
```

Below today's case: your archive. Above it: nothing. Tomorrow is unreachable.

### 2. Bibliothek — the library
**Info first**, because you can't be tested on something you came to look up.

Browse by topic and by region. Tap a topic, get a readable page assembled from
the guideline recommendations, every claim carrying its recommendation number
and AWMF reference. "Teste mich dazu" at the bottom pulls pre-generated
questions on that topic.

This is where a motivated user goes deep. Unlimited. But it is one tap away,
never the landing screen.

### 3. Beitragen — contribution
Verified physicians submit cases. AI triage screens, a physician editor
approves, approved cases enter the daily rotation.

This is the engine. Two doctors reviewing is a ceiling; a society of thousands
contributing with review as a gate is a supply line.

---

## The clone: keep, repurpose, delete

Mapped by feature concept, since the repo's file names will differ.

### Repurpose

| Instagram thing | Becomes |
|---|---|
| Reels player | The daily case. Full-bleed image, bottom overlay carries the QUESTION, not a caption. Keep the layout, kill the vertical swipe-to-next. |
| Explore grid | The library browse view. Same grid, curated archive instead of algorithmic discovery. |
| Search | Topic and finding search. Not people search. |
| Post composer | The case submission form: pick image, write question, 4 options, rationales, pick the guideline recommendation. |
| Auth + roles | Three roles: reader, contributor (verified physician), editor. |
| Saved / bookmarks | "Schwierige Fälle" — cases you got wrong, to redo. |
| Profile | Minimal and private: your streak, your accuracy, your submissions. Not a public identity page. |
| Moderation / admin views | The editor review queue. |

### Delete

- follow graph, followers, following
- likes, comments, shares, DMs
- Stories
- public profiles, avatar-as-identity, discovery of people
- video upload and playback
- infinite scroll on the main feed (this is the important one)
- algorithmic recommendation
- push notification nagging
- **user image upload, for v1.** A doctor uploading their own endoscopy image
  is uploading patient data. Contributors pick from the licensed image library
  and write the case around it. Consent pipeline is roadmap.

### The two semantic changes that matter most

1. **The feed is not "posts by people I follow, newest first."** It is one item
   per calendar date, identical for every user, globally. Same puzzle, same day.
2. **Explore is not discovery of the unknown.** It is your own finite, curated,
   already-published archive.

Get those two wrong and you've built a social app with quizzes in it.

---

## Demo-day scope (17–18 Sep)

Build:
- Heute: the full loop, real content, offline-capable
- Bibliothek: browse by topic, guideline-sourced pages, "test me"
- Beitragen: submit → AI triage → editor approves → appears in rotation
- Three seeded accounts to walk that loop live

Do not build:
- real multi-tenant anything, email verification, password reset
- image upload, consent flows
- notifications
- spaced repetition
- anything that will not appear in a ten-minute demo

Roadmap slide (costs zero build hours, buys credibility):
- consent-backed image contribution from real teaching collections
- live literature ingestion and personalisation
- DGVS member SSO, CME credit
- multi-society, beyond gastroenterology

---

## Rules that do not bend

1. **Quiz before information, on the daily.** Retrieval practice is the whole
   mechanism. Showing the caption first turns it into passive reading.
2. **One per day. Tomorrow is unreachable.** Scarcity is what makes people
   return. An endless feed kills the product.
3. **No live AI in the request path.** Content is pre-generated, screened,
   physician-approved, and served as static data. AI in the pipeline, never in
   front of the user. You will not be wrong on stage.
4. **Every answer carries its citation.** Guideline, AWMF number, version,
   recommendation number. Quotes stay short; copyright sits with the AWMF
   author collective.
5. **Nothing unreviewed reaches a user.** Draft until a physician approves.
   This is not a nice-to-have; a wrong answer in this domain causes harm.
6. **Not childish.** No mascot, no confetti, no cartoon streak flame, no
   Duolingo palette. Direct instruction from the idea owner.

---

## The moment that wins the demo

Not the app. The loop:

1. a physician submits a case
2. AI triage shows which recommendation it matched and what it flagged
3. an editor approves it
4. it appears as tomorrow's case

Ninety seconds. You're not showing an app, you're showing the society's own
machine for turning its guidelines into daily teaching.
