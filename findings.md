# GI DAILY — PERSISTENT RESEARCH & DECISION CACHE

> **CRITICAL:** This file is the project's memory. Check it before repeating discovery or external research.

## RULES
- Add findings **during implementation**, not after the project is finished.
- One concise entry per meaningful discovery/decision.
- Prefer conclusions and pointers over copied documentation.
- Mark entries `ACTIVE`, `SUPERSEDED`, or `RECHECK`.
- Do not delete useful history; supersede it when a decision changes.

## ENTRY TEMPLATE

### [ACTIVE] YYYY-MM-DD — <feature/component>
**Need:** <what was required>

**Local reuse:** `<files/symbols>` — <what can be reused>

**Research:** pub.dev: `<package>`; GitHub: `<repo>`  
**Selection:** `<package/component>`  
**Reason:** <why this is the best fit>

**Integration:** `<import/API/theme/adapter>`  
**Caveats:** <performance/platform/license/customization notes>

**Affected files:** `<paths>`

---

## DESIGN SYSTEM DECISIONS
Record durable GI Daily decisions here, such as:
- glass/liquid visual primitives selected
- typography and spacing rules
- navigation patterns
- reusable component choices
- animation/motion constraints
- image treatment/cropping rules

## ARCHITECTURE DECISIONS
Record durable implementation decisions here, especially when they prevent future rediscovery.

## RECHECK POLICY
Recheck a finding only when:
- the package/API changed materially;
- the dependency is stale or unavailable;
- the current requirement exceeds the documented capability;
- the recorded conclusion is contradicted by new evidence.


### [ACTIVE] 2026-08-30 — Primary liquid-glass engine
**Need:** GI Daily's dominant visual system requires immersive liquid/glass surfaces.

**Research:** pub.dev — `liquid_glass_renderer` `^0.2.0-dev.4`.  
**Selection:** `liquid_glass_renderer: ^0.2.0-dev.4`  
**Reason:** Dedicated Flutter liquid-glass renderer with blending layers, background blur/refraction, interactive glow, stretch, and configurable glass properties.

**Caveats:** Experimental/pre-release; mobile performance must be validated; current package requires Impeller and has documented rendering/performance limitations. Use `FakeGlass` strategically where appropriate.

**Source:** pub.dev package/changelog/API documentation.

---

### [ACTIVE] 2026-08-30 — Product brief & hard constraints (DGVS Hackathon 2026, Challenge 3)
**Event:** DGVS Hackathon 2026 @ Viszeralmedizin, CCH Hamburg. Challenge 3 "Leitlinien-Lern-App".
Build window Thu 17 Sep 10:00 → Fri 18 Sep 13:30 (~27h). Jury demo Fri 13:30, Saal B2.1, ~10 min.
Team: 3 devs + 2 physicians (domain experts, on-demand only).

**Idea owner:** Dr. med. Viliam Masaryk, Oberarzt, SRH Wald-Klinikum Gera. Full corpus = one row in `Hackathon_Idee_9.xlsx`.

**Verbatim constraints (do not dilute):**
- "ähnlich wie Instagram, aber pro Tag wird ein Bild mit einem Quiz gepostet"
- Q types named: Diagnose / endoskopischer Befund / Behandlungsstrategie
- "nicht kindlich, sondern auf Facharztniveau" — stated twice, sharpest instruction
- "niedrigschwellig, kurz, leicht zu merken", "das Format wäre spannend"
- "sich auf die neue Aufgabe freuen" — anticipation, NOT obligation/nag

**Derived hard rules:**
- IMAGE-FIRST. Unit = image + quiz. Not a text vignette.
- EXACTLY ONE PER DAY. Scarcity is the mechanic. No decks, no infinite scroll of quizzes.
- Answers sourced from Leitlinien.
- BANNED: mascots, confetti, cartoon streak flames, Duolingo palette, any childish gamification.
- Not stated by owner → DO NOT INVENT: spaced repetition, streaks, points, leaderboards, social/comments/following, notifications, colour/typography specifics.

