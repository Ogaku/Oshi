// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/interface/cupertino/widgets/text_chip.dart';
import 'package:oshi/models/data/classroom.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/share/share.dart';

class EventComposePage extends StatefulWidget {
  const EventComposePage({super.key});

  @override
  State<EventComposePage> createState() => _EventComposePageState();
}

class _EventComposePageState extends State<EventComposePage> {
  bool showOptional = false;

  EventCategory category = EventCategory.other;
  String customCategoryName = '';

  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController classroomController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController lessonNumberController = TextEditingController();

  late DateTime date;
  DateTime? startTime, endTime;

  @override
  void initState() {
    super.initState();
    date = DateTime.now().asDate();
  }

  @override
  Widget build(BuildContext context) {
    var categoriesToDisplay = EventCategory.values
        .where((x) => x != EventCategory.admin)
        .where((x) => x.asString().contains(RegExp(categoryController.text, caseSensitive: false)));

    return SearchableSliverNavigationBar(
      anchor: 0.0,
      searchController: TextEditingController(),
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
      largeTitle: subjectController.text.isEmpty
          ? Text('New event')
          : Text(subjectController.text, maxLines: 1, overflow: TextOverflow.ellipsis),
      leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text('Cancel', style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
          onPressed: () async => Navigator.pop(context)),
      transitionBetweenRoutes: false,
      trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.centerRight,
          child: Icon(CupertinoIcons.add,
              color: (subjectController.text.isNotEmpty && messageController.text.isNotEmpty)
                  ? CupertinoTheme.of(context).primaryColor
                  : CupertinoColors.inactiveGray),
          onPressed: () {
            try {
              Share.session.customEvents.add(Event(
                  title: subjectController.text,
                  content: messageController.text,
                  category: category,
                  categoryName: customCategoryName,
                  isOwnEvent: true,
                  classroom: classroomController.text.isNotEmpty
                      ? Classroom(name: classroomController.text, symbol: classroomController.text)
                      : null,
                  lessonNo: int.tryParse(lessonNumberController.text),
                  date: date,
                  timeFrom: startTime,
                  timeTo: endTime));
              Share.settings.save();
            } catch (e) {
              if (Platform.isAndroid || Platform.isIOS) {
                Fluttertoast.showToast(
                  msg: '$e',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                );
              }
            }
            // Close the current page
            Navigator.pop(context);
          }),
      child: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Date
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text('Date:', style: TextStyle(fontWeight: FontWeight.w600))),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: GestureDetector(
                                onTap: () => _showDialog(
                                      CupertinoDatePicker(
                                        initialDateTime: date,
                                        mode: CupertinoDatePickerMode.date,
                                        use24hFormat: true,
                                        showDayOfWeek: true,
                                        minimumDate: Share.session.data.student.mainClass.beginSchoolYear,
                                        maximumDate: Share.session.data.student.mainClass.endSchoolYear,
                                        onDateTimeChanged: (DateTime newDate) => setState(() => date = newDate),
                                      ),
                                    ),
                                child: Container(
                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Text(DateFormat.yMd(Share.settings.appSettings.localeCode).format(date),
                                        style: TextStyle(color: CupertinoTheme.of(context).primaryColor)))),
                          )
                        ]),
                    // Category
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text('Category:', style: TextStyle(fontWeight: FontWeight.w600))),
                          ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 250),
                              child: CupertinoTextField.borderless(
                                  onChanged: (s) => setState(() {}),
                                  controller: categoryController,
                                  placeholder: 'Start typing...')),
                        ]),
                    // Receivers
                    Container(
                        margin: EdgeInsets.only(left: 5),
                        child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: TextChip(
                                noMargin: true,
                                text: customCategoryName.isEmpty ? category.asString() : customCategoryName,
                                radius: 20,
                                fontSize: 14,
                                insets: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                fontWeight: FontWeight.w600),
                            onPressed: () => setState(() {
                                  category = EventCategory.other;
                                  customCategoryName = '';
                                }))),
                    // Either the receiver search or the contents
                    categoryController.text.isNotEmpty
                        ? CupertinoListSection.insetGrouped(
                            margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                            additionalDividerMargin: 5,
                            children: categoriesToDisplay.isEmpty
                                // No messages to display
                                ? [
                                    CupertinoListTile(
                                        title: Container(
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                onTap: () => setState(() {
                                                      category = EventCategory.other;
                                                      customCategoryName = categoryController.text;
                                                      categoryController.text = '';
                                                    }),
                                                child: Text(
                                                  'Custom category: ${categoryController.text}',
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                ))))
                                  ]
                                // Bindable messages layout
                                : categoriesToDisplay
                                    .select((x, index) => CupertinoListTile(
                                        onTap: category == x
                                            ? null
                                            : () => setState(() {
                                                  category = x;
                                                  customCategoryName = '';
                                                  categoryController.text = '';
                                                }),
                                        title: Opacity(opacity: category == x ? 0.3 : 1.0, child: Text(x.asString()))))
                                    .toList())
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                                // Subject input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    onChanged: (s) => setState(() {}),
                                    controller: subjectController,
                                    placeholder: 'Title',
                                    placeholderStyle:
                                        TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.tertiaryLabel)),
                                // Message input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    onChanged: (s) => setState(() {}),
                                    controller: messageController,
                                    placeholder: 'Type in the event description here...'),
                                Container(
                                    margin: EdgeInsets.only(left: 5, top: 25),
                                    child: GestureDetector(
                                        onTap: () => setState(() => showOptional = !showOptional),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                  showOptional
                                                      ? CupertinoIcons.chevron_up_circle
                                                      : CupertinoIcons.chevron_down_circle,
                                                  size: 20),
                                              Container(
                                                  margin: EdgeInsets.only(left: 5),
                                                  child: Opacity(
                                                      opacity: 0.5,
                                                      child: Text('Optional',
                                                          style: TextStyle(fontWeight: FontWeight.normal)))),
                                            ]))),
                                AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 100),
                                    switchInCurve: Curves.easeInExpo,
                                    child: showOptional
                                        ? Container(
                                            margin: EdgeInsets.only(top: 5),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  // Start time
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            margin: EdgeInsets.only(left: 5),
                                                            child: Text('Start time:',
                                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                                        Container(
                                                          margin: EdgeInsets.only(left: 5),
                                                          child: GestureDetector(
                                                              onTap: () => _showDialog(
                                                                    CupertinoDatePicker(
                                                                      initialDateTime: date,
                                                                      mode: CupertinoDatePickerMode.time,
                                                                      use24hFormat: true,
                                                                      showDayOfWeek: true,
                                                                      minimumDate: Share
                                                                          .session.data.student.mainClass.beginSchoolYear,
                                                                      maximumDate:
                                                                          Share.session.data.student.mainClass.endSchoolYear,
                                                                      onDateTimeChanged: (DateTime newDate) =>
                                                                          setState(() => startTime = newDate),
                                                                    ),
                                                                  ),
                                                              child: Container(
                                                                  margin: EdgeInsets.only(top: 5, bottom: 5),
                                                                  child: Text(
                                                                      startTime == null
                                                                          ? 'not specified'
                                                                          : DateFormat.Hm(
                                                                                  Share.settings.appSettings.localeCode)
                                                                              .format(startTime!),
                                                                      style: TextStyle(
                                                                          color: CupertinoTheme.of(context).primaryColor)))),
                                                        ),
                                                        Visibility(
                                                            visible: startTime != null,
                                                            child: Container(
                                                                margin: EdgeInsets.only(left: 3),
                                                                child: GestureDetector(
                                                                  onTap: () => setState(() => startTime = null),
                                                                  child: Icon(CupertinoIcons.xmark_circle, size: 15),
                                                                )))
                                                      ]),
                                                  // End time
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            margin: EdgeInsets.only(left: 5),
                                                            child: Text('End time:',
                                                                style: TextStyle(fontWeight: FontWeight.w600))),
                                                        Container(
                                                          margin: EdgeInsets.only(left: 5),
                                                          child: GestureDetector(
                                                              onTap: () => _showDialog(
                                                                    CupertinoDatePicker(
                                                                      initialDateTime: date,
                                                                      mode: CupertinoDatePickerMode.time,
                                                                      use24hFormat: true,
                                                                      showDayOfWeek: true,
                                                                      minimumDate: Share
                                                                          .session.data.student.mainClass.beginSchoolYear,
                                                                      maximumDate:
                                                                          Share.session.data.student.mainClass.endSchoolYear,
                                                                      onDateTimeChanged: (DateTime newDate) =>
                                                                          setState(() => endTime = newDate),
                                                                    ),
                                                                  ),
                                                              child: Container(
                                                                  margin: EdgeInsets.only(top: 5, bottom: 5),
                                                                  child: Text(
                                                                      endTime == null
                                                                          ? 'not specified'
                                                                          : DateFormat.Hm(
                                                                                  Share.settings.appSettings.localeCode)
                                                                              .format(endTime!),
                                                                      style: TextStyle(
                                                                          color: CupertinoTheme.of(context).primaryColor)))),
                                                        ),
                                                        Visibility(
                                                            visible: endTime != null,
                                                            child: Container(
                                                                margin: EdgeInsets.only(left: 3),
                                                                child: GestureDetector(
                                                                  onTap: () => setState(() => endTime = null),
                                                                  child: Icon(CupertinoIcons.xmark_circle, size: 15),
                                                                )))
                                                      ]),
                                                  // Classroom input
                                                  CupertinoTextField.borderless(
                                                      maxLines: null,
                                                      onChanged: (s) => setState(() {}),
                                                      controller: classroomController,
                                                      placeholder: 'Classroom'),
                                                  // Lesson number input
                                                  CupertinoTextField.borderless(
                                                      maxLines: null,
                                                      onChanged: (s) => setState(() => lessonNumberController.text =
                                                          int.tryParse(lessonNumberController.text)?.toString() ?? ''),
                                                      controller: lessonNumberController,
                                                      placeholder: 'Lesson number'),
                                                ]))
                                        : null),
                              ]),
                  ]))),
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
