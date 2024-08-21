// ignore_for_file: prefer_const_constructors

import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/components/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/share/share.dart';

class DataPage extends DataPageBase {
  const DataPage(
      {super.key,
      required super.title,
      super.pageFlags = 0,
      super.setState,
      super.searchController,
      super.searchBuilder,
      super.segmentController,
      super.children,
      super.selectedDate,
      super.leading,
      super.trailing,
      super.segments,
      super.previousPageTitle});

  @override
  State<DataPage> createState() => DataPageState();
}

class DataPageState extends State<DataPage> {
  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
    if (mounted && widget.setState != null) widget.setState!(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    // onChanged, onSubmitted -> already handled by searchController
    var navigationBar = SearchableSliverNavigationBar(
      children: widget.pageFlags.hasFlag(DataPageType.singleChild) ? null : widget.children,
      transitionBetweenRoutes: !widget.pageFlags.hasFlag(DataPageType.noTransitions),
      largeTitle: widget.pageFlags.hasFlag(DataPageType.removeLargeTitle) ? null : Text(widget.title),
      leading: widget.leading,
      alwaysShowMiddle: widget.pageFlags.hasFlag(DataPageType.childPage),
      previousPageTitle: widget.previousPageTitle,
      middle: widget.pageFlags.hasFlag(DataPageType.removeMiddleTitle) ? null : Text(widget.title),
      trailing: widget.trailing,
      child: widget.pageFlags.hasFlag(DataPageType.singleChild) ? widget.children?.firstOrNull : null,
      segments: widget.pageFlags.hasFlag(DataPageType.segmented) ? widget.segments : null,
      setState: widget.setState,
      anchor: widget.pageFlags.hasFlag(DataPageType.noTitleSpace) ? 0.0 : null,
      disableAddons:
          !(widget.pageFlags.hasFlag(DataPageType.searchable) || widget.pageFlags.hasFlag(DataPageType.segmented)) ||
              !widget.pageFlags.hasFlag(DataPageType.refreshable),
      useSliverBox: widget.pageFlags.hasFlag(DataPageType.boxedPage),
      selectedDate: widget.selectedDate,
      keepBackgroundWatchers: widget.pageFlags.hasFlag(DataPageType.keepBackgroundWatchers),
      alwaysShowAddons: widget.pageFlags.hasFlag(DataPageType.segmentedSticky),
      segmentController: widget.pageFlags.hasFlag(DataPageType.segmented) ? widget.segmentController : null,
      searchController: widget.pageFlags.hasFlag(DataPageType.searchable) ? widget.searchController : null,
      backgroundColor: widget.pageFlags.hasFlag(DataPageType.alternativeBackground)
          ? CupertinoDynamicColor.withBrightness(
              color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30))
          : null,
    );

    return widget.pageFlags.hasFlag(DataPageType.withBase)
        ? CupertinoPageScaffold(
            backgroundColor: CupertinoDynamicColor.withBrightness(
                color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
            child: navigationBar)
        : navigationBar;
  }
}
