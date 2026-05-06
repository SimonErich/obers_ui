# Typography

ObersUI ships with a complete type scale — 14 semantic text styles covering everything from hero displays to tiny captions.

## The type scale

| Style | Size | Weight | Use case |
| --- | --- | --- | --- |
| `display` | 56px | Bold | Hero / marketing text |
| `h1` | 40px | Bold | Page titles |
| `h2` | 32px | Semi-bold | Section headers |
| `h3` | 24px | Semi-bold | Subsection headers |
| `h4` | 20px | Semi-bold | Card titles |
| `body` | 16px | Regular | Paragraph text |
| `bodyStrong` | 16px | Semi-bold | Emphasized body text |
| `small` | 14px | Regular | Secondary text |
| `smallStrong` | 14px | Semi-bold | Emphasized small text |
| `tiny` | 12px | Regular | Dense UI elements |
| `caption` | 12px | Regular | Image captions |
| `code` | 14px | Regular | Monospace code |
| `overline` | 11px | Semi-bold | Section labels (ALL CAPS) |
| `link` | 16px | Regular | Hyperlinks (underlined) |

## Using text styles

```dart
Text('Welcome', style: context.textTheme.h1)
Text('Details', style: context.textTheme.body)
Text('Footnote', style: context.textTheme.caption)
```

You can also use the `OiLabelVariant` enum for dynamic style lookup:

```dart
final style = context.textTheme.styleFor(OiLabelVariant.h2);
```

## Custom fonts

Set fonts globally through the theme:

```dart
OiThemeData.light(
  fontFamily: 'Poppins',          // Applied to all styles except code
  monoFontFamily: 'Fira Code',    // Applied to code style only
)
```

## Overriding individual styles

```dart
OiThemeData.light().copyWith(
  textTheme: OiTextTheme.standard(fontFamily: 'Inter').copyWith(
    h1: TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
    ),
  ),
)
```

## The OiLabel widget

For convenience, use the `OiLabel` primitive — it reads the correct style
from the theme automatically. There is a named constructor for every
variant plus two helpers:

```dart
// One named constructor per variant
OiLabel.display('Hero line')
OiLabel.h1('Page title')
OiLabel.h2('Section header')
OiLabel.h3('Subsection header')
OiLabel.h4('Card title')
OiLabel.body('Paragraph text')
OiLabel.bodyStrong('Emphasised body')
OiLabel.small('Secondary text')
OiLabel.smallStrong('Emphasised small')
OiLabel.tiny('Dense UI text')
OiLabel.caption('Image caption')
OiLabel.code('const x = 1;')
OiLabel.overline('SECTION LABEL')
OiLabel.link('Read more')

// Pick a variant at runtime
OiLabel.variant('Dynamic title', variant: OiLabelVariant.h3)

// Select-and-copy support for code / IDs / tokens
OiLabel.copyable('api_key_abc123', variant: OiLabelVariant.code)
```

`OiLabel.copyable` wraps the label in long-press / right-click copy
affordances — use it for values users commonly need to copy (IDs, tokens,
error codes).

## Variant usage guidance

- Use `display` for hero sections or marketing moments.
- Use `h1` for page-level titles, `h2`/`h3` for section headings, and `h4` for card titles.
- Use `body` as default paragraph text and `bodyStrong` only for emphasis inside body copy.
- Use `small`/`smallStrong` for helper and supporting text, and `tiny` only in dense UIs.
- Use `overline` for compact all-caps labels and `caption` for media descriptions.
