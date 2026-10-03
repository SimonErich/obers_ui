# Media

These widgets show images and video. You get a gallery grid, a full-screen
lightbox, a video player, two image editors (crop and annotate), and two smaller
preview widgets for cards and file thumbnails. They all read their colors and
radius from the theme.

| Widget | What it does |
| --- | --- |
| `OiGallery` | A grid of image thumbnails with optional selection and an upload tile. |
| `OiLightbox` | A full-screen image viewer with navigation, zoom, and thumbnails. |
| `OiVideoPlayer` | A video surface with a poster, play control, and progress bar. |
| `OiImageCropper` | A crop tool with rotate, flip, and aspect ratio presets. |
| `OiImageAnnotator` | A drawing tool for shapes, freehand, arrows, and text on an image. |
| `OiImagePreviewCard` | A single image card with loading, badge, edit, and version states. |
| `OiFilePreview` | A thumbnail for a file, with a type-icon fallback. |

## OiGallery

A grid of images. Reach for it when you show a collection of photos or product
images. Tapping an item fires `onItemTap`, which you can use to open an
`OiLightbox`. Turn on selection to let people pick items.

```dart
OiGallery(
  label: 'Product photos',
  columns: 4,
  items: [
    OiGalleryItem(key: 'a', src: 'https://cdn.app/1.jpg', alt: 'Front view'),
    OiGalleryItem(key: 'b', src: 'https://cdn.app/2.jpg', alt: 'Side view'),
    OiGalleryItem(key: 'c', src: 'https://cdn.app/3.jpg', alt: 'Back view'),
  ],
  onItemTap: (item) => openLightbox(item),
)
```

### Selection and upload

Set `selectionMode` to let people select items. In `single` mode one item is
selected at a time, in `multi` several can be. Turn on `showUpload` to add a `+`
tile at the end.

```dart
OiGallery(
  label: 'Attachments',
  selectionMode: OiSelectionMode.multi,
  selectedKeys: _selected,
  onSelectionChange: (keys) => setState(() => _selected = keys),
  showUpload: true,
  onUpload: (files) => pickFiles(),
  items: items,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiGalleryItem>` | **required** | The grid items. Each has `key`, `src`, `alt`, `thumbnailUrl`. |
| `label` | `String` | **required** | Gallery accessibility label. |
| `columns` | `int` | `4` | Number of grid columns. |
| `selectionMode` | `OiSelectionMode` | `none` | `none`, `single`, or `multi`. |
| `selectedKeys` | `Set<Object>` | `{}` | The keys of the selected items. |
| `onSelectionChange` | `ValueChanged<Set<Object>>?` | `null` | Fires with the new selection. |
| `onItemTap` | `ValueChanged<OiGalleryItem>?` | `null` | Fires whenever an item is tapped. |
| `showUpload` | `bool` | `false` | Show a `+` upload tile at the end. |
| `onUpload` | `ValueChanged<List<Object>>?` | `null` | Fires when the upload tile is tapped. |
| `gap` | `double` | `8` | Gap in logical pixels between cells. |

!!! tip
    Set `thumbnailUrl` on each item to load small images in the grid and full
    images only in the lightbox. It keeps the grid fast.

## OiLightbox

A full-screen image viewer. You open it over your page, usually from an
`OiGallery` tap. It supports keyboard arrows, swipe, pinch-to-zoom, a thumbnail
strip, and captions. It does not manage its own overlay, so you render it inside
your own full-screen surface and close it in `onDismiss`.

