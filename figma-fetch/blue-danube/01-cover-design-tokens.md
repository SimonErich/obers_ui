# TapTap Design System - Cover Page Design Tokens
## Source: Figma node 1162:22033

## Color Palette

### Primary Colors (Teal/Cyan)
| Token | Hex | Usage |
|-------|-----|-------|
| Primary 700 | #00ABB6 | Darkest primary, pressed states |
| Primary 600 | #15C5CE | **Main primary** (marked with P) |
| Primary 500 | #47CFD6 | Hover states |
| Primary 400 | #7DDDE1 | Light variant |
| Primary 300 | #B0EBEC | Lighter variant |
| Primary 200 | #DFF7F7 | Very light, backgrounds |
| Primary 100 | #EEFCFC | Subtle backgrounds |
| Primary 50  | #F9FFFF | Lightest tint |

### Neutral Colors (Grey Scale)
| Token | Hex | Usage |
|-------|-----|-------|
| Neutral 700 | #1F1F1F | Darkest text |
| Neutral 600 | #4B4B4B | Primary text (marked with P) |
| Neutral 500 | #8E8E8E | Secondary/muted text |
| Neutral 400 | #CACACA | Disabled text |
| Neutral 300 | #E1E1E1 | Borders, dividers |
| Neutral 200 | #EEEEEE | Light borders |
| Neutral 100 | #F5F5F5 | Light backgrounds |
| Neutral 50  | #FAFAFA | Subtle backgrounds |

### Auxiliary Colors (Orange/Coral)
| Token | Hex | Usage |
|-------|-----|-------|
| Auxiliary 700 | #FE632F | Darkest accent |
| Auxiliary 600 | #FF8156 | **Main accent** (marked with P) |
| Auxiliary 500 | #FFA487 | Hover accent |
| Auxiliary 400 | #FFC8B6 | Light accent |
| Auxiliary 300 | #FFE1D6 | Lighter accent |
| Auxiliary 200 | #FFF2EE | Very light accent |
| Auxiliary 100 | #FFF6F3 | Subtle accent |
| Auxiliary 50  | #FFFCFC | Lightest accent |

### Black & White
| Token | Hex |
|-------|-----|
| Black | #000000 |
| White | #FFFFFF |

### Semantic/Status Colors (from styles output)
| Token | Hex | Usage |
|-------|-----|-------|
| Danger 600 | #F64C4C | Error/destructive |
| Info 600 | #3B82F6 | Informational |
| Success 600 | #47B881 | Success state |
| Warning 600 | #FFAD0D | Warning state |

### Chart Colors
| Token | Hex |
|-------|-----|
| Standard/1 | #4887F6 |
| Standard/3 | #59C3CF |
| Standard/5 | #E2635E |
| Standard/7 | #F1CD49 |

## Typography

### Font Family
- **Primary:** PingFang SC (Regular 400, Medium 500)
- **Mono/Numbers:** Roboto Bold

### Type Scale
| Style | Size | Line Height | Weight |
|-------|------|-------------|--------|
| H1 | 30px | 38px | Regular 400 |
| H2 | 24px | 32px | Regular 400 |
| H3 | 20px | 28px | Regular 400 |
| Title | 18px | 26px | Medium 500 |
| Subtitle | 16px | 24px | Regular 400 / Medium 500 |
| Body | 14px | 22px | Regular 400 |
| Caption | 12px | 18px | Regular 400 |

## Elevation/Shadows
| Level | Shadow 1 | Shadow 2 |
|-------|----------|----------|
| Elevation 1 | 0,1,1,0 @ #000000 2% | 0,2,4,0 @ #000000 4% |
| Elevation 2 | 0,1,4,0 @ #000000 4% | 0,4,10,0 @ #000000 8% |
| Elevation 3 | 0,2,20,0 @ #000000 4% | 0,8,32,0 @ #000000 8% |
| Elevation 4 | 0,8,20,0 @ #000000 6% | 0,24,60,0 @ #000000 12% |

## Button Styles (from cover preview)

### Primary Button
- **Default bg:** #15C5CE (Primary 600)
- **Hover bg:** #47CFD6 (Primary 500)
- **Pressed bg:** #00ABB6 (Primary 700)
- **Disabled bg:** #B0EBEC (Primary 300)
- **Text:** White, PingFang SC Medium 500, 16px/24px
- **Padding:** 8px
- **Border radius:** 4px
- **Min width:** 90px

### Outline Button
- **Default:** White bg, #E1E1E1 border
- **Hover:** White bg, #47CFD6 border, #47CFD6 text
- **Pressed:** White bg, #00ABB6 border, #00ABB6 text
- **Disabled:** White bg, #EEE border, #CACACA text
- **Text:** #4B4B4B (default), variant color (hover/pressed)
- **Border:** 1px solid
- **Border radius:** 4px

### Ghost Button
- **Default:** Transparent bg
- **Hover:** #F5F5F5 bg
- **Pressed:** #E1E1E1 bg
- **Disabled:** Transparent, #CACACA text
- **Text:** #4B4B4B
- **Border radius:** 4px

### Link Button
- **Default:** #15C5CE text
- **Hover:** #47CFD6 text
- **Pressed:** #00ABB6 text
- **Disabled:** #7DDDE1 text
- **No background, no border**

## Dialog/Modal
- **Background:** White
- **Border radius:** not explicit from cover (implied 4px or 8px)
- **Title:** PingFang SC Medium, 18px, #1F1F1F
- **Body:** PingFang SC Regular, 14px/22px, #4B4B4B
- **Close icon:** 14x14px
- **Button grid:** Ghost "Cancel" + Outline "Delete" (with #F64C4C danger color)
- **Padding:** 24px
- **Gap between content and buttons:** 32px

## Message/Toast
- **Background:** White
- **Border radius:** 4px
- **Shadow:** Elevation 3 (0,2,20 @ 4% + 0,8,32 @ 8%)
- **Padding:** 16px horizontal, 8px vertical
- **Icon + text gap:** 8px
- **Text:** PingFang SC Regular, 14px/22px, #4B4B4B

## Background Color
- **Cover/brand background:** #E5FEFF (very light teal)
- **Accent teal block:** #4AD7DE
