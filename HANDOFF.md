# GI Daily — handoff, 2026-08-30

Written so a fresh session can pick this up cold. Read this, then `findings.md`
for the accumulated research cache, then `VISION.md` for the product spec.

**Nothing in section 4 has been implemented.** It is a specification, not a
report of work done.

---

## 1. Where things stand

| | |
|---|---|
| Repo | `github.com/HarshaVardhan3002/Code_Helix`, branch `main` |
| Head | `0a8ec1f` — *docs: record the v3 imagery, theme and branding findings* |
| Entry point | `lib/main_demo.dart` (there is **no** `lib/main.dart`) |
| Package id on device | `com.emilzulufov.flutter_instagram_offline_first_clone.dev` |
| `flutter analyze lib test packages/app_ui` | No issues found |
| `flutter test` | 3/3 passed |
| Release APK for the QR sideload | `build/app/outputs/flutter-apk/app-arm64-v8a-development-release.apk` — 29.7 MB |

Commands (the flavour and target flags are **not** optional):

```bash
flutter analyze lib test packages/app_ui
flutter test
flutter build apk --flavor development --debug   -t lib/main_demo.dart
flutter build apk --flavor development --release -t lib/main_demo.dart --split-per-abi
adb install -r build/app/outputs/flutter-apk/app-development-debug.apk
adb shell pm clear com.emilzulufov.flutter_instagram_offline_first_clone.dev   # full reset
adb shell monkey -p com.emilzulufov.flutter_instagram_offline_first_clone.dev -c android.intent.category.LAUNCHER 1
```

`flutter analyze` across the **whole** repo reports 11 errors in
`packages/storage/secure_storage`. Those are pre-existing, belong to an unplugged
upstream package whose dependencies are not fetched, and do not affect the app
build. Do not "fix" them.

---

## 2. What landed this session

Three commits, all pushed.

**`0221353` — real imagery, two-scheme theme, branding.** Fourteen Kvasir v2
frames selected, screened, cropped and bundled; four new cases written to the
classes the dataset actually supports; `GiColors` ThemeExtension with both
schemes replacing 198 hardcoded `AppColors.white.withValues(…)` call sites;
Newsreader + Fira Sans; launcher icon and wordmark.

**`280b2c0` — device pass.** Nine defects found on an emulator in both schemes,
each reproduced before it was touched. The two structural ones:

- the hero frame sat in `Positioned.fill` of a `Stack` that grows with the
  question panel, so `BoxFit.cover` upscaled a 1400 px square by half and
  cropped away two thirds of its width;
- a `Stack` sizes to its non-positioned children only, so the bounded frame was
  then hard-clipped partway down — a straight line across the screen where the
  photograph stopped.

**`0a8ec1f` — findings.** The Kvasir licence, its two burned-in artefacts, the
class-to-case constraint, why glass tokens had to take a `Brightness`, the
variable-font instancing, and the layout rules the device pass produced.

Verified end to end on device in **both** schemes: login → quiz-first Heute →
answer → verdict → reveal with citations and `[offen]` placeholders → archive →
Bibliothek → topic → Beitragen → demo prefill → submit → triage report → account
switch → editor review queue → Freigeben → the approved case becomes Heute.

---

## 3. The UX audit — unfinished

A Sonnet 5 agent was given device-only access (explicitly no codebase, no edits)
and asked for a defect report judged against a top-tier SaaS bar.

**It died on a session rate limit before writing its report.** It got through
sign-in, the whole Weber reader flow, dark mode, Bibliothek, topics, the
Schneider submit flow, and had just opened the Braun review queue. No findings
were produced — treat this item as **not started**.

What survives is raw evidence: **116 screenshots** at

```
C:\Users\Von\Desktop\GI-Daily-audit-2026-08-30\
```

`00_*` – `71_*` are the agent's, in the order it walked the app.  `s01` – `s31`
are mine from the device pass that produced `280b2c0`.

**One lead, unverified.** Several of the agent's filenames imply a tap that did
not take the first time — `25/26/27_teste_mich_dazu_tap*`, `59/60_submit_retry*`,
`62_fertig_retry`, `54_check_dialog`. That *may* be a real hit-target or
gesture-handling defect on the topic page's "Teste mich dazu" rows and on the
submit / Fertig buttons, or it may be nothing more than the agent mis-scaling
coordinates (screenshots come back at 900×2000 for a 1080×2400 screen, so every
tap needs ×1.2 — it was warned and may still have got it wrong). **Reproduce
before believing it.**

To re-run the audit, relaunch the same agent — the brief is in the session
transcript, and the standing rules were: device only, no source access, no
edits, report exact repro steps and a screenshot filename per defect, and every
claim gets independently verified against the running app before anything
changes.

---

## 4. NEW REQUIREMENT — full-bleed image aspect policy

Raised by the user at the end of this session, in the terms of Instagram Reels'
multi-image slides. **Not implemented. Specified here only.**