```dart
OiLightbox(
  label: 'Photo viewer',
  initialIndex: 0,
  onDismiss: () => closeViewer(),
  items: [
    OiLightboxItem(src: 'https://cdn.app/1.jpg', alt: 'Front', caption: 'Front view'),
    OiLightboxItem(src: 'https://cdn.app/2.jpg', alt: 'Side', caption: 'Side view'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `List<OiLightboxItem>` | **required** | The images. Each has `src`, `alt`, `caption`. |
| `initialIndex` | `int` | **required** | The image shown first. |
| `label` | `String` | **required** | Viewer accessibility label. |
| `onDismiss` | `VoidCallback?` | `null` | Fires on close button, background tap, or Escape. |
| `showThumbnails` | `bool` | `true` | Show the thumbnail strip at the bottom. |
| `enableZoom` | `bool` | `true` | Allow pinch-to-zoom on the image. |
| `enableSwipe` | `bool` | `true` | Allow horizontal swipe between images. |

!!! note
    The thumbnail strip only appears when there is more than one item.

## OiVideoPlayer

A video surface. On web, tapping play embeds a native HTML video element. On
other platforms it shows the poster with a play button and fires `onPlay` and
`onPause`, so you can wire up your own player. Give it a `posterUrl` for a still
frame before playback starts.

```dart
OiVideoPlayer(
  label: 'Product demo',
  src: 'https://cdn.app/demo.mp4',
  posterUrl: 'https://cdn.app/demo-poster.jpg',
  onPlay: () => trackPlay(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `src` | `String` | **required** | The video source URL. |
| `label` | `String` | **required** | Player accessibility label. |
| `autoPlay` | `bool` | `false` | Start playing on load. |
| `loop` | `bool` | `false` | Restart when the video ends. |
| `showControls` | `bool` | `true` | Show the play control and progress bar. |
| `aspectRatio` | `double?` | `null` | Width over height. Defaults to 16:9. |
| `posterUrl` | `String?` | `null` | A still image shown before playback. |
| `onPlay` | `VoidCallback?` | `null` | Fires when playback starts or resumes. |
| `onPause` | `VoidCallback?` | `null` | Fires when playback pauses. |

## OiImageCropper

A crop tool. It shows the image with a draggable crop area, plus toolbar buttons
to rotate in 90-degree steps and flip. When the user confirms, `onCrop` fires
with an `OiCropResult` that holds the normalized crop rectangle, rotation, and
flip flags. You apply that result to the real image yourself.

```dart
OiImageCropper(
  label: 'Crop avatar',
  image: NetworkImage('https://cdn.app/avatar.jpg'),
  aspectRatio: 1,
  onCrop: (result) => applyCrop(result),
)
```

Pass `aspectRatioOptions` to show preset buttons the user can pick from.

```dart
OiImageCropper(
  label: 'Crop banner',
  image: NetworkImage('https://cdn.app/banner.jpg'),
  aspectRatioOptions: [1, 16 / 9, 4 / 3],
  onCrop: (result) => applyCrop(result),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `ImageProvider` | **required** | The image to crop. |
| `label` | `String` | **required** | Cropper accessibility label. |
| `onCrop` | `ValueChanged<OiCropResult>?` | `null` | Fires with the crop rectangle, rotation, and flips. |
| `aspectRatio` | `double?` | `null` | Lock the crop to this width over height. |
| `aspectRatioOptions` | `List<double>?` | `null` | Preset ratios shown as toolbar buttons. |
| `enableRotate` | `bool` | `true` | Show the rotate button. |
| `enableFlip` | `bool` | `true` | Show the flip buttons. |

!!! note
    `OiCropResult.rect` is normalized to 0 to 1 and `rotation` is in radians. The
    widget reports the crop. It does not produce a new image file for you.

## OiImageAnnotator

A drawing tool for marking up an image. People draw freehand strokes,
rectangles, circles, arrows, and text. You own the `annotations` list and update
it in `onAnnotationsChange`. This makes it a good fit for screenshot feedback and
review flows.

```dart
List<OiAnnotation> _marks = [];
OiAnnotationType _tool = OiAnnotationType.arrow;

OiImageAnnotator(
  label: 'Annotate screenshot',
  image: NetworkImage('https://cdn.app/screenshot.png'),
  annotations: _marks,
  selectedTool: _tool,
  onToolChange: (tool) => setState(() => _tool = tool),
  onAnnotationsChange: (marks) => setState(() => _marks = marks),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `ImageProvider` | **required** | The image to draw on. |
| `label` | `String` | **required** | Annotator accessibility label. |
| `annotations` | `List<OiAnnotation>` | `[]` | The current annotations. |
| `onAnnotationsChange` | `ValueChanged<List<OiAnnotation>>?` | `null` | Fires when an annotation is added. |
| `selectedTool` | `OiAnnotationType` | `freehand` | `freehand`, `rectangle`, `circle`, `arrow`, or `text`. |
| `onToolChange` | `ValueChanged<OiAnnotationType>?` | `null` | Fires when the user picks a tool. |
| `strokeColor` | `Color?` | `null` | Stroke color. Defaults to the primary color. |
| `strokeWidth` | `double` | `2.0` | Stroke width for new annotations. |
| `readOnly` | `bool` | `false` | Hide the toolbar and block drawing. |

!!! tip
    Set `readOnly: true` to show existing annotations without letting anyone edit
    them, for example in a resolved review.

## OiImagePreviewCard

A single image card with states for real work: a shimmer while loading, a pulse
while regenerating, a status badge, a version label, and an edit icon on hover.
It fits design and wireframe previews where an image has a status. It requires
`alt` for accessibility.

```dart
OiImagePreviewCard(
  alt: 'Landing page mockup',
  imageUrl: 'https://cdn.app/mockup.png',
  aspectRatio: 16 / 9,
  versionLabel: 'v3',
  statusBadge: OiBadge.soft(label: 'Draft'),
  onEdit: () => editImage(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alt` | `String` | **required** | Accessibility description of the image. |
| `imageUrl` | `String?` | `null` | The image URL. Null shows a shimmer placeholder. |
| `statusBadge` | `Widget?` | `null` | A widget pinned to the top-right, usually an `OiBadge`. |
| `onTap` | `VoidCallback?` | `null` | Fires when the card is tapped. |
| `onEdit` | `VoidCallback?` | `null` | Shows an edit overlay on hover and fires on tap. |
| `loading` | `bool` | `false` | Force the shimmer placeholder. |
| `regenerating` | `bool` | `false` | Pulse a shimmer over the existing image. |
| `enableZoom` | `bool` | `false` | Wrap the image in pinch-to-zoom. |
| `versionLabel` | `String?` | `null` | A small label in the bottom-right, for example `v3`. |
| `aspectRatio` | `double?` | `null` | Wrap the card in a fixed width over height. |
| `placeholder` | `Widget?` | `null` | A custom widget shown instead of the shimmer. |

## OiFilePreview

A thumbnail for a file. It shows a real image for image and video files, and
falls back to a type icon for everything else. Give it an `OiFileNodeData`. It is
the tile you use inside file lists and explorers.

```dart
OiFilePreview(
  file: OiFileNodeData(
    id: 'f1',
    name: 'diagram.png',
    folder: false,
    url: 'https://cdn.app/diagram.png',
  ),
  width: 64,
  height: 64,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `OiFileNodeData` | **required** | The file to preview. |
| `width` | `double?` | `null` | Preview width. |
| `height` | `double?` | `null` | Preview height. |
| `fit` | `BoxFit` | `cover` | How the image fits its bounds. |
| `showPlayButton` | `bool` | `true` | Show a play badge on video files. |
| `loading` | `bool` | `false` | Show a shimmer placeholder. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. Defaults to `"<name> preview"`. |

!!! note
    `OiFilePreview` reads `thumbnailUrl` first, then `url`. Set `thumbnailUrl` on
    large files so the list does not download full images.

## Related

- [Display](display.md) for `OiImage`, `OiAvatar`, and other display widgets.
- [File Explorer](../modules/files.md) for the file manager that uses `OiFilePreview`.
- [Overlays & Menus](overlays.md) for the surface you render `OiLightbox` inside.
