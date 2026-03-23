# WinFlowz Brand Identity Specification

This document serves as the definitive guide to the WinFlowz brand identity, capturing all visual, typographic, and interactive elements that define the brand experience.

---

## Table of Contents

1. [Brand Overview](#brand-overview)
2. [Logo System](#logo-system)
3. [Color Palette](#color-palette)
4. [Typography](#typography)
5. [Iconography & Visual Elements](#iconography--visual-elements)
6. [Animation & Motion](#animation--motion)
7. [Component Styles](#component-styles)
8. [Theme System (Light/Dark)](#theme-system-lightdark)
9. [Internationalization](#internationalization)
10. [Asset Inventory](#asset-inventory)

---

## Brand Overview

### Brand Name
**WinFlowz**

### Brand Tagline
"Optimize your Windows workflow"

### Brand Description
WinFlowz is a Windows toolkit designed to optimize daily workflow. The brand offers productivity tools and training for Windows workflows, targeting entrepreneurs, freelancers, and professionals.

### Site Information
- **URL**: https://winflowz.com
- **GitHub**: https://github.com/winflowz

### SEO Meta
- **Title**: WinFlowz - Optimize your Windows workflow
- **Description**: WinFlowz is a Windows toolkit designed to optimize your daily workflow.
- **OG Title**: WinFlowz: Software & Courses
- **OG Description**: Equip your projects with WinFlowz's top-quality software and courses. Trusted by industry leaders, WinFlowz offers simplicity, affordability, and reliability.

---

## Logo System

### Primary Logo (SVG Text-Based)

The primary logo uses an SVG text rendering of "WinFlowz" with sophisticated gradient and filter effects.

#### Logo Colors
```
Primary Gradient (editing-shiny-gradient):
- Start: #ffb200 (Gold/Orange)
- Middle (50%): #e10057 (Magenta/Pink)
- End: #5A1A80 (Deep Purple)
```

#### Logo Effects
- **Gradient Fill**: Three-color linear gradient (gold → magenta → purple)
- **Shiny Filter**: Complex SVG filter with:
  - Flood fill (#ffffff)
  - Convolution matrix for texture
  - Offset for depth
  - Gaussian blur for shadow
  - Color matrix for dark shadow
  - Edge shadow effects
  - Merged layers for final composition

### Text Logo (CSS-Based)

An alternative animated logo using CSS for enhanced interactivity.

#### Text Logo Properties
- **Font Family**: `Audiowide`
- **Font Weight**: Bold
- **Base Font Size**:
  - Desktop: `2.5rem`
  - Tablet (max-width 640px): `2rem`
  - Mobile (max-width 480px): `1.5rem`

#### Rainbow Gradient (Signature Effect)
```css
background-image: linear-gradient(
  45deg,
  #ff0033,   /* Red */
  #ff00c8,   /* Magenta */
  #ffe500,   /* Yellow */
  #00ff44,   /* Green */
  #00c8ff,   /* Cyan */
  #ff0033    /* Red (loop) */
);
```

#### Secondary Radial Gradient
```css
radial-gradient(
  circle at top left,
  #ff0033,   /* Red */
  #ff3366,   /* Coral */
  #ff00c8,   /* Magenta */
  #ff33cc,   /* Pink */
  #ffe500,   /* Yellow */
  #ffcc00,   /* Gold */
  #00ff44,   /* Green */
  #00cc44,   /* Forest Green */
  #00c8ff,   /* Cyan */
  #0099ff,   /* Sky Blue */
  #ff0033    /* Red (loop) */
);
```

#### Interactive Effects
- **3D Parallax**: Mouse-following perspective transformation
  - Max rotation: ±12 degrees
  - Perspective: 1000px
  - Transition: 0.5s cubic-bezier(0.23, 1, 0.32, 1)
- **Text Layering**:
  - Foreground: Gradient text with background-clip
  - Middle layer: White text shadow for depth
  - Background: Blur glow effect
- **Hover States**:
  - Increased glow opacity (0.45)
  - Enhanced blur (15px)
  - Faster animation (4s)
  - Deeper shadow

---

## Color Palette

### Primary Rainbow Spectrum (BRAND COLORS)

These are the ONLY colors used for branding, taken directly from the logo. All accents, highlights, and interactive elements use these colors.

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Red | `#ff0033` | rgb(255, 0, 51) | Primary accent, gradient start, CTAs |
| Magenta | `#ff00c8` | rgb(255, 0, 200) | Primary UI accent, links, highlights |
| Yellow | `#ffe500` | rgb(255, 229, 0) | Secondary accent, hover states |
| Green | `#00ff44` | rgb(0, 255, 68) | Tertiary accent, success indicators |
| Cyan | `#00c8ff` | rgb(0, 200, 255) | Quaternary accent, info states |

### Neutral Colors

Used ONLY for backgrounds, text, borders, and structural elements:
- **Grays**: Tailwind gray scale (for general UI)
- **Neutrals**: Tailwind neutral scale (for text and backgrounds)
- **Zinc**: Tailwind zinc scale (for subtle shadows only)

**NO orange, blue, indigo, or other colors are used in the brand.**

---

## Typography

### Primary Font: Audiowide

**Font File**: `/public/fonts/Audiowide-Regular.woff2`

**CSS Declaration**:
```css
@font-face {
  font-family: 'Audiowide';
  src: url('/fonts/Audiowide-Regular.woff2') format('woff2');
  font-weight: normal;
  font-style: normal;
  font-display: swap;
}
```

**Usage**: Logo, Brand Text, Hero Headlines (optional)

### System Fonts (Body)

Uses Tailwind CSS default system font stack for optimal performance and native feel.

### Typography Scale

| Element | Mobile | Tablet | Desktop | CSS Classes |
|---------|--------|--------|---------|-------------|
| Hero H1 | 24px | 30px | 60px | `text-2xl sm:text-3xl md:text-5xl lg:text-6xl` |
| Section H2 | 20px | 24px | 30px | `text-xl sm:text-2xl md:text-3xl` |
| Card H3 | 18px | 20px | 24px | `text-lg sm:text-xl md:text-2xl` |
| Body | 16px | 18px | 18px | `text-base sm:text-lg` |
| Small | 14px | 14px | 16px | `text-sm sm:text-base` |
| Caption | 12px | 12px | 14px | `text-xs sm:text-sm` |

### Font Weights
- **Regular**: 400 (body text)
- **Medium**: 500 (emphasis)
- **Bold**: 700 (headings, CTAs)

### Line Heights
- **Headings**: `leading-tight` (1.25)
- **Body**: `leading-relaxed` (1.625)
- **Buttons**: `line-height: 1.1875`

---

## Iconography & Visual Elements

### Icon Sources
- **Astro Starlight Icons**: Used via `@astrojs/starlight/components`
- **Custom SVG Icons**: Located in `src/components/ui/icons/`

### Decorative Elements

#### Hero Section Gradient Blur
```css
background: linear-gradient(to right, #44BCFF, #FF44EC, #FF675E);
opacity: 0.30;
filter: blur(24px); /* Tailwind's blur-lg equivalent */
```

#### Page Background (Starlight)
```css
background: 
  linear-gradient(215deg, var(--overlay-yellow), transparent 40%),
  radial-gradient(var(--overlay-yellow), transparent 40%) no-repeat center center / cover,
  radial-gradient(var(--overlay-yellow), transparent 65%) no-repeat center center / cover;
background-blend-mode: overlay;
```

### Logo Assets
| File | Location | Purpose |
|------|----------|---------|
| `WinFlowz.png` | `/public/WinFlowz.png` | OG Image, Social sharing |
| `WinFlowz.png` | `/public/images/WinFlowz.png` | Alternative location |
| `WinFlowz.png` | `/src/images/WinFlowz.png` | Source image |
| `banner-pattern.svg` | `/public/banner-pattern.svg` | Decorative pattern |

---

## Animation & Motion

### Link Hover Animation (Rainbow Underline)

```css
a::before, a::after {
  background-image: linear-gradient(90deg, 
    #ff0033ff,   /* Red */
    #ff00c8ff,   /* Magenta */
    #ffe500ff,   /* Yellow */
    #00ff44ff,   /* Green */
    #00c8ffff,   /* Cyan */
    #ff0033ff    /* Red (loop) */
  );
  height: 3px;
}

a::before {
  width: 0%;
  transition: width 0.3s ease-in-out;
}

a:hover::before {
  width: 100%;
}

@keyframes gradient-animation {
  0% { background-position: 0% 100%; }
  100% { background-position: 200% 100%; }
}
```

### Logo Gradient Animation

```css
@keyframes gradient {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

/* Duration: 6s (normal), 4s (hover) */
animation: gradient 6s ease infinite;
```

### Glow Pulse Animation

```css
@keyframes pulseGlow {
  0%, 100% {
    transform: scale(1) translateZ(-10px);
    filter: blur(12px);
    border-radius: 45% / 100%;
  }
  50% {
    transform: scale(1.1) translateZ(-10px);
    filter: blur(14px);
    border-radius: 35% / 100%;
  }
}
```

### Transition Defaults
- **Standard**: `transition duration-300`
- **Smooth**: `transition-all duration-200`
- **Complex**: `transition 0.5s cubic-bezier(0.23, 1, 0.32, 1)`

### Smooth Scrolling
```css
html {
  scroll-behavior: smooth;
}
```
Uses Lenis library for enhanced smooth scrolling (`src/assets/styles/lenis.css`).

---

## Component Styles

### Navbar

```css
/* Container */
border-radius: rounded-[36px] (desktop), rounded-[28px] (mobile);
background: bg-white/60 (light), bg-neutral-800/80 (dark);
backdrop-filter: blur(md);
border: 1px solid neutral-200/60 (light), neutral-700/40 (dark);
shadow: shadow-sm (light), shadow-none (dark);

/* Positioning */
position: sticky;
top: 1rem (sm:top-4);
z-index: 50;
```

### Buttons

#### Primary CTA
```css
background: bg-gray-900;
hover: bg-magenta, bg-gradient-rainbow;
color: white;
border-radius: rounded-xl;
padding: px-6 py-2.5 (mobile), px-8 py-3 (desktop);
font-weight: bold;
border: 2px transparent;
transition: all 200ms;
```

#### Secondary CTA
```css
background: bg-neutral-100 (light), bg-zinc-700 (dark);
border: 2px solid gray-400;
hover: bg-magenta, border-magenta;
border-radius: rounded-xl;
padding: px-4 py-2.5 (mobile), px-6 py-3 (desktop);
font-weight: bold;
```

#### Starlight Action Buttons
```css
/* Primary variant */
.action.primary {
  background: var(--sl-color-text-accent);
  color: var(--sl-color-black);
  border-radius: 999rem;
  padding: 0.5rem 1.125rem (mobile), 1rem 1.25rem (desktop);
}

/* Secondary variant */
.action.secondary {
  background: var(--sl-color-black);
  border: 2px solid currentColor;
}
```

### Cards

#### Starlight Asides
```css
/* Tip */
.starlight-aside--tip {
  background: linear-gradient(45deg, #ff00c8, #ffe500);
  color: #2d2d2d;
  border-radius: 0.5rem;
}

/* Note */
.starlight-aside--note {
  background: linear-gradient(45deg, #00c8ff, #00ff44);
  color: #1a1a1a;
  border-radius: 0.5rem;
}
```

### Scrollbar Styling

```css
/* WebKit Browsers */
::-webkit-scrollbar { width: 12px; }
::-webkit-scrollbar-track { background: #ffffff (light), #272727 (dark); }
::-webkit-scrollbar-thumb {
  background: var(--sl-color-accent, #ffcfaa);
  border: 3px solid #ffffff (light), #272727 (dark);
  border-radius: 9999px;
}

/* Firefox */
scrollbar-width: thin;
/* Light mode: accent color on white track */
scrollbar-color: var(--sl-color-accent, #ffcfaa) #ffffff;
/* Dark mode (applied via html.dark): accent color on gray track */
/* html.dark { scrollbar-color: var(--sl-color-accent, #ffcfaa) var(--sl-color-gray-6, #272727); } */
```

---

## Theme System (Light/Dark)

### Dark Mode Configuration
```javascript
// tailwind.config.mjs
darkMode: ['class', '[data-theme="dark"]']
```

### Theme Toggle Implementation
- Uses Preline UI's `hs-dark-mode` system
- Toggle buttons with sun (light) and moon (dark) icons
- Transition: 300ms duration

### CSS Variables Approach
The Starlight theme uses CSS custom properties for seamless theme switching:
- `:root` / `:root[data-theme="dark"]` for dark mode
- `:root[data-theme="light"]` for light mode
- `.dark` class as fallback

---

## Internationalization

### Supported Languages
- **English (en)**: Default locale
- **French (fr)**: Secondary locale

### URL Structure
- English: `/`, `/products`, `/about`, etc.
- French: `/fr`, `/fr/produits`, `/fr/a-propos`, etc.

### Route Translations
```javascript
// English routes
'products', 'about', 'contact', 'blog', 'roadmap', 'services',
'privacy', 'terms', 'disclaimer', 'copyright', 'legal'

// French routes
'produits', 'a-propos', 'contact', 'blog', 'roadmap', 'services',
'confidentialite', 'conditions-utilisation', 'avertissement',
'droits-auteur', 'mentions-legales'
```

### Translation Files
- `/src/i18n/en/` - English translations
- `/src/i18n/fr/` - French translations

---

## Asset Inventory

### Fonts
| File | Format | Location |
|------|--------|----------|
| Audiowide-Regular.woff2 | WOFF2 | `/public/fonts/` |

### Images
| File | Location | Purpose |
|------|----------|---------|
| WinFlowz.png | `/public/`, `/public/images/`, `/src/images/` | Logo, OG image |
| banner-pattern.svg | `/public/` | Decorative pattern |
| houston_love.png | `/src/assets/` | Mascot/character |
| exploding-head-much-work.gif | `/public/images/` | Animated reaction |
| hacker-pc.gif | `/public/images/` | Animated illustration |

### Style Files
| File | Location | Purpose |
|------|----------|---------|
| global.css | `/src/assets/styles/` | Global styles, scrollbar |
| starlight.css | `/src/assets/styles/` | Starlight theme overrides |
| lenis.css | `/src/assets/styles/` | Smooth scroll library |

### Component Files (Brand-Related)
| File | Location | Purpose |
|------|----------|---------|
| BrandLogo.astro | `/src/components/` | SVG logo component |
| TextLogo.astro | `/src/components/ui/` | Animated text logo |
| Button.astro | `/src/components/` | Starlight button styles |
| PrimaryCTA.astro | `/src/components/ui/buttons/` | Primary call-to-action |
| SecondaryCTA.astro | `/src/components/ui/buttons/` | Secondary call-to-action |
| ThemeIcon.astro | `/src/components/` | Theme toggle icons |
| ThemePicker.astro | `/src/components/ui/` | Theme selection dropdown |
| LanguagePicker.astro | `/src/components/ui/` | Language selection |

---

## Quick Reference

### Key Brand Colors
```
Rainbow Gradient (ONLY COLORS USED):
Red:     #ff0033
Magenta: #ff00c8
Yellow:  #ffe500
Green:   #00ff44
Cyan:    #00c8ff

Gradient: linear-gradient(45deg, #ff0033, #ff00c8, #ffe500, #00ff44, #00c8ff, #ff0033)
```

### Key Measurements
```
Navbar radius: 36px (desktop), 28px (mobile)
Button radius: rounded-xl (1rem)
Card radius: 0.5rem
Max content width: 85rem
Full width container: 2xl:max-w-screen-2xl
```

### Key Transitions
```
Standard: 300ms
Smooth: 200ms
Complex: 500ms cubic-bezier(0.23, 1, 0.32, 1)
Gradient animation: 6s (normal), 4s (hover)
```

---

*Last Updated: January 10, 2026*
*Source Repository: dianedef/winflowz*
