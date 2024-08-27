// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:format/format.dart';
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
import 'package:oshi/share/translator.dart';

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
          child: AdaptiveButton(title: 'D91ED34B-BB94-4EFF-8DF8-D5F4FF8906BF'.localized, click: () async => Navigator.pop(context))),
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
                                  child: Text('63C342E6-6583-45CE-B273-8CB402AE5BAD'.localized, style: TextStyle(fontWeight: FontWeight.w600))),
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
                          child: '/Date'.localized,
                          after: '4A36ACC2-773E-49FD-9946-321EF34ADFCB'.localized,
                          trailingElement: DateFormat.yMd(Share.settings.appSettings.localeCode).format(date),
                        ),
                      // Category
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text('D6C84B44-B72B-4EEC-A2E9-3C139BBCA8AC'.localized,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: Share.settings.appSettings.useCupertino ? null : 16))),
                            ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 250),
                                child: AdaptiveTextField(
                                    setState: setState, controller: categoryController, placeholder: '6FFC787F-7E74-4467-94A7-DE04A8349C1A'.localized)),
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
                                        child: '89DCFE4D-3EBA-4E62-8892-BC5644D639E8'.localized.format(categoryController.text),
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
                                    placeholder: '8CA8A5B0-F318-46DA-A453-72D162D266E6'.localized),
                              ]
                                  .prependIf(
                                      // Subject input
                                      AdaptiveTextField(
                                          maxLines: null,
                                          setState: setState,
                                          controller: subjectController,
                                          placeholder: 'ED8D10FC-50FE-48C5-AD57-8E7418669AC3'.localized),
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
                                                title: '7B2546FB-BF5A-4390-9ACD-32130F356320'.localized,
                                                helper: '619C02B6-9564-48DB-B205-FCEE140DF534'.localized,
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
                                                      child: Text('65233B9B-801B-4145-BDC3-6CA7A4B5736F'.localized,
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
                                                              child: Text('E5F106C3-4B5F-44B0-AD28-8545CB9A3EF2'.localized,
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
                                                                            ? 'BC4C4828-36B3-4009-A06B-14641E292A61'.localized
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
                                                              child: Text('D0B44429-BF9F-4483-8B3A-0540449B227D'.localized,
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
                                                                            ? 'BC4C4828-36B3-4009-A06B-14641E292A61'.localized
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
                                                      child: '58710A36-F758-4E5F-916E-9F7846ED58BA'.localized,
                                                      after: '6D95AC19-4F2C-45C6-A80F-FEECF8A319E3'.localized,
                                                      trailingElement: startTime == null
                                                          ? '7E2F717D-B138-4E74-A278-8E26F7FC4C4B'.localized
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
                                                      child: '87657B56-BFB1-44FB-9B51-9155ED6396E4'.localized,
                                                      after: 'CB7BA3C9-548E-4854-B9CD-E6EA31FC1319'.localized,
                                                      trailingElement: endTime == null
                                                          ? '7E2F717D-B138-4E74-A278-8E26F7FC4C4B'.localized
                                                          : DateFormat.Hm(Share.settings.appSettings.localeCode)
                                                              .format(startTime ?? DateTime.now()),
                                                    ),
                                                  // Classroom input
                                                  AdaptiveTextField(
                                                      maxLines: null,
                                                      setState: setState,
                                                      controller: classroomController,
                                                      placeholder: 'AA2B9B71-49B6-45BD-A0FE-707D42A09EC5'.localized),
                                                  // Lesson number input
                                                  AdaptiveTextField(
                                                      maxLines: null,
                                                      setState: (s) => setState(() => lessonNumberController.text =
                                                          int.tryParse(lessonNumberController.text)?.toString() ?? ''),
                                                      controller: lessonNumberController,
                                                      placeholder: '89C8B5CF-1E70-4084-A04D-1CDBA5D54603'.localized),
                                                ].appendIf(
                                                    // Shared event switch
                                                    CupertinoFormSection.insetGrouped(
                                                        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                        children: [
                                                          CupertinoFormRow(
                                                              prefix: Text('7B2546FB-BF5A-4390-9ACD-32130F356320'.localized),
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