**Target user (ASSUMPTION — unconfirmed, verify with physicians):**
Hospital gastroenterologists in Germany, Ärzte in Weiterbildung + new Fachärzte. Secondary: established Fachärzte, foreign-trained colleagues. 60–90s attention, once/day, on phone. Reads German fluently, clinical abbreviations unexplained. Insulted by simplification. No exam/mandate/CME — must be worth opening on curiosity alone.
NOT the user: medical students, patients, general public.

**Delivery constraints (these decide architecture):**
- Must run on jury's own phones via public URL + QR code → web build.
- Must work WITHOUT network (congress wifi unreliable) → PWA, service worker, all content + images bundled as assets.
- Real GI content, no lorem ipsum.
- Codebase depth is NOT scored. Anything invisible in 10 min does not matter.
- Organiser constraint: solvable without clinical datasets or patient data.

**Scope decision for this repo:** build UI/UX to near-production polish. Backend redacted and DETACHED, not deleted — Firebase / PowerSync / Supabase removed from the boot path and replaced with a local make-do data source. Real GI content is TBD and out of scope for now.

**Affected (planned):** `lib/bootstrap.dart`, `lib/main_*.dart`, `lib/app/`, new `lib/daily/`, `packages/app_ui/`.

---

### [ACTIVE] 2026-08-30 — Product architecture decision: reels-shaped immersive feed
**Directive from idea owner (session, 2026-08-30):**

KEEP AS-IS (do not touch for now):
- Instagram splash screen, branding, app identity, theme.
- Top navigation bar (the bar holding the Instagram logo) — stays, but must be converted to LIQUID GLASS via `liquid_glass_renderer`.

REPLACE:
- Main feed layout. The boxed, scrollable card feed is gone.
- New shape = **reels/TikTok vertical full-screen pager, but the media is a still image, not video**. One image per viewport, vertical scroll snaps to the next. "TikTok for GI".
- Full-bleed edge-to-edge image fills the entire screen.
- Bottom **frosted-glass sheet** overlaid on the image. Collapsed by default. Tap or drag up expands it to reveal the article / news / case text.
- Inside the expanded sheet: the quiz. "Test me on this case" challenge.
  - Correct answer → confirm + explain WHY it is correct.
  - Wrong answer → explain WHY it is wrong + give the correct answer and its rationale.
- Reaction rail (like / save-archive / share) sits ON TOP of the image inside its own frosted container. Not below the image.

AI: **PLACEHOLDER ONLY.** No real model call. Imitate the look and feel of AI-generated challenge + explanation. Demo piece, not an end feature.

AUTH: **REMOVED** from the demo path. No login for a demo.

UNPLUG (comment out / detach, DO NOT DELETE — keep as later-pluggable):
- search, user_profile, timeline, chats, create-media / create-post / publish-post, stories, comments, reels(video), auth.
- They stay in the codebase but must not be reachable and must not interfere with the demo UI.

UX LAW: zero friction. Content is scannable at a glance; digging deeper is optional, fast and assisted.

**Architecture conclusion:** `lib/reels/` is the SHAPE reference, not the substrate. `ReelView`/`Reel` are hard-coupled to `PostBloc`, `FeedBloc`, `VideoPlayerState`, comments, stories and `UserRepository` (`lib/reels/reel/view/reel_view.dart`). Forking it is more expensive than writing a clean module. Build a new `lib/daily/` module that copies the *vertical `PageView` + Stack overlay* pattern from `lib/reels/view/reels_view.dart` and nothing else.

**Coupling map (verified this session):**
- `lib/bootstrap.dart` — hard `Firebase.initializeApp()` + `PowerSyncRepository.initialize()` before `runApp`. Blocks any offline start.
- `lib/app/routes/app_router.dart:486-493` — auth redirect gate; unauthenticated always bounced to `/auth`. Must be neutralised.
- `lib/app/routes/app_router.dart:153-260` — `StatefulShellRoute.indexedStack` with 5 branches (feed / timeline+search / createMedia / reels / user).
- `lib/home/view/home_page.dart` — 3-page horizontal `PageView` (createPost | main | chats) wrapping the shell. Must collapse to the single main page.
- `lib/navigation/view/bottom_nav_bar.dart` — 5-item `BottomNavigationBar`, reads `AppBloc.state.user` for the avatar.

