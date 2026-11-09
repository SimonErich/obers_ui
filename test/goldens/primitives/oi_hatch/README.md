# OiHatch browser reference pixels

These18 new fixtures are independent browser pixels, not snapshots blessed
from Flutter output. Eighteen cases in the50-case public primitive suite compare
every80×24 straight-RGBA pixel, including transparent RGB/alpha, without resizing,
masking, tolerance or excluded edges. Existing placeholder goldens are unchanged.

`reference.json` pins every PNG and decoded RGBA SHA-256. Its provenance SHA is
`127e194592abac93a0c5ad35ee15e16726c07b04f123461eedfa61208ade021f`.
The source is the extracted Fluvie studio CSS SHA
`b1ba6b0c905b1e6938502a969ee7ed22023313ef52e5db0e3ee61e9dd389ce1f`:
135-degree repeating gradient,1px stripe,5px default perpendicular pitch.

## What each case establishes

Opaque and transparent ink/backing are each sampled with pitches3,4,5 and
phases0,.375,−.5. Six phase0 cases use the unchanged source hatch class with
explicit pitch/color variables. Pitch5 is the original default;3/4 are authored
overrides. The12 nonzero-phase cases use a continued gradient with translated
color stops. They do **not** prove the original CSS background-position tile
animation, its900ms timing, or application motion adoption.

Chrome154.0.8037.57 headless software, DPR1, produced two fresh-profile PNGs
that are byte-identical. The requested screenshot is320×400; the actual browser
viewport is500×257. All18 measured80×24 boxes fit both the viewport and image.
Each fixture is the literal integer rectangle from that measured frame, with
no interpolation or extra crop. Original whole-frame SHA:
`c35e9e0228c9a83143c5e5f1bd842b228d6359ebf942535bfaa4527d3a758263`.
The exact capture HTML SHA is
`c57a951724a86cb8912bd04dd965cff8fc77bef17bf7b8ae4d7a9ff15ae8b936`.

The additional2×1 local-span test compares its same-origin pixels with the
first two pixels of these frozen references. It is a branch regression, not a
new independently captured browser-size oracle. Huge finite pitches/negative
phases use explicit public pixel-center or uniform-color expectations. Tiny
pitches prove no unauthored opaque alpha/error/frame loop, not universal
subpixel averaging or exact continuous geometry below representable precision.

## Preservation

The package test needs only these portable fixtures; it has no absolute sibling
source path, live browser dependency or automatic update mode. Recreating the
external reference requires the exact original CSS, capture fixture, browser
version/DPR, measured DOM rectangles and two fresh profiles. Retain those
inputs/results as a new reviewed provenance checkpoint if a browser changes.
Do not use Flutter output, a weaker tolerance or a changed alpha policy to
overwrite these independent originals. Component evidence does not certify
whole-platform, whole-application or Studio background-tile pixel parity.
