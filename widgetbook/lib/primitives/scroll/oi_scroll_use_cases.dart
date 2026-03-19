import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiVirtualListComponent = WidgetbookComponent(
  name: 'OiVirtualList',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final itemCount = context.knobs.int.slider(
          label: 'Item Count',
          initialValue: 50,
          min: 5,
          max: 200,
        );

        return SizedBox(
          height: 400,
          width: 300,
          child: OiVirtualList(
            itemCount: itemCount,
            itemBuilder: (context, index) => Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              color: index.isEven
                  ? const Color(0xFFBBDEFB)
                  : const Color(0xFFE3F2FD),
              child: Center(child: Text('Item $index')),
            ),
          ),
        );
      },
    ),
  ],
);

final oiVirtualGridComponent = WidgetbookComponent(
  name: 'OiVirtualGrid',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final crossAxisCount = context.knobs.int.slider(
          label: 'Cross Axis Count',
          initialValue: 3,
          min: 1,
          max: 6,
        );
        final itemCount = context.knobs.int.slider(
          label: 'Item Count',
          initialValue: 30,
          min: 5,
          max: 100,
        );
        final spacing = context.knobs.double.slider(
          label: 'Spacing',
          initialValue: 4,
          min: 0,
          max: 16,
        );

        return SizedBox(
          height: 400,
          width: 400,
          child: OiVirtualGrid(
            itemCount: itemCount,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            itemBuilder: (context, index) => Container(
              color: Color(0xFF9C27B0).withValues(
                alpha: 0.2 + (index % 5) * 0.15,
              ),
              child: Center(child: Text('$index')),
            ),
          ),
        );
      },
    ),
  ],
);

final oiInfiniteScrollComponent = WidgetbookComponent(
  name: 'OiInfiniteScroll',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return const SizedBox(
          height: 400,
          width: 300,
          child: _InfiniteScrollDemo(),
        );
      },
    ),
  ],
);

class _InfiniteScrollDemo extends StatefulWidget {
  const _InfiniteScrollDemo();

  @override
  State<_InfiniteScrollDemo> createState() => _InfiniteScrollDemoState();
}

class _InfiniteScrollDemoState extends State<_InfiniteScrollDemo> {
  int _count = 20;
  bool _hasMore = true;

  Future<void> _loadMore() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _count += 10;
        if (_count >= 50) _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OiInfiniteScroll(
      moreAvailable: _hasMore,
      onLoadMore: _loadMore,
      child: ListView.builder(
        itemCount: _count,
        itemBuilder: (context, index) => Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          color: const Color(0xFFC8E6C9),
          child: Center(child: Text('Item $index')),
        ),
      ),
    );
  }
}

final oiScrollbarComponent = WidgetbookComponent(
  name: 'OiScrollbar',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final alwaysShow = context.knobs.boolean(
          label: 'Always Show',
          initialValue: true,
        );

        return SizedBox(
          height: 300,
          width: 300,
          child: OiScrollbar(
            alwaysShow: alwaysShow,
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Text('Scrollbar item $index'),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