**Toolchain verified:** `flutter` 3.35.7 stable on PATH (matches `.fvmrc`), Dart 3.9.2. No fvm wrapper needed.

**Still open:** design doc from idea owner (pending); real GI content (TBD, out of scope).

---

### [RECHECK] 2026-08-30 — BLOCKER: `liquid_glass_renderer` does NOT support web
**Evidence (pub.dev API, `https://pub.dev/api/packages/liquid_glass_renderer`, checked 2026-08-30):**
```
"version":"0.2.0-dev.4"
"environment":{"sdk":">=3.0.0 <4.0.0","flutter":">=3.32.4"}
"platforms":{"macos":null,"ios":null,"android":null}
"flutter":{"shaders":[... 4 .frag files ...]}
```
Declared platforms are **macOS, iOS, Android only**. No `web`. No `windows`. It ships 4 `.frag` shaders and depends on `flutter_shaders`; it needs Impeller.

**Consequence:** it cannot be used in the web build. The delivery brief requires a public URL + QR on the jury's own phones and offline operation — that is a Flutter web PWA. The two requirements are mutually exclusive with this package.

Side effect: it also cannot run on Windows desktop, so local visual checks must use Chrome or an Android device/emulator, never `flutter run -d windows`.

**Alternatives checked (pub.dev API, same date):**
- `glassmorphism` 3.0.0 — SDK `>=2.12.0 <3.0.0`. Dead, pre-Dart-3. REJECTED.
- `liquid_glass` 0.0.2 — 0.0.x, effectively unmaintained. REJECTED.
- `glass_kit` 4.0.2 — SDK `>=3.0.0 <4.0.0`, Flutter `>=3.0.0`, no platform restriction, so web-capable. Thin `BackdropFilter` + gradient-border wrapper. Viable web backend.
- `blur_glass` 0.0.2 — 0.0.x. REJECTED.

**Recommended resolution:** one project-owned primitive, `GlassSurface`, in `packages/app_ui`, with a swappable backend:
- web / default → `BackdropFilter` + `ImageFilter.blur` + gradient border + specular highlight. Works on every platform.
- native (Android/iOS) → `liquid_glass_renderer`, behind a compile-time / runtime flag.
All glass in the app goes through this one primitive. No scattered ad-hoc blurs (CLAUDE.md rule).

**Status RECHECK:** supersedes the earlier `[ACTIVE] Primary liquid-glass engine` entry's assumption that `liquid_glass_renderer` can be the sole engine. Awaiting delivery-target confirmation from the idea owner / team.

### [ACTIVE] 2026-08-30 — RESOLVED: delivery target = native Android APK, real liquid glass
**Decision (idea owner/team, 2026-08-30):** ship a **native Android APK**, distributed by QR → download → install. Web PWA is abandoned.

**Therefore:**
- `liquid_glass_renderer: ^0.2.0-dev.4` IS the glass engine. No `BackdropFilter` web fallback backend is needed.
- Accepted risks, eyes open: iPhone jurors cannot install; sideload friction inside a 10-minute slot; the download itself needs congress wifi (mitigate — have the APK on a local hotspot / preinstalled spare handset).
- Dev/QA runs on an Android device or emulator. **`flutter run -d windows` is impossible** — the package declares no windows platform.
- Offline requirement now means: bundle all images and content as Flutter assets in the APK. No network at runtime.

**Still applies:** all glass goes through ONE project primitive (`GlassSurface` in `packages/app_ui`), never scattered ad-hoc blur. Keep `FakeGlass` / cheap fallback available for perf-critical surfaces per the package's own guidance.

**Supersedes:** the `[RECHECK]` web-blocker entry above — the conflict is resolved by dropping web, not by dropping the package.

### [ACTIVE] 2026-08-30 — `liquid_glass_renderer` 0.2.0-dev.4 verified API + performance rules
**Resolution:** installed. `flutter pub get` succeeded on Flutter 3.35.7 / Dart 3.9.2, "Changed 7 dependencies", no conflicts with the 20 local path packages. Locked in `pubspec.lock` as `direct main`; pulls `flutter_shaders`, `motor`, `logging` transitively.

