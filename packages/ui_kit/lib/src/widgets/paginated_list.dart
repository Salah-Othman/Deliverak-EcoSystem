import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'app_loader.dart';

class PaginatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final ScrollController? scrollController;
  final double loadMoreThreshold;

  const PaginatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.padding,
    this.emptyWidget,
    this.loadingWidget,
    this.scrollController,
    this.loadMoreThreshold = 200,
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PaginatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.removeListener(_onScroll);
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (widget.onLoadMore == null) return;
    if (widget.isLoadingMore || !widget.hasMore) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - widget.loadMoreThreshold) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: AppLoader(size: 24)),
              );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
