// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:darq/darq.dart';
import 'package:duration/locale.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/components/shim/modal_page.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/pages/timetable.dart';
import 'package:oshi/interface/shared/views/new_event.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart' show GradeBodyExtension;
import 'package:oshi/interface/shared/views/new_grade.dart';
import 'package:oshi/interface/components/cupertino/widgets/entries_form.dart';
import 'package:oshi/interface/components/cupertino/widgets/options_form.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:duration/duration.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _callTimeController = TextEditingController();
  final TextEditingController _bellTimeController = TextEditingController();
  final TextEditingController _syncTimeController = TextEditingController();

  final TextEditingController _toTitleController = TextEditingController();
  final TextEditingController _noTitleController = TextEditingController();
  final TextEditingController _noContentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _callTimeController.text =
        Share.session.settings.lessonCallTime == 15 ? '' : Share.session.settings.lessonCallTime.toString();
    _bellTimeController.text = Share.session.settings.bellOffset == Duration.zero
        ? ''
        : prettyDuration(Share.session.settings.bellOffset,
            tersity: DurationTersity.second,
            upperTersity: DurationTersity.minute,
            abbreviated: true,
            conjunction: ', ',
            spacer: '',
            locale: DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ?? EnglishDurationLocale());
    _syncTimeController.text = Share.session.settings.backgroundSyncInterval == 15
        ? ''
        : prettyDuration(Duration(minutes: Share.session.settings.backgroundSyncInterval),
            tersity: DurationTersity.second,
            upperTersity: DurationTersity.minute,
            abbreviated: true,
            conjunction: ', ',
            spacer: '',
            locale: DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ?? EnglishDurationLocale());
  }

  @override
  Widget build(BuildContext context) => DataPageBase.adaptive(
          pageFlags: [
            DataPageType.noTitleSpace,
            DataPageType.keepBackgroundWatchers,
          ].flag,
          setState: setState,
          title: 'Settings',
          previousPageTitle: 'Home',
          children: [
            // Name and school, avatar picker
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: true,
              children: [
                AdaptiveCard(
                    regular: true,
                    child: Row(children: [
                      Container(
                          margin: EdgeInsets.all(15),
                          child: GestureDetector(
                              onTap: (isAndroid || isIOS)
                                  ? () => ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                                        if (value == null) return;
                                        File(value.path).readAsBytes().then((result) =>
                                            Share.session.settings.setUserAvatar(result).then((value) => setState(() {})));
                                      })
                                  : null,
                              child: FutureBuilder(
                                  future: Share.session.settings.userAvatarImage,
                                  builder: (context, snapshot) => snapshot.hasData
                                      ? CircleAvatar(
                                          radius: 25,
                                          foregroundImage: snapshot.data?.image,
                                          backgroundColor: Colors.transparent,
                                        )
                                      : Icon(CupertinoIcons.person_circle_fill, size: 50)))),
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Share.session.data.student.account.name,
                              style: TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                          Opacity(
                              opacity: 0.5,
                              child: Text(Share.session.data.student.mainClass.unit.name,
                                  style: TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                        ],
                      ))
                    ]),
                    click: () => Navigator.push(
                        context,
                        AdaptivePageRoute(
                            builder: (context) => ModalPageBase.adaptive(title: 'About Me', children: [
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'ACCOUNT DATA',
                                    children: [
                                      AdaptiveCard(
                                          regular: true, child: 'Name', after: Share.session.data.student.account.name),
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'Class',
                                        after: Share.session.data.student.mainClass.className,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'Home teacher',
                                        after: Share.session.data.student.mainClass.classTutor.name,
                                      ),
                                    ],
                                  ),
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'SCHOOL DATA',
                                    children: [
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'Name',
                                        after: Share.session.data.student.mainClass.unit.name,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'Head teacher',
                                        after: Share.session.data.student.mainClass.unit.principalName,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'Address',
                                        click: () {
                                          try {
                                            MapsLauncher.launchQuery(
                                                '${Share.session.data.student.mainClass.unit.name}, ${Share.session.data.student.mainClass.unit.address}');
                                          } catch (ex) {
                                            // ignored
                                          }
                                        },
                                        after: Share.session.data.student.mainClass.unit.address,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'Phone',
                                        click: () {
                                          try {
                                            launchUrlString('tel:${Share.session.data.student.mainClass.unit.phone}');
                                          } catch (ex) {
                                            // ignored
                                          }
                                        },
                                        after: Share.session.data.student.mainClass.unit.phone,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        child: 'E-mail',
                                        click: () {
                                          try {
                                            launchUrlString('mailto:${Share.session.data.student.mainClass.unit.email}');
                                          } catch (ex) {
                                            // ignored
                                          }
                                        },
                                        after: Share.session.data.student.mainClass.unit.email,
                                      ),
                                    ],
                                  ),
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'SUMMARY',
                                    footer:
                                        'Presence times are calculated using only the registered attendances, assuming a lesson is 45 minutes long. The shown average is an average of all subjects\' averages.',
                                    children: [
                                      AdaptiveCard(
                                          regular: true,
                                          child: 'Average',
                                          after: () {
                                            var majors = Share.session.data.student.subjects
                                                .where((x) => x.hasMajor)
                                                .select((x, _) => x.topMajor!.asValue);
                                            return majors.isNotEmpty ? majors.average().toStringAsFixed(2) : 'Unavailable';
                                          }()),
                                      AdaptiveCard(
                                          regular: true,
                                          child: 'Wasted time',
                                          after: prettyDuration(
                                              tersity: DurationTersity.minute,
                                              upperTersity: DurationTersity.day,
                                              conjunction: ', ',
                                              Duration(
                                                  minutes: Share.session.data.student.attendances
                                                          ?.where((x) => x.lesson.subject?.name.toLowerCase() != 'religia')
                                                          .sum((x) => 45) ??
                                                      0),
                                              locale:
                                                  DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ??
                                                      EnglishDurationLocale())),
                                      AdaptiveCard(
                                          regular: true,
                                          child: 'Gained time',
                                          after: prettyDuration(
                                              tersity: DurationTersity.minute,
                                              upperTersity: DurationTersity.day,
                                              conjunction: ', ',
                                              Duration(
                                                  minutes: Share.session.data.student.attendances
                                                          ?.where((x) => x.lesson.subject?.name.toLowerCase() == 'religia')
                                                          .sum((x) => 45) ??
                                                      0),
                                              locale:
                                                  DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ??
                                                      EnglishDurationLocale())),
                                      AdaptiveCard(
                                          regular: true,
                                          child: 'Total presence',
                                          after:
                                              '${(100 * (Share.session.data.student.attendances?.count((x) => x.type == AttendanceType.present) ?? 0) / (Share.session.data.student.attendances?.count() ?? 1)).toStringAsFixed(1)}%'),
                                    ],
                                  ),
                                  CardContainer(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                      filled: false,
                                      additionalDividerMargin: 5,
                                      largeHeader: false,
                                      header: 'ATTENDANCE',
                                      children: (Share.session.data.student.attendances
                                                  ?.groupBy((element) => element.lesson.subject?.name ?? 'Unknown')
                                                  .select((element, index) => (
                                                        lesson: element.key,
                                                        value:
                                                            element.toList().count((x) => x.type == AttendanceType.present) /
                                                                element.count
                                                      ))
                                                  .orderBy((element) => element.lesson)
                                                  .select(
                                                    (element, index) => AdaptiveCard(
                                                        regular: true,
                                                        child: element.lesson,
                                                        after: Share.settings.appSettings.useCupertino
                                                            ? Container(
                                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                                child: Opacity(
                                                                    opacity: element.value >= 0.6 ? 0.5 : 1.0,
                                                                    child:
                                                                        Text('${(100 * element.value).toStringAsFixed(2)}%',
                                                                            style: TextStyle(
                                                                                color: switch (element.value) {
                                                                              < 0.5 => CupertinoColors.systemRed,
                                                                              < 0.6 => CupertinoColors.activeOrange,
                                                                              _ => null // Default
                                                                            }))))
                                                            : Text('${(100 * element.value).toStringAsFixed(2)}%')),
                                                  )
                                                  .toList() ??
                                              [])
                                          .appendIfEmpty(
                                        AdaptiveCard(regular: true, child: '', after: 'No attendances to display'),
                                      )),
                                  CardContainer(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                      filled: false,
                                      additionalDividerMargin: 5,
                                      largeHeader: false,
                                      header: 'AVERAGE',
                                      children: (Share.session.data.student.subjects
                                              .select(
                                                  (element, index) => (lesson: element.name, value: element.gradesAverage))
                                              .orderBy((element) => element.lesson)
                                              .select(
                                                (element, index) => AdaptiveCard(
                                                    regular: true,
                                                    child: element.lesson,
                                                    after: Share.settings.appSettings.useCupertino
                                                        ? Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                                            child: Opacity(
                                                                opacity: element.value >= 0 ? 1.0 : 0.0,
                                                                child: Text(
                                                                    element.value >= 0
                                                                        ? element.value.toStringAsFixed(2)
                                                                        : '-',
                                                                    style: TextStyle(
                                                                        color: switch (Share.session.settings
                                                                                .customGradeMarginValuesMap.entries
                                                                                .firstWhereOrDefault((x) =>
                                                                                    (x.value < element.value) &&
                                                                                    (x.value.floor() ==
                                                                                        element.value.floor()))
                                                                                ?.key ??
                                                                            (element.value - 0.25).round()) {
                                                                      6 => CupertinoColors.systemTeal,
                                                                      5 => CupertinoColors.systemGreen,
                                                                      4 => Color(0xFF76FF03),
                                                                      3 => CupertinoColors.systemOrange,
                                                                      2 => CupertinoColors.systemRed,
                                                                      1 => CupertinoColors.destructiveRed,
                                                                      _ => CupertinoColors.inactiveGray
                                                                    }))))
                                                        : element.value >= 0
                                                            ? element.value.toStringAsFixed(2)
                                                            : 'Unavailable'),
                                              )
                                              .toList())
                                          .appendIfEmpty(
                                        AdaptiveCard(regular: true, child: '', after: 'No attendances to display'),
                                      ))
                                ]))))
              ],
            ),
            // Settings - appearance settings
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : 'Appearance settings',
              children: [
                AdaptiveCard(
                    regular: true,
                    click: () => Navigator.push(
                        context,
                        AdaptivePageRoute(
                            builder: (context) => ModalPageBase.adaptive(title: 'App Style', children: [
                                  OptionsForm(
                                      selection: Share.settings.appSettings.useCupertino,
                                      description:
                                          'Note, there is no ETA for the Material interface style. Likely, the Cupertino one has to be finished first, as there is only one developer.',
                                      options: [
                                        OptionEntry(name: 'Cupertino', value: true),
                                        OptionEntry(name: 'Material', value: false),
                                      ],
                                      update: <T>(v) {
                                        if (Share.settings.appSettings.useCupertino == v) return;
                                        Share.settings.appSettings.useCupertino = v; // Set
                                        Share.changeBase.broadcast(); // Refresh
                                        Navigator.of(context).pop();
                                      })
                                ]))),
                    child: 'App Style',
                    after: Share.settings.appSettings.useCupertino ? 'Cupertino' : 'Material'),
                AdaptiveCard(
                    regular: true,
                    click: () => Navigator.push(
                        context,
                        AdaptivePageRoute(
                            builder: (context) => ModalPageBase.adaptive(title: 'Accent Color', children: [
                                  OptionsForm(
                                      selection: Resources.cupertinoAccentColors.entries
                                              .firstWhereOrDefault((value) =>
                                                  value.value.color == Share.session.settings.cupertinoAccentColor.color)
                                              ?.key ??
                                          0,
                                      description:
                                          'Note, this color may be overridden during certain events, such as Christmas, Easter, or Halloween.',
                                      options: Resources.cupertinoAccentColors.entries
                                          .select((x, index) => OptionEntry(
                                              name: x.value.name,
                                              value: x.key,
                                              decoration: Container(
                                                  margin: EdgeInsets.only(bottom: 2, right: 7),
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: x.value.color),
                                                  ))))
                                          .toList(),
                                      update: <T>(v) {
                                        Share.session.settings.cupertinoAccentColor = Resources.cupertinoAccentColors[v] ??
                                            Resources.cupertinoAccentColors.values.first; // Set
                                        Share.refreshBase.broadcast(); // Refresh
                                      })
                                ]))),
                    child: 'Accent Color',
                    after: Share.session.settings.cupertinoAccentColor.name),
                AdaptiveCard(
                    regular: true,
                    click: () => Navigator.push(
                        context,
                        AdaptivePageRoute(
                            builder: (context) => ModalPageBase.adaptive(title: 'Language', children: [
                                  OptionsForm(
                                      selection: Share.settings.appSettings.languageCode,
                                      description:
                                          'The selected language will only be reflected in the app interface. Grade, event, lesson descriptions and generated messages will not be affected.',
                                      options: Share.translator.supportedLanguages
                                          .select((x, index) => OptionEntry(name: x.name, value: x.code))
                                          .toList(),
                                      update: <T>(v) {
                                        Share.settings.appSettings.languageCode = v; // Set
                                        Share.translator
                                            .loadResources(Share.settings.appSettings.languageCode)
                                            .then((value) {
                                          Share.currentIdleSplash = Share.translator.getRandomSplash();
                                          Share.currentEndingSplash = Share.translator.getRandomEndingSplash();
                                          Share.refreshBase.broadcast(); // Refresh everything
                                        }); // Refresh
                                      })
                                ]))),
                    child: 'Language',
                    after: Share.translator.localeName),
              ],
            ),
            // Settings - app settings
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : 'Sharing and sync',
              children: [
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) => ModalPageBase.adaptive(title: 'Sync Settings', children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        children: [
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 3,
                                                  child: Text('Background synchronization',
                                                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableBackgroundSync,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.enableBackgroundSync = s))),
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        footer:
                                            'Synchronization will only happen when you have a working internet connection and Oshi is closed.',
                                        children: [
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 3,
                                                  child: Text('Synchronize on Wi-Fi only',
                                                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.backgroundSyncWiFiOnly,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.backgroundSyncWiFiOnly = s))),
                                          CupertinoListTile(
                                              title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                  child: Text('Refresh interval',
                                                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              ConstrainedBox(
                                                  constraints: BoxConstraints(maxWidth: 100),
                                                  child: CupertinoTextField.borderless(
                                                      onChanged: (s) => setState(() {}),
                                                      onSubmitted: (value) {
                                                        var result = tryParseDuration(value);
                                                        if (result != null &&
                                                            (result < Duration(minutes: 15) ||
                                                                result > Duration(minutes: 180))) {
                                                          result = null;
                                                        }
                                                        Share.session.settings.backgroundSyncInterval =
                                                            result?.inMinutes ?? 15;
                                                        setState(() => _syncTimeController.text = result != null
                                                            ? prettyDuration(result,
                                                                tersity: DurationTersity.second,
                                                                upperTersity: DurationTersity.minute,
                                                                abbreviated: true,
                                                                conjunction: ', ',
                                                                spacer: '',
                                                                locale: DurationLocale.fromLanguageCode(
                                                                        Share.settings.appSettings.localeCode) ??
                                                                    EnglishDurationLocale())
                                                            : '');
                                                      },
                                                      controller: _syncTimeController,
                                                      placeholder: '15 minutes',
                                                      expands: false,
                                                      textAlign: TextAlign.end,
                                                      maxLength: 10,
                                                      showCursor: _syncTimeController.text.isNotEmpty,
                                                      maxLengthEnforcement: MaxLengthEnforcement.enforced)),
                                            ],
                                          )),
                                        ])
                                  ]))))),
                  child: 'Sync Settings',
                  after: Share.settings.appSettings.useCupertino ? '' : 'Background synchronization',
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) => ModalPageBase.adaptive(title: 'Shared Events', children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        noDivider: true,
                                        footer: Container(margin: EdgeInsets.symmetric(horizontal: 20)),
                                        children: [
                                          GestureDetector(
                                              onTap: () => launchUrlString('https://github.com/szkolny-eu/szkolny-android'),
                                              child: Image.network(
                                                  'https://github.com/szkolny-eu/szkolny-android/blob/develop/.github/readme-banner.png?raw=true')),
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        footer:
                                            'By courtesy of Szkolny.eu developers, Szkolny.eu apps and Oshi can now share events, notes, and notifications!',
                                        children: [
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 3,
                                                  child: Text('Allow registration',
                                                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.allowSzkolnyIntegration,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.allowSzkolnyIntegration = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 3,
                                                  child: Opacity(
                                                      opacity: Share.session.settings.allowSzkolnyIntegration ? 1.0 : 0.5,
                                                      child: Text('Share events by default',
                                                          maxLines: 1, overflow: TextOverflow.ellipsis))),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.allowSzkolnyIntegration &&
                                                      Share.session.settings.shareEventsByDefault,
                                                  onChanged: Share.session.settings.allowSzkolnyIntegration
                                                      ? (s) =>
                                                          setState(() => Share.session.settings.shareEventsByDefault = s)
                                                      : null)),
                                        ])
                                  ]))))),
                  child: 'Shared Events',
                  after: Share.settings.appSettings.useCupertino ? '' : 'Thanks to szkolny.eu',
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) => ModalPageBase.adaptive(title: 'Notifications', children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        largeHeader: false,
                                        header: 'NOTIFICATION FILTERS',
                                        children: [
                                          CupertinoListTile(
                                            title: Text('Request notification access'),
                                            trailing: CupertinoListTileChevron(),
                                          )
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        children: [
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('App updates', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: true,
                                                  onChanged: (s) => NotificationController.sendNotification(
                                                      title: 'Pathetic.',
                                                      content: 'You thought you could escape?',
                                                      category: NotificationCategories.other)))
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        footer:
                                            'Notifications will be sent for the selected categories once the new data is downloaded and there are any changes.',
                                        children: [
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Timetables', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableTimetableNotifications,
                                                  onChanged: (s) => setState(
                                                      () => Share.session.settings.enableTimetableNotifications = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Grades', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableGradesNotifications,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.enableGradesNotifications = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Events', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableEventsNotifications,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.enableEventsNotifications = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Attendance', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableAttendanceNotifications,
                                                  onChanged: (s) => setState(
                                                      () => Share.session.settings.enableAttendanceNotifications = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child:
                                                      Text('Announcements', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableAnnouncementsNotifications,
                                                  onChanged: (s) => setState(
                                                      () => Share.session.settings.enableAnnouncementsNotifications = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Messages', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.enableMessagesNotifications,
                                                  onChanged: (s) => setState(
                                                      () => Share.session.settings.enableMessagesNotifications = s))),
                                        ])
                                  ]))))),
                  child: 'Notifications',
                  after: Share.settings.appSettings.useCupertino ? '' : 'Select categories',
                )
              ],
            ),
            // Settings - timetable settings
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : 'User data',
              children: [
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => ModalPageBase.adaptive(title: 'Timetable Settings', children: [
                                CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'BELL SYNCHRONIZATION',
                                    footer:
                                        'Used to calibrate bell times in the app to offsets used by particular schools, format i.e. \'10s\', \'1min, 5s\' Don\'t forget to confirm your input!',
                                    children: [
                                      CupertinoListTile(
                                          title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              child:
                                                  Text('School bell offset', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 100),
                                              child: CupertinoTextField.borderless(
                                                  onChanged: (s) => setState(() {}),
                                                  onSubmitted: (value) {
                                                    var result = tryParseDuration(value);
                                                    if (result != null &&
                                                        (result > Duration(minutes: 15) ||
                                                            result < Duration(minutes: -15))) {
                                                      result = null;
                                                    }
                                                    Share.session.settings.bellOffset = result ?? Duration.zero;
                                                    setState(() => _bellTimeController.text = result != null
                                                        ? prettyDuration(result,
                                                            tersity: DurationTersity.second,
                                                            upperTersity: DurationTersity.minute,
                                                            abbreviated: true,
                                                            conjunction: ', ',
                                                            spacer: '',
                                                            locale: DurationLocale.fromLanguageCode(
                                                                    Share.settings.appSettings.localeCode) ??
                                                                EnglishDurationLocale())
                                                        : '');
                                                  },
                                                  controller: _bellTimeController,
                                                  placeholder: '0 seconds',
                                                  expands: false,
                                                  textAlign: TextAlign.end,
                                                  maxLength: 10,
                                                  showCursor: _bellTimeController.text.isNotEmpty,
                                                  maxLengthEnforcement: MaxLengthEnforcement.enforced)),
                                        ],
                                      )),
                                    ]),
                                CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'LESSON CALL TIME',
                                    footer:
                                        'In minutes, will be used for "calling" last X minutes of a lesson. Falls back 15 minutes by default.',
                                    children: [
                                      CupertinoListTile(
                                          title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              child: Text('Lesson call time', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 70),
                                              child: CupertinoTextField.borderless(
                                                  onChanged: (value) {
                                                    var result = int.tryParse(value);
                                                    if (result != null && (result > 45 || result <= 0)) result = null;
                                                    Share.session.settings.lessonCallTime = result ?? 15;
                                                    setState(() => _callTimeController.text = result?.toString() ?? '');
                                                  },
                                                  controller: _callTimeController,
                                                  placeholder: '15 min',
                                                  expands: false,
                                                  textAlign: TextAlign.end,
                                                  maxLength: 2,
                                                  showCursor: _callTimeController.text.isNotEmpty,
                                                  maxLengthEnforcement: MaxLengthEnforcement.enforced)),
                                        ],
                                      )),
                                    ]),
                                OptionsForm(
                                    pop: false,
                                    header: 'CALL SETTINGS',
                                    selection: Share.session.settings.lessonCallType,
                                    description:
                                        'Note, this is used only for auto-generating preset messages, which may not always be accurate.',
                                    options: LessonCallTypes.values
                                        .select((x, index) => OptionEntry(name: x.name, value: x))
                                        .toList(),
                                    update: <T>(v) {
                                      Share.session.settings.lessonCallType = v; // Set
                                      Share.refreshBase.broadcast(); // Refresh
                                    })
                              ]))),
                  child: 'Timetable Settings',
                  after: Share.settings.appSettings.useCupertino ? '' : 'School bell offset',
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) => ModalPageBase.adaptive(
                                  title: 'Custom Events',
                                  trailing: AdaptiveMenuButton(
                                    itemBuilder: (context) => [
                                      AdaptiveMenuItem(
                                        title: 'New event',
                                        icon: CupertinoIcons.add,
                                        onTap: () => showCupertinoModalBottomSheet(
                                            context: context,
                                            builder: (context) => EventComposePage()).then((value) => setState(() {})),
                                      )
                                    ],
                                  ),
                                  children: Share.session.customEvents
                                      .where((x) =>
                                          (x.date ?? x.timeFrom).isAfter(DateTime.now().add(Duration(days: -1)).asDate()))
                                      .orderBy((x) => x.date ?? x.timeFrom)
                                      .groupBy((x) => DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode)
                                          .format(x.date ?? x.timeFrom))
                                      .select((element, index) => CardContainer(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                          filled: false,
                                          header: Text(element.key),
                                          additionalDividerMargin: 5,
                                          children: element.isEmpty
                                              // No messages to display
                                              ? [
                                                  CupertinoListTile(
                                                      title: Opacity(
                                                          opacity: 0.5,
                                                          child: Container(
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                'No events to display',
                                                                style:
                                                                    TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                              ))))
                                                ]
                                              // Bindable messages layout
                                              : element
                                                  .toList()
                                                  .asEventWidgets(null, '', 'No events matching the query', setState)))
                                      .appendIfEmpty(CardContainer(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                          filled: false,
                                          additionalDividerMargin: 5,
                                          children: [
                                            CupertinoListTile(
                                                title: Opacity(
                                                    opacity: 0.5,
                                                    child: Container(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          'No events to display',
                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                                                        ))))
                                          ]))
                                      .toList()))))),
                  child: 'Custom Events',
                  after: Share.settings.appSettings.useCupertino ? '' : 'Shared with the class',
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) => ModalPageBase.adaptive(title: 'Grades Settings', children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        largeHeader: false,
                                        header: 'AVERGAE CALCULATION',
                                        footer:
                                            'Average calculation will ignore weights if all of them are 0 for auto-adapt enabled.',
                                        children: [
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Use weighted average',
                                                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.weightedAverage,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.weightedAverage = s))),
                                          CupertinoFormRow(
                                              prefix: Flexible(
                                                  flex: 2,
                                                  child: Text('Auto-adapt to grades',
                                                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                                              child: CupertinoSwitch(
                                                  value: Share.session.settings.autoArithmeticAverage,
                                                  onChanged: (s) =>
                                                      setState(() => Share.session.settings.autoArithmeticAverage = s))),
                                        ]),
                                    OptionsForm(
                                        pop: false,
                                        header: 'YEARLY AVERAGE',
                                        selection: Share.session.settings.yearlyAverageMethod,
                                        description:
                                            'Note, the average displayed by the app is calculated locally, and may not be respected by every school.',
                                        options: YearlyAverageMethods.values
                                            .select((x, index) => OptionEntry(name: x.name, value: x))
                                            .toList(),
                                        update: <T>(v) {
                                          Share.session.settings.yearlyAverageMethod = v; // Set
                                          Share.refreshBase.broadcast(); // Refresh
                                        }),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        largeHeader: false,
                                        header: 'GRADES SIMULATOR',
                                        footer:
                                            'Grades added by you here are not synchronized across devices, and have local effect only.',
                                        children: [
                                          CupertinoListTile(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  AdaptivePageRoute(
                                                      builder: (context) => StatefulBuilder(
                                                          builder: ((context, setState) => ModalPageBase.adaptive(
                                                              title: 'Custom Grades',
                                                              previousPageTitle: 'Grade Settings',
                                                              trailing: AdaptiveMenuButton(
                                                                itemBuilder: (context) => [
                                                                  AdaptiveMenuItem(
                                                                    title: 'New custom grade',
                                                                    icon: CupertinoIcons.add,
                                                                    onTap: () => showCupertinoModalBottomSheet(
                                                                            context: context,
                                                                            builder: (context) => GradeComposePage())
                                                                        .then((value) => setState(() {})),
                                                                  )
                                                                ],
                                                              ),
                                                              children: Share.session.customGrades.entries
                                                                  .selectMany((x, _) =>
                                                                      x.value.select((y, _) => (lesson: x.key, grade: y)))
                                                                  .orderBy((x) => x.grade.date)
                                                                  .groupBy((x) => x.lesson)
                                                                  .select((element, index) => CardContainer(
                                                                      margin:
                                                                          EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                      filled: false,
                                                                      header: Text(element.key.nameExtra),
                                                                      additionalDividerMargin: 5,
                                                                      children: element.isEmpty
                                                                          // No messages to display
                                                                          ? [
                                                                              CupertinoListTile(
                                                                                  title: Opacity(
                                                                                      opacity: 0.5,
                                                                                      child: Container(
                                                                                          alignment: Alignment.center,
                                                                                          child: Text(
                                                                                            'No grades to display',
                                                                                            style: TextStyle(
                                                                                                fontSize: 16,
                                                                                                fontWeight:
                                                                                                    FontWeight.normal),
                                                                                          ))))
                                                                            ]
                                                                          // Bindable messages layout
                                                                          : element
                                                                              .toList()
                                                                              .select((x, _) =>
                                                                                  x.grade.asGrade(context, setState))
                                                                              .toList()))
                                                                  .appendIfEmpty(CardContainer(
                                                                      margin:
                                                                          EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                      filled: false,
                                                                      additionalDividerMargin: 5,
                                                                      children: [
                                                                        CupertinoListTile(
                                                                            title: Opacity(
                                                                                opacity: 0.5,
                                                                                child: Container(
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      'No grades to display',
                                                                                      style: TextStyle(
                                                                                          fontSize: 16,
                                                                                          fontWeight: FontWeight.normal),
                                                                                    ))))
                                                                      ]))
                                                                  .toList()))))),
                                              title: Text('Custom Grades', overflow: TextOverflow.ellipsis),
                                              trailing: CupertinoListTileChevron()),
                                        ]),
                                  ]))))),
                  child: 'Grades Settings',
                  after: Share.settings.appSettings.useCupertino ? '' : 'Average calculation',
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => ModalPageBase.adaptive(title: 'Custom Grade Values', children: [
                                // Custom grade values
                                EntriesForm<double>(
                                    header: 'CUSTOM GRADE MODIFIERS',
                                    description:
                                        'These values will overwite all default grade modifiers for the specified entries, e.g. count \'-\' as \'-0.25\', etc.',
                                    placeholder: 'Value',
                                    maxKeyLength: 1,
                                    update: <T>([v]) => (Share.session.settings.customGradeModifierValues =
                                            v?.cast() ?? Share.session.settings.customGradeModifierValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v)),
                                // Custom grade values
                                EntriesForm<double>(
                                    header: 'CUSTOM GRADE MARGINS',
                                    description:
                                        'These values will overwite the default grade margins, e.g. make values such as \'4.75\' count as \'5\', etc.',
                                    placeholder: 'Value',
                                    update: <T>([v]) => (Share.session.settings.customGradeMarginValues =
                                            v?.cast() ?? Share.session.settings.customGradeMarginValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v)),
                                // Custom grade values
                                EntriesForm<double>(
                                    header: 'CUSTOM GRADES',
                                    description:
                                        'These values will overwite all default grade values for the specified entries, e.g. from \'nb\' to \'1\', etc.',
                                    placeholder: 'Value',
                                    update: <T>([v]) => (Share.session.settings.customGradeValues =
                                            v?.cast() ?? Share.session.settings.customGradeValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v))
                              ]))),
                  child: 'Custom Grade Values',
                  after: Share.settings.appSettings.useCupertino ? '' : 'Plus, minus, and other values',
                )
              ],
            ),
            // Settings - credits
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : 'About',
              children: [
                AdaptiveCard(
                    regular: true,
                    click: () => Navigator.push(
                        context,
                        AdaptivePageRoute(
                            builder: (context) => ModalPageBase.adaptive(title: 'App Info', children: [
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'VERSION INFO',
                                    children: [
                                      AdaptiveCard(
                                          regular: true,
                                          child: 'Version',
                                          after: GestureDetector(
                                              onDoubleTap: () => Navigator.push(
                                                  context,
                                                  AdaptivePageRoute(
                                                      builder: (context) => StatefulBuilder(
                                                          builder: ((context, setState) => ModalPageBase.adaptive(
                                                              title: 'Developers',
                                                              previousPageTitle: 'App Info',
                                                              children: [
                                                                // Developer mode
                                                                CardContainer(
                                                                    margin:
                                                                        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                    filled: false,
                                                                    additionalDividerMargin: 5,
                                                                    largeHeader: false,
                                                                    header: 'FOR DEVELOPERS',
                                                                    children: [
                                                                      CupertinoFormRow(
                                                                          prefix: Flexible(
                                                                              flex: 2,
                                                                              child: Text('Developer mode',
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis)),
                                                                          child: CupertinoSwitch(
                                                                              value: Share.session.settings.devMode,
                                                                              onChanged: (s) {
                                                                                setState(() =>
                                                                                    Share.session.settings.devMode = s);
                                                                                Share.refreshBase
                                                                                    .broadcast(); // Refresh everything
                                                                              }))
                                                                    ]),
                                                                CardContainer(
                                                                    margin:
                                                                        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                    filled: false,
                                                                    additionalDividerMargin: 5,
                                                                    largeHeader: false,
                                                                    header: 'APPLICATION DIALOG TESTS',
                                                                    children: [
                                                                      // Toasts
                                                                      CupertinoFormRow(
                                                                          prefix: Flexible(
                                                                              flex: 2,
                                                                              child: CupertinoButton(
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      Fluttertoast.showToast(
                                                                                        msg: _toTitleController.text,
                                                                                        toastLength: Toast.LENGTH_SHORT,
                                                                                        gravity: ToastGravity.CENTER,
                                                                                        timeInSecForIosWeb: 1,
                                                                                      );
                                                                                    } catch (ex) {
                                                                                      // ignored
                                                                                    }
                                                                                  },
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Text('Toast test',
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis))),
                                                                          child: Column(children: [
                                                                            CupertinoTextField(
                                                                                controller: _noTitleController,
                                                                                placeholder: 'Title'),
                                                                          ])),
                                                                      // Modal dialog
                                                                      CupertinoFormRow(
                                                                          prefix: Flexible(
                                                                              flex: 2,
                                                                              child: CupertinoButton(
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      showCupertinoModalPopup<void>(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) =>
                                                                                              CupertinoAlertDialog(
                                                                                                title: Text(
                                                                                                    _noTitleController.text),
                                                                                                content: Text(
                                                                                                    _noContentController
                                                                                                        .text),
                                                                                              ));
                                                                                    } catch (ex) {
                                                                                      // ignored
                                                                                    }
                                                                                  },
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Text('Modal test',
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis))),
                                                                          child: Column(children: [
                                                                            CupertinoTextField(
                                                                                controller: _noTitleController,
                                                                                placeholder: 'Title'),
                                                                          ])),
                                                                      // Alert dialog
                                                                      CupertinoFormRow(
                                                                          prefix: Flexible(
                                                                              flex: 2,
                                                                              child: CupertinoButton(
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      Share.showErrorModal.broadcast(Value((
                                                                                        title: _noTitleController.text,
                                                                                        message: _noContentController.text,
                                                                                        actions: {}
                                                                                      )));
                                                                                    } catch (ex) {
                                                                                      // ignored
                                                                                    }
                                                                                  },
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Text('Alert test',
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis))),
                                                                          child: Column(children: [
                                                                            CupertinoTextField(
                                                                                controller: _noTitleController,
                                                                                placeholder: 'Title'),
                                                                            Container(
                                                                                margin: EdgeInsets.only(top: 6),
                                                                                child: CupertinoTextField(
                                                                                    controller: _noContentController,
                                                                                    placeholder: 'Content')),
                                                                          ])),
                                                                      // Notifications
                                                                      CupertinoFormRow(
                                                                          prefix: Flexible(
                                                                              flex: 2,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  CupertinoButton(
                                                                                      onPressed: () {
                                                                                        try {
                                                                                          NotificationController
                                                                                              .sendNotification(
                                                                                                  title: _noTitleController
                                                                                                      .text,
                                                                                                  content:
                                                                                                      _noContentController
                                                                                                          .text,
                                                                                                  category:
                                                                                                      NotificationCategories
                                                                                                          .register,
                                                                                                  data: jsonEncode(
                                                                                                      TimelineNotification()
                                                                                                          .toJson()));
                                                                                        } catch (ex) {
                                                                                          // ignored
                                                                                        }
                                                                                      },
                                                                                      padding: EdgeInsets.zero,
                                                                                      child: Text('Register notification',
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis)),
                                                                                  CupertinoButton(
                                                                                      onPressed: () {
                                                                                        try {
                                                                                          NotificationController.sendNotification(
                                                                                              title: _noTitleController.text,
                                                                                              content:
                                                                                                  _noContentController.text,
                                                                                              category:
                                                                                                  NotificationCategories
                                                                                                      .messages,
                                                                                              data: jsonEncode(TimelineNotification(
                                                                                                      data: Announcement(
                                                                                                          subject:
                                                                                                              _noTitleController
                                                                                                                  .text,
                                                                                                          content:
                                                                                                              _noContentController
                                                                                                                  .text,
                                                                                                          contact: Teacher(
                                                                                                              firstName:
                                                                                                                  _noTitleController
                                                                                                                      .text,
                                                                                                              lastName:
                                                                                                                  _noContentController
                                                                                                                      .text)))
                                                                                                  .toJson()));
                                                                                        } catch (ex) {
                                                                                          // ignored
                                                                                        }
                                                                                      },
                                                                                      padding: EdgeInsets.zero,
                                                                                      child: Text('Mess/Ann notification',
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis)),
                                                                                  CupertinoButton(
                                                                                      onPressed: () {
                                                                                        try {
                                                                                          NotificationController
                                                                                              .sendNotification(
                                                                                                  title: _noTitleController
                                                                                                      .text,
                                                                                                  content:
                                                                                                      _noContentController
                                                                                                          .text,
                                                                                                  category:
                                                                                                      NotificationCategories
                                                                                                          .other);
                                                                                        } catch (ex) {
                                                                                          // ignored
                                                                                        }
                                                                                      },
                                                                                      padding: EdgeInsets.zero,
                                                                                      child: Text('Other notification',
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis))
                                                                                ],
                                                                              )),
                                                                          child: Column(children: [
                                                                            CupertinoTextField(
                                                                                controller: _noTitleController,
                                                                                placeholder: 'Title'),
                                                                            Container(
                                                                                margin: EdgeInsets.only(top: 6),
                                                                                child: CupertinoTextField(
                                                                                    controller: _noContentController,
                                                                                    placeholder: 'Content')),
                                                                          ])),
                                                                    ]),
                                                                // Codes - user
                                                                CardContainer(
                                                                    margin:
                                                                        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                    filled: false,
                                                                    additionalDividerMargin: 5,
                                                                    largeHeader: false,
                                                                    header: 'SHARING CODES',
                                                                    children: [
                                                                      CupertinoFormRow(
                                                                          prefix: Flexible(
                                                                              flex: 1,
                                                                              child: Text('User code',
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis)),
                                                                          child: Flexible(
                                                                              flex: 3,
                                                                              child: Container(
                                                                                  margin: EdgeInsets.only(
                                                                                      top: 8, bottom: 8, right: 8),
                                                                                  child: Text(
                                                                                      Share.session.data.student.userCode,
                                                                                      maxLines: 3,
                                                                                      overflow: TextOverflow.ellipsis))))
                                                                    ]),
                                                              ].appendAllIf([
                                                                // Codes - classes
                                                                CardContainer(
                                                                    margin:
                                                                        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                    filled: false,
                                                                    additionalDividerMargin: 5,
                                                                    largeHeader: false,
                                                                    header: 'VIRTUAL CLASS CODES',
                                                                    children: Share.session.data.student.teamCodes.entries
                                                                        .select((x, _) => CupertinoFormRow(
                                                                            prefix: Flexible(
                                                                                flex: 1,
                                                                                child: Text(x.value,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis)),
                                                                            child: Flexible(
                                                                                flex: 3,
                                                                                child: Container(
                                                                                    margin: EdgeInsets.only(
                                                                                        top: 8, bottom: 8, right: 8),
                                                                                    child: Text(x.key,
                                                                                        maxLines: 3,
                                                                                        overflow: TextOverflow.ellipsis)))))
                                                                        .toList()),
                                                              ], Share.session.data.student.teamCodes.isNotEmpty)))))),
                                              child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                                  child: Opacity(opacity: 0.5, child: Text(Share.buildNumber))))),
                                      AdaptiveCard(
                                          regular: true,
                                          child: 'Build',
                                          after: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(opacity: 0.5, child: Text(Share.buildNumber.split('.').last))))
                                    ],
                                  ),
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'CONTRIBUTORS',
                                    children: [
                                      CupertinoListTile(
                                          onTap: () {
                                            try {
                                              launchUrlString('https://github.com/KimihikoAkayasaki');
                                            } catch (ex) {
                                              // ignored
                                            }
                                          },
                                          title: Text('公彦赤屋先', overflow: TextOverflow.ellipsis),
                                          trailing: Row(children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(opacity: 0.5, child: Text('Lead Developer'))),
                                            CupertinoListTileChevron()
                                          ])),
                                      CupertinoListTile(
                                          onTap: () {
                                            try {
                                              launchUrlString('https://github.com/xFaiafokkusu');
                                            } catch (ex) {
                                              // ignored
                                            }
                                          },
                                          title: Text('Faiafokkusu', overflow: TextOverflow.ellipsis),
                                          trailing: Row(children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(opacity: 0.5, child: Text('Support Developer'))),
                                            CupertinoListTileChevron()
                                          ])),
                                      CupertinoListTile(
                                          onTap: () {
                                            try {
                                              launchUrlString('https://github.com/AAhockey');
                                            } catch (ex) {
                                              // ignored
                                            }
                                          },
                                          title: Text('AAhockey', overflow: TextOverflow.ellipsis),
                                          trailing: Row(children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(opacity: 0.5, child: Text('Support'))),
                                            CupertinoListTileChevron()
                                          ]))
                                    ],
                                  )
                                ]))),
                    child: 'App Info',
                    after: Share.buildNumber),
                AdaptiveCard(
                    regular: true,
                    click: () {
                      try {
                        launchUrlString('https://github.com/Ogaku');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    child: 'Socials',
                    after: 'GitHub'),
                AdaptiveCard(
                    regular: true,
                    click: () {
                      try {
                        launchUrlString('https://ko-fi.com/ogaku_oshi');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    child: 'Support Us',
                    after: 'Ko-fi'),
                AdaptiveCard(
                    regular: true,
                    click: () {
                      try {
                        launchUrlString('https://discord.gg/7EzU9M3W5H');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    child: 'Contact Us',
                    after: 'Discord'),
              ],
            ),
          ]);
}
