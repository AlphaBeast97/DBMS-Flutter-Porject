# TechFix Kinetic (Design System)

## Style Guidelines

## Brand & Style

The design system is built on a "Bold-Grounded" philosophy, merging the precision of technical repair with a fresh, approachable retail energy. It targets tech-savvy individuals who value transparency and modern aesthetics.

The visual style is Modern / High-Contrast, characterized by:

- Kinetic Geometry: Large, overlapping circular accent shapes that suggest motion and systemic flow.
- Layered Vibrancy: Utilization of soft, multi-stop gradients within containers to provide depth without resorting to traditional skeuomorphism.
- Human-Centric Tech: A balance of technical typefaces and warm, cream-based backgrounds to ensure the digital experience feels inviting rather than clinical.
- Precision Boldness: Heavy-weight strokes and high-contrast typography to instill confidence in the repair process.

## Layout & Spacing

The layout follows a Fluid Grid model with a mobile-first priority.

- Grid: A 12-column grid on desktop, collapsing to 4 columns on mobile.
- Margins: Generous outer margins ensure the Warm Cream background acts as a framing device for the content cards.
- Rhythm: An 8px linear scale governs all padding and margins. Use Section Gaps (48px) to separate distinct stages of the repair workflow (e.g., Diagnostics vs. Quote).
- Large Shapes: Circular decorative elements (Sky Blue) should be positioned absolutely behind content cards, often bleeding off the edge of the viewport to create a sense of scale.

## Elevation & Depth

Depth is achieved through Tonal Layering and Soft Shadows rather than stark borders.

- Surface Levels: The base is the Warm Cream background. Content sits on elevated white cards.
- Shadows: Use extremely soft, long-range shadows (Blur: 30px, Opacity: 4%) tinted with the Secondary Teal color to create an ambient lift effect.
- Gradients: Use low-opacity gradients (5-10%) on top of white cards to signify active or in-progress states.
- Glassmorphism: Apply a light backdrop blur (8px) to floating navigation bars or sticky headers to maintain context of the underlying geometric shapes.

## Components

- Buttons: Primarily pill-shaped. The Primary button uses the Coral gradient with white text. Secondary uses a Teal outline.
- Status Chips: Small, pill-shaped badges. Use Coral for Action Required, Teal for Ready for Pickup, and Sky Blue for In Progress.
- Repair Cards: Large, white rounded containers with 24px internal padding. Include a Metadata row at the bottom for tracking numbers.
- Input Fields: Soft cream backgrounds (slightly darker than the page background) with 12px rounded corners and a 2px Teal border on focus.
- Progress Steppers: Use thick 4px lines and large circular nodes to represent the repair journey, ensuring the active step uses the Coral glow effect.
- Device Icons: Contained within circular Sky Blue backgrounds to maintain the Kinetic Geometry theme.

## Design MD

---

name: TechFix Kinetic
colors:
surface: '#fbf9f1'
surface-dim: '#dcdad2'
surface-bright: '#fbf9f1'
surface-container-lowest: '#ffffff'
surface-container-low: '#f5f4ec'
surface-container: '#f0eee6'
surface-container-high: '#eae8e0'
surface-container-highest: '#e4e3db'
on-surface: '#1b1c17'
on-surface-variant: '#57423b'
inverse-surface: '#30312c'
inverse-on-surface: '#f3f1e9'
outline: '#8b7169'
outline-variant: '#dec0b6'
surface-tint: '#a43c12'
primary: '#a43c12'
on-primary: '#ffffff'
primary-container: '#ff7f50'
on-primary-container: '#6c2000'
inverse-primary: '#ffb59c'
secondary: '#006a6a'
on-secondary: '#ffffff'
secondary-container: '#90efef'
on-secondary-container: '#006e6e'
tertiary: '#0c6780'
on-tertiary: '#ffffff'
tertiary-container: '#66adc9'
on-tertiary-container: '#003f51'
error: '#ba1a1a'
on-error: '#ffffff'
error-container: '#ffdad6'
on-error-container: '#93000a'
primary-fixed: '#ffdbcf'
primary-fixed-dim: '#ffb59c'
on-primary-fixed: '#380c00'
on-primary-fixed-variant: '#822800'
secondary-fixed: '#93f2f2'
secondary-fixed-dim: '#76d6d5'
on-secondary-fixed: '#002020'
on-secondary-fixed-variant: '#004f4f'
tertiary-fixed: '#baeaff'
tertiary-fixed-dim: '#89d0ed'
on-tertiary-fixed: '#001f29'
on-tertiary-fixed-variant: '#004d62'
background: '#fbf9f1'
on-background: '#1b1c17'
surface-variant: '#e4e3db'
typography:
display-lg:
fontFamily: Space Grotesk
fontSize: 48px
fontWeight: '700'
lineHeight: '1.1'
letterSpacing: -0.02em
display-lg-mobile:
fontFamily: Space Grotesk
fontSize: 36px
fontWeight: '700'
lineHeight: '1.1'
headline-md:
fontFamily: Space Grotesk
fontSize: 24px
fontWeight: '600'
lineHeight: '1.2'
body-base:
fontFamily: Space Grotesk
fontSize: 16px
fontWeight: '400'
lineHeight: '1.5'
metadata-sm:
fontFamily: Space Grotesk
fontSize: 12px
fontWeight: '500'
lineHeight: '1.4'
letterSpacing: 0.01em
button-text:
fontFamily: Space Grotesk
fontSize: 14px
fontWeight: '600'
lineHeight: '1'
rounded:
sm: 0.25rem
DEFAULT: 0.5rem
md: 0.75rem
lg: 1rem
xl: 1.5rem
full: 9999px
spacing:
unit: 8px
container-margin-mobile: 20px
container-margin-desktop: 40px
gutter: 16px
section-gap: 48px

---
