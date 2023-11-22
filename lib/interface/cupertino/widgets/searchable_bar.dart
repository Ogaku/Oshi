import 'dart:ui';

import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart';
import 'package:oshi/share/share.dart';

class SearchableSliverNavigationBar extends StatefulWidget {
  final Widget? largeTitle;
  final Widget? leading;
  final bool? alwaysShowMiddle;
  final String? previousPageTitle;
  final Widget? middle;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color color;
  final Color darkColor;
  final double? anchor;
  final bool? transitionBetweenRoutes;
  final bool disableAddons;
  final bool useSliverBox;
  final TextEditingController searchController;
  final List<Widget>? children;
  final Widget? child;
  final Map<dynamic, String>? segments;
  final Function(String)? onChanged;
  final Function(dynamic)? onSegmentChanged;
  final Function(String)? onSubmitted;
  final void Function(VoidCallback fn)? setState;
  final Function(({double? progress, String? message})? progress)? onProgress;
  final DateTime? selectedDate;
  final bool keepBackgroundWatchers;
  final bool alwaysShowAddons;

  SearchableSliverNavigationBar(
      {super.key,
      TextEditingController? searchController,
      this.children,
      this.onChanged,
      this.onSegmentChanged,
      this.onSubmitted,
      this.transitionBetweenRoutes,
      this.largeTitle,
      this.leading,
      this.alwaysShowMiddle = false,
      this.previousPageTitle,
      this.middle,
      this.trailing,
      this.child,
      this.segments,
      this.setState,
      this.color = Colors.white,
      this.darkColor = Colors.black,
      this.backgroundColor,
      this.onProgress,
      this.anchor,
      bool? disableAddons,
      this.useSliverBox = false,
      this.selectedDate,
      this.keepBackgroundWatchers = false,
      this.alwaysShowAddons = false})
      : searchController = searchController ?? TextEditingController(),
        disableAddons = disableAddons ?? (child != null);

  @override
  State<SearchableSliverNavigationBar> createState() => _NavState();
}

class _NavState extends State<SearchableSliverNavigationBar> {
  late ScrollController scrollController;
  late dynamic groupSelection;

  double _pixels = 0;
  int _timestamp = 0;

