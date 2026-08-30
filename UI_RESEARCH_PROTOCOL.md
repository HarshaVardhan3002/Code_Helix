# GI DAILY — INCREMENTAL RESEARCH PROTOCOL

## CRITICAL RULE
**DO NOT scan the entire repository before starting work.** Discover only what the active task needs. Expand context only when blocked or when a concrete dependency is introduced.

## DISCOVERY ORDER
1. Identify the exact feature/screen/component being changed.
2. Inspect only the most likely local files, symbols, routes, models, widgets, and dependencies.
3. Check `findings.md` for existing research and decisions.
4. Search **pub.dev** only if the finding cache does not already answer the need.
5. Search GitHub/open-source only when pub.dev/local code is insufficient or verification is needed.
6. Choose the smallest reliable reusable solution.
7. Record the result in `findings.md` before moving on.

## FINDINGS CACHE RULE
Before any external research, search `findings.md` using the feature/component/package terms.
If an existing finding satisfies the requirement, **DO NOT SEARCH AGAIN** unless it is stale, contradictory, or missing a critical detail.

## WHAT TO RECORD
Record concise, reusable evidence:
- date/check context
- feature/component need
- local implementation found
- package/repository candidates checked
- selected package/component
- why it won
- relevant API/import
- version/compatibility notes
- limitations
- exact project files affected
- rejected alternatives and why

## GLASS PRIORITY
For GI Daily, **start with `liquid_glass_renderer: ^0.2.0-dev.4`**.
It is the primary candidate for the glass system because it supports liquid/frosted effects, blending, background distortion/refraction, glow, and stretch. Verify its current API and project compatibility before implementation.

Search alternatives only when the primary package cannot satisfy the requirement or introduces a material performance/platform problem.
Useful fallback search terms:
`glassmorphism`, `liquid glass`, `frosted glass`, `backdrop blur`, `refraction`, `distortion`, `glass card`, `glass navigation`.

## DO NOT CACHE JUNK
Do not record raw search dumps or large copied documentation. Record conclusions and the minimum evidence needed to avoid repeating the research.
