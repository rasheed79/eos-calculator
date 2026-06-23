# Critique: landing/index.html
**Date:** 2026-06-23 | **Score:** 72/100 | **P0:** 0 | **P1:** 3 | **P2:** 2

## P1 — High

### [P1-1] Contrast: `.seo-table th`
White text on `#2563EB` background = 3.93:1. WCAG AA requires 4.5:1 for normal text.
**Fix:** Change header bg to `--blue-dk` (#1D4ED8) → 4.7:1 ✓

### [P1-2] Contrast: `.ex-result`
`#2563EB` text on white = 3.93:1 < 4.5:1.
**Fix:** Change to `--blue-dk` (#1D4ED8).

### [P1-3] Em-dash overuse
11 em-dashes (—) in body copy. AI cadence tell per brand register.
**Fix:** Replace sentence-interrupting em-dashes with parentheses, colons, or natural Arabic phrasing.

## P2 — Medium

### [P2-1] Transliterated English: "أوف لاين"
Appears in trust bar and CTA section. Breaks brand Arabic voice.
**Fix:** Replace with "بدون إنترنت".

### [P2-2] Mobile breakpoint gap
`@media (max-width: 400px)` misses iPhones 428/430px (14 Pro Max, 15 Plus).
**Fix:** Extend to `max-width: 430px`.