  double previousScrollPosition = 0, isVisibleSearchBar = 0, refreshTurns = 0;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(initialScrollOffset: (widget.disableAddons || widget.alwaysShowAddons) ? 0 : 55);
    isVisibleSearchBar = widget.alwaysShowAddons ? 60 : 0;
    groupSelection = widget.segments?.keys.first;
  }

  void refreshChanged(Value<bool>? value) => setState(() {
        isRefreshing = value?.value ?? false;
        if (!isRefreshing && widget.onProgress != null) widget.onProgress!(null);
      });

  void progressChanged(Value<String>? value) => setState(() {
        if (widget.onProgress != null) widget.onProgress!((message: value?.value ?? '', progress: 0.0));
      });

  @override
  Widget build(BuildContext context) {
    // Re-subscribe for refresh updates
    Share.refreshChanged.unsubscribe(refreshChanged);
    Share.refreshChanged.subscribe(refreshChanged);

    // Re-subscribe for progress updates
    Share.progressChanged.unsubscribe(progressChanged);
    Share.progressChanged.subscribe(progressChanged);

    var navBarSliver = SliverNavigationBar(
      backgroundColor: widget.backgroundColor,
      alternativeVisibility: widget.disableAddons && !widget.keepBackgroundWatchers,
      transitionBetweenRoutes: widget.transitionBetweenRoutes,
      leading: widget.leading,
      previousPageTitle: widget.previousPageTitle,
      threshold: ((widget.anchor != null && widget.child != null) || (widget.anchor == 0.0 && widget.keepBackgroundWatchers))
          ? 52
          : 112,
      middle: widget.middle ?? widget.largeTitle,
      largeTitle: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: widget.largeTitle),
          Visibility(
              visible: !widget.disableAddons && widget.child == null,
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                height: lerpDouble(0, 55, isVisibleSearchBar.clamp(0.0, 55.0) / 55.0),
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 15, top: 3, bottom: 15),
                  child: widget.segments != null
                      ? Opacity(
                          opacity: ((isVisibleSearchBar - 45) / 5).clamp(0.0, 1.0),
                          child: CupertinoSlidingSegmentedControl(
                            groupValue: groupSelection,
                            children: widget.segments!.map((key, value) => MapEntry(
                                key,
                                Container(
                                    width: double.maxFinite,
                                    alignment: Alignment.center,
                                    child: Text(value,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: lerpDouble(13, 15, ((isVisibleSearchBar - 30) / 10).clamp(0.0, 1.0)),
                                            color: CupertinoDynamicColor.resolve(
                                                CupertinoDynamicColor.withBrightness(
                                                    color: CupertinoColors.black.withAlpha(
                                                        (((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0) * 153).round()),
                                                    darkColor: CupertinoColors.white.withAlpha(
                                                        (((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0) * 153).round())),
                                                context)))))),
                            onValueChanged: (value) {
                              if (value == null) return;
                              setState(() => groupSelection = value);
                              if (widget.onSegmentChanged != null) widget.onSegmentChanged!(value);
                            },
                          ))
                      : CupertinoSearchTextField(
                          onChanged: widget.onChanged,
                          placeholderStyle: TextStyle(
                              fontSize: lerpDouble(13, 17, ((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0)),
                              color: CupertinoDynamicColor.withBrightness(
                                  color: const Color.fromARGB(153, 60, 60, 67)
                                      .withAlpha((((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0) * 153).round()),
                                  darkColor: const Color.fromARGB(153, 235, 235, 245)
                                      .withAlpha((((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0) * 153).round()))),
                          prefixIcon: Opacity(
                            opacity: ((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0),
                            child: Transform.scale(
                                scale: lerpDouble(0.7, 1.1, ((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0)),
                                child: Container(
                                    margin: const EdgeInsets.only(top: 2, left: 2),
                                    child: const Icon(CupertinoIcons.search))),
                          ),
                          controller: widget.searchController,
                          onSubmitted: widget.onSubmitted,
                        ),
                ),
              )),
        ],
      ),
      scrollController: scrollController,
      alwaysShowMiddle: false,
      trailing: (previousScrollPosition >= -40 && !isRefreshing) || widget.setState == null
          ? widget.trailing != null
              ? Opacity(
                  opacity: (lerpDouble(2.5, 0.0, previousScrollPosition / -40.0)?.clamp(0.0, 1.0) ?? 0.0),
                  child: widget.trailing)
              : widget.trailing
          : Container(
              margin: const EdgeInsets.only(right: 5, top: 5),
              child: AnimatedRotation(
                  turns: refreshTurns,
                  duration: const Duration(seconds: 1),
                  curve: Curves.ease,
                  child: _buildIndicatorForRefreshState(
                      (previousScrollPosition < -130 || isRefreshing)
                          ? RefreshIndicatorMode.refresh
                          : RefreshIndicatorMode.drag,
                      12,
                      (lerpDouble(-0.3, 1.0, previousScrollPosition / -130.0)?.clamp(0.0, 0.99) ?? 0.0)))),
    );

    return CupertinoPageScaffold(
        backgroundColor: widget.backgroundColor ??
            const CupertinoDynamicColor.withBrightness(
                color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0)),
        child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (widget.disableAddons) return true;
              if (scrollInfo is ScrollUpdateNotification) {
                if (scrollInfo.metrics.pixels < -130 && !isRefreshing && widget.setState != null) {
                  setState(() {
                    isRefreshing = true;
                    refreshTurns =
                        (-2 * (scrollInfo.metrics.pixels - _pixels) / (DateTime.now().millisecondsSinceEpoch - _timestamp))
                            .clamp(0.3, 1);
                  });

                  try {
                    HapticFeedback.mediumImpact(); // Trigger a haptic feedback
                  } catch (ex) {
                    // ignored
                  }

                  Share.session.refreshAll(weekStart: widget.selectedDate).then((arg) {
                    setState(() {
                      isRefreshing = false;
                      refreshTurns = 0;
                    });

                    if (widget.setState != null) widget.setState!(() {});
                  });
                }
                // print(scrollInfo.metrics.pixels);
                if (scrollInfo.metrics.pixels > previousScrollPosition) {
                  if (isVisibleSearchBar > 0 && scrollInfo.metrics.pixels > 0) {
                    setState(() {
                      isVisibleSearchBar = widget.alwaysShowAddons
                          ? 60
                          : (55 - scrollInfo.metrics.pixels) >= 0
                              ? (55 - scrollInfo.metrics.pixels)
                              : 0;
                    });
                  }
                } else if (scrollInfo.metrics.pixels <= previousScrollPosition) {
                  if (isVisibleSearchBar < 55 /*&& scrollInfo.metrics.pixels >= 0*/ && scrollInfo.metrics.pixels <= 55) {
                    setState(() {
                      isVisibleSearchBar = widget.alwaysShowAddons
                          ? 60
                          : (55 - scrollInfo.metrics.pixels) <= 55
                              ? (55 - scrollInfo.metrics.pixels)
                              : 55;
                    });
                  }
                }
                setState(() {
                  previousScrollPosition = scrollInfo.metrics.pixels;
                  _pixels = scrollInfo.metrics.pixels;
                  _timestamp = DateTime.now().millisecondsSinceEpoch;
                });
              } else if (scrollInfo is ScrollEndNotification) {
                if (widget.disableAddons || widget.child != null) return true;
                Future.delayed(Duration.zero, () {
                  if (isVisibleSearchBar < 25 && isVisibleSearchBar > 10 && !widget.alwaysShowAddons) {
                    setState(() {
                      scrollController.animateTo(55, duration: const Duration(milliseconds: 200), curve: Curves.ease);
                    });
                  } else if (isVisibleSearchBar >= 25 && isVisibleSearchBar <= 55) {
                    setState(() {
                      scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.ease);
                    });
                  }
                });
              }
              return true;
            },
            child: SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                anchor: widget.anchor ?? 0.077,
                slivers: <Widget>[
                  navBarSliver,
                  widget.useSliverBox
                      ? SliverToBoxAdapter(
                          child: widget.child ??
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: widget.children ?? [],
                              ))
                      : SliverFillRemaining(
                          hasScrollBody: false,
                          child: widget.child ??
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: widget.children ?? [],
                              )),
                ],
              ),
            )));
  }
}