**Public API (from `lib/liquid_glass_renderer.dart`):**
`LiquidGlassLayer`, `LiquidGlass`, `LiquidGlass.grouped`, `LiquidGlass.withOwnLayer`, `LiquidGlassBlendGroup`, `LiquidGlassSettings`, `FakeGlass`, `GlassGlow` / `GlassGlowLayer`, `LiquidStretch` / `RawLiquidStretch`, `LgrLogs`, `Glassify` (experimental, separate `experimental.dart` import).

Shapes (`LiquidShape` sealed): `LiquidRoundedSuperellipse` (recommended squircle), `LiquidOval`, `LiquidRoundedRectangle`.

`LiquidGlassSettings` fields + defaults:
`visibility 1.0`, `glassColor Color(0x00FFFFFF)`, `thickness 20`, `blur 5`, `chromaticAberration 0.01`, `lightAngle 0.5*pi`, `lightIntensity 0.5`, `ambientStrength 0`, `refractiveIndex 1.2`, `saturation 1.5`.

**Usage rule:** `LiquidGlass` REQUIRES an ancestor `LiquidGlassLayer` (or use `.withOwnLayer`). Glass must sit in a `Stack` above real content — it distorts the pixels behind it, so it renders as nothing over a flat background.

**Performance rules taken straight from the package README — these drive our layout:**
- Static glass is almost free. **Moving glass re-renders every frame and is expensive.**
- `LiquidGlassLayer` and `LiquidGlassBlendGroup` allocate a texture covering their whole area. **Keep each layer's area small.** Sparse shapes over a big area → split into several small layers, never one full-screen layer.
- Max 16 shapes per blend group; perf degrades well before that.
- Moving one shape in a blend group re-renders every shape in that group.
- Known Flutter bug flutter#138627: textures are not disposed immediately → memory spikes while animating glass shapes.
- `blur` introduces artifacts when blending shapes.

**Design consequences for this app (decided):**
- Three small separate `LiquidGlassLayer`s — top bar, reaction rail, bottom sheet. **No single full-screen layer.**
- The draggable bottom sheet is the only moving glass surface, i.e. the one real perf risk. Mitigation: render `FakeGlass` while the drag is in flight, swap to real `LiquidGlass` once it settles at rest.
- Target device should be API 29+ with Vulkan. Project `minSdk 24`, `compileSdk/targetSdk 36`; no Impeller-disable flag anywhere in `android/`, so Flutter 3.35's Impeller default applies.

**Package status:** flagged EXPERIMENTAL by its authors; Impeller only, Skia unsupported.

### [ACTIVE] 2026-08-30 — How the Instagram modules get unplugged
**Constraint:** unwanted Instagram screens must stop interfering with the UI but must stay in the codebase as later-pluggable components.

**Rejected:** commenting out branches inside `lib/app/routes/app_router.dart` and stubbing the repositories. `App` (`lib/app/view/app.dart`) requires 8 repositories up front — user, posts, chats, stories, search, notifications, remote config — and `AppBloc` additionally requires `UserRepository` + `NotificationsRepository` and subscribes to `userRepository.user` in its constructor. Nothing renders until all of that exists. Faking 8 repositories to serve screens nobody will open is a lot of surface for zero demo value, and it leaves the original app broken rather than pluggable.

**Chosen:** a parallel demo shell. `lib/app/`, `lib/feed/`, `lib/reels/`, `lib/chats/`, `lib/search/`, `lib/stories/`, `lib/timeline/`, `lib/user_profile/`, `lib/comments/`, `lib/auth/` are left byte-for-byte untouched and keep compiling. The demo runs through its own entry point, its own router with one route, and its own repository. Unplugged by not being wired, not by being broken.

This satisfies all three requirements at once: they stay in the codebase, they cannot interfere with the demo UI, and re-plugging one is a matter of adding a route back.

**What is preserved from Instagram, per directive:** the native Android launch/splash screen (defined in `android/`, entirely independent of the Dart entry point, so it survives automatically), the app identity and logo (`packages/app_ui` `app_logo.dart`), and `AppTheme` / `AppDarkTheme` typography and colour.

