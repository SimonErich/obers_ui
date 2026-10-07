# Independent CSS inset-shadow paint references

These four new 100×64 PNGs are literal crops of a parent-owned Chrome capture,
not Flutter-produced goldens. Never regenerate them from the implementation.

Source: Fluvie Studio `design/fluvie_studio/css/0f6f9c9a0abbd2a4.css`, SHA256
`0f6f9c9a0abbd2a4f9e9f4825dd30c2eb27deba26adf86de4eb36a027f9cd520`.
Fixture HTML SHA256:
`4cda09cfac3199c1d94a09e60e6737095c3f6424ed44d162cff7b3b6a871c3e8`.
Google Chrome154.0.8037.57, headless software renderer, DPR1, no fonts or text.
Accepted parent captures pass3/pass4 use fresh browser profiles and have
byte-identical full PNGs and crops. The full pass3 capture was visually reviewed.

Full PNG: 624×256; measured CSS viewport: 624×113. All four surfaces and their
8px surrounding shadow margin fit. Crop y=24, x=24/176/328/480, width=100,
height=64; integer cropping only, no resizing or filtering. Only one set is
persisted here. Pass1/pass2 are rejected because their 41px-high content
viewport clipped the lower surfaces; they are not references.

| File | Independent case | SHA256 |
| --- | --- | --- |
| sharp.png | Black rectangle; inset 0 1px 0 white | 1c3edb5680d977c6c565d150b0325df04f1af06fc69ef443bd139f43e87f2609 |
| border.png | Same inset; solid 2px red border, border-box 100×64 | 01b7998e36ae1723251f2dc1a7bf340716eaf658876c409d35b58d368a5c8df0 |
| dark-calibration.png | Radius14, scalar #131417, original dark --shadow-sheet | 85837c4406c294b2715df50b53d297a349f96eac813aa9494ef2289f16460c50 |
| source-sheet.png | Radius14, original OKLCH --sheet and dark --shadow-sheet | 459686afb2b52786ff111dc65daa4a9695b616dde2f2c86fb56730c71bac8452 |

The source sheet's raw OKLCH background has the same center bytes as the scalar
calibration but different edge pixels. They must not be conflated. The source
shadow list, first on top, is inset 0 1px 0 #ffffff0a, outer white spread1
#ffffff0d, then outer black offsetY1 blur2 #00000066.

Sharp and border references were independently checked across all 6400 pixels.
Rounded/blurred cross-render parity is not implied by reference acceptance.
Compare every raw RGBA pixel with full metrics and diff masks; no tolerance,
alpha masking, edge exclusions, or automatic reference updates are permitted.
Parent capture provenance is retained at `/tmp/studio-f4a-browser-reference/`.
