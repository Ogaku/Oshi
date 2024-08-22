// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/containers.dart';
// import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:oshi/share/share.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
      super.pageBuilder});

  @override
  State<DataPage> createState() => DataPageState();
}

class DataPageState extends State<DataPage> with TickerProviderStateMixin {
  late final TabController tabController;
  bool? isChildPage;
  var refreshController = RefreshController(initialRefresh: false);

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
      widget.setState!(() {});
      if (self) setState(() {});
    }
  }

  void pushUpdateSegment() {
    if (widget.segmentController?.segment == widget.segments?.keys.elementAt(tabController.index)) return;
    tabController.animateTo(widget.segments?.keys.toList().indexOf(widget.segmentController?.segment) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // Detect if this is a child page (once)
    isChildPage ??= Navigator.of(context).canPop();

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

    // Pull the refresh status from the session data
    refreshController.headerMode?.value =
        Share.session.refreshStatus.isRefreshing ? RefreshStatus.refreshing : RefreshStatus.idle;

    // onChanged, onSubmitted -> already handled by searchController
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      // ignore: unused_local_variable
      ColorScheme? lightColorScheme, darkColorScheme;

      if (lightDynamic != null && darkDynamic != null) {
        (lightColorScheme, darkColorScheme) = generateDynamicColourSchemes(lightDynamic, darkDynamic);
      }

      return Scaffold(
        backgroundColor: widget.pageFlags.hasFlag(DataPageType.alternativeBackground) ? Theme.of(context).hoverColor : null,
        body: SmartRefresher(
          enablePullDown: widget.pageFlags.hasFlag(DataPageType.refreshable),
          header: MaterialClassicHeader(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          controller: refreshController,
          onRefresh: () {
            if (Share.session.refreshStatus.isRefreshing) return;
            Share.session.refreshStatus.refreshMutex.protect<void>(() async {
              try {
                HapticFeedback.mediumImpact(); // Trigger a haptic feedback
              } catch (ex) {
                // ignored
              }

              await Share.session.refreshAll(weekStart: widget.selectedDate);

              setState(() {
                refreshController.refreshCompleted();
              });

              if (widget.setState != null) widget.setState!(() {});
            });
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                key: ValueKey<int>(1),
                backgroundColor:
                    widget.pageFlags.hasFlag(DataPageType.alternativeBackground) ? Theme.of(context).hoverColor : null,
                pinned: true,
                snap: false,
                floating: false,
                expandedHeight: 130.0,
                flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  return FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: EdgeInsets.only(left: 20, bottom: 15, right: 20),
                      title: AnimatedOpacity(
                          duration: Duration(milliseconds: 250),
                          opacity: (top > 110 || widget.leading == null) ? 1.0 : 0.0,
                          child: Text(widget.title)),
                      background: (isChildPage ?? false)
                          ? GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: SafeArea(
                                        child: Icon(
                                      Icons.arrow_back,
                                      size: 25,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ))),
                              ),
                            )
                          : ((widget.pageFlags.hasFlag(DataPageType.searchable) &&
                                  (Share.session.refreshStatus.progressStatus?.isEmpty ?? true)
                              ? SearchAnchor(
                                  isFullScreen: true,
                                  builder: (context, controller) => Padding(
                                    padding: (isChildPage ?? false) && widget.trailing != null
                                        ? const EdgeInsets.only(left: 65, top: 17)
                                        : const EdgeInsets.all(15.0),
                                    child: Align(
                                        alignment: (isChildPage ?? false) && widget.trailing == null
                                            ? Alignment.topRight
                                            : Alignment.topLeft,
                                        child: SafeArea(
                                            child: Icon(
                                          Icons.search,
                                          size: 25,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ))),
                                  ),
                                  suggestionsBuilder: widget.searchBuilder ??
                                      (context, controller) => (widget.children ?? []).prepend(SizedBox(height: 15)),
                                )
                              : null)));
                }),
                leadingWidth: (isChildPage ?? false) ? null : 150,
                leading: (isChildPage ?? false)
                    ? Container() // Don't show the funny arrow
                    : ((Share.session.refreshStatus.progressStatus?.isNotEmpty ?? false)
                        ? Container(
                            margin: const EdgeInsets.only(top: 7, left: 10),
                            child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  Share.session.refreshStatus.progressStatus ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: CupertinoColors.inactiveGray, fontSize: 13, fontWeight: FontWeight.w300),
                                )))
                        : Container(margin: EdgeInsets.only(left: 10, top: 3, bottom: 1), child: widget.leading)),
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
          ),
        ),
      );
    });
  }
}