**Affected files:** new `lib/daily/`, new `lib/demo/`, new `lib/main_demo.dart`, new `bootstrapDemo()`. No existing file is modified except `pubspec.yaml` (asset registration).

### [OPEN] 2026-08-30 — Missing asset: real endoscopy images
The demo is image-first and the brief forbids lorem ipsum, but the project has no endoscopy imagery. Needed from the physicians or an openly-licensed set before the jury demo. Until then the case model carries an asset path and the UI degrades to a neutral placeholder, so dropping real files in later is a content change, not a code change.

Text placeholder content is written in German at Facharzt level and cites guidelines by name only. **No AWMF register numbers or recommendation numbers are invented.** Every placeholder case carries an `unverified` flag that the UI renders as a visible badge, so nothing unreviewed can be mistaken for cleared clinical content.

### [ACTIVE] 2026-08-30 — Two pre-existing build blockers, both fixed
Neither was caused by this work; both stopped *any* Android build of this repo.

**1. `envied` codegen was never run.** `packages/env/lib/src/env.{dev,prod}.dart` reference `_EnvDev` / `_EnvProd` from `part 'env.*.g.dart'` files that were not in the tree, so `kernel_snapshot_program` failed with `Undefined name '_EnvProd'`. Unavoidable even for the prototype: `app_ui` → `shared` → `shared/lib/src/config/app_flavor.dart` → `package:env/env.dart`.
Fix: created `packages/env/.env.dev` and `.env.prod` holding **placeholder values only, no real credentials** (`https://placeholder.invalid`, `placeholder-anon-key`, …), then ran `dart run build_runner build` in `packages/env`. Generated `env.dev.g.dart` and `env.prod.g.dart`. The prototype never reads any of these; they exist solely so codegen can complete. Note: `--delete-conflicting-outputs` is removed in this build_runner version and is ignored.

**2. The Google Services Gradle plugin aborted the build.** `com.google.gms.google-services` was applied unconditionally in `android/app/build.gradle` and fails hard when `google-services.json` is missing — even for a variant that never touches Firebase.
Fix: the plugin is now applied only `if (file("google-services.json").exists())`. Dropping that file into `android/app/` re-enables it for the original Instagram flavours. This is the only change made to an existing file besides `pubspec.yaml`.

**Build verified:** `flutter build apk --debug -t lib/main_demo.dart` compiles and produces all three flavour APKs in `build/app/outputs/flutter-apk/`. The tool prints "Gradle build failed to produce an .apk file" without `--flavor` because the project defines three product flavours — the APKs are there; pass `--flavor development` to have the tool resolve one.

### [ACTIVE] 2026-08-30 — Four defects found by running the build on a device
All four were invisible to `flutter analyze`, which reported clean throughout. Each is a trap worth not re-entering.

**1. `DraggableScrollableSheet` resets when `snapSizes` is a fresh list.**
`didUpdateWidget` compares `snapSizes` with `!=`, and Dart lists compare by identity, so a list literal built inline is "changed" on every rebuild. That triggers `_replaceExtent`, which aborts any in-flight `animateTo`. Cache the list and hand back the same instance.

**2. Glass must be a backing plate, not a wrapper.**
This was the real cause of the sheet stopping mid-drag. Toggling `LiquidGlassLayer.fake` swaps the renderer's subtree; with the `CustomScrollView` inside that subtree, the swap remounted the scroll view mid-gesture, detached the sheet's `ScrollController` and stranded the drag at whatever extent it had reached. Symptom: exactly one `DraggableScrollableNotification`, then silence.
Fix: glass and content are siblings in a `Stack` — `GlassLayer` fills behind, content sits above inside a `ClipRSuperellipse`. The plate can now change underneath the content without the content noticing.

**3. A non-uniform `Border` plus a `borderRadius` silently kills the paint.**
The verdict panel used `Border(left: 2.5px accent, …thinner other sides)` together with `borderRadius`. Flutter rejects that combination, the container failed to paint, and it took **every one of its children down with it** — the box rendered at full height with its background and not a single glyph inside. No exception reached logcat.
Fix: uniform `Border.all` plus a separate 2.5px `ColoredBox` accent bar as a `Row` sibling, inside `IntrinsicHeight`.

