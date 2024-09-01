// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:format/format.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/components/cupertino/widgets/options_form.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/components/cupertino/widgets/text_chip.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/models/data/grade.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

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
      title: nameController.text.isEmpty ? 'C9DE7B87-B4B9-410E-AB54-CA6FB5B2F005'.localized : nameController.text,
      childOverride: false,
      leading: Align(
          alignment: Alignment.centerLeft,
          child: AdaptiveButton(
              title: 'D91ED34B-BB94-4EFF-8DF8-D5F4FF8906BF'.localized, click: () async => Navigator.pop(context))),
      trailing: CupertinoButton(
          padding: Share.settings.appSettings.useCupertino ? EdgeInsets.only() : EdgeInsets.all(5),
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
              size: Share.settings.appSettings.useCupertino ? 25 : null,
              color: (nameController.text.isNotEmpty && valueController.text.isNotEmpty && category != null)
                  ? (Share.settings.appSettings.useCupertino
                      ? CupertinoTheme.of(context).primaryColor
                      : Theme.of(context).colorScheme.primary)
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
                                child: Text('63C342E6-6583-45CE-B273-8CB402AE5BAD'.localized,
                                    style: TextStyle(fontWeight: FontWeight.w600))),
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
                                child: AdaptiveTextField(
                                    setState: setState,
                                    controller: categoryController,
                                    placeholder: '6FFC787F-7E74-4467-94A7-DE04A8349C1A'.localized)),
                          ]),
                      // Receivers
                      Visibility(
                          visible: category?.name.isNotEmpty ?? false,
                          child: Container(
                              margin: EdgeInsets.only(left: 5),
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: TextChip(
                                      noMargin: Share.settings.appSettings.useCupertino,
                                      text: category?.name ?? '5751E462-FFCF-4857-A5EA-EAF4A25B6F11'.localized,
                                      radius: 20,
                                      fontSize: Share.settings.appSettings.useCupertino ? 14 : 16,
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
                                        child:
                                            '3C50E8E5-1764-48BF-9E6D-47C5DB958A23'.localized.format(categoryController.text),
                                      )
                                    ]
                                  // Bindable messages layout
                                  : categoriesToDisplay
                                      .select((x, index) => AdaptiveCard(
                                          secondary: true,
                                          hideChevron: true,
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
                                AdaptiveTextField(
                                    maxLines: null,
                                    setState: setState,
                                    controller: nameController,
                                    placeholder: '8C49630C-B41B-4D50-87C8-6A3EA3FD6A3D'.localized),
                                // Value input
                                AdaptiveTextField(
                                    maxLines: null,
                                    setState: setState,
                                    controller: valueController,
                                    placeholder: '828F8EBE-4681-4FC9-9FFE-239540470A97'.localized),
                                // Message input
                                if (!Share.settings.appSettings.useCupertino)
                                  AdaptiveTextField(
                                      maxLines: null,
                                      setState: setState,
                                      controller: commentController,
                                      placeholder: 'C01E0657-4723-487A-8095-382022E441CF'.localized),
                                // Weight
                                if (Share.settings.appSettings.useCupertino)
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Opacity(
                                            opacity: 1,
                                            child: Container(
                                                margin: EdgeInsets.only(left: 7),
                                                child: Text('36E7AD9C-4766-400D-82E0-D882D8C1DBBE'.localized,
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
                                if (!Share.settings.appSettings.useCupertino)
                                  AdaptiveCard(
                                    regular: true,
                                    margin: EdgeInsets.symmetric(horizontal: 6),
                                    click: () => showOptionDialog(
                                        context: context,
                                        title: 'F455E699-B0AA-4718-B6E1-56623B2332CA'.localized,
                                        icon: Icons.line_weight,
                                        selection: weight,
                                        options: List<OptionEntry>.generate(10, (int index) {
                                          return OptionEntry(name: index.toString(), value: index);
                                        }),
                                        onChanged: (v) {
                                          setState(() => weight = v);
                                        }),
                                    child: 'C70BF0CC-9152-4856-9AF3-45DF1CDE0EBA'.localized,
                                    after: '394DA71A-A887-46C6-8ECB-D7CFFA5487C2'.localized,
                                    trailingElement: weight.toString(),
                                  ),
                                // Semester
                                if (Share.settings.appSettings.useCupertino)
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Opacity(
                                            opacity: 1,
                                            child: Container(
                                                margin: EdgeInsets.only(left: 7),
                                                child: Text('952C16E3-7C31-4E6D-968B-80FC4C27C292'.localized,
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
                                                          switch (index + 1) {
                                                            1 => '0C168486-8BDF-4923-898E-6E8D6E066394'.localized,
                                                            2 => 'BD3A0594-129B-4DEE-8F33-E848C4B00E3B'.localized,
                                                            _ => '3D0F6617-080E-410B-8650-33E6CB83AE4D'.localized
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
                                                          switch (semester) {
                                                            1 => '0C168486-8BDF-4923-898E-6E8D6E066394'.localized,
                                                            2 => 'BD3A0594-129B-4DEE-8F33-E848C4B00E3B'.localized,
                                                            _ => '3D0F6617-080E-410B-8650-33E6CB83AE4D'.localized
                                                          },
                                                          style: TextStyle(fontWeight: FontWeight.w600))))),
                                        )
                                      ]),

                                if (!Share.settings.appSettings.useCupertino)
                                  AdaptiveCard(
                                    regular: true,
                                    margin: EdgeInsets.symmetric(horizontal: 6),
                                    click: () => showOptionDialog(
                                        context: context,
                                        title: '4456F7D3-1173-4A61-A093-712A2AB21764'.localized,
                                        icon: Icons.line_weight,
                                        selection: semester,
                                        options: [
                                          OptionEntry(name: '8860BA8F-47A4-4723-A786-7FC26B971453'.localized, value: 1),
                                          OptionEntry(name: '3C821237-50E2-4764-B61D-489C2E05C7EA'.localized, value: 2),
                                        ],
                                        onChanged: (v) {
                                          setState(() => semester = v);
                                        }),
                                    child: '4456F7D3-1173-4A61-A093-712A2AB21764'.localized,
                                    after: '11340D77-0525-4EEF-A0A0-EB8933553149'.localized,
                                    trailingElement: switch (semester) {
                                      1 => '0C168486-8BDF-4923-898E-6E8D6E066394'.localized,
                                      2 => 'BD3A0594-129B-4DEE-8F33-E848C4B00E3B'.localized,
                                      _ => '3D0F6617-080E-410B-8650-33E6CB83AE4D'.localized
                                    }
                                        .toString()
                                        .capitalize(),
                                  ),
                                // Message input
                                if (Share.settings.appSettings.useCupertino)
                                  AdaptiveTextField(
                                      maxLines: null,
                                      setState: setState,
                                      controller: commentController,
                                      placeholder: 'C01E0657-4723-487A-8095-382022E441CF'.localized),
                              ].appendAll([
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
                                                  // Grade type
                                                  if (Share.settings.appSettings.useCupertino)
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
                                                                      child: Text(
                                                                          'AC106467-0FBE-4916-82B5-594F11D21C8B'.localized,
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
                                                                                  0 => '41943B1D-B32A-4547-81B0-1882F5495942'
                                                                                      .localized,
                                                                                  1 => '0D37C787-F585-4091-AC3E-CC2AF05A534F'
                                                                                      .localized,
                                                                                  2 => '83AAE02D-9BDA-4AD1-BD70-7987CF46FECC'
                                                                                      .localized,
                                                                                  3 => 'BB246CED-F0D0-4425-B33B-C5F68E563A04'
                                                                                      .localized,
                                                                                  4 => '23AC622C-A52D-43DD-A764-E74750C3E523'
                                                                                      .localized,
                                                                                  _ => '3D0F6617-080E-410B-8650-33E6CB83AE4D'
                                                                                      .localized
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
                                                                                  0 => '41943B1D-B32A-4547-81B0-1882F5495942'
                                                                                      .localized,
                                                                                  1 => '0D37C787-F585-4091-AC3E-CC2AF05A534F'
                                                                                      .localized,
                                                                                  2 => '83AAE02D-9BDA-4AD1-BD70-7987CF46FECC'
                                                                                      .localized,
                                                                                  3 => 'BB246CED-F0D0-4425-B33B-C5F68E563A04'
                                                                                      .localized,
                                                                                  4 => '23AC622C-A52D-43DD-A764-E74750C3E523'
                                                                                      .localized,
                                                                                  _ => '3D0F6617-080E-410B-8650-33E6CB83AE4D'
                                                                                      .localized
                                                                                },
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.w600))))),
                                                              )
                                                            ])),
                                                  if (!Share.settings.appSettings.useCupertino)
                                                    AdaptiveCard(
                                                      regular: true,
                                                      margin: EdgeInsets.symmetric(horizontal: 6),
                                                      click: () => showOptionDialog(
                                                          context: context,
                                                          title: '1D6F18B4-5F70-4CF7-8302-C15F111EBA64'.localized,
                                                          icon: Icons.grade,
                                                          selection: type,
                                                          options: [
                                                            OptionEntry(
                                                                name: '41943B1D-B32A-4547-81B0-1882F5495942'
                                                                    .localized
                                                                    .capitalize(),
                                                                value: 0),
                                                            OptionEntry(
                                                                name: '0D37C787-F585-4091-AC3E-CC2AF05A534F'
                                                                    .localized
                                                                    .capitalize(),
                                                                value: 1),
                                                            OptionEntry(
                                                                name: '83AAE02D-9BDA-4AD1-BD70-7987CF46FECC'
                                                                    .localized
                                                                    .capitalize(),
                                                                value: 2),
                                                            OptionEntry(
                                                                name: 'BB246CED-F0D0-4425-B33B-C5F68E563A04'
                                                                    .localized
                                                                    .capitalize(),
                                                                value: 3),
                                                            OptionEntry(
                                                                name: '23AC622C-A52D-43DD-A764-E74750C3E523'
                                                                    .localized
                                                                    .capitalize(),
                                                                value: 4),
                                                          ],
                                                          onChanged: (v) {
                                                            setState(() => type = v);
                                                          }),
                                                      child: '1D6F18B4-5F70-4CF7-8302-C15F111EBA64'.localized,
                                                      after: '2EBF8EDE-5F5B-40BD-914D-5A47026D2D2D'.localized,
                                                      trailingElement: switch (type) {
                                                        0 => '41943B1D-B32A-4547-81B0-1882F5495942'.localized,
                                                        1 => '0D37C787-F585-4091-AC3E-CC2AF05A534F'.localized,
                                                        2 => '83AAE02D-9BDA-4AD1-BD70-7987CF46FECC'.localized,
                                                        3 => 'BB246CED-F0D0-4425-B33B-C5F68E563A04'.localized,
                                                        4 => '23AC622C-A52D-43DD-A764-E74750C3E523'.localized,
                                                        _ => 'F9647083-FB1F-450E-AE99-E77C17B75509'.localized
                                                      }
                                                          .capitalize(),
                                                    ),
                                                  // Toggles | form
                                                  CardContainer(additionalDividerMargin: 5, filled: false, children: [
                                                    // Average
                                                    AdaptiveFormRow(
                                                        noMargin: true,
                                                        helper: '0E300562-B30B-4E1C-94DD-0E244255DA13'.localized,
                                                        title: '4E53AD1F-9CEE-4676-947C-35CE59986E21'.localized,
                                                        value: counts,
                                                        onChanged: (s) => setState(() => counts = s)),
                                                    // Resit
                                                    AdaptiveFormRow(
                                                        noMargin: true,
                                                        helper: '836100BB-8CC9-4DD0-BE98-9B5E7CBC3525'.localized,
                                                        title: 'E99E0F5D-AFDC-45F0-8B5A-76AD8CA1FE17'.localized,
                                                        value: resit,
                                                        onChanged: (s) => setState(() => resit = s)),
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