### 4.1 The problem

The Heute and case stages present the frame full-bleed, edge to edge, with
`BoxFit.cover`. That is right for a tall image and wrong for everything else:

- a **wide** frame loses most of its width to the crop;
- a **square** frame loses less but still gets cut;
- a **small or low-resolution** frame is upscaled and goes soft.

In all three cases the immersive premise breaks — the finding can end up outside
the visible crop, which in a diagnostic quiz is not a cosmetic problem.

### 4.2 The current geometry, measured

`lib/daily/view/heute_page.dart` `_Stage` and the identical `_Stage` in
`lib/daily/view/case_page.dart`:

```dart
headroom    = max(viewportHeight * 0.40, topInset + 150);
imageHeight = max(viewportHeight * 0.56, topInset + 260);
```

On a 1080×2400 phone that is a **1080×1344** frame slot — **aspect 0.80**.

### 4.3 What the bundled assets actually are

All fourteen shipped files are **1400×1400 squares** (they are cropped to the
endoscopic aperture, then squared). Measured aperture aspects in the Kvasir
sources behind them:

| asset | source frame | aperture | w/h |
|---|---|---|---|
| paris_iia_colon_ascendens | 720×576 | 516×488 | 1.06 |
| colitis_ulcerosa_mayo_3 | 720×576 | 553×528 | 1.05 |
| oesophagitis_erosionen_distal | 1280×1024 | 1221×1012 | 1.21 |
| emr_lifting_kolonpolyp | 720×576 | 627×547 | 1.15 |
| z_linie_uebergang | 1280×1024 | 1221×1011 | 1.21 |
| zoekum_landmarken | 720×576 | 514×530 | 0.97 |

**Two consequences a fresh session must not miss.**

1. **No endoscopic frame is ever portrait.** The aperture is a circle or an
   octagon; the range is 0.97–1.21. There is no source in this dataset that
   satisfies the "vertically long image" category, and there never will be.
2. **Rotating these images accomplishes nothing.** Rotating the widest one
   (1.21) yields 0.83 — against a 0.80 slot that is a rounding error, and
   rotating the 0.97 one makes it *worse*. Rotation only pays off on genuinely
   wide material, roughly 1.5 and above, which this app does not currently have.

### 4.4 Clinical objection to auto-rotation — read before implementing

The user asked for wide images to be auto-rotated 90° so the width becomes the
vertical extent. State this concern once and then let the user decide; do not
silently drop the requirement.

Orientation in endoscopy carries meaning. Lesion position is reported by the
clock face, retroflexion views are read against gravity, and "proximal" and
"distal" are inferred from the direction of the lumen in the frame. Turning a
frame 90° to fit a layout changes what a reader sees and can move an apparent
lesion from 6 o'clock to 3 o'clock. In an app whose entire claim is that its
answer key is traceable to a guideline, silently re-orienting the evidence is
the same class of error as inventing an AWMF number.

**Recommended alternative**, which achieves the identical visual goal without
touching the pixels' meaning: render non-tall frames **contained and centred
over a blurred, scaled copy of themselves**. The screen still fills edge to
edge, the image keeps its aspect and its orientation, and nothing is cropped.
This is what Apple Photos, Spotify and YouTube Shorts do with off-aspect media.