**4. The way out has to stay where the way in was.**
With the drag handle in a scrolling sliver, closing the sheet after reading meant scrolling the whole case text back to the top first — the inner scroll consumes the downward drag until it reaches the top. Fix: the handle is a `SliverPersistentHeader(pinned: true)`; the chips, title and summary stay scrollable below it.

**Also fixed:** the action rail and scroll hint sat underneath the sheet on first paint. `DraggableScrollableSheet` emits no notification for its initial layout, so the extent notifier stayed at `0`. `CaseSheet.collapsedFractionFor(context)` is now public and seeds the notifier in `didChangeDependencies`.

**Also fixed:** PostHog was posting to `us.i.posthog.com` on launch, before any Dart code ran, auto-initialised from `AndroidManifest.xml` meta-data. Wrong for a prototype that claims no network, and wrong to demo at a medical congress. The four meta-data entries are commented out with a note on restoring them.

**Device note:** the Pixel 8 API 36 emulator reports `Using the Impeller rendering backend (OpenGLES)`, not Vulkan. Liquid glass renders correctly there, but the demo handset should be checked separately — Vulkan is the path the package is tuned for.

**Verified on device (emulator, API 36):** full-bleed pager with vertical snap between cases; the day label tracks position (Heute → Gestern); glass top bar, glass action rail and glass sheet all render with rim light; sheet expands on tap and on drag to 0.86; case text and quiz reachable; answering marks the chosen option amber and the correct one green, dims the rest, then reveals the verdict, both explanations, the takeaway and the guideline citation.

### [ACTIVE] 2026-08-30 — Release build, signing and APK size
**Blocker fixed:** `flutter build apk --release` failed with `SigningConfig "release" is missing required property "storeFile"` whenever no keystore was configured. `android/app/build.gradle` now falls back to the debug signing config in that case. A real store release is unaffected — set `ANDROID_KEYSTORE_PATH` (or `key.properties`) and the release config takes over.

**Verified:** the release APK installs and runs correctly under R8/minification. Glass, pager, sheet and quiz all behave as in debug.

**Sizes (development flavour, release):**
- universal — 56.2 MB
- arm64-v8a — 24.2 MB ← the one to hand the jury
- armeabi-v7a — 21.6 MB
- x86_64 — 25.4 MB

Build the split set with `--split-per-abi` and distribute the **arm64-v8a** APK. Every phone the jury is likely to hold is arm64; 24 MB over congress wifi is a very different proposition from 56 MB.

Most of that weight is the original Instagram clone's native plugins — video_player, camera, Firebase, Supabase, PowerSync — still linked in even though the prototype never calls them. Removing those dependencies would cut it much further, but that means editing `pubspec.yaml` in a way that breaks the modules we agreed to keep pluggable. Not worth it unless download size becomes the binding constraint on the day.

**Commands:**
```
flutter build apk --release --split-per-abi --flavor development -t lib/main_demo.dart
flutter run -t lib/main_demo.dart -d <android device>
```

---

## ⚠️ 2026-08-30 — DIRECTION CHANGE. `VISION.md` is now the product spec.

The idea owner re-read the problem statement and rewrote the product. **`VISION.md` in the project root supersedes every product decision recorded above.** Engineering findings (build blockers, package API, glass tokens, device defects) all still stand.

**Superseded:** `[ACTIVE] 2026-08-30 — Product architecture decision: reels-shaped immersive feed`. Specifically:
- The vertical case-to-case pager is **wrong now**. `VISION.md` kills swipe-to-next explicitly and lists "infinite scroll on the main feed" as the single most important deletion. Heute shows exactly one case; tomorrow is unreachable; the archive sits *below* today's case.
- The sheet order was **info-first** — title and summary visible while collapsed, body text, then the quiz. `VISION.md` rule 1 inverts this: **quiz before information, always**, and the image must carry no caption that gives the answer away. Everything I put in the collapsed sheet is a spoiler.
- The Merken / Teilen actions are deleted (no likes, no shares). Bookmarks are repurposed as **"Schwierige Fälle"**, auto-populated by cases answered wrong.
- Auth comes back. Three roles — reader, contributor, editor — and three seeded accounts to walk the contribution loop live on stage.

