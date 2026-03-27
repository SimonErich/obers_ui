# TapTap Design System - Dialog/Modal
## Source: Figma node 1162:22644

## Modal Component

### Container
- **Background:** White (#FFFFFF)
- **Border radius:** 26px (cover preview) — likely 8px or 12px in actual component
- **Shadow:** 0px 10px 60px rgba(40, 145, 150, 0.2) — teal-tinted shadow
- **Padding:** 24px
- **Overflow:** clip

### Title Section
- **Font:** PingFang SC Medium 500, 18px/26px
- **Color:** #1F1F1F (Neutral 700)
- **Layout:** Row with close button

### Close Button
- **Size:** 14x14px icon
- **Position:** Top right of title row
- **Gap from title:** 8px

### Body Section
- **Font:** PingFang SC Regular 400, 14px/22px
- **Color:** #4B4B4B (Neutral 600)
- **Layout:** Icon (16x16px) + text, 8px gap
- **Gap between title and body:** 16px

### Button Grid
- **Alignment:** Right-aligned (justify-end)
- **Gap between buttons:** 8px
- **Gap above buttons (from content):** 32px

### Button Styles in Dialog
- **Cancel (Ghost):** No background, #4B4B4B text, 4px radius, 8px/7px padding
- **Delete (Outline Danger):** White bg, #F64C4C border and text, 4px radius
- **Both:** 14px/22px text, 82px min-width

## Styles Referenced
- Medium/Title: Font(PingFang SC, Medium, 18px, w500, lh26)
- Regular/Body: Font(PingFang SC, Regular, 14px, w400, lh22)
- Neutral/700: #1F1F1F
- Neutral/600: #4B4B4B
- Neutral/500: #8E8E8E
- Danger/600: #F64C4C
- Warning/600: #FFAD0D
- Neutral/White: #FFFFFF
