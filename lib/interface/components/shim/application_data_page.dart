import 'package:flutter/widgets.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/components/material/data_page.dart' as material;
import 'package:oshi/interface/components/cupertino/data_page.dart' as cupertino;

abstract class DataPageBase extends StatefulWidget {
  const DataPageBase(
      {super.key,
      required this.title,
      this.pageFlags = 0,
      this.setState,
      this.searchController,
      this.segmentController,
      this.children,
      this.selectedDate,
      this.leading,
      this.trailing,
      this.segments,
      this.previousPageTitle});

  final String title; // Page title
  final String? previousPageTitle;
  final Widget? leading;
  final Widget? trailing;

  final int pageFlags; // Page flags
  final void Function(VoidCallback fn)? setState;

  final TextEditingController? searchController; // Searchable
  final SegmentController? segmentController; // Segmentable
  final Map<dynamic, String>? segments; // For segmented control

  final List<Widget>? children; // Page children
  final DateTime? selectedDate; // For refreshes

  static DataPageBase adaptive(
      {required String title,
      String? previousPageTitle,
      Widget? leading,
      Widget? trailing,
      int pageFlags = 0,
      void Function(VoidCallback fn)? setState,
      TextEditingController? searchController,
      SegmentController? segmentController,
      Map<dynamic, String>? segments,
      List<Widget>? children,
      DateTime? selectedDate}) {
    // Search controller watcher
    if (searchController != null && setState != null) {
      searchController.removeListener(() => setState(() => {}));
      searchController.addListener(() => setState(() => {}));
    }

    // Segment controller watcher
    if (segmentController != null && setState != null) {
      segmentController.removeListener(() => setState(() => {}));
      segmentController.addListener(() => setState(() => {}));
    }

    return Share.settings.appSettings.useCupertino
        ? cupertino.DataPage(
            title: title,
            previousPageTitle: previousPageTitle,
            leading: leading,
            trailing: trailing,
            pageFlags: pageFlags,
            setState: setState,
            searchController: searchController,
            segmentController: segmentController,
            segments: segments,
            selectedDate: selectedDate,
            children: children)
        : material.DataPage(
            title: title,
            previousPageTitle: previousPageTitle,
            leading: leading,
            trailing: trailing,
            pageFlags: pageFlags,
            setState: setState,
            searchController: searchController,
            segmentController: segmentController,
            segments: segments,
            selectedDate: selectedDate,
            children: children);
  }
}

enum DataPageType with EnumFlag {
  searchable, // Search bar -> disableAddons
  segmented, // Segmented control
  refreshable, // Pull to refresh
  noTransitions, // No transitions -> transitionBetweenRoutes
  childPage, // Small header page -> alwaysShowMiddle

  segmentedSticky, // Sticky segmented control, MUST be used with segmented -> alwaysShowAddons
  keepBackgroundWatchers, // Keep background color watchers active -> for Cupertino only
  boxedPage, // Boxed page -> useSliverBox, for Cupertino only
  noTitleSpace, // No space for title -> anchor = 0.0, for Cupertino only
  singleChild, // Single child -> anti-column measure, for Cupertino only
  withBase, // With base -> add the page scaffold with additional theming

  removeLargeTitle, // Remove large title -> don't use the large title
  removeMiddleTitle, // Remove middle title -> don't use the middle title
  alternativeBackground, // Alternative background -> use the alternative background
}

class SegmentController with ChangeNotifier {
  SegmentController({dynamic segment}) : _segment = segment;
  dynamic _segment;

  get segment => _segment;

  set segment(value) {
    _segment = value;
    notifyListeners();
  }
}
