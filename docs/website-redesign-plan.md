# Smart Muslim Website — Complete Redesign Execution Plan

**Document**: `docs/website-redesign-plan.md`  
**Status**: Executed & Deployed  
**Deployment**: [https://smart-muslim.web.app/](https://smart-muslim.web.app/)

---

## 1. Objectives & Scope
Transform the Smart Muslim website into an official, production-grade digital home reflecting:
- **Calm, Apple-level technological clarity** paired with serene, authentic Islamic identity.
- **Zero commercialism**: 100% free, zero ads, zero analytics/tracking, perpetual charity (*Sadaqah Jariyah*).
- **International accessibility**: Seamless bilingual Arabic (RTL) & English (LTR) switching.
- **System Theme Support**: Clean serene light mode and high-contrast dark mode.
- **Total Transparency**: Traceable source documentation, minimal permission justification, realistic feature inventories, and authentic release roadmaps.

---

## 2. Phase-by-Phase Execution Summary

### Phase 1: Reverse Engineering & Repository Audit
- Diagnosed single-file prototype bottlenecks (heavy unminified CDN Tailwind script, imperative section hiding without RESTful state, lack of bilingual support, lack of SEO/schema markup).
- Documented in `docs/website-reverse-engineering-report.md`.

### Phase 2: Design System & Visual Tokens
- Replaced dark green wall templates with a balanced, calm aesthetic:
  - 55–65% Light Ivory (`#FAF8F2`) and White (`#FFFFFF`).
  - 20–25% Deep Islamic Teal (`#0F5C5E`).
  - 5–10% Emerald (`#2F806A`).
  - 2–5% Muted Gold (`#C9A96E`) strictly for delicate accents.
- Created `website/css/design-system.css` with semantic CSS variables, fluid typography, and zero dependencies.

### Phase 3: Brand Identity & Iconography
- Crafted an authentic SVG emblem combining the Rub el Hizb (8-point geometric star) with a subtle mihrab arch curve.
- Deployed as `website/assets/smart_muslim_icon.svg` and `website/favicon.svg`.

### Phase 4: Bilingual Engine & Directional Switching
- Built `website/js/i18n.js` with comprehensive Arabic and English dictionaries.
- Implemented full reactive direction switching (`dir="rtl"` ⇄ `dir="ltr"`).

### Phase 5: Theme Engine (System / Light / Dark)
- Built `website/js/theme.js` with local preference persistence (`localStorage`) and system media query synchronization (`prefers-color-scheme`).

### Phase 6: Router & Interactive UI
- Built `website/js/app.js` with hash-based section routing (`#/`, `#/features`, `#/quran`, `#/privacy`, `#/sources`, `#/roadmap`, `#/faq`, `#/download`, `#/about`, `#/other-apps`).
- Added accessible mobile drawer with ARIA keyboard controls.
- Added accessible iOS Safari PWA installation modal with focus trap.
- Added interactive FAQ accordion.

### Phase 7: SEO, Accessibility & Structured Data
- Schema.org JSON-LD (`SoftwareApplication`, `Organization`, `WebSite`).
- `website/robots.txt` and `website/sitemap.xml`.
- WCAG 2.2 AA contrast compliance and semantic HTML landmarks.
