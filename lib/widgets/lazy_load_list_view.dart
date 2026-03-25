import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// A lazy-loading ListView that loads items in pages
///
/// Features:
/// - Loads items in configurable page sizes
/// - Shows loading indicator at the bottom while loading more
/// - Supports pull-to-refresh
/// - Handles empty and error states
/// - Scroll-based trigger for loading more items
class LazyLoadListView<T> extends StatefulWidget {
  /// All available items (the full dataset)
  final List<T> allItems;

  /// Number of items to load per page
  final int pageSize;

  /// Builder for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Padding around the list
  final EdgeInsets? padding;

  /// Widget to show when loading more items
  final Widget? loadingIndicator;

  /// Callback when user pulls to refresh
  final Future<void> Function()? onRefresh;

  /// Scroll threshold (0.0 to 1.0) at which to trigger loading more
  /// Default: 0.8 (80% scrolled)
  final double loadMoreThreshold;

  /// Separator between items
  final Widget? separator;

  /// Widget to show when list is empty
  final Widget? emptyWidget;

  const LazyLoadListView({
    super.key,
    required this.allItems,
    required this.itemBuilder,
    this.pageSize = 20,
    this.padding,
    this.loadingIndicator,
    this.onRefresh,
    this.loadMoreThreshold = 0.8,
    this.separator,
    this.emptyWidget,
  });

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  int _displayedCount = 0;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  List<T> get _displayedItems =>
      widget.allItems.take(_displayedCount).toList();

  bool get _hasMore => _displayedCount < widget.allItems.length;

  @override
  void initState() {
    super.initState();
    _displayedCount = widget.pageSize.clamp(0, widget.allItems.length);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant LazyLoadListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allItems.length != widget.allItems.length) {
      // Dataset changed (e.g., filter applied), reset pagination
      setState(() {
        _displayedCount = widget.pageSize.clamp(0, widget.allItems.length);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * widget.loadMoreThreshold;

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    // Simulate a small delay for smoother UX
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      setState(() {
        _displayedCount = (_displayedCount + widget.pageSize)
            .clamp(0, widget.allItems.length);
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    if (mounted) {
      setState(() {
        _displayedCount = widget.pageSize.clamp(0, widget.allItems.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allItems.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    final items = _displayedItems;

    Widget listView = ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      // +1 for loading indicator if there are more items
      itemCount: items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          // Loading indicator at the bottom
          return _buildLoadingIndicator();
        }

        final itemWidget = widget.itemBuilder(context, items[index], index);

        if (widget.separator != null && index < items.length - 1) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              itemWidget,
              widget.separator!,
            ],
          );
        }

        return itemWidget;
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: _handleRefresh,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildLoadingIndicator() {
    return widget.loadingIndicator ??
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        );
  }
}

/// Extension to make it easy to add lazy loading to existing lists
extension LazyLoadExtension<T> on List<T> {
  /// Get a paginated subset of this list
  List<T> paginate({required int page, int pageSize = 20}) {
    final start = 0;
    final end = ((page + 1) * pageSize).clamp(0, length);
    return sublist(start, end);
  }
}