If the user still wants rotation, make it an **explicit per-image editorial
flag** (`rotate: 90` in `images.json`, set by someone who has judged that this
particular frame's orientation is not load-bearing), never an automatic
decision made from the aspect ratio alone.

### 4.5 The policy to implement

Let `a = width / height` of the source, and `slot` be the frame slot's aspect
(0.80 today).

| condition | mode | rendering |
|---|---|---|
| `a <= 0.75` | **fill** | `BoxFit.cover`, full-bleed — today's behaviour |
| `a >= 1.35` | **wide** | boxed by default; rotated only if the image carries an explicit editorial rotate flag, then treated as **fill** |
| otherwise | **boxed** | `BoxFit.contain`, centred, over a blurred backdrop |
| any mode where cover would upscale by more than **1.15×** | **boxed** | resolution gate wins over aspect |

The upscale gate is what handles the user's "smaller low resolution" case: cover
needs `sourceHeight >= 1344` for the current slot, and our 1400 px assets clear
it by a hair. Anything smaller must box rather than go soft.

Under this policy **every asset currently shipped is `boxed`** (0.97–1.21 all
land in the middle band). That is a large visual change to the app's signature
screen and the user has to see it before it is called done. If it reads as a
regression, the lever is not the policy — it is to re-export the assets with a
portrait crop through the aperture centre (e.g. 1080×1440, `a = 0.75`) so they
qualify for `fill`. The export script is reproducible and
`assets/daily/images/SOURCES.json` records the source behind each asset.

### 4.6 Definition of "boxed"

- `BoxFit.contain`, horizontally centred, vertically centred in the frame slot.
- Backdrop: the same image, `BoxFit.cover`, scaled ~1.15×, blurred hard
  (`ImageFilter.blur` sigma ≈ 40 at 1080 logical px), then the existing
  `_LegibilityScrim` on top of it. The backdrop must be dimmed enough that it
  never competes with the contained image and can never be mistaken for the
  finding.
- A hairline rim (`context.gi.onMediaHairline`) on the contained image's edge so
  it reads as a deliberate frame rather than a rendering failure.
- Square corners, not rounded — this is a clinical image, not a card. Confirm
  with the user.
- The `_LegibilityScrim` still has to reach **full opacity** at the slot's lower
  edge or the seam returns. See `findings.md`.

### 4.7 Where the code changes

- `lib/daily/widgets/case_image.dart` — the single place the hero is rendered.
  The policy belongs here, not at the call sites.
- `lib/daily/view/heute_page.dart` and `lib/daily/view/case_page.dart` — no
  change expected; they already hand `CaseImage` a bounded slot.
- **Leave the small renderers on `cover`.** The 52×52 archive thumbnails in
  `lib/daily/widgets/archive_section.dart` and the 68 px picker tiles in
  `lib/contribution/view/submit_case_page.dart` should keep cropping; a
  contained thumbnail in a square tile looks broken.

### 4.8 How to know the aspect — do this the cheap way

Deciding the mode needs the image's intrinsic size, and resolving an
`ImageStream` at runtime is asynchronous: the first frame would lay out with an
unknown mode and then jump. **Do not do that.**

Instead write the intrinsic size into the data at export time — the export
script already opens every file — and add the fields to the models:

- `assets/daily/images.json`: `"width": 1400, "height": 1400` per entry
- `assets/daily/cases.json`: the same on each case's image
- `lib/catalog/models/library_image.dart` and
  `lib/catalog/models/daily_case.dart`: nullable `width` / `height`

Missing size ⇒ fall back to **boxed**, which is the mode that cannot crop away a
finding.

### 4.9 Open question the user has to answer — do not guess

The requirement was described in terms of *"slides in Instagram reels … multiple
images as horizontally scrollable slides"*. It is genuinely ambiguous whether
that was context for the aspect problem or a request for a multi-image carousel.

Arguments both ways, so **ask before building it**:

- *For*: endoscopists read a finding across several frames, and one still is
  often not enough to answer a Befund question honestly.
- *Against*: `VISION.md` deliberately deleted every feed-like pattern, and a
  horizontal swipe on the hero would sit directly on top of the vertical scroll
  that reveals the teaching. It also multiplies the licensed-image problem by
  however many frames a case needs.

---

## 5. Open items carried forward

- **Three cases still have no image.** Forrest IIa, oesophageal varices and
  coeliac scalloping have no matching Kvasir class, so they keep their
  `imageAsset` path, the file is absent, and `CaseImage` falls back to the
  abstract placeholder. Drop a licensed frame at the named path and it appears
  with no code change. This is deliberate: a plausible-looking fake frame under
  a real register number is the exact failure the citation rules exist to
  prevent.
- **Kvasir v2 is licensed for research and education only.** Commercial use
  needs prior written permission from Simula. Every case and library entry
  carries that line. Commercialising the product means relicensing or replacing
  the imagery; nothing else depends on it.
- **`src/random_images/` is unused on purpose.** Twelve multi-panel figure grids
  from publications, no attributable provenance. Two of them are a good
  haemostasis-clip frame that would suit the Forrest case, and they still cannot
  be used until someone can write a credit that stands up.
- **The lance MCP server is registered but not authenticated.** It was added at
  user scope for icon generation; it needs an OAuth pass via `/mcp` before it
  can be called. The current icon was generated in-repo instead — the generator
  is `$CLAUDE_JOB_DIR/tmp/icon.py` from this session, which is *not* durable, so
  re-derive it if the icon needs to change.
- **The target-user assumption is still unconfirmed** with the two physicians.

---

## 6. Traps a fresh session will otherwise walk into

- Every build needs `-t lib/main_demo.dart` **and** `--flavor development`.
- A `Stack` sizes itself to its **non-positioned** children only. A `Positioned`
  child is clipped to that size.
- `Text` with `maxLines` inside a box shorter than those lines **clips**; it does
  not ellipsise. Bound the lines and push the rest down with a `Spacer`.
- Liquid glass renders by distorting what is behind it. Over a flat fill it
  renders as nothing. Every surface that carries glass needs real content or a
  gradient underneath.
- `product flavors` in `android/app/build.gradle` can carry their own `res/`
  directory that overrides `main/res` wholesale. That is how a unicorn icon
  survived three rounds of icon work earlier today.
- Screenshots come back scaled 900×2000 from a 1080×2400 screen. Multiply by 1.2
  before feeding a coordinate to `adb shell input tap`.
- `packages/env/.env.dev` and `.env.prod` hold placeholder values only. They
  exist so `envied` codegen can run. The prototype never reads them and makes no
  network calls at all.
