# Smart Muslim Website — Design System Specification

**Document**: `docs/website-design-system.md`  
**Version**: 1.0.0  
**Scope**: Smart Muslim Official Web Platform

---

## 1. Color System & Philosophy

The visual philosophy embodies **Apple-level simplicity + modern SaaS product clarity + subtle Islamic serenity**.
The interface avoids heavy, dark green walls or cliché ornamentation. Surfaces are predominantly light, breathable, and calm.

### Visual Balance Target
- **55–65% Neutral Surfaces**: Light Ivory (`#FAF8F2`), Pure White (`#FFFFFF`), and Warm Sand (`#E8DFC9`).
- **20–25% Deep Islamic Teal**: (`#0F5C5E`) for primary interactive controls, nav headers, and key brand accents.
- **5–10% Emerald**: (`#2F806A`) for sub-accents, verified badges, and Islamic context highlights.
- **2–5% Muted Gold**: (`#C9A96E`) strictly reserved for small decorative details, Ayah markers, and subtle highlights.

### Token Palette

| Token | Light Value | Dark Value | Purpose |
| :--- | :--- | :--- | :--- |
| `--bg-base` | `#FAF8F2` (Light Ivory) | `#0D191A` (Deep Slate Teal) | Primary ambient page canvas |
| `--bg-surface` | `#FFFFFF` (Pure White) | `#142526` (Card Surface) | Content cards, modals, dropdowns |
| `--bg-surface-elevated` | `#FFFFFF` | `#1A2E30` | Hover states, elevated cards |
| `--bg-accent-subtle` | `rgba(15, 92, 94, 0.05)` | `rgba(79, 163, 160, 0.1)` | Subtle tint backgrounds |
| `--color-primary` | `#0F5C5E` (Islamic Teal) | `#4FA3A0` (Accessible Teal) | Primary buttons, brand identity |
| `--color-primary-dark` | `#083F41` | `#3B8784` | Primary hover state, strong headings |
| `--color-secondary` | `#2F806A` (Emerald) | `#449C82` | Verification badges, secondary accents |
| `--color-gold` | `#C9A96E` (Muted Gold) | `#C9A96E` | Ayah markers, star accents (strictly 2–5%) |
| `--color-sand` | `#E8DFC9` (Warm Sand) | `#2A3A34` | Quranic surfaces, parchment panels |
| `--text-primary` | `#172A2B` | `#F3F1E8` | High-contrast body & heading copy |
| `--text-secondary` | `#5F6F70` | `#B8C5C4` | Subtitles, meta text, supporting labels |
| `--text-muted` | `#8A9A9B` | `#7D8E8D` | Footnotes, disabled states |
| `--border-subtle` | `#E3ECE9` | `#223839` | Standard structural borders |
| `--border-strong` | `#C4D5D1` | `#2F4B4D` | Form inputs, interactive borders |
| `--shadow-sm` | `0 1px 2px rgba(15, 92, 94, 0.04)` | `0 1px 2px rgba(0, 0, 0, 0.3)` | Subtle card elevation |
| `--shadow-md` | `0 4px 12px rgba(15, 92, 94, 0.06)` | `0 4px 16px rgba(0, 0, 0, 0.4)` | Standard interactive card |
| `--shadow-lg` | `0 12px 32px rgba(15, 92, 94, 0.10)` | `0 12px 36px rgba(0, 0, 0, 0.5)` | Modal, floating popovers |

---

## 2. Typography Hierarchy

### Fonts
- **Arabic UI**: `IBM Plex Sans Arabic`, `Noto Sans Arabic`, sans-serif.
- **Quranic Scripture**: `Amiri`, serif (strictly preserved for the holy Quranic verse).
- **English UI**: `Inter`, system-ui, -apple-system, sans-serif.

### Type Scale & Line-Heights
Arabic requires generous line-heights to prevent diacritic (*tashkeel*) and ascender collisions.

| Style | Desktop Size / Line-Height | Mobile Size / Line-Height | Weight | Tracking |
| :--- | :--- | :--- | :--- | :--- |
| **Display** | `52px` / `1.35` | `32px` / `1.35` | 800 (Black) | `normal` (0) |
| **H1** | `38px` / `1.4` | `26px` / `1.4` | 700 (Bold) | `normal` (0) |
| **H2** | `28px` / `1.45` | `22px` / `1.45` | 700 (Bold) | `normal` (0) |
| **H3** | `20px` / `1.5` | `18px` / `1.5` | 600 (SemiBold)| `normal` (0) |
| **Body Large** | `18px` / `1.7` | `16px` / `1.7` | 400 (Regular) | `normal` (0) |
| **Body** | `16px` / `1.75` | `15px` / `1.75` | 400 (Regular) | `normal` (0) |
| **Small / Meta** | `14px` / `1.6` | `13px` / `1.6` | 500 (Medium) | `0.01em` |
| **Quran Verse** | `22px` / `2.0` (Amiri) | `18px` / `2.0` | 700 (Bold) | `normal` (0) |

---

## 3. Spacing, Radius & Layout Grid

### Spatial Scale
Based on an 8px grid:
- `space-1`: 4px
- `space-2`: 8px
- `space-3`: 12px
- `space-4`: 16px
- `space-5`: 20px
- `space-6`: 24px
- `space-8`: 32px
- `space-10`: 40px
- `space-12`: 48px
- `space-16`: 64px
- `space-20`: 80px

### Border Radius
- `radius-sm`: 8px (badges, buttons, pill tags)
- `radius-md`: 12px (dropdowns, inputs, small cards)
- `radius-lg`: 20px (feature cards, hero containers)
- `radius-xl`: 28px (modals, showcase panels)
- `radius-full`: 9999px (circular actions, pills)

### Responsive Breakpoints
- `mobile`: `< 640px` (single column, full-bleed padding, collapsible drawer)
- `tablet`: `640px – 1024px` (2-column grids, optimized touch targets)
- `desktop`: `1024px – 1280px` (full layout, split hero, multi-column navigation)
- `wide`: `> 1280px` (max container width 1200px, centered with generous margins)

---

## 4. Subtle Islamic Motifs & Geometry

To maintain dignity and avoid visual clichés:
1. **Rub el Hizb (8-Point Star)**: Used strictly as a tiny SVG accent or list marker.
2. **Subtle Arch Geometry**: Card tops use gentle curvature or 1px ornamental dividers.
3. **Kaaba Proportions**: Qibla showcase highlights authentic coordinates (`21.4225° N, 39.8262° E`).
4. **Quranic Border**: The Ayah card uses a delicate warm border (`#E8DFC9`) with central ornamental Ayah end marker `۝`.

---

## 5. Animation & Transitions
- Micro-interactions on buttons: `transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1)`.
- Cards: Gentle elevation `transform: translateY(-2px)` on hover with `box-shadow` depth increase.
- Respects `@media (prefers-reduced-motion: reduce)`: All animations and transitions fall back to instant state changes.
