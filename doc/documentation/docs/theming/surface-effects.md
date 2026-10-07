# Inner surface shadows

`OiInsetShadow` adds an opt-in inner shadow. Existing surface backgrounds,
outer shadows, borders, clipping, layout, and defaults remain unchanged when
`OiSurface.insetShadows` is null or empty.

```dart
OiSurface(
  color: const Color(0xFF131417),
  borderRadius: BorderRadius.circular(14),
  insetShadows: [
    OiInsetShadow(
      color: const Color(0x0AFFFFFF),
      offset: const Offset(0, 1),
    ),
  ],
  child: content,
)
```

## Geometry and layering

The shadow is the area outside an interior hole, clipped to the surface's
padding-edge shape. The hole follows the rounded, elliptical, or circular
shape and accounts for the authored border dimensions.

- `offset` translates the hole: positive y reveals a top inner edge.
- Positive `spread` contracts the hole; negative spread expands it.
- `blurSigma` is the Gaussian standard deviation in logical pixels, **not a
  CSS blur radius**. Zero is a sharp shadow. A CSS blur radius B has an intended
  standard deviation B/2; backend raster equivalence is a separate concern.
- Insets use front-to-back order: the first entry is painted on top.

The paint order is outer shadows, background/gradient/image, inner shadows,
border, then child. Inner shadows do not cover child content or expand layout
or hit-test bounds. Existing outer `BoxShadow` lists retain Flutter's own paint
order; do not reverse existing lists when adding an inset. If translating a CSS
shadow list, adapt its outer order explicitly at the call site.

Construction immediately rejects nonfinite offsets/spread, nonfinite or
negative sigma, and colors with nonfinite channels or alpha outside 0–1. Raw
extended RGB channels are preserved rather than clipped. `copyWith` and `lerp`
retain this validation in release builds.

## Reusable decoration

Use `OiSurfaceDecoration` wherever a Flutter `Decoration` is accepted. The
supplied `BoxDecoration` remains the source of background, border, shape,
padding, hit testing, and clipping:

```dart
final decoration = OiSurfaceDecoration(
  base: BoxDecoration(
    color: const Color(0xFF131417),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFF323339)),
  ),
  insetShadows: [
    OiInsetShadow(color: const Color(0x0AFFFFFF), offset: const Offset(0, 1)),
  ],
);

DecoratedBox(decoration: decoration, child: content)
```

The constructor defensively snapshots only its inset list and the base
decoration's outer-shadow list. Those retained lists cannot be mutated, and
later edits to the caller's lists cannot change the decoration. Other authored
Flutter values retain `BoxDecoration` input semantics; arbitrary gradient or
image values are not cloned or claimed to be deeply immutable.

Empty insets use the original base painter. Nonempty insets retain the image
painter's asynchronous change notifications and disposal. `DecoratedBox`
manages this lifecycle; manual `BoxPainter` users must provide an `onChanged`
callback for an asynchronous decoration image and dispose the painter.

## Interpolation

Both values support `copyWith`, equality, and interpolation. Exact lerp
endpoints retain their original objects; two null endpoints return null.
Unequal inset lists fade missing entries from transparent zero geometry.
Finite extrapolation is allowed; negative interpolated sigma clamps to zero.

Ordinary inset colors retain `Color.lerp` semantics. If either inset color is
extended sRGB, SDK color-space conversion is followed by straight raw-channel
interpolation without RGB clipping, with alpha clamped to 0–1. A null fade
retains the surviving color's RGB. This is not CSS premultiplied mixing.

The base fields use `BoxDecoration.lerp`, including its discrete shape policy
and native color-interpolation restrictions. Supporting a raw inset color does
not change the SDK's restrictions on interpolating an extended-sRGB base color.

Native background and outer-shadow rendering is deliberately retained. These
APIs do not promise byte-exact CSS/browser rendering: rounded-edge composition,
outer spread geometry, and blur kernels require independent renderer evidence.
