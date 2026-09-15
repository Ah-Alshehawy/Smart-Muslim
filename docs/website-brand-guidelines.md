# Smart Muslim — Brand Guidelines
**المسلم الذكي — دليل الهوية البصرية**

---

## Brand Identity

| | |
|---|---|
| **Arabic Name** | المسلم الذكي |
| **English Name** | Smart Muslim |
| **Tagline (AR)** | رفيقك للعبادة والطاعة |
| **Tagline (EN)** | Your companion for worship |

### Naming Rules
- ✅ **Correct**: المسلم الذكي, Smart Muslim
- ❌ **Never use**: SmartMuslim, Smart-Muslim, Muslim Smart

---

## Logo System

### Logo Concept
The Smart Muslim logo is built from three symbolic elements:

1. **Islamic Arch (Mihrab Frame)** — A pointed arch representing Islamic architectural heritage and spiritual doorways
2. **Open Quran / Book** — Two symmetrical wing-shaped pages representing knowledge and divine guidance
3. **8-Pointed Star (Rub el Hizb)** — A geometric star at the apex representing divine light and Islamic geometry

### Logo Variants

| Variant | File | Use Case |
|---------|------|----------|
| **Primary Icon** | `assets/brand/smart-muslim-icon.svg` | Main usage: headers, favicons, app icons, social media |
| **Light Background** | `assets/brand/smart-muslim-icon-light.svg` | When placed on ivory/light surfaces |
| **Monochrome** | `assets/brand/smart-muslim-icon-mono.svg` | Single-color printing, watermarks |
| **Arabic Logo** | `assets/brand/smart-muslim-logo-ar.svg` | Arabic-first contexts with wordmark |
| **English Logo** | `assets/brand/smart-muslim-logo-en.svg` | English-first contexts with wordmark |

### Logo Sizes
- **Minimum size**: 16×16px (icon recognizable)
- **Favicon**: 32×32px or SVG
- **Header**: 40×40px
- **Footer**: 32×32px
- **App icon**: 512×512px
- **Social media**: 256×256px or larger

### Logo Clear Space
Maintain at least 25% of the logo width as clear space around all sides.

---

## Color System

### Primary Palette

| Token | Hex | Role |
|-------|-----|------|
| **Primary Teal** | `#0F5C5E` | Primary brand color, buttons, accents |
| **Dark Teal** | `#083F41` | Hover states, deep headings |
| **Secondary Emerald** | `#2F806A` | Success states, badges (5–10%) |
| **Muted Gold** | `#C9A96E` | Accent ONLY (2–5%), star ornaments |

### Neutral Palette

| Token | Hex | Role |
|-------|-----|------|
| **Light Ivory** | `#FAF8F2` | Primary background surface |
| **Pure White** | `#FFFFFF` | Cards, modals, elevated surfaces |
| **Warm Sand** | `#E8DFC9` | Quranic content surfaces |
| **Text Dark** | `#172A2B` | Primary typography |
| **Text Secondary** | `#5F6F70` | Body copy, meta text |

### Dark Mode Palette

| Token | Hex | Role |
|-------|-----|------|
| **Dark Background** | `#0D191A` | Main dark background |
| **Dark Surface** | `#142526` | Elevated dark cards |
| **Dark Text** | `#F3F1E8` | Primary text on dark |

### Visual Balance Target
- 55–65% neutral/ivory/white surfaces
- 20–25% deep teal
- 5–10% emerald
- 2–5% muted gold (strictly accent only)

---

## Typography

| Context | Font Family | Weight |
|---------|------------|--------|
| **Arabic UI** | IBM Plex Sans Arabic | 400, 500, 600, 700, 800 |
| **Quranic Text** | Amiri | 700 (strictly for Ayahs) |
| **English UI** | Inter | 400, 500, 600, 700, 800 |

### Type Scale
- Display: 48–60px
- H1: 36–42px
- H2: 28–32px
- H3: 20–24px
- Body: 16–18px
- Caption: 13–14px

---

## Design Principles

1. **"Apple-level simplicity + modern SaaS clarity + serene Islamic identity"**
2. Zero exaggerated claims — 100% truthful feature representation
3. Restrained Islamic geometry — subtle, never overwhelming
4. Accessibility-first — WCAG 2.2 AA compliance
5. RTL-native — Arabic is the primary language

### Strictly Avoid
- ❌ Mosque silhouettes as decoration
- ❌ Oversized crescents or heavy gold arabesques
- ❌ Distracting animations
- ❌ Green-dominant monotone design
- ❌ Excessive gradients

---

## Asset Locations

```
website/
├── assets/
│   └── brand/
│       ├── smart-muslim-icon.svg          (Primary icon)
│       ├── smart-muslim-icon-light.svg    (Light BG variant)
│       ├── smart-muslim-icon-mono.svg     (Monochrome variant)
│       ├── smart-muslim-logo-ar.svg       (Arabic wordmark)
│       └── smart-muslim-logo-en.svg       (English wordmark)
├── favicon.svg                            (Copy of primary icon)
└── manifest.json                          (References primary icon)
```
