// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/interface/components/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/share/share.dart';

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
      transitionBetweenRoutes: !widget.pageFlags.hasFlag(DataPageType.noTransitions),
      alwaysShowMiddle: widget.pageFlags.hasFlag(DataPageType.childPage),
      previousPageTitle: widget.previousPageTitle,
      middle: widget.pageFlags.hasFlag(DataPageType.removeMiddleTitle) ? null : Text(widget.title),
      segments: widget.pageFlags.hasFlag(DataPageType.segmented) ? widget.segments : null,
      setState: widget.setState,
      anchor: widget.pageFlags.hasFlag(DataPageType.noTitleSpace) ? 0.0 : null,
      disableAddons:
          !widget.pageFlags.hasFlag(DataPageType.searchable) || !widget.pageFlags.hasFlag(DataPageType.refreshable),
      useSliverBox: widget.pageFlags.hasFlag(DataPageType.boxedPage),
      selectedDate: widget.selectedDate,
      keepBackgroundWatchers: widget.pageFlags.hasFlag(DataPageType.keepBackgroundWatchers),
      alwaysShowAddons: widget.pageFlags.hasFlag(DataPageType.segmentedSticky),
      segmentController: widget.pageFlags.hasFlag(DataPageType.segmented) ? widget.segmentController : null,
    );

    return DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) => Scaffold(
            backgroundColor:
                widget.pageFlags.hasFlag(DataPageType.alternativeBackground) ? Theme.of(context).hoverColor : null,
            body: CustomScrollView(
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
                        background: (widget.pageFlags.hasFlag(DataPageType.searchable)
                            ? SearchAnchor(
                                isFullScreen: true,
                                builder: (context, controller) => Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.search,
                                        size: 25,
                                        color: Theme.of(context).indicatorColor,
                                      )),
                                ),
                                suggestionsBuilder: widget.searchBuilder ??
                                    (context, controller) => (widget.children ?? []).prepend(SizedBox(height: 15)),
                              )
                            : null));
                  }),
                  leadingWidth: 110,
                  leading: (Share.session.refreshStatus.progressStatus?.isNotEmpty ?? false)
                      ? Container(
                          margin: const EdgeInsets.only(top: 7),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                Share.session.refreshStatus.progressStatus ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: CupertinoColors.inactiveGray, fontSize: 13, fontWeight: FontWeight.w300),
                              )))
                      : Container(margin: EdgeInsets.only(left: 10, top: 3, bottom: 1), child: widget.leading),
                  actions: <Widget>[]
                      .append(
                        !Share.session.refreshStatus.isRefreshing || widget.setState == null
                            ? Container(margin: EdgeInsets.only(right: 10), child: widget.trailing)
                            : Container(
                                margin: const EdgeInsets.only(right: 5, top: 5),
                                child: AnimatedRotation(
                                    turns: 5,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.ease,
                                    child: Text('data'))),
                      )
                      .toList(),
                ),
                // SliverToBoxAdapter(
                //     child: ),
                if (!(widget.children?.isEmpty ?? true))
                  SliverList.list(
                    children: widget.children!,
                  ),
              ],
            )));
  }
}
