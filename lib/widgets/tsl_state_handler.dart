import 'package:flutter/material.dart';

import 'tsl_empty_state.dart';
import 'tsl_error_state.dart';
import 'tsl_loading_state.dart';

/// Unified state handler widget that manages loading, error, empty, and content states
///
/// Features:
/// - Automatic state management
/// - Animated transitions between states
/// - Customizable state widgets
/// - Pull-to-refresh support
/// - Retry functionality
class TslStateHandler<T> extends StatelessWidget {
  /// Current state
  final TslViewState state;

  /// Data for content state
  final T? data;

  /// Builder for content when data is available
  final Widget Function(BuildContext context, T data) contentBuilder;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Loading message
  final String? loadingMessage;

  /// Custom error widget
  final Widget? errorWidget;

  /// Error type
  final TslErrorType errorType;

  /// Error message
  final String? errorMessage;

  /// Retry callback for error state
  final VoidCallback? onRetry;

  /// Custom empty state widget
  final Widget? emptyWidget;

  /// Empty state icon
  final IconData emptyIcon;

  /// Empty state title
  final String emptyTitle;

  /// Empty state message
  final String? emptyMessage;

  /// Empty state action text
  final String? emptyActionText;

  /// Empty state action callback
  final VoidCallback? onEmptyAction;

  /// Whether to enable pull-to-refresh
  final bool enableRefresh;

  /// Refresh callback
  final Future<void> Function()? onRefresh;

  /// Whether to animate state transitions
  final bool animateTransitions;

  /// Transition duration
  final Duration transitionDuration;

