# TapTap Design System - Toast/Message
## Source: Figma node 1162:22588 (Info variant)

## Message/Toast Component

### Container
- **Background:** White (#FFFFFF)
- **Border radius:** 4px
- **Shadow:** Elevation 3
  - Shadow 1: 0px 2px 20px rgba(0,0,0,0.04)
  - Shadow 2: 0px 8px 32px rgba(0,0,0,0.08)
- **Padding:** 16px horizontal, 8px vertical

### Content Layout
- **Direction:** Row (horizontal)
- **Gap:** 8px between icon and text
- **Alignment:** Center

### Icon
- **Size:** 18x18px (Info, Success, Error) or 20x20px (Warning)
- **Type:** Filled icon with color matching status

### Text
- **Font:** PingFang SC Regular 400, 14px/22px
- **Color:** #4B4B4B (Neutral 600)

### Status Variants
| Status | Icon Color | Example Text |
|--------|-----------|-------------|
| Info | #3B82F6 (Info 600) | "This is a normal message" |
| Success | Green (Success) | "This is a success message" |
| Error | Red (Error) | "This is an error message" |
| Warning | #FFAD0D (Warning) | "This is a warning message" |

## Styles Referenced
- Info/600: #3B82F6
- Regular/Body: Font(PingFang SC, Regular, 14px, w400, lh22)
- Neutral/600: #4B4B4B
- White: #FFFFFF
- Elevation/3: dual shadow
