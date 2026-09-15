# Smart Muslim Website — Reverse Engineering & Comprehensive Audit Report

**Document**: `docs/website-reverse-engineering-report.md`  
**Date**: September 15, 2026  
**Auditor**: Lead Product Designer, Senior Frontend Architect & Accessibility Specialist  
**Target Domain**: [https://smart-muslim.web.app/](https://smart-muslim.web.app/)  
**Target Repository**: `D:\Projects\Smart-Muslim`

---

## 1. Executive Summary

Smart Muslim is an open-source, non-profit, ad-free Islamic mobile application (built in Flutter) accompanied by a lightweight web deployment and landing page. The application strictly adheres to an authentic, privacy-first, offline-first philosophy dedicated as a continuous charity (*Sadaqah Jariyah*).

The current website serves as both:
1. A static landing/product portal (`/` -> `public_html/index.html`).
2. A Flutter Web Progressive Web Application (PWA) client (`/lite/` -> `public_html/lite/index.html`).

While recent hotfixes resolved runtime web crashes (`Platform._operatingSystem`), missing audio interpolation (`adhan_${name}.mp3`), and button scrolling, the existing website remains an elementary single-file prototype relying on runtime CDN scripts, imperative DOM toggling, and rudimentary styling. It falls significantly short of a world-class, production-grade Islamic digital product website with Apple-level restraint, modern SaaS clarity, international bilingual support, and WCAG 2.2 AA accessibility.

---

## 2. Technical Audit by Dimensions (A to X)

### A. Technology Stack
- **Web Hosting**: Firebase Hosting (`smart-muslim.web.app`, project ID: `smart-muslim-ad4f6`).
- **Landing Page**: Vanilla HTML5, Vanilla JavaScript (inline `<script>`), and Tailwind CSS loaded dynamically via CDN (`https://cdn.tailwindcss.com`).
- **Embedded Web Client**: Flutter Web engine (HTML / CanvasKit / WebAssembly compiled output in `/lite/`).
- **Build Scripts**: `build_web.ps1` (compiles Flutter Web and copies static directory to `public_html`).

### B. Framework
- **Current State**: No frontend build framework (no Next.js, Vite, Astro, or Vue). It is a single static HTML file with dynamic runtime DOM manipulation.
- **Evaluation**: Loading Tailwind via CDN (`cdn.tailwindcss.com`) is explicitly intended for development only; it causes a heavy JavaScript parsing penalty (3MB+ unminified script), layout shift (CLS), and lacks CSS tree-shaking for production.

### C. Routing
- **Current State**: Simulated client-side section switching using imperative JavaScript:
  - `showSection('home-section')`
  - `showSection('about-section')`
  - `showSection('developer-section')`
  - `showSection('download-section')`
  - `showSection('other-apps-section')`
- **Evaluation**: Weak and non-RESTful. The browser URL does not change (no hash or history state), meaning users cannot share direct links to `/about`, `/download`, or `/sources`, and page refreshes always reset state to `home-section`.

### D. Components
- **Current State**: Monolithic, non-componentized single HTML document (`621 lines`). Navbar, Hero, Features, About, Developer, Other Apps, Downloads, and Modal are hardcoded in a single file.
- **Evaluation**: Lacks reusability, testability, and separation of concerns.

### E. Pages & Sub-sections
- Currently simulated via hidden `<div>` tags:
  1. `home-section`: Hero banner, Quranic Ayah block, 4 feature cards, callout banner.
  2. `other-apps-section`: Smart CV Builder card, upcoming apps placeholder.
  3. `about-section`: Basic vision statement.
  4. `developer-section`: SBS company card, projects summary.
  5. `download-section`: PWA, Android APK, iOS modal trigger.
- **Missing Required Pages**:
  - `/sources` (Traceable data sources and integrity verification).
  - `/privacy` (Transparent privacy & zero-tracking policy).
  - `/roadmap` (Current vs next product development phases).
  - `/changelog` (Authentic release history).
  - `/faq` (Interactive, authentic product FAQ).

### F. Assets
- **Audio Assets**: 14 bundled audio files in `assets/audio/` and `android/app/src/main/res/raw/`.
- **Image Assets**: No custom SVG brand assets or real UI mockups in `website/`. It relies almost entirely on CSS shapes, emojis, and basic SVGs.

### G. Fonts & Typography
- **Google Fonts Loaded**:
  - `Cairo` (`wght@400;500;600;700;800;900`) for primary UI.
  - `Amiri` (`wght@700`) for the Quranic Ayah.
- **Evaluation**: While Cairo and Amiri are good fonts, the project specification recommends evaluating **IBM Plex Sans Arabic** or **Noto Sans Arabic** for modern tech clarity, paired with a matching clean Latin sans-serif (such as Inter) for international English support.

### H. Icons
- **Current State**: Ad-hoc mix of emojis (`📖`, `🕌`, `🧭`, `📿`, `⚡️`, `⭐`, `🤖`, `🍏`, `📱`) and hardcoded SVG paths.
- **Evaluation**: Unprofessional icon consistency. High-end modern design requires a unified, lightweight, vector iconography system (e.g. Lucide or Heroicons style with consistent 1.5px / 2px stroke and harmonious optical weight).

### I. Existing Colors
- **Current State**: `#011c15`, `#022c22`, `#032e24`, `#064e3b`, `#d4af37`.
- **Evaluation**: Overwhelmingly dark green. The brand specification mandates an Apple-level calm aesthetic where the dominant surface is **Light Ivory (`#FAF8F2`) / Pure White (`#FFFFFF`)** at 55–65%, with **Deep Islamic Teal (`#0F5C5E`)** at 20–25%, **Emerald (`#2F806A`)** at 5–10%, and **Muted Gold (`#C9A96E`)** strictly as a 2–5% subtle accent.

### J. Responsive Behavior
- Desktop layout is functional and tested; mobile layout has hamburger drawer and stacking cards.
- Breakpoint behavior relies on default Tailwind (`sm`, `md`, `lg`, `xl`).

### K. RTL / LTR Implementation
- **Current State**: Hardcoded `dir="rtl"` and `lang="ar"`.
- **Evaluation**: Completely lacks LTR support and English localization. International users cannot browse the product website in English.

### L. Localization Architecture
- **Current State**: None. All copy is hardcoded Arabic.
- **Evaluation**: A modern Islamic product site must support seamless Arabic/English switching with authentic bilingual content and correct directional switching (`dir="ltr"` / `dir="rtl"`).

### M. SEO Implementation
- **Current State**: Basic `<title>` and `<meta name="description">`.
- **Evaluation**: Extremely minimal.
  - Missing Canonical URL.
  - Missing Open Graph tags (`og:title`, `og:description`, `og:image`, `og:url`, `og:type`).
  - Missing Twitter Card tags (`twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`).
  - Missing JSON-LD Structured Data (`SoftwareApplication`, `Organization`, `WebSite`).
  - Missing `robots.txt` and `sitemap.xml`.

### N. Metadata
- Missing theme color meta (`<meta name="theme-color" content="#0F5C5E">`), Apple touch icon definitions, and web app capabilities.

### O. Favicon
- Currently defaults to generic Flutter or missing on the root domain (`favicon.ico` / `favicon.png`).

### P. Manifest
- No `manifest.json` configured for the root marketing site (only exists inside `/lite/`).

### Q. Performance
- **Bottlenecks**:
  - `https://cdn.tailwindcss.com` runtime script blocks rendering and adds ~3.2MB uncompressed runtime footprint.
  - Absence of asset preloading (`preconnect` to Google Fonts).
  - Absence of responsive WebP/AVIF imagery.

### R. Accessibility (WCAG 2.2 AA)
- Missing `aria-expanded` and `aria-controls` on mobile burger toggle.
- Modal lacks focus trap, `aria-modal="true"`, and `role="dialog"`.
- Contrast ratio between text and certain backgrounds needs strict auditing.
- Missing `prefers-reduced-motion` respect.

### S. Mobile Layout
- Mobile menu drawer exists but has no smooth transition or accessible keyboard focus.
- Hero and cards stack well, but can be much more intentional and tactile.

### T. Dark / Light Theme Behavior
- **Current State**: Only a single hybrid dark/green theme exists. No user-selectable theme toggle, no system preference detection (`prefers-color-scheme`).
- **Evaluation**: The project demands a primary serene light mode (Ivory/Teal) and a sophisticated dark mode (`#0D191A`, `#142526`, `#F3F1E8`).

### U. Existing Download Links
- **Android APK**: Points to authentic MEGA file hosted by user (`https://mega.nz/file/8lJ23TxC#XnRyVJH3zfKqlRNFk1yxb8LzXH5pJmNSC4_sNoPCsCY`).
- **Web PWA**: Points directly to `/lite/`.
- **iOS**: Modal explaining PWA Add to Home Screen in Safari.
- **Evaluation**: Accurate, transparent, and non-fabricated.

### V. Existing App Screenshots
- The website currently displays **zero real screenshots** of the mobile app; it only displays icon cards. Real screenshots of Prayer, Quran/Mushaf, Qibla, and Tasbih from the actual app must be featured in realistic, elegant device frames.

### W. Existing Content
- Free / Ad-free / Sadaqah Jariyah positioning is clear.
- Ayah from Surah Yusuf (108) is appropriately placed.
- Missing in-depth technical transparency, calculation methods, data source provenance, and privacy details.

### X. Existing External Links
- `https://sbs-official.web.app/` (SBS Software Solutions).
- `https://smart-cv-pro.web.app/` (Smart CV Builder).
- `https://mega.nz/...` (APK download).

---

## 3. Detailed Diagnosis: What to Preserve vs What to Redesign

### What is Already Good & Must Be Preserved
1. **The Core Philosophy**: 100% free, no ads, no tracking, pure Sadaqah Jariyah.
2. **Honesty & Authenticity**: No exaggerated claims, no fake awards, no fabricated testimonials.
3. **Surah Yusuf Ayah (108)**: Authentic, inspiring, beautifully contextualized.
4. **Valid Distribution Channels**: The working MEGA Android download link, the `/lite/` Flutter PWA link, and the Safari iOS PWA installation walkthrough.
5. **Brand Name**: "المسلم الذكي | Smart Muslim".

### What Must Be Redesigned & Re-engineered
1. **Visual Tone**: Transition from "dark green template with emojis" to "Apple-level modern technology product + subtle Islamic serenity".
2. **Color Palette**: Implement the mandated palette:
   - Surface: Light Ivory (`#FAF8F2`) and White (`#FFFFFF`)
   - Primary: Deep Islamic Teal (`#0F5C5E`)
   - Dark Primary: (`#083F41`)
   - Secondary: Emerald (`#2F806A`)
   - Muted Gold: (`#C9A96E`) strictly for subtle accents (2–5%).
   - Dark Mode: Surface (`#142526`), Background (`#0D191A`), Text (`#F3F1E8`).
3. **Bilingual RTL/LTR Architecture**: Full seamless Arabic and English switching with persistent state and correct typography.
4. **Information Architecture**: Multi-page or seamless client-routed structure supporting:
   - `/` (Home & Product Showcase)
   - `/features` (Detailed feature breakdown)
   - `/quran` (Quran showcase with real Mushaf details)
   - `/privacy` (Verified zero-tracking declaration)
   - `/sources` (Tanzil, Hadith, calculation method provenance)
   - `/roadmap` (Verified Phase 1 to 5 status)
   - `/faq` (Common questions answered authentically)
   - `/download` (Dedicated download center with QR code)
   - `/about` (Mission and SBS development background)
5. **Real Product Imagery**: Feature actual, verified screens from the Flutter codebase (Prayer schedule, Qibla compass, Tanzil Mushaf page, and Tasbeeh counter).
6. **Performance & Engineering**:
   - Eliminate runtime Tailwind CDN (`cdn.tailwindcss.com`) or replace with optimized zero-runtime / precompiled production styling.
   - Comprehensive SEO with Open Graph, Twitter cards, JSON-LD Schema (`SoftwareApplication`), `robots.txt`, and `sitemap.xml`.
   - WCAG 2.2 AA accessibility (proper ARIA attributes, keyboard navigation, focus indicators, semantic elements).
