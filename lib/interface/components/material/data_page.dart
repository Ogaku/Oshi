// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/share/share.dart';

final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

class DataPage extends DataPageBase {
  const DataPage(
      {super.key,
      required super.title,
      super.pageFlags = 0,
      super.setState,
      super.segmentController,
      super.searchBuilder,
      super.children,
      super.selectedDate,
      super.leading,
      super.trailing,
      super.segments,
      super.previousPageTitle,
      super.childOverride,
      super.pageBuilder});

  @override
  State<DataPage> createState() => DataPageState();
}

class DataPageState extends State<DataPage> with TickerProviderStateMixin {
  late final TabController tabController;
  bool? isChildPage;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
        length: widget.segments?.length ?? 1,
        vsync: this,
        initialIndex: widget.segments?.keys.toList().indexOf(widget.segmentController?.segment) ?? 0);
    widget.segmentController?.reserved = tabController;
  }

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
    if (mounted && widget.setState != null) widget.setState!(() {});
  }

  void setStateListener([bool self = false]) {
    if (mounted) {
      if (self) setState(() {});
      // widget.setState!(() {});
    }
  }

  void pushUpdateSegment() {
    if (widget.segmentController?.segment == widget.segments?.keys.elementAt(tabController.index)) return;
    tabController.animateTo(widget.segments?.keys.toList().indexOf(widget.segmentController?.segment) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // Detect if this is a child page (once)
    isChildPage ??= widget.childOverride ?? Navigator.of(context).canPop();

    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    tabController.removeListener(() => setState(() {
          widget.segmentController?.segment = widget.segments?.keys.elementAt(tabController.index);
        }));
    tabController.addListener(() => setState(() {
          widget.segmentController?.segment = widget.segments?.keys.elementAt(tabController.index);
        }));

    if (widget.setState != null) {
      Share.session.refreshStatus.removeListener(setStateListener);
      Share.session.refreshStatus.addListener(setStateListener);
    }

    widget.segmentController?.removeListener(pushUpdateSegment);
    widget.segmentController?.addListener(pushUpdateSegment);

    // onChanged, onSubmitted -> already handled by searchController
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      // ignore: unused_local_variable
      ColorScheme? lightColorScheme, darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        (lightColorScheme, darkColorScheme) = generateDynamicColourSchemes(lightDynamic, darkDynamic);
      }

      var pageChild = CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            key: ValueKey<int>(1),
            backgroundColor:
                widget.pageFlags.hasFlag(DataPageType.alternativeBackground) ? Theme.of(context).hoverColor : null,
            pinned: true,
            snap: false,
            floating: false,
            flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              var top = constraints.biggest.height;
              var padding = 100.0 - ((constraints.maxHeight - 64) * 100 / (242 - 64));

              return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: (isChildPage ?? false) ? padding : 20, bottom: 15, right: 20),
                  title: AnimatedOpacity(
                      duration: Duration(milliseconds: 250),
                      opacity: (top > 110 || widget.leading == null) ? 1.0 : 0.0,
                      child: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  background: Stack(children: <Widget>[
                    // Search icon
                    if (widget.pageFlags.hasFlag(DataPageType.searchable))
                      SearchAnchor(
                        isFullScreen: true,
                        builder: (context, controller) => Padding(
                          padding: (isChildPage ?? false) && widget.trailing != null
                              ? const EdgeInsets.only(left: 65, top: 17)
                              : const EdgeInsets.all(15.0),
                          child: Align(
                              alignment:
                                  (isChildPage ?? false) && widget.trailing == null ? Alignment.topRight : Alignment.topLeft,
                              child: SafeArea(
                                  child: Icon(
                                Icons.search,
                                size: 25,
                                color: Theme.of(context).colorScheme.onSurface,
                              ))),
                        ),
                        suggestionsBuilder: widget.searchBuilder ??
                            (context, controller) => (widget.children ?? []).prepend(SizedBox(height: 15)),
                      ),
                    // Refresh progress status
                    if ((Share.session.refreshStatus.progressStatus?.isNotEmpty ?? false) &&
                        widget.pageFlags.hasFlag(DataPageType.refreshable))
                      SafeArea(
                        child: Padding(
                          padding: switch (isChildPage ?? false) {
                            false when widget.pageFlags.hasFlag(DataPageType.searchable) =>
                              const EdgeInsets.only(left: 45), // Search icon only
                            false when !widget.pageFlags.hasFlag(DataPageType.searchable) =>
                              const EdgeInsets.only(left: 5), // Nothing in the way
                            true when widget.pageFlags.hasFlag(DataPageType.searchable) && widget.trailing == null =>
                              const EdgeInsets.only(left: 45), // Back icon only
                            true when widget.pageFlags.hasFlag(DataPageType.searchable) && widget.trailing != null =>
                              const EdgeInsets.only(left: 100), // Two icons ::before
                            _ => const EdgeInsets.all(0),
                          },
                          child: Container(
                              margin: const EdgeInsets.only(top: 10, left: 10),
                              child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    Share.session.refreshStatus.progressStatus ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: CupertinoColors.inactiveGray, fontSize: 13, fontWeight: FontWeight.w300),
                                  ))),
                        ),
                      ),
                    if (widget.leading != null &&
                        (!widget.pageFlags.hasFlag(DataPageType.refreshable) ||
                            (Share.session.refreshStatus.progressStatus?.isEmpty ?? true)))
                      SafeArea(
                        child: SizedBox(
                            height: 60,
                            width: 150,
                            child: Container(margin: EdgeInsets.only(left: 10, top: 3, bottom: 1), child: widget.leading)),
                      ),
                  ]));
            }),
            leadingWidth: widget.leading != null ? 150 : null,
            leading: widget.leading != null ? Container() : null,
            actions: <Widget>[Container(margin: EdgeInsets.only(right: 10), child: widget.trailing)],
          ),
          if (widget.pageFlags.hasFlag(DataPageType.segmented) && (widget.segments?.isNotEmpty ?? false))
            SliverAppBar(
              pinned: true,
              primary: false,
              centerTitle: false,
              titleSpacing: 0,
              toolbarHeight: 48,
              automaticallyImplyLeading: false,
              title: widget.pageFlags.hasFlag(DataPageType.segmented) && (widget.segments?.isNotEmpty ?? false)
                  ? TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      isScrollable: widget.segmentController?.scrollable ?? true,
                      tabAlignment:
                          (widget.segmentController?.scrollable ?? false) ? TabAlignment.center : TabAlignment.fill,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      tabs: widget.segments!.values.select((x, _) => Tab(text: x)).toList(),
                      controller: tabController,
                    )
                  : null,
            ),
          if (!(widget.children?.isEmpty ?? true) && widget.pageBuilder == null)
            SliverList.list(
              children: widget.children!,
            ),
          if (widget.pageFlags.hasFlag(DataPageType.segmented) && widget.pageBuilder != null)
            SliverFillRemaining(
              child: TabBarView(
                controller: tabController,
                children: List.generate(widget.segments!.length,
                    (index) => widget.pageBuilder!(context, widget.segments!.keys.elementAt(index))),
              ),
            ),
        ],
      );

      return Scaffold(
        backgroundColor: widget.pageFlags.hasFlag(DataPageType.alternativeBackground) ? Theme.of(context).hoverColor : null,
        body: widget.pageFlags.hasFlag(DataPageType.refreshable)
            ? RefreshIndicator(
                key: widget.pageFlags.hasFlag(DataPageType.refreshable) ? _refreshIndicatorKey : null,
                displacement: 55,
                onRefresh: () async {
                  if (Share.session.refreshStatus.isRefreshing) return;
                  await Share.session.refreshStatus.refreshMutex.protect<void>(() async {
                    try {
                      HapticFeedback.mediumImpact(); // Trigger a haptic feedback
                    } catch (ex) {
                      // ignored
                    }

                    await Share.session.refreshAll(weekStart: widget.selectedDate);
                    // refreshController.refreshCompleted();

                    if (mounted) setState(() {});
                    if (mounted && widget.setState != null) widget.setState!(() {});
                  });
                },
                child: pageChild)
            : pageChild,
      );
    });
  }
}
