// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/models/data/classroom.dart';
import 'package:oshi/models/data/event.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/share/share.dart';

class EventComposePage extends StatefulWidget {
  const EventComposePage(
      {super.key, this.date, this.startTime, this.endTime, this.lessonNumber, this.classroom, this.previous});

  final DateTime? date, startTime, endTime;
  final int? lessonNumber;
  final String? classroom;
  final Event? previous;

  @override
  State<EventComposePage> createState() => _EventComposePageState();
}

class _EventComposePageState extends State<EventComposePage> {
  bool showOptional = false;
  bool shareEvent = false;

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
    date = widget.date ?? DateTime.now().asDate();
    shareEvent = Share.session.settings.shareEventsByDefault;

    if (widget.startTime != null || widget.endTime != null || widget.lessonNumber != null || widget.classroom != null) {
      showOptional = true;
      startTime = widget.startTime;
      endTime = widget.endTime;

      lessonNumberController.text = widget.lessonNumber?.toString() ?? '';
      classroomController.text = widget.classroom ?? '';
    }

    if (widget.previous != null) {
      subjectController.text = widget.previous!.title ?? '';
      messageController.text = widget.previous!.content;
      classroomController.text = widget.previous!.classroom?.name ?? '';
      // categoryController.text = widget.previous!.categoryName;
      customCategoryName = widget.previous!.categoryName;
      category = widget.previous!.category;
      date = widget.previous!.date ?? DateTime.now().asDate();
      shareEvent = widget.previous!.isSharedEvent;

      if (widget.previous!.timeFrom != DateTime(2000) ||
          widget.previous!.timeTo != null ||
          widget.previous!.lessonNo != null ||
          widget.previous!.classroom != null) {
        showOptional = true;
        startTime = widget.previous!.timeFrom != DateTime(2000) ? widget.previous!.timeFrom : null;
        endTime = widget.previous!.timeTo != DateTime(2000) ? widget.previous!.timeTo : null;
        lessonNumberController.text = widget.previous!.lessonNo?.toString() ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var categoriesToDisplay = EventCategory.values
        .where((x) => x != EventCategory.admin)
        .where((x) => x.asString().contains(RegExp(categoryController.text, caseSensitive: false)));

    return DataPageBase.adaptive(
      pageFlags: [
        DataPageType.noTitleSpace,
        DataPageType.noTransitions,
        DataPageType.alternativeBackground,
      ].flag,
      title: (shareEvent ? messageController : subjectController).text.isEmpty
          ? 'New event'
          : (shareEvent ? messageController : subjectController).text,
      childOverride: false,
      leading: Align(
          alignment: Alignment.centerLeft,
          child: AdaptiveButton(title: 'Cancel', click: () async => Navigator.pop(context))),
      trailing: CupertinoButton(
          padding: EdgeInsets.all(5),
          alignment: Alignment.centerRight,
          onPressed: ((shareEvent || subjectController.text.isNotEmpty) && messageController.text.isNotEmpty)
              ? () {
                  try {
                    if (widget.previous != null) {
                      (widget.previous!.isSharedEvent ? Share.session.sharedEvents : Share.session.customEvents)
                          .remove(widget.previous);
                    }

                    var event = Event(
                        id: shareEvent
                            ? (widget.previous != null ? widget.previous!.id : DateTime.now().millisecondsSinceEpoch)
                            : -1,
                        title: shareEvent ? null : subjectController.text,
                        content: messageController.text,
                        category: category,
                        categoryName: customCategoryName,
                        isOwnEvent: !shareEvent,
                        isSharedEvent: shareEvent,
                        sender: shareEvent
                            ? Teacher(
                                firstName: Share.session.data.student.account.firstName,
                                lastName: Share.session.data.student.account.lastName)
                            : null,
                        classroom: classroomController.text.isNotEmpty
                            ? Classroom(name: classroomController.text, symbol: classroomController.text)
                            : null,
                        lessonNo: int.tryParse(lessonNumberController.text),
                        date: date,
                        timeFrom: startTime,
                        timeTo: endTime);

                    (shareEvent ? Share.session.sharedEvents : Share.session.customEvents).add(event);
                    Share.settings.save();

                    if (shareEvent) event.share();
                  } catch (e) {
                    if (isAndroid || isIOS) {
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
                }
              : null,
          child: Icon(widget.previous != null ? CupertinoIcons.pencil : CupertinoIcons.add,
              color: ((shareEvent || subjectController.text.isNotEmpty) && messageController.text.isNotEmpty)
                  ? CupertinoTheme.of(context).primaryColor
                  : CupertinoColors.inactiveGray)),
      children: [
        SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Date
                      if (Share.settings.appSettings.useCupertino)
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
                                            maximumDate: DateTime.now()
                                                        .asDate()
                                                        .difference(
                                                            Share.session.data.student.mainClass.endSchoolYear.asDate())
                                                        .inDays >=
                                                    0
                                                ? DateTime.now().asDate()
                                                : Share.session.data.student.mainClass.endSchoolYear,
                                            onDateTimeChanged: (DateTime newDate) => setState(() => date = newDate),
                                          ),
                                        ),
                                    child: Container(
                                        margin: EdgeInsets.only(top: 5, bottom: 5),
                                        child: Text(DateFormat.yMd(Share.settings.appSettings.localeCode).format(date),
                                            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)))),
                              )
                            ]),
                      if (!Share.settings.appSettings.useCupertino)
                        AdaptiveCard(
                          regular: true,
                          margin: EdgeInsets.symmetric(horizontal: 6),
                          click: () => showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: Share.session.data.student.mainClass.beginSchoolYear,
                            lastDate: DateTime.now()
                                        .asDate()
                                        .difference(Share.session.data.student.mainClass.endSchoolYear.asDate())
                                        .inDays >=
                                    0
                                ? DateTime.now().asDate()
                                : Share.session.data.student.mainClass.endSchoolYear,
                          ).then((newDate) {
                            if (newDate == null) return;
                            setState(() => date = newDate);
                          }),
                          child: 'Date',
                          after: 'The event date',
                          trailingElement: DateFormat.yMd(Share.settings.appSettings.localeCode).format(date),
                        ),
                      // Category
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text('Category:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: Share.settings.appSettings.useCupertino ? null : 16))),
                            ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 250),
                                child: AdaptiveTextField(
                                    setState: setState, controller: categoryController, placeholder: 'Start typing...')),
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
                                  fontSize: Share.settings.appSettings.useCupertino ? 14 : 16,
                                  insets: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  fontWeight: FontWeight.w600),
                              onPressed: () => setState(() {
                                    category = EventCategory.other;
                                    customCategoryName = '';
                                  }))),
                      // Either the receiver search or the contents
                      categoryController.text.isNotEmpty
                          ? CardContainer(
                              additionalDividerMargin: 5,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              children: categoriesToDisplay.isEmpty
                                  // No messages to display
                                  ? [
                                      AdaptiveCard(
                                        secondary: true,
                                        click: () => setState(() {
                                          category = EventCategory.other;
                                          customCategoryName = categoryController.text;
                                          categoryController.text = '';
                                        }),
                                        child: 'Custom category: ${categoryController.text}',
                                      )
                                    ]
                                  // Bindable messages layout
                                  : categoriesToDisplay
                                      .select((x, index) => AdaptiveCard(
                                          secondary: true,
                                          click: category == x
                                              ? null
                                              : () => setState(() {
                                                    category = x;
                                                    customCategoryName = '';
                                                    categoryController.text = '';
                                                  }),
                                          child: Opacity(opacity: category == x ? 0.3 : 1.0, child: Text(x.asString()))))
                                      .toList())
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                // Message input
                                AdaptiveTextField(
                                    maxLines: null,
                                    setState: setState,
                                    controller: messageController,
                                    placeholder: 'Type in the event description here...'),
                              ]
                                  .prependIf(
                                      // Subject input
                                      AdaptiveTextField(
                                          maxLines: null,
                                          setState: setState,
                                          controller: subjectController,
                                          placeholder: 'Title'),
                                      !shareEvent)
                                  .appendIf(
                                      // Shared event switch
                                      CardContainer(
                                          margin: EdgeInsets.only(left: 5, right: 5, top: 25),
                                          regularOverride: true,
                                          filled: false,
                                          children: [
                                            AdaptiveFormRow(
                                                noMargin: true,
                                                title: 'Share with class',
                                                helper: 'Event will be shared with others',
                                                value: shareEvent,
                                                onChanged: (value) => setState(() => shareEvent = value))
                                          ]),
                                      Share.session.settings.shareEventsByDefault &&
                                          Share.session.settings.allowSzkolnyIntegration)
                                  .appendAll([
                                Container(
                                    margin: EdgeInsets.only(left: 5, top: 15),
                                    child: GestureDetector(
                                        onTap: () => setState(() => showOptional = !showOptional),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              if (Share.settings.appSettings.useCupertino)
                                                Icon(
                                                    showOptional
                                                        ? CupertinoIcons.chevron_up_circle
                                                        : CupertinoIcons.chevron_down_circle,
                                                    size: 20),
                                              if (!Share.settings.appSettings.useCupertino)
                                                Icon(showOptional ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
                                                  if (Share.settings.appSettings.useCupertino)
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
                                                                        maximumDate: Share
                                                                            .session.data.student.mainClass.endSchoolYear,
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
                                                                            color:
                                                                                CupertinoTheme.of(context).primaryColor)))),
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
                                                  if (Share.settings.appSettings.useCupertino)
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
                                                                        maximumDate: Share
                                                                            .session.data.student.mainClass.endSchoolYear,
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
                                                                            color:
                                                                                CupertinoTheme.of(context).primaryColor)))),
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

                                                  if (!Share.settings.appSettings.useCupertino)
                                                    AdaptiveCard(
                                                      regular: true,
                                                      margin: EdgeInsets.symmetric(horizontal: 6),
                                                      click: () => {
                                                        showTimePicker(context: context, initialTime: TimeOfDay.now())
                                                            .then((value) => setState(() => startTime = value?.asDateTime()))
                                                      },
                                                      child: 'Start time',
                                                      after: 'When the event starts',
                                                      trailingElement: startTime == null
                                                          ? 'Not specified'
                                                          : DateFormat.Hm(Share.settings.appSettings.localeCode)
                                                              .format(startTime ?? DateTime.now()),
                                                    ),
                                                  if (!Share.settings.appSettings.useCupertino)
                                                    AdaptiveCard(
                                                      regular: true,
                                                      margin: EdgeInsets.symmetric(horizontal: 6),
                                                      click: () => {
                                                        showTimePicker(context: context, initialTime: TimeOfDay.now())
                                                            .then((value) => setState(() => endTime = value?.asDateTime()))
                                                      },
                                                      child: 'End time',
                                                      after: 'When the event ends',
                                                      trailingElement: endTime == null
                                                          ? 'Not specified'
                                                          : DateFormat.Hm(Share.settings.appSettings.localeCode)
                                                              .format(startTime ?? DateTime.now()),
                                                    ),
                                                  // Classroom input
                                                  AdaptiveTextField(
                                                      maxLines: null,
                                                      setState: setState,
                                                      controller: classroomController,
                                                      placeholder: 'Classroom'),
                                                  // Lesson number input
                                                  AdaptiveTextField(
                                                      maxLines: null,
                                                      setState: (s) => setState(() => lessonNumberController.text =
                                                          int.tryParse(lessonNumberController.text)?.toString() ?? ''),
                                                      controller: lessonNumberController,
                                                      placeholder: 'Lesson number'),
                                                ].appendIf(
                                                    // Shared event switch
                                                    CupertinoFormSection.insetGrouped(
                                                        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                        children: [
                                                          CupertinoFormRow(
                                                              prefix: Text('Share with class'),
                                                              child: CupertinoSwitch(
                                                                  value: shareEvent,
                                                                  onChanged: (value) => setState(() => shareEvent = value)))
                                                        ]),
                                                    !Share.session.settings.shareEventsByDefault &&
                                                        Share.session.settings.allowSzkolnyIntegration)))
                                        : null),
                              ]).toList()),
                    ])))
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

extension on TimeOfDay {
  DateTime asDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