  const TslStateHandler({
    super.key,
    required this.state,
    this.data,
    required this.contentBuilder,
    this.loadingWidget,
    this.loadingMessage,
    this.errorWidget,
    this.errorType = TslErrorType.unknown,
    this.errorMessage,
    this.onRetry,
    this.emptyWidget,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'No Data',
    this.emptyMessage,
    this.emptyActionText,
    this.onEmptyAction,
    this.enableRefresh = false,
    this.onRefresh,
    this.animateTransitions = true,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (state) {
      case TslViewState.loading:
        content = _buildLoadingState();
        break;
      case TslViewState.error:
        content = _buildErrorState();
        break;
      case TslViewState.empty:
        content = _buildEmptyState();
        break;
      case TslViewState.content:
        if (data != null) {
          content = contentBuilder(context, data as T);
        } else {
          content = _buildEmptyState();
        }
        break;
    }

    if (enableRefresh && onRefresh != null && state == TslViewState.content) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    if (animateTransitions) {
      return AnimatedSwitcher(
        duration: transitionDuration,
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: KeyedSubtree(
          key: ValueKey(state),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildLoadingState() {
    if (loadingWidget != null) return loadingWidget!;

    return TslLoadingState(
      message: loadingMessage,
      size: TslLoadingSize.large,
    );
  }

  Widget _buildErrorState() {
    if (errorWidget != null) return errorWidget!;

    return TslErrorState(
      type: errorType,
      message: errorMessage,
      onAction: onRetry,
    );
  }

  Widget _buildEmptyState() {
    if (emptyWidget != null) return emptyWidget!;

    return TslEmptyState(
      icon: emptyIcon,
      title: emptyTitle,
      message: emptyMessage,
      actionText: emptyActionText,
      onAction: onEmptyAction,
    );
  }
}

/// View states for TslStateHandler
enum TslViewState {
  loading,
  error,
  empty,
  content,
}

/// State handler for lists with built-in empty checking
class TslListStateHandler<T> extends StatelessWidget {
  /// Current state
  final TslViewState state;

  /// List data
  final List<T>? items;

  /// Builder for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional separator builder
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Loading message
  final String? loadingMessage;

  /// Custom error widget
  final Widget? errorWidget;

  /// Error type
  final TslErrorType errorType;

  /// Error message
  final String? errorMessage;

  /// Retry callback
  final VoidCallback? onRetry;

  /// Custom empty state
  final Widget? emptyWidget;

  /// Empty state icon
  final IconData emptyIcon;

  /// Empty state title
  final String emptyTitle;

  /// Empty state message
  final String? emptyMessage;

  /// Empty state action text
  final String? emptyActionText;

  /// Empty state action callback
  final VoidCallback? onEmptyAction;

  /// List header widget
  final Widget? header;

  /// List footer widget
  final Widget? footer;

  /// List padding
  final EdgeInsetsGeometry? padding;

  /// Whether list should shrink wrap
  final bool shrinkWrap;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Scroll controller
  final ScrollController? controller;

  /// Enable pull-to-refresh
  final bool enableRefresh;

  /// Refresh callback
  final Future<void> Function()? onRefresh;

  const TslListStateHandler({
    super.key,
    required this.state,
    this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.loadingWidget,
    this.loadingMessage,
    this.errorWidget,
    this.errorType = TslErrorType.unknown,
    this.errorMessage,
    this.onRetry,
    this.emptyWidget,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'No Items',
    this.emptyMessage,
    this.emptyActionText,
    this.onEmptyAction,
    this.header,
    this.footer,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.enableRefresh = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Determine effective state
    TslViewState effectiveState = state;
    if (state == TslViewState.content && (items == null || items!.isEmpty)) {
      effectiveState = TslViewState.empty;
    }

    Widget content;

    switch (effectiveState) {
      case TslViewState.loading:
        content = _buildLoadingState();
        break;
      case TslViewState.error:
        content = _buildErrorState();
        break;
      case TslViewState.empty:
        content = _buildEmptyState();
        break;
      case TslViewState.content:
        content = _buildListContent();
        break;
    }

    if (enableRefresh && onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: effectiveState == TslViewState.content
            ? content
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: content,
                ),
              ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(effectiveState),
        child: content,
      ),
    );
  }

  Widget _buildLoadingState() {
    if (loadingWidget != null) return loadingWidget!;

    return TslLoadingState(
      message: loadingMessage,
      size: TslLoadingSize.large,
    );
  }

  Widget _buildErrorState() {
    if (errorWidget != null) return errorWidget!;

    return TslErrorState(
      type: errorType,
      message: errorMessage,
      onAction: onRetry,
    );
  }

  Widget _buildEmptyState() {
    if (emptyWidget != null) return emptyWidget!;

    return TslEmptyState(
      icon: emptyIcon,
      title: emptyTitle,
      message: emptyMessage,
      actionText: emptyActionText,
      onAction: onEmptyAction,
    );
  }

  Widget _buildListContent() {
    final itemCount = items?.length ?? 0;

    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount + (header != null ? 1 : 0) + (footer != null ? 1 : 0),
        separatorBuilder: (context, index) {
          if (header != null && index == 0) return const SizedBox.shrink();
          if (footer != null && index == itemCount) return const SizedBox.shrink();
          final adjustedIndex = header != null ? index - 1 : index;
          return separatorBuilder!(context, adjustedIndex);
        },
        itemBuilder: (context, index) {
          if (header != null && index == 0) return header!;
          if (footer != null && index == itemCount + (header != null ? 1 : 0)) {
            return footer!;
          }
          final adjustedIndex = header != null ? index - 1 : index;
          return itemBuilder(context, items![adjustedIndex], adjustedIndex);
        },
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount + (header != null ? 1 : 0) + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (header != null && index == 0) return header!;
        if (footer != null && index == itemCount + (header != null ? 1 : 0)) {
          return footer!;
        }
        final adjustedIndex = header != null ? index - 1 : index;
        return itemBuilder(context, items![adjustedIndex], adjustedIndex);
      },
    );
  }
}

/// Shimmer loading placeholder for list items
class TslShimmerList extends StatelessWidget {
  /// Number of shimmer items to show
  final int itemCount;

  /// Height of each shimmer item
  final double itemHeight;

  /// Padding around each item
  final EdgeInsetsGeometry itemPadding;

  /// Custom shimmer item builder
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const TslShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.itemPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (itemBuilder != null) {
          return itemBuilder!(context, index);
        }
        return Padding(
          padding: itemPadding,
          child: TslShimmerItem(height: itemHeight),
        );
      },
    );
  }
}

/// Single shimmer item placeholder
class TslShimmerItem extends StatefulWidget {
  /// Width of the shimmer item
  final double? width;

  /// Height of the shimmer item
  final double height;

  /// Border radius
  final double borderRadius;

  const TslShimmerItem({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius = 12,
  });

  @override
  State<TslShimmerItem> createState() => _TslShimmerItemState();
}

class _TslShimmerItemState extends State<TslShimmerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
            ),
          ),
        );
      },
    );
  }
}


