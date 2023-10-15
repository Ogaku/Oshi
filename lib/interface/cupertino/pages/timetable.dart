// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogaku/interface/cupertino/pages/home.dart';
import 'package:ogaku/interface/cupertino/widgets/searchable_bar.dart';
import 'package:ogaku/interface/cupertino/widgets/text_chip.dart';
import 'package:ogaku/share/share.dart';

// Boiler: returned to the app tab builder
StatefulWidget get timetablePage => TimetablePage();

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final searchController = TextEditingController();
  String searchQuery = '';

  bool isWorking = false;
  DateTime selectedDate = DateTime.now().asDate();

  @override
  Widget build(BuildContext context) {
    var selectedDay = Share.session.data.timetables.timetable[selectedDate];
    var eventsToday = Share.session.data.student.mainClass.events
        .where((x) => x.date == selectedDate)
        .where((x) =>
            x.titleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.subtitleString.contains(RegExp(searchQuery, caseSensitive: false)) ||
            x.locationString.contains(RegExp(searchQuery, caseSensitive: false)))
        .toList();

    var lessonsToDisplay = selectedDay?.lessonsStripped
            .select((x, index) => x?.firstWhereOrDefault((y) => !y.isCanceled))
            .where((x) => x != null) // Filter out all null entries
            .select((x, index) => x!) // Remove the nullable annotation
            .toList() ??
        [];

    var lessonsWidget = CupertinoListSection.insetGrouped(
      header: Text(DateFormat('EEEE, d MMMM y').format(selectedDate)),
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      additionalDividerMargin: 5,
      children: lessonsToDisplay.isEmpty
          // No messages to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            selectedDay == null ? 'Refresh to synchronize' : 'No lessons, yay!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : lessonsToDisplay
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () {},
                          trailingIcon: CupertinoIcons.share,
                          child: const Text('Share'),
                        ),
                        CupertinoContextMenuAction(
                          onPressed: () {},
                          trailingIcon: CupertinoIcons.calendar,
                          child: const Text('Add to calendar'),
                        ),
                        CupertinoContextMenuAction(
                          onPressed: () {},
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.chat_bubble_2,
                          child: const Text('Inquiry'),
                        ),
                      ],
                      builder: (BuildContext context, Animation<double> animation) {
                        return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: CupertinoDynamicColor.resolve(
                                    CupertinoDynamicColor.withBrightness(
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                    context)),
                            padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight:
                                        animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 80,
                                    maxWidth:
                                        animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 300),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  x.subject?.name ?? 'Unknown',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                )),
                                            Container(
                                                padding: EdgeInsets.only(left: 15),
                                                child: Text(
                                                  x.classroom?.name ?? '',
                                                  style: TextStyle(fontSize: 17),
                                                ))
                                          ]),
                                      Container(
                                          margin: EdgeInsets.only(top: 4),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(
                                                x.detailsTimeTeacherString,
                                                style: TextStyle(fontSize: 17),
                                              )))
                                    ])));
                      })))
              .toList(),
    );

    var bottomWidgets = eventsToday.isEmpty && searchQuery.isNotEmpty
        ? [
            CupertinoListTile(
                title: Opacity(
                    opacity: 0.5,
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'No events matching the query',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        ))))
          ]
        : eventsToday
            .select((x, index) =>
                // Average (yearly - for now)
                Visibility(
                    visible: eventsToday.isNotEmpty,
                    child: CupertinoListTile(
                        padding: EdgeInsets.all(0),
                        title: CupertinoContextMenu.builder(
                            actions: [
                              CupertinoContextMenuAction(
                                onPressed: () {},
                                trailingIcon: CupertinoIcons.share,
                                child: const Text('Share'),
                              ),
                              CupertinoContextMenuAction(
                                onPressed: () {},
                                trailingIcon: CupertinoIcons.calendar,
                                child: const Text('Add to calendar'),
                              ),
                              CupertinoContextMenuAction(
                                onPressed: () {},
                                isDestructiveAction: true,
                                trailingIcon: CupertinoIcons.chat_bubble_2,
                                child: const Text('Inquiry'),
                              ),
                            ],
                            builder: (BuildContext context, Animation<double> animation) {
                              return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: CupertinoDynamicColor.resolve(
                                          CupertinoDynamicColor.withBrightness(
                                              color: const Color.fromARGB(255, 255, 255, 255),
                                              darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                          context)),
                                  padding: EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20),
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight:
                                              animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 80,
                                          maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                              ? double.infinity
                                              : 260),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        x.titleString,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                                      ),
                                                      Visibility(
                                                          visible: x.subtitleString.isNotEmpty,
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Container(
                                                                  margin: EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    x.subtitleString,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                                    style: TextStyle(fontSize: 16),
                                                                  )))),
                                                      Visibility(
                                                          visible: x.locationString.isNotEmpty,
                                                          child: Opacity(
                                                              opacity: 0.5,
                                                              child: Container(
                                                                  margin: EdgeInsets.only(top: 4),
                                                                  child: Text(
                                                                    x.locationString,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(fontSize: 16),
                                                                  )))),
                                                    ])),
                                            Visibility(
                                                visible: x.classroom?.name != null,
                                                child: Container(
                                                    margin: EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      x.classroom?.name ?? '^^',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 16),
                                                    ))),
                                          ])));
                            }))))
            .toList();

    return SearchableSliverNavigationBar(
      leading: GestureDetector(
          onTap: () => _showDialog(
                CupertinoDatePicker(
                  initialDateTime: selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  showDayOfWeek: true,
                  minimumDate: Share.session.data.student.mainClass.beginSchoolYear,
                  maximumDate: Share.session.data.student.mainClass.endSchoolYear,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() => selectedDate = newDate.asDate());
                  },
                ),
              ),
          child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: TextChip(width: 100, text: DateFormat('d.MM.y').format(selectedDate)))),
      trailing: isWorking
          ? Container(margin: EdgeInsets.only(right: 5, top: 5), child: CupertinoActivityIndicator(radius: 12))
          : GestureDetector(
              onTap: () {
                if (isWorking) return;
                setState(() => isWorking = true);
                try {
                  Share.session.refresh(weekStart: selectedDate).then((value) => setState(() => isWorking = false));
                } catch (ex) {
                  // ignored
                }
              },
              child: Icon(CupertinoIcons.refresh)),
      searchController: searchController,
      onChanged: (s) => setState(() => searchQuery = s),
      largeTitle: Text('Schedule'),
      children: [
        (searchQuery.isEmpty ? lessonsWidget : Container()),
        Visibility(
            visible: bottomWidgets.isNotEmpty,
            child: Container(
                margin: EdgeInsets.only(top: 20),
                child: CupertinoListSection.insetGrouped(
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  additionalDividerMargin: 5,
                  children: bottomWidgets.isNotEmpty ? bottomWidgets : [Text('')],
                )))
      ],
    );
  }

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}