**Still valid and reused unchanged:** `packages/app_ui/lib/src/glass/` (tokens + `GlassSurface`), the full-bleed image + glass overlay layout, `CaseQuizPanel`'s commit-and-reveal behaviour, the local bundled-asset repository pattern, and every build fix (envied codegen, conditional google-services, release signing fallback, PostHog disabled).

**New scope:** three surfaces — Heute, Bibliothek, Beitragen — plus the demo loop: submit → AI triage → editor approves → appears as tomorrow's case.

## v2 visual QA pass — every surface verified on device (2026-08-30)

Emulator, `app-development-debug.apk`, walked login → Heute → answer → reveal →
archive → Bibliothek → topic → Beitragen → submit → triage → Konto wechseln →
editor → Redaktionsprüfung → Freigeben → Heute. The whole loop runs.

### Defects found and fixed

**Heute stage overflowed upward.** `_Stage` was `SizedBox(height: viewport)` with
the panel bottom-aligned. A question with four multi-line German options is
taller than `viewport − bottomInset`, so the panel pushed off the top, collided
with the status bar, and hid the image completely. Fix: `Stack` sized by a
`Column(mainAxisSize: min)` of `[spacer, panel]` with the image behind via
`Positioned.fill`. The spacer (`max(viewport * 0.42, topInset + 150)`) reserves
the image; a tall panel grows the stage downward instead of overflowing.
Same shape applied in `case_page.dart`.

**Glass rendered as a flat dark card.** `LiquidGlass` takes colour and
refraction from what is behind it, and the missing-image placeholder was a near
black gradient crushed further by the legibility scrim — so the panel had
nothing to bend. `_MissingImage` is now three stacked gradients (a lit lobe, an
offset warm lobe, a vignette) with a `BILD FOLGT` marker aligned high so the
question panel does not cover it. Top scrim softened `0x99 → 0x80`.
**Rule: glass needs a non-flat backdrop or it reads as a plain container.**

**Bibliothek cards clipped mid-line.** `Expanded(Text(maxLines: 4, ellipsis))`
does not ellipsise — a `Text` in a box shorter than its `maxLines` clips at the
box edge. Fix: bounded `maxLines: 3` + `Spacer()`, `childAspectRatio` 0.86 → 0.76.

**Image picker rendered as hairlines.** The thumbnail `Container` had a height
but no width, so it shrank to its child — and the missing-asset placeholder has
no intrinsic size. Fix: `width: double.infinity` + `SizedBox.expand()` in the
`errorBuilder`.

**Two RenderFlex overflows in the review card** (79 px and 3.5 px): a `Row` of
two `MetaChip`s plus the author name became a `Wrap`; the confidence label
became `Expanded`.

**Content collided with the system clock** on every pushed page. Extracted
`StatusBarScrim` (`lib/shell/widgets/status_bar_scrim.dart`) — a status-bar-tall
top fade — used by the shell and by case, topic, profile, submit and review
pages. Only as tall as the status bar; taller reads as a header band and breaks
the full-bleed premise.

### Copy corrections (integrity, not polish)

Approval inserts the case at index 0, so it is visible **immediately**, while
the UI promised "Erscheint: Morgen". Strings now say what the build does:
`scheduledLabel` = `als nächster Fall des Tages`, the submission path step reads
"Im Prototyp sofort, im Betrieb am nächsten Tag", and approving shows a snackbar
("Freigegeben. Steht jetzt als Fall des Tages in Heute.") — previously the card
vanished and left the editor on an empty page. Also killed `Einreichung(en)`.

### Empty states

Contributor Beitragen was a single card over a void. Added `_PathNotice`: the
four-step route a submission takes (einreichen → Vorprüfung → ärztliche Freigabe
→ Fall des Tages). Doubles as the demo narration.

### Still open

- No real endoscopy imagery. `assets/daily/images/` is empty; every case shows
  the abstract placeholder. Deliberately abstract — a plausible fake frame under
  a real AWMF number is the exact failure the citation rules exist to prevent.
- Target-user assumption unconfirmed with the physicians.
