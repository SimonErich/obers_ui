import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for editor and media widgets.
class EditorsMediaScreen extends StatefulWidget {
  const EditorsMediaScreen({super.key});

  @override
  State<EditorsMediaScreen> createState() => _EditorsMediaScreenState();
}

class _EditorsMediaScreenState extends State<EditorsMediaScreen> {
  late final OiRichEditorController _editorController;

  @override
  void initState() {
    super.initState();
    _editorController = OiRichEditorController();
  }

  @override
  void dispose() {
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiRichEditor ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Rich Editor',
            widgetName: 'OiRichEditor',
            description:
                'A block-based rich text editor with toolbar and slash '
                'commands. Supports headings, bold/italic/underline, '
                'lists, code blocks, quotes, and @mentions.',
            examples: [
              ComponentExample(
                title: 'Rich text editor',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    height: 300,
                    child: OiRichEditor(
                      controller: _editorController,
                      label: 'Rich editor',
                      placeholder: 'Start typing or use / for commands...',
                      onChange: (_) {},
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiSmartInput ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Smart Input',
            widgetName: 'OiSmartInput',
            description:
                'A text input that recognizes patterns inline such as '
                '@mentions, #tags, :emoji:, URLs, and dates. Each '
                'pattern gets distinct styling and can trigger suggestions.',
            examples: [
              ComponentExample(
                title: 'Pattern-aware input',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: OiSmartInput(
                    label: 'Smart input',
                    placeholder: 'Try typing @ or # ...',
                    recognizers: [
                      OiPatternRecognizer(
                        trigger: '@',
                        pattern: RegExp(r'@\w+'),
                        style: TextStyle(color: colors.primary.base),
                      ),
                      OiPatternRecognizer(
                        trigger: '#',
                        pattern: RegExp(r'#\w+'),
                        style: TextStyle(color: colors.success.base),
                      ),
                    ],
                    onChange: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiGallery ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Gallery',
            widgetName: 'OiGallery',
            description:
                'An image/media gallery grid with selection and lightbox '
                'preview. Supports single and multi-select modes, upload '
                'action, and configurable column count.',
            examples: [
              ComponentExample(
                title: 'Image gallery',
                child: OiGallery(
                  label: 'Photo gallery',
                  items: const [
                    OiGalleryItem(
                      key: 'photo-1',
                      src: 'https://picsum.photos/seed/a/400/300',
                      alt: 'Sample photo 1',
                    ),
                    OiGalleryItem(
                      key: 'photo-2',
                      src: 'https://picsum.photos/seed/b/400/300',
                      alt: 'Sample photo 2',
                    ),
                    OiGalleryItem(
                      key: 'photo-3',
                      src: 'https://picsum.photos/seed/c/400/300',
                      alt: 'Sample photo 3',
                    ),
                    OiGalleryItem(
                      key: 'photo-4',
                      src: 'https://picsum.photos/seed/d/400/300',
                      alt: 'Sample photo 4',
                    ),
                  ],
                  columns: 2,
                  onItemTap: (_) {},
                ),
              ),
            ],
          ),

          // ── OiLightbox ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Lightbox',
            widgetName: 'OiLightbox',
            description:
                'A full-screen image viewer overlay with swipe navigation, '
                'pinch-to-zoom, and optional thumbnail strip. Typically '
                'opened from an OiGallery item tap.',
            examples: [
              ComponentExample(
                title: 'Usage',
                child: OiLabel.body(
                  'OiLightbox(items: [...], initialIndex: 0, label: "Lightbox") '
                  '— opens as a full-screen overlay. Required parameters: '
                  'items (List<OiLightboxItem>), initialIndex (int), '
                  'label (String). Optional: onDismiss, showThumbnails, '
                  'enableZoom, enableSwipe.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiImageCropper ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Image Cropper',
            widgetName: 'OiImageCropper',
            description:
                'An interactive image cropping tool with aspect ratio '
                'presets, rotation, and flip controls.',
            examples: [
              ComponentExample(
                title: 'Usage',
                child: OiLabel.body(
                  'OiImageCropper(image: ImageProvider, label: "Crop image") '
                  '— renders a crop interface with drag handles. Required '
                  'parameters: image (ImageProvider), label (String). '
                  'Optional: onCrop, aspectRatio, aspectRatioOptions, '
                  'enableRotate, enableFlip.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiImageAnnotator ────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Image Annotator',
            widgetName: 'OiImageAnnotator',
            description:
                'An image annotation tool supporting freehand drawing, '
                'arrows, rectangles, text labels, and other annotation '
                'types over an image.',
            examples: [
              ComponentExample(
                title: 'Usage',
                child: OiLabel.body(
                  'OiImageAnnotator(image: ImageProvider, label: "Annotate") '
                  '— renders an annotation canvas over an image. Required '
                  'parameters: image (ImageProvider), label (String). '
                  'Optional: annotations, onAnnotationsChange, selectedTool, '
                  'strokeColor, strokeWidth, readOnly.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── OiVideoPlayer ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Video Player',
            widgetName: 'OiVideoPlayer',
            description:
                'A video player with play/pause controls, progress bar, '
                'and optional poster image. Supports autoplay and loop.',
            examples: [
              ComponentExample(
                title: 'Usage',
                child: OiLabel.body(
                  'OiVideoPlayer(src: "https://...", label: "Video player") '
                  '— renders a video player with transport controls. '
                  'Required parameters: src (String), label (String). '
                  'Optional: autoPlay, loop, showControls, aspectRatio, '
                  'posterUrl, onPlay, onPause.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
