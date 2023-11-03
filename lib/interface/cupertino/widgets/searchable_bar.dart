import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/interface/cupertino/widgets/navigation_bar.dart';
import 'package:oshi/models/progress.dart';
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
  final TextEditingController searchController;
  final List<Widget>? children;
  final Widget? child;
  final Map<String, String>? segments;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final void Function(VoidCallback fn)? setState;
  final Function(({double? progress, String? message})? progress)? onProgress;

  SearchableSliverNavigationBar(
      {super.key,
      TextEditingController? searchController,
      this.children,
      this.onChanged,
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
      bool? disableAddons})
      : searchController = searchController ?? TextEditingController(),
        disableAddons = disableAddons ?? (child != null);

  @override
  State<SearchableSliverNavigationBar> createState() => _NavState();
}

class _NavState extends State<SearchableSliverNavigationBar> {
  late ScrollController scrollController;
  late String? groupSelection;

  double previousScrollPosition = 0, isVisibleSearchBar = 0;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(initialScrollOffset: widget.disableAddons ? 0 : 55);
    groupSelection = widget.segments?.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    var navBarSliver = SliverNavigationBar(
      backgroundColor: widget.backgroundColor,
      alternativeVisibility: widget.disableAddons,
      transitionBetweenRoutes: widget.transitionBetweenRoutes,
      leading: widget.leading,
      previousPageTitle: widget.previousPageTitle,
      threshold: 97,
      middle: widget.middle ?? widget.largeTitle,
      largeTitle: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: widget.largeTitle),
          Visibility(
              visible: !widget.disableAddons,
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
                                Text(value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: lerpDouble(13, 15, ((isVisibleSearchBar - 30) / 10).clamp(0.0, 1.0)),
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: CupertinoColors.black.withAlpha(
                                                    (((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0) * 153).round()),
                                                darkColor: CupertinoColors.white.withAlpha(
                                                    (((isVisibleSearchBar - 45) / 10).clamp(0.0, 1.0) * 153).round())),
                                            context))))),
                            onValueChanged: (value) {
                              if (value == null) return;
                              setState(() => groupSelection = value);
                              if (widget.onChanged != null) widget.onChanged!(value);
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
      trailing: (previousScrollPosition >= -20 && !isRefreshing) || widget.setState == null
          ? widget.trailing
          : Container(
              margin: const EdgeInsets.only(right: 5, top: 5),
              child: _buildIndicatorForRefreshState(
                  (previousScrollPosition < -120 || isRefreshing) ? RefreshIndicatorMode.refresh : RefreshIndicatorMode.drag,
                  12,
                  ((previousScrollPosition + 20) / previousScrollPosition).clamp(0.0, 1.0))),
    );

    return CupertinoPageScaffold(
        backgroundColor: widget.backgroundColor ??
            const CupertinoDynamicColor.withBrightness(
                color: Color.fromARGB(255, 242, 242, 247), darkColor: Color.fromARGB(255, 0, 0, 0)),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (widget.disableAddons) return true;
            if (scrollInfo is ScrollUpdateNotification) {
              if (scrollInfo.metrics.pixels < -120 && !isRefreshing && widget.setState != null) {
                setState(() => isRefreshing = true);
                var progress = Progress<({double? progress, String? message})>();
                progress.progressChanged.subscribe((args) {
                  if (widget.onProgress != null) widget.onProgress!(args?.value);
                });
                Share.session.refreshAll(progress: progress).then((arg) {
                  setState(() => isRefreshing = false);
                  if (widget.setState != null) widget.setState!(() {});

                  progress.progressChanged.unsubscribeAll();
                  if (widget.onProgress != null) widget.onProgress!(null);
                });
              }
              if (scrollInfo.metrics.pixels > previousScrollPosition) {
                if (isVisibleSearchBar > 0 && scrollInfo.metrics.pixels > 0) {
                  setState(() {
                    isVisibleSearchBar = (55 - scrollInfo.metrics.pixels) >= 0 ? (55 - scrollInfo.metrics.pixels) : 0;
                  });
                }
              } else if (scrollInfo.metrics.pixels <= previousScrollPosition) {
                if (isVisibleSearchBar < 55 && scrollInfo.metrics.pixels >= 0 && scrollInfo.metrics.pixels <= 55) {
                  setState(() {
                    isVisibleSearchBar = (55 - scrollInfo.metrics.pixels) <= 55 ? (55 - scrollInfo.metrics.pixels) : 55;
                  });
                }
              }
              setState(() {
                previousScrollPosition = scrollInfo.metrics.pixels;
              });
            } else if (scrollInfo is ScrollEndNotification) {
              Future.delayed(Duration.zero, () {
                if (isVisibleSearchBar < 25 && isVisibleSearchBar > 10) {
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
          child: widget.child != null
              ? NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [navBarSliver],
                  body: widget.child!,
                  controller: scrollController)
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  anchor: widget.anchor ?? 0.07,
                  slivers: <Widget>[
                    navBarSliver,
                    SliverFillRemaining(
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
        ));
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
