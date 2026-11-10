part of '../oi_app.dart';

/// Web view-focus events can arrive between detaching an editor's render object
/// and detaching its FocusNode. ReadingOrderTraversalPolicy reads node.rect,
/// which requires an attached, laid-out render object. Leave those transient
/// nodes out of traversal until they are laid out again.
class _OiAttachedReadingOrderTraversalPolicy
    extends ReadingOrderTraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) => super.sortDescendants(
    descendants.where((node) {
      final context = node.context;
      if (context == null || !context.mounted) return false;
      final render = context.findRenderObject();
      return render != null &&
          render.attached &&
          (render is! RenderBox || render.hasSize);
    }),
    currentNode,
  );
}
