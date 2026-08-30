# GI DAILY — NON-NEGOTIABLE MASTER DIRECTIVE
> **WARNING: Treat this file as mandatory. Do not dilute, skip, or override these rules with default coding habits.**

## PRODUCT / VISUAL NORTH STAR
- **GI Daily** = premium, image-first mobile research/news consumption for gastrointestinal researchers.
- **PRIMARY EXPERIENCE: IMMERSIVE FULL-SCREEN IMAGERY + GLASSMORPHIC UI.**
- “Large visual” means **full-screen/end-to-end imagery**, not a normal card image.
- Glass is the dominant visual language: **liquid, frosted, reflective, refractive, layered, tactile, premium**.
- The result must feel like a **mature commercial product**, not a template, clone, or academic prototype.

## RESEARCH-FIRST IMPLEMENTATION
- **DO NOT LOAD OR SCAN THE ENTIRE CODEBASE UP FRONT.**
- Discover **only the files, symbols, dependencies, assets, and architecture relevant to the active task**; expand context only when required.
- **FIRST CHECK `findings.md`.** Do not repeat research already documented unless stale, contradictory, or insufficient.
- **RESEARCH → REUSE → ADAPT → IMPLEMENT → RECORD.**
- Before creating a component, check existing project capabilities, then **pub.dev first**, then relevant GitHub/open-source libraries as needed.
- **FIRST CHOICE = EXISTING, MATURE, MAINTAINED COMPONENT/PACKAGE.**
- Prefer adaptation/theme/override over replacement.
- **FORBIDDEN:** hand-building primitive replacements when a suitable reusable solution exists.

## GLASS-FIRST ENGINEERING
- Prefer **pub.dev glass/liquid-glass libraries** over custom glass rendering.
- Before use, verify the package/API against the project; this release is experimental and requires Impeller/mobile performance validation. Do not blindly apply expensive effects everywhere.
- Establish reusable glass primitives/tokens; **do not scatter ad-hoc blur/transparency effects**.
- Use optical depth, blur, highlights, translucency, reflection/refraction, and restrained motion where technically appropriate.
- Never confuse “opacity + blur” with a finished glass system.

## MOBILE / UI QUALITY
- Design **mobile-first and composition-first** before coding.
- Deliberately evaluate safe areas, hierarchy, spacing, typography, touch targets, image cropping, scrolling, density, responsiveness, and interaction states.
- **NO arbitrary pixel placement** without design-system justification.
- Preserve visual consistency across the entire app; reject one-off patterns.

## PERSISTENT MEMORY
- Record useful discoveries, package evaluations, architectural conclusions, design decisions, and affected paths in **`findings.md`**.
- Keep findings concise: **conclusions + minimum evidence + reusable pointers**, never raw research dumps.
- Treat `findings.md` as the project's external research cache to prevent repeated discovery and context bloat.

## VISUAL QA GATE
- After every **3–4 meaningful feature groups**, stop and perform visual QA with the configured **Sonnet sub-agent** when available.
- The reviewer gets **running-app/UI interaction access only**, not source-code access for the visual audit.
- It must interact, inspect, screenshot, and identify layout, hierarchy, consistency, responsiveness, polish, performance perception, and glass-system problems.
- **FIX DEFECTS BEFORE CONTINUING.**
- Quality bar: **top-tier commercial mobile/SaaS product maturity**.

## TECHNICAL GOVERNANCE
- `flutter-strict.md` is mandatory for Flutter/Dart work; `UI_RESEARCH_PROTOCOL.md` and `UI_QA_PROTOCOL.md` govern their respective procedures.
> **FINAL RULE: Never trade research, reuse, visual quality, or context discipline for speed.**
