# TapTap Design System - Slider
## Source: Figma nodes 11:1935 (Slider variants frame), 11:1936, 11:1954, 11:1995

## Slider Component

### Track
- **Inactive track:** #EEEEEE (Neutral 200)
- **Active track:** #47CFD6 (Primary 500)
- **Track height:** 4px
- **Track border radius:** 10px (pill)

### Thumb
- **Size:** 12x12px
- **Shape:** Circle (ellipse)
- **Color:** White (#FFFFFF) with #15C5CE (Primary 600) border/stroke
- **Border:** Primary 600 stroke around white fill

### Disabled State
- **Inactive track:** #EEEEEE (same)
- **Active track:** greyed out
- **Thumb:** greyed out / lower opacity

### Tooltip
- **Background:** Black (#000000) at 80% opacity
- **Text:** White, PingFang SC Regular 400, 14px/22px
- **Padding:** 8px
- **Border radius:** 4px
- **Shadow:** Elevation 2 (0,1,4 @ 4% + 0,4,10 @ 8%)
- **Arrow:** 5x5px rotated square, same black bg
- **Gap between tooltip and thumb:** 8px

### Marks/Labels
- **Mark line:** 2px wide, 8px tall, #EEEEEE (Neutral 200)
- **Mark text:** PingFang SC Regular 400, 12px/18px, #CACACA (Neutral 400)
- **Mark position:** Below track

### Variants Available
| Type | Disable | Tooltips | Marks |
|------|---------|----------|-------|
| Single | false | false | false |
| Double | false | false | false |
| Single | true | false | false |
| Double | true | false | false |
| Single | false | true | false |
| Double | false | true | false |
| Single | false | false | true |
| Double | false | false | true |
