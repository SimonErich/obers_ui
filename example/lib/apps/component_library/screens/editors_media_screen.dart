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
  bool _showLightbox = false;
  List<OiAnnotation> _annotations = [];
  OiAnnotationType _selectedTool = OiAnnotationType.freehand;

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
                title: 'Open lightbox',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiButton.primary(
                      label: 'Open Lightbox',
                      onTap: () {
                        setState(() => _showLightbox = true);
                      },
                    ),
                    if (_showLightbox) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: OiLightbox(
                          label: 'Sample lightbox',
                          items: const [
                            OiLightboxItem(
                              src: 'https://picsum.photos/seed/lb1/800/600',
                              alt: 'Sample image 1',
                              caption: 'Mountain landscape',
                            ),
                            OiLightboxItem(
                              src: 'https://picsum.photos/seed/lb2/800/600',
                              alt: 'Sample image 2',
                              caption: 'Ocean view',
                            ),
                            OiLightboxItem(
                              src: 'https://picsum.photos/seed/lb3/800/600',
                              alt: 'Sample image 3',
                              caption: 'Forest path',
                            ),
                          ],
                          initialIndex: 0,
                          onDismiss: () {
                            setState(() => _showLightbox = false);
                          },
                        ),
                      ),
                    ],
                  ],
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
                title: 'Crop an image',
                child: SizedBox(
                  height: 400,
                  child: OiImageCropper(
                    image: const NetworkImage(
                      'https://picsum.photos/seed/crop/800/600',
                    ),
                    label: 'Crop image',
                    enableRotate: true,
                    enableFlip: true,
                    aspectRatioOptions: const [1.0, 16 / 9, 4 / 3],
                    onCrop: (_) {},
                  ),
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
                title: 'Annotate an image',
                child: SizedBox(
                  height: 400,
                  child: OiImageAnnotator(
                    image: const NetworkImage(
                      'https://picsum.photos/seed/annotate/800/600',
                    ),
                    label: 'Annotate image',
                    annotations: _annotations,
                    selectedTool: _selectedTool,
                    onToolChange: (tool) {
                      setState(() => _selectedTool = tool);
                    },
                    onAnnotationsChange: (annotations) {
                      setState(() => _annotations = annotations);
                    },
                  ),
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
                title: 'Video player',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const OiVideoPlayer(
                    src: 'https://example.com/sample-video.mp4',
                    label: 'Sample video',
                    posterUrl: 'https://picsum.photos/seed/video/800/450',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