Widget _buildIndicatorForRefreshState(RefreshIndicatorMode refreshState, double radius, double percentageComplete) {
  switch (refreshState) {
    case RefreshIndicatorMode.drag:
      // While we're dragging, we draw individual ticks of the spinner while simultaneously
      // easing the opacity in. The opacity curve values here were derived using
      // Xcode through inspecting a native app running on iOS 13.5.
      const Curve opacityCurve = Interval(0.0, 0.35, curve: Curves.easeInOut);
      return Opacity(
        opacity: opacityCurve.transform(percentageComplete),
        child: CupertinoActivityIndicator.partiallyRevealed(radius: radius, progress: percentageComplete),
      );
    case RefreshIndicatorMode.armed:
    case RefreshIndicatorMode.refresh:
      // Once we're armed or performing the refresh, we just show the normal spinner.
      return CupertinoActivityIndicator(radius: radius);
    case RefreshIndicatorMode.done:
      // When the user lets go, the standard transition is to shrink the spinner.
      return CupertinoActivityIndicator(radius: radius * percentageComplete);
    case RefreshIndicatorMode.inactive:
      // Anything else doesn't show anything.
      return const SizedBox.shrink();
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) {
      return;
    }
    final size = context.size;
    if (_oldSize != size && size != null) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}

// https://stackoverflow.com/a/65332810
class ExpandablePageView extends StatefulWidget {
  final NullableIndexedWidgetBuilder builder;
  final PageController controller;
  final void Function(int)? pageChanged;

  const ExpandablePageView({
    Key? key,
    required this.builder,
    required this.controller,
    this.pageChanged,
  }) : super(key: key);

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> with TickerProviderStateMixin {
  final Map<int, double> _heights = {};
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage] ?? 0;

  void pageChanged() {
    final newPage = widget.controller.page?.round() ?? 0;
    if (_currentPage != newPage) {
      setState(() => _currentPage = newPage);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(pageChanged);
    _currentPage = widget.controller.initialPage;
  }

  @override
  void dispose() {
    widget.controller.removeListener(pageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: _currentHeight, end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView.builder(
          controller: widget.controller,
          onPageChanged: widget.pageChanged,
          scrollBehavior: const CupertinoScrollBehavior(),
          scrollDirection: Axis.horizontal,
          pageSnapping: true,
          itemBuilder: ((context, index) => OverflowBox(
                minHeight: 0,
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: SizeReportingWidget(
                  onSizeChange: (size) => setState(() => _heights[index] = size.height),
                  child: Align(child: widget.builder(context, index)),
                ),
              ))),
    );
  }
}
