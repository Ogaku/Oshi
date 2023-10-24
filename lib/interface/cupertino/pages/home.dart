// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/views/message_compose.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/cupertino/widgets/text_chip.dart' show TextChip;

// Boiler: returned to the app tab builder
StatefulWidget get homePage => HomePage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();

  bool get isLucky =>
      Share.session.data.student.mainClass.unit.luckyNumber != null &&
      Share.session.data.student.account.number == Share.session.data.student.mainClass.unit.luckyNumber;

  @override
  Widget build(BuildContext context) {
    // Event list for the next week (7 days), exc homeworks and teacher absences
    var eventsWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category != EventCategory.homework && x.category != EventCategory.teacher)
        .where((x) => x.date?.isAfter(DateTime.now().asDate()) ?? false)
        .where((x) => x.date?.isBefore(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .orderBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Event list for the next week (7 days), exc homeworks and teacher absences
    var gradesWeek = Share.session.data.student.subjects
        .where((x) => x.grades.isNotEmpty)
        .select((x, index) => (
              lesson: x,
              grades: x.grades.where((y) => y.addDate.isAfter(DateTime.now().subtract(Duration(days: 7)).asDate())).toList()
            ))
        .where((x) => x.grades.isNotEmpty)
        .orderByDescending((x) => x.grades.orderByDescending((y) => y.addDate).first.addDate)
        .toList();

    // Homework list for the next week (7 days)
    var homeworksWeek = Share.session.data.student.mainClass.events
        .where((x) => x.category == EventCategory.homework)
        .where((x) => x.timeTo?.isAfter(DateTime.now().asDate()) ?? false)
        .where((x) => x.timeTo?.isBefore(DateTime.now().add(Duration(days: 7)).asDate()) ?? false)
        .orderByDescending((x) => x.done ? 0 : 1)
        .thenBy((x) => x.date ?? x.timeTo ?? x.timeFrom)
        .toList();

    // Homeworks - first if any(), otherwise last
    var homeworksLast = homeworksWeek.isEmpty || homeworksWeek.all((x) => x.done);
    var homeworksWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      dividerMargin: 35,
      header: Text('Homeworks'),
      children: homeworksWeek.isEmpty
          // No homeworks to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'All done, yay!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable homework layout
          : homeworksWeek
              .select((x, index) => CupertinoListTile(
                  padding: EdgeInsets.all(0),
                  title: CupertinoContextMenu.builder(
                      actions: [
                        CupertinoContextMenuAction(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          trailingIcon: CupertinoIcons.share,
                          child: const Text('Share'),
                        ),
                        CupertinoContextMenuAction(
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.chat_bubble_2,
                          child: const Text('Inquiry'),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => MessageComposePage(
                                    receivers: x.sender != null ? [x.sender!] : [],
                                    subject:
                                        'Pytanie o pracę domową na dzień ${DateFormat("y.M.d").format(x.timeTo ?? x.timeFrom)}',
                                    signature:
                                        '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                          },
                        ),
                      ],
                      builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                          onPressed: () {
                            Share.tabsNavigatePage.broadcast(Value(2));
                            Future.delayed(Duration(milliseconds: 250))
                                .then((arg) => Share.timetableNavigateDay.broadcast(Value(x.timeTo ?? x.timeFrom)));
                          },
                          padding: EdgeInsets.zero,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoDynamicColor.withBrightness(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                      context)),
                              padding: EdgeInsets.only(right: 10, left: 6),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 125,
                                      maxWidth:
                                          animation.value < CupertinoContextMenu.animationOpensAt ? double.infinity : 260),
                                  child: Opacity(
                                      opacity: x.done ? 0.5 : 1.0,
                                      child: Container(
                                          margin: EdgeInsets.only(right: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextChip(
                                                        text: DateFormat('d/M').format(x.timeTo ?? x.timeFrom),
                                                        margin: EdgeInsets.only(top: 6, bottom: 6, right: 10)),
                                                    Expanded(
                                                        child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Flexible(
                                                                child: Text(
                                                              x.title ?? x.content,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  color: CupertinoDynamicColor.resolve(
                                                                      CupertinoDynamicColor.withBrightness(
                                                                          color: CupertinoColors.black,
                                                                          darkColor: CupertinoColors.white),
                                                                      context)),
                                                            )))),
                                                    Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Visibility(
                                                          visible: x.done,
                                                          child: Container(
                                                              margin: EdgeInsets.only(left: 5),
                                                              child: Icon(CupertinoIcons.check_mark)),
                                                        ))
                                                  ],
                                                ),
                                                Visibility(
                                                    visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                    child: Container(
                                                        margin: EdgeInsets.only(left: 5, right: 5, bottom: 7, top: 3),
                                                        child: Flexible(
                                                            child: Text(
                                                          'Notes: ${x.content}',
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                              color: CupertinoDynamicColor.resolve(
                                                                  CupertinoDynamicColor.withBrightness(
                                                                      color: CupertinoColors.black,
                                                                      darkColor: CupertinoColors.white),
                                                                  context)),
                                                        )))),
                                                Visibility(
                                                    visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                    child: Container(
                                                        margin: EdgeInsets.only(left: 5, right: 5, bottom: 7),
                                                        child: Flexible(
                                                            child: Text(
                                                          x.addedByString,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                              color: CupertinoDynamicColor.resolve(
                                                                  CupertinoDynamicColor.withBrightness(
                                                                      color: CupertinoColors.black,
                                                                      darkColor: CupertinoColors.white),
                                                                  context)),
                                                        ))))
                                              ])))))))))
              .toList(),
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 0, 0, 0)),
      child: SearchableSliverNavigationBar(
        setState: setState,
        segments: {'home': 'Home', 'timeline': 'Timeline'},
        searchController: searchController,
        largeTitle: Text('Home'),
        trailing: Icon(CupertinoIcons.gear),
        children: [
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            hasLeading: false,
            header: Text('Summary'),
            children: [
              CupertinoListTile(
                  title: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODO Conditional lesson text',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Visibility(
                              visible: Share.session.data.student.mainClass.unit.luckyNumber != null,
                              child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                      margin: EdgeInsets.only(top: 5), child: Text("You're the lucky one today!"))))
                        ],
                      ))),
              CupertinoListTile(
                  title: Text(
                'TODO Conditional lesson text',
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
              CupertinoListTile(
                  title: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TODO Conditional lesson text'),
                          Visibility(
                              visible: Share.session.data.student.mainClass.unit.luckyNumber == null,
                              child: Opacity(
                                  opacity: 0.5,
                                  child: Container(
                                      margin: EdgeInsets.only(top: 5), child: Text('TODO Conditional lesson text'))))
                        ],
                      ))),
              CupertinoListTile(title: Text('TODO Conditional lesson text')),
            ],
          ),
          // Homeworks - first if any(), otherwise last
          Visibility(visible: !homeworksLast, child: homeworksWidget),
          // Upcoming events - in the middle, or top
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            dividerMargin: 35,
            header: Text('Upcoming events'),
            children: eventsWeek.isEmpty
                // No events to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No events to display',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable event layout
                : eventsWeek
                    .select((x, index) => CupertinoListTile(
                        padding: EdgeInsets.all(0),
                        title: CupertinoContextMenu.builder(
                            actions: [
                              CupertinoContextMenuAction(
                                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                trailingIcon: CupertinoIcons.share,
                                child: const Text('Share'),
                              ),
                              CupertinoContextMenuAction(
                                isDestructiveAction: true,
                                trailingIcon: CupertinoIcons.chat_bubble_2,
                                child: const Text('Inquiry'),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => MessageComposePage(
                                          receivers: x.sender != null ? [x.sender!] : [],
                                          subject:
                                              'Pytanie o wydarzenie w dniu ${DateFormat("y.M.d").format(x.date ?? x.timeFrom)}',
                                          signature:
                                              '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                                },
                              ),
                            ],
                            builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                                onPressed: () {
                                  Share.tabsNavigatePage.broadcast(Value(2));
                                  Future.delayed(Duration(milliseconds: 250))
                                      .then((arg) => Share.timetableNavigateDay.broadcast(Value(x.date ?? x.timeFrom)));
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                            context)),
                                    padding: EdgeInsets.only(right: 10, left: 6),
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 100,
                                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 260),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextChip(
                                                      text: DateFormat('d/M').format(x.date ?? x.timeFrom),
                                                      margin: EdgeInsets.only(top: 6, bottom: 6, right: 10)),
                                                  Flexible(
                                                      child: Text(
                                                    x.title ?? x.content,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: CupertinoDynamicColor.resolve(
                                                            CupertinoDynamicColor.withBrightness(
                                                                color: CupertinoColors.black,
                                                                darkColor: CupertinoColors.white),
                                                            context)),
                                                  ))
                                                ],
                                              ),
                                              Visibility(
                                                  visible: animation.value >= CupertinoContextMenu.animationOpensAt,
                                                  child: Container(
                                                      margin: EdgeInsets.only(left: 5, right: 5, bottom: 7),
                                                      child: Flexible(
                                                          child: Text(
                                                        x.locationTypeString,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500,
                                                            color: CupertinoDynamicColor.resolve(
                                                                CupertinoDynamicColor.withBrightness(
                                                                    color: CupertinoColors.black,
                                                                    darkColor: CupertinoColors.white),
                                                                context)),
                                                      ))))
                                            ])))))))
                    .toList(),
          ),
          // Recent grades - always below events
          CupertinoListSection.insetGrouped(
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            additionalDividerMargin: 5,
            header: Text('Recent grades'),
            children: gradesWeek.isEmpty
                // No grades to display
                ? [
                    CupertinoListTile(
                        title: Opacity(
                            opacity: 0.5,
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'No recent grades',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                ))))
                  ]
                // Bindable grades layout
                : gradesWeek
                    .select((x, index) => CupertinoListTile(
                        padding: EdgeInsets.all(0),
                        title: CupertinoContextMenu.builder(
                            actions: [
                              CupertinoContextMenuAction(
                                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                trailingIcon: CupertinoIcons.share,
                                child: const Text('Share'),
                              ),
                              CupertinoContextMenuAction(
                                isDestructiveAction: true,
                                trailingIcon: CupertinoIcons.chat_bubble_2,
                                child: const Text('Inquiry'),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop();
                                  showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (context) => MessageComposePage(
                                          receivers: [x.lesson.teacher],
                                          subject:
                                              'Pytanie o ${x.grades.length > 1 ? "oceny" : "ocenę"} ${x.grades.select((y, index) => y.value).join(', ')} z przedmiotu ${x.lesson.name}',
                                          signature:
                                              '${Share.session.data.student.account.name}, ${Share.session.data.student.mainClass.name}'));
                                },
                              ),
                            ],
                            builder: (BuildContext context, Animation<double> animation) => CupertinoButton(
                                onPressed: () {
                                  Share.tabsNavigatePage.broadcast(Value(1));
                                  Future.delayed(Duration(milliseconds: 250))
                                      .then((arg) => Share.gradesNavigate.broadcast(Value(x.lesson)));
                                },
                                padding: EdgeInsets.zero,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoDynamicColor.withBrightness(
                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                            context)),
                                    padding: EdgeInsets.only(right: 10, left: 6),
                                    child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 100,
                                            maxWidth: animation.value < CupertinoContextMenu.animationOpensAt
                                                ? double.infinity
                                                : 260),
                                        child: Container(
                                            margin: EdgeInsets.only(right: 10, left: 7),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 2,
                                                    child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          x.lesson.name,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w700,
                                                              color: CupertinoDynamicColor.resolve(
                                                                  CupertinoDynamicColor.withBrightness(
                                                                      color: CupertinoColors.black,
                                                                      darkColor: CupertinoColors.white),
                                                                  context)),
                                                        ))),
                                                Expanded(
                                                    child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: RichText(
                                                            overflow: TextOverflow.ellipsis,
                                                            text: TextSpan(
                                                                text: '',
                                                                children: x.grades
                                                                    .select((y, index) => TextSpan(
                                                                        text: y.value,
                                                                        style: TextStyle(
                                                                            fontSize: 25,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: y.asColor())))
                                                                    .toList()
                                                                    .intersperse(TextSpan(
                                                                        text: ', ',
                                                                        style: TextStyle(
                                                                            fontSize: 25,
                                                                            fontWeight: FontWeight.w600,
                                                                            color: CupertinoDynamicColor.resolve(
                                                                                CupertinoDynamicColor.withBrightness(
                                                                                    color: CupertinoColors.black,
                                                                                    darkColor: CupertinoColors.white),
                                                                                context))))
                                                                    .toList()))))
                                              ],
                                            ))))))))
                    .toList(),
          ),
          // Homeworks - first if any(), otherwise last
          Visibility(visible: homeworksLast, child: homeworksWidget)
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime asDate({bool utc = false}) => utc ? DateTime.utc(year, month, day) : DateTime(year, month, day);
}

extension ColorsExtension on Grade {
  Color asColor() => switch (asValue.round()) {
        6 => CupertinoColors.systemTeal,
        5 => CupertinoColors.systemGreen,
        4 => Color(0xFF76FF03),
        3 => CupertinoColors.systemOrange,
        2 => CupertinoColors.systemRed,
        1 => CupertinoColors.destructiveRed,
        _ => CupertinoColors.inactiveGray
      };
}

extension ListExtension on List<TextSpan> {
  Iterable<TextSpan> intersperse(TextSpan element) sync* {
    for (int i = 0; i < length; i++) {
      yield this[i];
      if (length != i + 1) yield element;
    }
  }
}
