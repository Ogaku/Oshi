// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/share.dart';

class GradeComposePage extends StatefulWidget {
  const GradeComposePage({super.key, this.date, this.previous});

  final DateTime? date;
  final ({Lesson lesson, Grade grade})? previous;

  @override
  State<GradeComposePage> createState() => _GradeComposePageState();
}

class _GradeComposePageState extends State<GradeComposePage> {
  bool showOptional = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  late DateTime date;
  Lesson? category;
  int weight = 0, semester = 1, type = 0;
  bool resit = false, counts = true;

  @override
  void initState() {
    super.initState();
    date = widget.date ?? DateTime.now().asDate();

    if (widget.previous != null) {
      nameController.text = widget.previous!.grade.name;
      valueController.text = widget.previous!.grade.value;
      commentController.text = widget.previous!.grade.comments.join();

      category = widget.previous!.lesson;
      semester = widget.previous!.grade.semester;
      weight = widget.previous!.grade.weight;
      date = widget.previous!.grade.date;
      counts = widget.previous!.grade.countsToAverage;

      if (widget.previous != null &&
          (widget.previous!.grade.isSemesterProposition ||
              widget.previous!.grade.isSemester ||
              widget.previous!.grade.isFinalProposition ||
              widget.previous!.grade.isFinal ||
              widget.previous!.grade.resitPart ||
              !widget.previous!.grade.countsToAverage)) {
        if (widget.previous!.grade.isSemesterProposition) type = 1;
        if (widget.previous!.grade.isSemester) type = 2;
        if (widget.previous!.grade.isFinalProposition) type = 3;
        if (widget.previous!.grade.isFinal) type = 4;
        resit = widget.previous!.grade.resitPart;
        showOptional = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var categoriesToDisplay = Share.session.data.student.subjects
        .where((x) => x.nameExtra.contains(RegExp(categoryController.text, caseSensitive: false)));

    return DataPageBase.adaptive(
      pageFlags: [
        DataPageType.noTitleSpace,
        DataPageType.noTransitions,
        DataPageType.alternativeBackground,
      ].flag,
      title: nameController.text.isEmpty ? 'New custom grade' : nameController.text,
      leading: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text('Cancel', style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
          onPressed: () async => Navigator.pop(context)),
      trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.centerRight,
          onPressed: (nameController.text.isNotEmpty && valueController.text.isNotEmpty && category != null)
              ? () {
                  try {
                    if (widget.previous != null) {
                      Share.session.customGrades[widget.previous?.lesson]?.remove(widget.previous?.grade);
                      Share.session.customGrades[widget.previous?.lesson]
                          ?.removeWhere((x) => x.id != -1 && x.id == widget.previous?.grade.id);
                    }

                    var grade = Grade(
                      id: widget.previous != null ? widget.previous!.grade.id : DateTime.now().millisecondsSinceEpoch,
                      date: date,
                      addDate: DateTime.now(),
                      name: nameController.text,
                      value: valueController.text,
                      comments: commentController.text.isNotEmpty ? [commentController.text] : [],
                      weight: weight,
                      semester: semester,
                      resitPart: resit,
                      isSemesterProposition: type == 1,
                      isSemester: type == 2,
                      isFinalProposition: type == 3,
                      isFinal: type == 4,
                      countsToAverage: counts,
                      addedBy: Teacher(
                          firstName: Share.session.data.student.account.firstName,
                          lastName: Share.session.data.student.account.lastName),
                    );

                    /*
                      0 => "general",
                      1 => "semester proposition",
                      2 => "semester",
                      3 => "final proposition",
                      4 => "final",
                     */

                    if (!Share.session.customGrades.containsKey(category)) Share.session.customGrades[category!] = [];
                    Share.session.customGrades[category]?.add(grade);
                    Share.settings.save();
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
              color: (nameController.text.isNotEmpty && valueController.text.isNotEmpty && category != null)
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
                      // Lesson
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text('Lesson:', style: TextStyle(fontWeight: FontWeight.w600))),
                            ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 250),
                                child: CupertinoTextField.borderless(
                                    onChanged: (s) => setState(() {}),
                                    controller: categoryController,
                                    placeholder: 'Start typing...')),
                          ]),
                      // Receivers
                      Visibility(
                          visible: category?.name.isNotEmpty ?? false,
                          child: Container(
                              margin: EdgeInsets.only(left: 5),
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: TextChip(
                                      noMargin: true,
                                      text: category?.name ?? 'GO FCK YOURSELF',
                                      radius: 20,
                                      fontSize: 14,
                                      insets: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                      fontWeight: FontWeight.w600),
                                  onPressed: () => setState(() {
                                        category = null;
                                      })))),
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
                                        centered: true,
                                        child: 'Not found: ${categoryController.text}',
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
                                                    categoryController.text = '';
                                                  }),
                                          child: Opacity(opacity: category == x ? 0.3 : 1.0, child: Text(x.nameExtra))))
                                      .toList())
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                // Name input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    onChanged: (s) => setState(() {}),
                                    controller: nameController,
                                    placeholder: 'Name',
                                    placeholderStyle:
                                        TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.tertiaryLabel)),
                                // Value input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    onChanged: (s) => setState(() {}),
                                    controller: valueController,
                                    placeholder: 'Value',
                                    placeholderStyle:
                                        TextStyle(fontWeight: FontWeight.w600, color: CupertinoColors.tertiaryLabel)),
                                // Weight
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Opacity(
                                          opacity: 1,
                                          child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text('Weight:', style: TextStyle(fontWeight: FontWeight.w600)))),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: GestureDetector(
                                            onTap: () => _showDialog(
                                                  CupertinoPicker(
                                                    magnification: 1.22,
                                                    squeeze: 1.2,
                                                    useMagnifier: true,
                                                    itemExtent: 32.0,
                                                    // This sets the initial item.
                                                    scrollController: FixedExtentScrollController(
                                                      initialItem: weight,
                                                    ),
                                                    // This is called when selected item is changed.
                                                    onSelectedItemChanged: (int selectedItem) {
                                                      setState(() {
                                                        weight = selectedItem;
                                                      });
                                                    },
                                                    children: List<Widget>.generate(10, (int index) {
                                                      return Center(child: Text(index.toString()));
                                                    }),
                                                  ),
                                                ),
                                            child: Opacity(
                                                opacity: 0.5,
                                                child: Container(
                                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                                    child: Text(weight.toString(),
                                                        style: TextStyle(fontWeight: FontWeight.w600))))),
                                      )
                                    ]),
                                // Semester
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Opacity(
                                          opacity: 1,
                                          child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text('Semester:', style: TextStyle(fontWeight: FontWeight.w600)))),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: GestureDetector(
                                            onTap: () => _showDialog(
                                                  CupertinoPicker(
                                                    magnification: 1.22,
                                                    squeeze: 1.2,
                                                    useMagnifier: true,
                                                    itemExtent: 32.0,
                                                    // This sets the initial item.
                                                    scrollController: FixedExtentScrollController(
                                                      initialItem: semester - 1,
                                                    ),
                                                    // This is called when selected item is changed.
                                                    onSelectedItemChanged: (int selectedItem) {
                                                      setState(() {
                                                        semester = selectedItem + 1;
                                                      });
                                                    },
                                                    children: List<Widget>.generate(2, (int index) {
                                                      return Center(
                                                          child: Text(
                                                        switch (index + 1) { 1 => "first", 2 => "second", _ => "ERR" },
                                                      ));
                                                    }),
                                                  ),
                                                ),
                                            child: Opacity(
                                                opacity: 0.5,
                                                child: Container(
                                                    margin: EdgeInsets.only(top: 5, bottom: 5),
                                                    child: Text(
                                                        switch (semester) { 1 => "first", 2 => "second", _ => "ERR" },
                                                        style: TextStyle(fontWeight: FontWeight.w600))))),
                                      )
                                    ]),
                                // Message input
                                CupertinoTextField.borderless(
                                    maxLines: null,
                                    onChanged: (s) => setState(() {}),
                                    controller: commentController,
                                    placeholder: 'Type in any grade comments here...'),
                              ].appendAll([
                                Container(
                                    margin: EdgeInsets.only(left: 5, top: 15),
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
                                                  // Grade type
                                                  Container(
                                                      margin: EdgeInsets.only(left: 10),
                                                      child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Opacity(
                                                                opacity: 1,
                                                                child: Container(
                                                                    margin: EdgeInsets.only(left: 7),
                                                                    child: Text('Grade type:',
                                                                        style: TextStyle(fontWeight: FontWeight.w600)))),
                                                            Container(
                                                              margin: EdgeInsets.only(left: 5),
                                                              child: GestureDetector(
                                                                  onTap: () => _showDialog(
                                                                        CupertinoPicker(
                                                                          magnification: 1.22,
                                                                          squeeze: 1.2,
                                                                          useMagnifier: true,
                                                                          itemExtent: 32.0,
                                                                          // This sets the initial item.
                                                                          scrollController: FixedExtentScrollController(
                                                                            initialItem: type,
                                                                          ),
                                                                          // This is called when selected item is changed.
                                                                          onSelectedItemChanged: (int selectedItem) {
                                                                            setState(() {
                                                                              type = selectedItem;
                                                                            });
                                                                          },
                                                                          children: List<Widget>.generate(5, (int index) {
                                                                            return Center(
                                                                                child: Text(
                                                                              switch (index) {
                                                                                0 => "general",
                                                                                1 => "semester proposition",
                                                                                2 => "semester",
                                                                                3 => "final proposition",
                                                                                4 => "final",
                                                                                _ => "ERR"
                                                                              },
                                                                            ));
                                                                          }),
                                                                        ),
                                                                      ),
                                                                  child: Opacity(
                                                                      opacity: 0.5,
                                                                      child: Container(
                                                                          margin: EdgeInsets.only(top: 5, bottom: 5),
                                                                          child: Text(
                                                                              switch (type) {
                                                                                0 => "general",
                                                                                1 => "semester proposition",
                                                                                2 => "semester",
                                                                                3 => "final proposition",
                                                                                4 => "final",
                                                                                _ => "ERR"
                                                                              },
                                                                              style:
                                                                                  TextStyle(fontWeight: FontWeight.w600))))),
                                                            )
                                                          ])),
                                                  // Toggles | form
                                                  CardContainer(
                                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                                      additionalDividerMargin: 5,
                                                      children: [
                                                        // Average
                                                        CupertinoFormRow(
                                                            prefix: Flexible(
                                                                flex: 3,
                                                                child: Text('Counts to the average',
                                                                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                            child: CupertinoSwitch(
                                                                value: counts,
                                                                onChanged: (s) => setState(() => counts = s))),
                                                        // Resit
                                                        CupertinoFormRow(
                                                            prefix: Flexible(
                                                                flex: 3,
                                                                child: Text('Resit (corrected grade)',
                                                                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                            child: CupertinoSwitch(
                                                                value: resit, onChanged: (s) => setState(() => resit = s))),
                                                      ]),
                                                ]))
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
