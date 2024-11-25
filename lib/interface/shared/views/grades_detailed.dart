// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:format/format.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/components/shim/elements/context_menu.dart';
import 'package:oshi/interface/components/shim/elements/grade.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/views/message_compose.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/models/data/lesson.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:share_plus/share_plus.dart' as sharing;

class GradesDetailedPage extends StatefulWidget {
  const GradesDetailedPage({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<GradesDetailedPage> createState() => _GradesDetailedPageState();
}

class _GradesDetailedPageState extends State<GradesDetailedPage> {
  Widget gradesWidget([String query = '', bool filled = true]) {
    var gradesToDisplay = widget.lesson.allGrades
        .where((x) => x.semester == 2)
        .appendAllIfEmpty(widget.lesson.allGrades)
        .where((x) => !x.major)
        .where((x) =>
            x.name.contains(RegExp(query, caseSensitive: false)) ||
            x.detailsDateString.contains(RegExp(query, caseSensitive: false)) ||
            x.commentsString.contains(RegExp(query, caseSensitive: false)) ||
            x.addedByString.contains(RegExp(query, caseSensitive: false)))
        .orderByDescending((x) => x.addDate)
        .distinct((x) => mapPropsToHashCode([x.resitPart ? 0 : UniqueKey(), x.name]))
        .toList();

    return CardContainer(
      additionalDividerMargin: 5,
      filled: false,
      regularOverride: true,
      children: gradesToDisplay.isEmpty
          // No messages to display
          ? [
              AdaptiveCard(
                padding: EdgeInsets.only(),
                centered: true,
                secondary: true,
                child: query.isNotEmpty
                    ? '37DB4F6C-E0AE-44AF-8905-5384B038E522'.localized
                    : '9A027181-A1D0-41DA-9E0C-719B3D43B9DF'.localized,
              )
            ]
          // Bindable messages layout
          : gradesToDisplay.select((x, index) {
              return AdaptiveCard(
                  padding: EdgeInsets.only(),
                  child: x.asGrade(context, setState,
                      corrected: widget.lesson.allGrades.firstWhereOrDefault(
                          (y) => x.resitPart && y.resitPart && y.name == x.name && x != y,
                          defaultValue: null)));
            }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var secondSemester = widget.lesson.allGrades.any((x) => x.semester == 2 || x.isFinal || x.isFinalProposition);
    var gradesBottomWidgets = <Widget>[].appendIf(
        // Average (yearly)
        Visibility(
            visible: widget.lesson.gradesAverage >= 0,
            child: AdaptiveCard(
                padding: EdgeInsets.only(),
                child: AdaptiveContextMenu(
                    actions: [
                      AdaptiveContextMenuAction(
                        onPressed: () {
                          sharing.Share.share('0440D007-CD66-495E-A1C3-9D290E26F507'
                              .localized
                              .format(widget.lesson.name, widget.lesson.gradesAverage));
                          if (Share.settings.appSettings.useCupertino) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                        icon: CupertinoIcons.share,
                        title: '/Share'.localized,
                      ),
                      AdaptiveContextMenuAction(
                        isDestructiveAction: true,
                        icon: CupertinoIcons.chat_bubble_2,
                        title: '/Inquiry'.localized,
                        onPressed: () {
                          if (Share.settings.appSettings.useCupertino) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => MessageComposePage(
                                  receivers: [widget.lesson.teacher],
                                  subject: '79617CAD-C9A1-4BCA-98FC-4F9D1ADE1B35'.localized.format(widget.lesson.name),
                                  signature: '36C35A24-B8AA-47FB-B564-9B83D2838415'.localized.format(
                                      Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                        },
                      ),
                    ],
                    child: Container(
                        decoration: Share.settings.appSettings.useCupertino
                            ? BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: CupertinoDynamicColor.resolve(
                                    CupertinoDynamicColor.withBrightness(
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                    context))
                            : null,
                        padding: Share.settings.appSettings.useCupertino
                            ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                            : null,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    '/Average'.localized,
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  )),
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    widget.lesson.gradesAverage.toStringAsFixed(2),
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  )),
                            ]))))),
        secondSemester);

    var gradesSemesterBottomWidgets = <Widget>[
      // Average (1st semester)
      Visibility(
          visible: widget.lesson.gradesSemAverage >= 0,
          child: AdaptiveCard(
              padding: EdgeInsets.only(),
              child: AdaptiveContextMenu(
                  actions: [
                    AdaptiveContextMenuAction(
                      onPressed: () {
                        sharing.Share.share('86D66F6A-6E4B-4C65-8AB3-EBEACA3FFC90'
                            .localized
                            .format(widget.lesson.name, widget.lesson.gradesSemAverage));
                        if (Share.settings.appSettings.useCupertino) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      },
                      icon: CupertinoIcons.share,
                      title: '/Share'.localized,
                    ),
                    AdaptiveContextMenuAction(
                      isDestructiveAction: true,
                      icon: CupertinoIcons.chat_bubble_2,
                      title: '/Inquiry'.localized,
                      onPressed: () {
                        if (Share.settings.appSettings.useCupertino) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                        showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => MessageComposePage(
                                receivers: [widget.lesson.teacher],
                                subject: 'BC6173B0-BD9D-4627-8512-594FB359B983'.localized.format(widget.lesson.name),
                                signature: '36C35A24-B8AA-47FB-B564-9B83D2838415'.localized.format(
                                    Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                      },
                    ),
                  ],
                  child: Container(
                      decoration: Share.settings.appSettings.useCupertino
                          ? BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoDynamicColor.withBrightness(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      darkColor: const Color.fromARGB(255, 28, 28, 30)),
                                  context))
                          : null,
                      padding: Share.settings.appSettings.useCupertino
                          ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                          : null,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Semester average',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                )),
                            Container(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  widget.lesson.gradesSemAverage.toStringAsFixed(2),
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                )),
                          ])))))
    ];

    // Proposed grade (2nd semester / year)
    if (widget.lesson.allGrades
            .firstWhereOrDefault((x) => x.isFinalProposition || (x.isSemesterProposition && x.semester == 2))
            ?.value !=
        null) {
      gradesBottomWidgets.add(AdaptiveCard(
          padding: EdgeInsets.only(),
          child: AdaptiveContextMenu(
              actions: [
                AdaptiveContextMenuAction(
                  onPressed: () {
                    sharing.Share.share('E02FB126-60E8-4604-B616-69529AB0EE64'.localized.format(
                        (widget.lesson.allGrades
                                .firstWhereOrDefault(
                                    (x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))
                                ?.value) ??
                            '',
                        widget.lesson.name));
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  icon: CupertinoIcons.share,
                  title: 'Share',
                ),
                AdaptiveContextMenuAction(
                  isDestructiveAction: true,
                  icon: CupertinoIcons.chat_bubble_2,
                  title: 'Inquiry',
                  onPressed: () {
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => MessageComposePage(
                            receivers: [widget.lesson.teacher],
                            subject: '9221D91C-83A8-423E-8352-31FEE4C06FD0'.localized.format(widget.lesson.name),
                            signature: '36C35A24-B8AA-47FB-B564-9B83D2838415'.localized.format(
                                Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                  },
                ),
              ],
              child: Container(
                  decoration: Share.settings.appSettings.useCupertino
                      ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: CupertinoDynamicColor.resolve(
                              CupertinoDynamicColor.withBrightness(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  darkColor: const Color.fromARGB(255, 28, 28, 30)),
                              context))
                      : null,
                  padding: Share.settings.appSettings.useCupertino
                      ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                      : null,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UnreadDot(
                                  unseen: () => widget.lesson.allGrades.any((x) =>
                                      (x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition)) && x.unseen),
                                  markAsSeen: () => widget.lesson.allGrades
                                      .where((x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))
                                      .forEach((x) => x.markAsSeen()),
                                  margin: EdgeInsets.only(right: 8)),
                              Text(
                                'B7322EA2-71DE-4CB6-B71C-CDB9E763B32A'.localized,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ]),
                        Text(
                          widget.lesson.allGrades
                                  .firstWhereOrDefault(
                                      (x) => x.isFinalProposition || (x.semester == 2 && x.isSemesterProposition))
                                  ?.value
                                  .toString() ??
                              '94149CBB-5B72-4186-A155-20A9C7FB1B2C'.localized,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ])))));
    }

    // Proposed grade (1st semester)
    if (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)?.value != null) {
      gradesSemesterBottomWidgets.add(AdaptiveCard(
          padding: EdgeInsets.only(),
          child: AdaptiveContextMenu(
              actions: [
                AdaptiveContextMenuAction(
                  onPressed: () {
                    sharing.Share.share('A7A1CA79-09B4-4EA6-BA6D-ED85243BADDA'.localized.format(
                        (widget.lesson.allGrades
                                .firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)
                                ?.value) ??
                            '',
                        widget.lesson.name));
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  icon: CupertinoIcons.share,
                  title: '/Share'.localized,
                ),
                AdaptiveContextMenuAction(
                  isDestructiveAction: true,
                  icon: CupertinoIcons.chat_bubble_2,
                  title: '/Inquiry'.localized,
                  onPressed: () {
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => MessageComposePage(
                            receivers: [widget.lesson.teacher],
                            subject: '9F390DDF-CBAB-45FA-B762-BDBBDAC7472D'.localized.format(widget.lesson.name),
                            signature: '36C35A24-B8AA-47FB-B564-9B83D2838415'.localized.format(
                                Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                  },
                ),
              ],
              child: Container(
                  decoration: Share.settings.appSettings.useCupertino
                      ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: CupertinoDynamicColor.resolve(
                              CupertinoDynamicColor.withBrightness(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  darkColor: const Color.fromARGB(255, 28, 28, 30)),
                              context))
                      : null,
                  padding: Share.settings.appSettings.useCupertino
                      ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                      : null,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UnreadDot(
                                  unseen: () => widget.lesson.allGrades
                                      .any((x) => (x.isSemesterProposition && x.semester == 1) && x.unseen),
                                  markAsSeen: () => widget.lesson.allGrades
                                      .where((x) => x.isSemesterProposition && x.semester == 1)
                                      .forEach((x) => x.markAsSeen()),
                                  margin: EdgeInsets.only(right: 8)),
                              Text(
                                'B7322EA2-71DE-4CB6-B71C-CDB9E763B32A'.localized,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ]),
                        Text(
                          widget.lesson.allGrades
                                  .firstWhereOrDefault((x) => x.isSemesterProposition && x.semester == 1)
                                  ?.value
                                  .toString() ??
                              '94149CBB-5B72-4186-A155-20A9C7FB1B2C'.localized,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ])))));
    }

    // Final grade (2nd semester / year)
    if (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isFinal || (x.isSemester && x.semester == 2))?.value != null) {
      gradesBottomWidgets.add(AdaptiveCard(
          padding: EdgeInsets.only(),
          child: AdaptiveContextMenu(
              actions: [
                AdaptiveContextMenuAction(
                  onPressed: () {
                    sharing.Share.share('C0E5DDF1-1578-41A3-8833-9F6B8F327512'.localized.format(
                        (widget.lesson.allGrades
                                .firstWhereOrDefault((x) => x.isFinal || (x.semester == 2 && x.isSemester))
                                ?.value) ??
                            '',
                        widget.lesson.name));
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  icon: CupertinoIcons.share,
                  title: '/Share'.localized,
                ),
                AdaptiveContextMenuAction(
                  isDestructiveAction: true,
                  icon: CupertinoIcons.chat_bubble_2,
                  title: '/Inquiry'.localized,
                  onPressed: () {
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => MessageComposePage(
                            receivers: [widget.lesson.teacher],
                            subject: '3A47D98A-3FDF-4BD0-94BE-B97A402AE20B'.localized.format(widget.lesson.name),
                            signature: '36C35A24-B8AA-47FB-B564-9B83D2838415'.localized.format(
                                Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                  },
                ),
              ],
              child: Container(
                  decoration: Share.settings.appSettings.useCupertino
                      ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: CupertinoDynamicColor.resolve(
                              CupertinoDynamicColor.withBrightness(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  darkColor: const Color.fromARGB(255, 28, 28, 30)),
                              context))
                      : null,
                  padding: Share.settings.appSettings.useCupertino
                      ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                      : null,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UnreadDot(
                                  unseen: () => widget.lesson.allGrades
                                      .any((x) => (x.isFinal || (x.semester == 2 && x.isSemester)) && x.unseen),
                                  markAsSeen: () => widget.lesson.allGrades
                                      .where((x) => x.isFinal || (x.semester == 2 && x.isSemester))
                                      .forEach((x) => x.markAsSeen()),
                                  margin: EdgeInsets.only(right: 8)),
                              Text(
                                '3D7343F4-A362-4D50-BC7B-8E2303B50729'.localized,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ]),
                        Text(
                          widget.lesson.allGrades
                                  .firstWhereOrDefault((x) => x.isFinal || (x.semester == 2 && x.isSemester))
                                  ?.value
                                  .toString() ??
                              '94149CBB-5B72-4186-A155-20A9C7FB1B2C'.localized,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ])))));
    }

    // Final grade (1st semester)
    if (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemester && x.semester == 1)?.value != null) {
      gradesSemesterBottomWidgets.add(AdaptiveCard(
          padding: EdgeInsets.only(),
          child: AdaptiveContextMenu(
              actions: [
                AdaptiveContextMenuAction(
                  onPressed: () {
                    sharing.Share.share('113A072F-2E32-4BBE-8705-4FB4F5B26F6E'.localized.format(
                        (widget.lesson.allGrades.firstWhereOrDefault((x) => x.isSemester && x.semester == 1)?.value) ?? '',
                        widget.lesson.name));
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  icon: CupertinoIcons.share,
                  title: '/Share'.localized,
                ),
                AdaptiveContextMenuAction(
                  isDestructiveAction: true,
                  icon: CupertinoIcons.chat_bubble_2,
                  title: '/Inquiry'.localized,
                  onPressed: () {
                    if (Share.settings.appSettings.useCupertino) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => MessageComposePage(
                            receivers: [widget.lesson.teacher],
                            subject: '6023BF44-17D2-463D-870B-759681BA3CA7'.localized.format(widget.lesson.name),
                            signature: '36C35A24-B8AA-47FB-B564-9B83D2838415'.localized.format(
                                Share.session.data.student.account.name, Share.session.data.student.mainClass.name)));
                  },
                ),
              ],
              child: Container(
                  decoration: Share.settings.appSettings.useCupertino
                      ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: CupertinoDynamicColor.resolve(
                              CupertinoDynamicColor.withBrightness(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  darkColor: const Color.fromARGB(255, 28, 28, 30)),
                              context))
                      : null,
                  padding: Share.settings.appSettings.useCupertino
                      ? EdgeInsets.only(top: 15, bottom: 15, right: 15, left: 20)
                      : null,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UnreadDot(
                                  unseen: () =>
                                      widget.lesson.allGrades.any((x) => (x.isSemester && x.semester == 1) && x.unseen),
                                  markAsSeen: () => widget.lesson.allGrades
                                      .where((x) => x.isSemester && x.semester == 1)
                                      .forEach((x) => x.markAsSeen()),
                                  margin: EdgeInsets.only(right: 8)),
                              Text(
                                '102472D7-81EC-45F3-816E-D9EE5783A3CF'.localized,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ]),
                        Text(
                          widget.lesson.allGrades
                                  .firstWhereOrDefault((x) => x.isSemester && x.semester == 1)
                                  ?.value
                                  .toString() ??
                              '94149CBB-5B72-4186-A155-20A9C7FB1B2C'.localized,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ])))));
    }

    return DataPageBase.adaptive(
        pageFlags: [
          DataPageType.searchable,
          if (Share.settings.appSettings.useCupertino) DataPageType.refreshable,
        ].flag,
        setState: setState,
        title: widget.lesson.name,
        searchBuilder: (_, controller) => [gradesWidget(controller.text, false)],
        children: <Widget>[
          gradesWidget(),
        ]
            .appendIf(
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CardContainer(
                      additionalDividerMargin: 5,
                      header: gradesSemesterBottomWidgets.isEmpty ? Container() : null,
                      children: gradesSemesterBottomWidgets,
                    )),
                gradesSemesterBottomWidgets.isNotEmpty)
            .appendIf(
                Container(
                    margin: EdgeInsets.only(top: 20),
                    child: CardContainer(
                      additionalDividerMargin: 5,
                      header: gradesBottomWidgets.isEmpty ? Container() : null,
                      children: gradesBottomWidgets,
                    )),
                gradesBottomWidgets.isNotEmpty));
  }
}

extension StringExtension on String {
  String capitalize() {
    try {
      return "${this[0].toUpperCase()}${substring(1)}";
    } catch (ex) {
      return this;
    }
  }
}
