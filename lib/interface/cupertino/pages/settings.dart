// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:darq/darq.dart';
import 'package:duration/locale.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/cupertino/pages/home.dart';
import 'package:oshi/interface/cupertino/pages/timetable.dart';
import 'package:oshi/interface/cupertino/views/new_event.dart';
import 'package:oshi/interface/cupertino/widgets/entries_form.dart';
import 'package:oshi/interface/cupertino/widgets/modal_page.dart';
import 'package:oshi/interface/cupertino/widgets/options_form.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:pull_down_button/pull_down_button.dart';
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
  Widget build(BuildContext context) => SearchableSliverNavigationBar(
          setState: setState,
          largeTitle: Text('Settings'),
          previousPageTitle: 'Home',
          disableAddons: true,
          keepBackgroundWatchers: true,
          anchor: 0.0,
          children: [
            // Name and school, avatar picker
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              children: [
                CupertinoListTile(
                    padding: EdgeInsets.only(right: 15),
                    title: Row(children: [
                      Container(
                          margin: EdgeInsets.all(15),
                          child: GestureDetector(
                              onTap: (Platform.isAndroid || Platform.isIOS)
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
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'About Me', children: [
                                  CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                    additionalDividerMargin: 5,
                                    header: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Text('ACCOUNT DATA',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                    children: [
                                      CupertinoListTile(
                                          title: Text('Name', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5, child: Text(Share.session.data.student.account.name)))),
                                      CupertinoListTile(
                                          title: Text('Class', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(Share.session.data.student.mainClass.className)))),
                                      CupertinoListTile(
                                          title: Text('Home teacher', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(Share.session.data.student.mainClass.classTutor.name)))),
                                    ],
                                  ),
                                  CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                    additionalDividerMargin: 5,
                                    header: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Text('SCHOOL DATA',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                    children: [
                                      CupertinoListTile(
                                          title: Text('Name', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(Share.session.data.student.mainClass.unit.name)))),
                                      CupertinoListTile(
                                          title: Text('Head teacher', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(Share.session.data.student.mainClass.unit.principalName)))),
                                      CupertinoListTile(
                                          title: Text('Address', overflow: TextOverflow.ellipsis),
                                          onTap: () {
                                            try {
                                              MapsLauncher.launchQuery(
                                                  '${Share.session.data.student.mainClass.unit.name}, ${Share.session.data.student.mainClass.unit.address}');
                                            } catch (ex) {
                                              // ignored
                                            }
                                          },
                                          trailing: Row(children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(Share.session.data.student.mainClass.unit.address))),
                                            CupertinoListTileChevron()
                                          ])),
                                      CupertinoListTile(
                                          title: Text('Phone', overflow: TextOverflow.ellipsis),
                                          onTap: () {
                                            try {
                                              launchUrlString('tel:${Share.session.data.student.mainClass.unit.phone}');
                                            } catch (ex) {
                                              // ignored
                                            }
                                          },
                                          trailing: Row(children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(Share.session.data.student.mainClass.unit.phone))),
                                            CupertinoListTileChevron()
                                          ])),
                                      CupertinoListTile(
                                          title: Text('E-mail', overflow: TextOverflow.ellipsis),
                                          onTap: () {
                                            try {
                                              launchUrlString('mailto:${Share.session.data.student.mainClass.unit.email}');
                                            } catch (ex) {
                                              // ignored
                                            }
                                          },
                                          trailing: Row(children: [
                                            Container(
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child: Text(Share.session.data.student.mainClass.unit.email))),
                                            CupertinoListTileChevron()
                                          ])),
                                    ],
                                  ),
                                  CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                    additionalDividerMargin: 5,
                                    header: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Text('SUMMARY',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                    footer: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Text(
                                                'Presence times are calculated using only the registered attendances, assuming a lesson is 45 minutes long. The shown average is an average of all subjects\' averages.',
                                                style: TextStyle(fontSize: 13)))),
                                    children: [
                                      CupertinoListTile(
                                          title: Text('Average', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(Share.session.data.student.subjects
                                                      .where((x) => x.gradesAverage > 0)
                                                      .average((x) => x.gradesAverage)
                                                      .toStringAsFixed(2))))),
                                      CupertinoListTile(
                                          title: Text('Wasted time', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(prettyDuration(
                                                      tersity: DurationTersity.minute,
                                                      upperTersity: DurationTersity.day,
                                                      conjunction: ', ',
                                                      Duration(
                                                          minutes: Share.session.data.student.attendances
                                                                  ?.where((x) =>
                                                                      x.lesson.subject?.name.toLowerCase() != 'religia')
                                                                  .sum((x) => 45) ??
                                                              0),
                                                      locale: DurationLocale.fromLanguageCode(
                                                              Share.settings.appSettings.localeCode) ??
                                                          EnglishDurationLocale()))))),
                                      CupertinoListTile(
                                          title: Text('Gained time', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(prettyDuration(
                                                      tersity: DurationTersity.minute,
                                                      upperTersity: DurationTersity.day,
                                                      conjunction: ', ',
                                                      Duration(
                                                          minutes: Share.session.data.student.attendances
                                                                  ?.where((x) =>
                                                                      x.lesson.subject?.name.toLowerCase() == 'religia')
                                                                  .sum((x) => 45) ??
                                                              0),
                                                      locale: DurationLocale.fromLanguageCode(
                                                              Share.settings.appSettings.localeCode) ??
                                                          EnglishDurationLocale()))))),
                                      CupertinoListTile(
                                          title: Text('Total presence', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(
                                                      '${(100 * (Share.session.data.student.attendances?.count((x) => x.type == AttendanceType.present) ?? 0) / (Share.session.data.student.attendances?.count() ?? 1)).toStringAsFixed(1)}%')))),
                                    ],
                                  ),
                                  CupertinoListSection.insetGrouped(
                                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                      additionalDividerMargin: 5,
                                      header: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text('ATTENDANCE',
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
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
                                                    (element, index) => CupertinoListTile(
                                                        title: Text(element.lesson, overflow: TextOverflow.ellipsis),
                                                        trailing: Container(
                                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                                            child: Opacity(
                                                                opacity: element.value >= 0.6 ? 0.5 : 1.0,
                                                                child: Text('${(100 * element.value).toStringAsFixed(2)}%',
                                                                    style: TextStyle(
                                                                        color: switch (element.value) {
                                                                      < 0.5 => CupertinoColors.systemRed,
                                                                      < 0.6 => CupertinoColors.activeOrange,
                                                                      _ => null // Default
                                                                    }))))),
                                                  )
                                                  .toList() ??
                                              [])
                                          .appendIfEmpty(
                                        CupertinoListTile(
                                            title: Text('', overflow: TextOverflow.ellipsis),
                                            trailing: Container(
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child:
                                                        Text('No attendances to displasy', textAlign: TextAlign.center)))),
                                      )),
                                  CupertinoListSection.insetGrouped(
                                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                      additionalDividerMargin: 5,
                                      header: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text('AVERAGE',
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                      children: (Share.session.data.student.subjects
                                              .select(
                                                  (element, index) => (lesson: element.name, value: element.gradesAverage))
                                              .orderBy((element) => element.lesson)
                                              .select(
                                                (element, index) => CupertinoListTile(
                                                    title: Text(element.lesson, overflow: TextOverflow.ellipsis),
                                                    trailing: Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 5),
                                                        child: Opacity(
                                                            opacity: element.value >= 0 ? 1.0 : 0.0,
                                                            child: Text(
                                                                element.value >= 0 ? element.value.toStringAsFixed(2) : '-',
                                                                style: TextStyle(
                                                                    color: switch (Share.session.settings
                                                                            .customGradeMarginValuesMap.entries
                                                                            .firstWhereOrDefault((x) =>
                                                                                (x.value < element.value) &&
                                                                                (x.value.floor() == element.value.floor()))
                                                                            ?.key ??
                                                                        (element.value - 0.25).round()) {
                                                                  6 => CupertinoColors.systemTeal,
                                                                  5 => CupertinoColors.systemGreen,
                                                                  4 => Color(0xFF76FF03),
                                                                  3 => CupertinoColors.systemOrange,
                                                                  2 => CupertinoColors.systemRed,
                                                                  1 => CupertinoColors.destructiveRed,
                                                                  _ => CupertinoColors.inactiveGray
                                                                }))))),
                                              )
                                              .toList())
                                          .appendIfEmpty(
                                        CupertinoListTile(
                                            title: Text('', overflow: TextOverflow.ellipsis),
                                            trailing: Container(
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                child: Opacity(
                                                    opacity: 0.5,
                                                    child:
                                                        Text('No attendances to displasy', textAlign: TextAlign.center)))),
                                      ))
                                ]))),
                    trailing: CupertinoListTileChevron())
              ],
            ),
            // Settings - appearance settings
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
              additionalDividerMargin: 5,
              children: [
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'App Style', children: [
                                  OptionsForm(
                                      selection: Share.settings.appSettings.useCupertino,
                                      description:
                                          'Note, there is no ETA for the Material interface style. Likely, the Cupertino one has to be finished first, as there is only one developer.',
                                      options: [
                                        OptionEntry(name: 'Cupertino', value: true),
                                        OptionEntry(name: 'Material', value: false),
                                      ],
                                      update: <T>(v) {})
                                ]))),
                    title: Text('App Style', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Opacity(opacity: 0.5, child: Text('Cupertino'))),
                      CupertinoListTileChevron()
                    ])),
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'Accent Color', children: [
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
                    title: Text('Accent Color', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Opacity(opacity: 0.5, child: Text(Share.session.settings.cupertinoAccentColor.name))),
                      CupertinoListTileChevron()
                    ])),
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'Language', children: [
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
                    title: Text('Language', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Opacity(opacity: 0.5, child: Text(Share.translator.localeName))),
                      CupertinoListTileChevron()
                    ])),
              ],
            ),
            // Settings - app settings
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
              additionalDividerMargin: 5,
              children: [
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => StatefulBuilder(
                                builder: ((context, setState) => CupertinoModalPage(title: 'Sync settings', children: [
                                      CupertinoListSection.insetGrouped(
                                          additionalDividerMargin: 5,
                                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
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
                                      CupertinoListSection.insetGrouped(
                                          additionalDividerMargin: 5,
                                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                          footer: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 20),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(
                                                      'Synchronization will only happen when you have a working internet connection and Oshi is closed.',
                                                      style: TextStyle(fontSize: 13)))),
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
                    title: Text('Sync Settings', overflow: TextOverflow.ellipsis),
                    trailing: CupertinoListTileChevron()),
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => StatefulBuilder(
                                builder: ((context, setState) => CupertinoModalPage(title: 'Notifications', children: [
                                      CupertinoListSection.insetGrouped(
                                          additionalDividerMargin: 5,
                                          margin: EdgeInsets.only(left: 15, right: 15),
                                          header: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 20),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text('NOTIFICATION FILTERS',
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                          children: [
                                            CupertinoListTile(
                                              title: Text('Request notification access'),
                                              trailing: CupertinoListTileChevron(),
                                            )
                                          ]),
                                      CupertinoListSection.insetGrouped(
                                          additionalDividerMargin: 5,
                                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                                          children: [
                                            CupertinoFormRow(
                                                prefix: Flexible(
                                                    flex: 2,
                                                    child:
                                                        Text('App updates', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                child: CupertinoSwitch(
                                                    value: true,
                                                    onChanged: (s) => NotificationController.sendNotification(
                                                        title: 'Pathetic.',
                                                        content: 'You thought you could escape?',
                                                        category: NotificationCategories.other)))
                                          ]),
                                      CupertinoListSection.insetGrouped(
                                          additionalDividerMargin: 5,
                                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                          footer: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 20),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(
                                                      'Notifications will be sent for the selected categories once the new data is downloaded and there are any changes.',
                                                      style: TextStyle(fontSize: 13)))),
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
                                                    onChanged: (s) => setState(
                                                        () => Share.session.settings.enableGradesNotifications = s))),
                                            CupertinoFormRow(
                                                prefix: Flexible(
                                                    flex: 2,
                                                    child: Text('Events', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                                child: CupertinoSwitch(
                                                    value: Share.session.settings.enableEventsNotifications,
                                                    onChanged: (s) => setState(
                                                        () => Share.session.settings.enableEventsNotifications = s))),
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
                    title: Text('Notifications', overflow: TextOverflow.ellipsis),
                    trailing: CupertinoListTileChevron())
              ],
            ),
            // Settings - timetable settings
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
              additionalDividerMargin: 5,
              children: [
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'Timetable Settings', children: [
                                  CupertinoListSection.insetGrouped(
                                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                                      additionalDividerMargin: 5,
                                      header: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text('BELL SYNCHRONIZATION',
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                      footer: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(
                                                  'Used to calibrate bell times in the app to offsets used by particular schools, format i.e. \'10s\', \'1min, 5s\' Don\'t forget to confirm your input!',
                                                  style: TextStyle(fontSize: 13)))),
                                      children: [
                                        CupertinoListTile(
                                            title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                                child: Text('School bell offset',
                                                    maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                                  CupertinoListSection.insetGrouped(
                                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                                      additionalDividerMargin: 5,
                                      header: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text('LESSON CALL TIME',
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                      footer: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Text(
                                                  'In minutes, will be used for "calling" last X minutes of a lesson. Falls back 15 minutes by default.',
                                                  style: TextStyle(fontSize: 13)))),
                                      children: [
                                        CupertinoListTile(
                                            title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                                child:
                                                    Text('Lesson call time', maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                    title: Text('Timetable Settings', overflow: TextOverflow.ellipsis),
                    trailing: CupertinoListTileChevron()),
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => StatefulBuilder(
                                builder: ((context, setState) => CupertinoModalPage(
                                    title: 'Custom Events',
                                    trailing: PullDownButton(
                                      itemBuilder: (context) => [
                                        PullDownMenuItem(
                                          title: 'New event',
                                          icon: CupertinoIcons.add,
                                          onTap: () => showCupertinoModalBottomSheet(
                                              context: context,
                                              builder: (context) => EventComposePage()).then((value) => setState(() {})),
                                        )
                                      ],
                                      buttonBuilder: (context, showMenu) => GestureDetector(
                                        onTap: showMenu,
                                        child: const Icon(CupertinoIcons.ellipsis_circle),
                                      ),
                                    ),
                                    children: Share.session.customEvents
                                        .where((x) =>
                                            (x.date ?? x.timeFrom).isAfter(DateTime.now().add(Duration(days: -1)).asDate()))
                                        .orderBy((x) => x.date ?? x.timeFrom)
                                        .groupBy((x) => DateFormat.yMMMMEEEEd(Share.settings.appSettings.localeCode)
                                            .format(x.date ?? x.timeFrom))
                                        .select((element, index) => CupertinoListSection.insetGrouped(
                                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                                        .appendIfEmpty(CupertinoListSection.insetGrouped(
                                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
                    title: Text('Custom Events', overflow: TextOverflow.ellipsis),
                    trailing: CupertinoListTileChevron()),
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => StatefulBuilder(
                                builder: ((context, setState) => CupertinoModalPage(title: 'Grades Settings', children: [
                                      CupertinoListSection.insetGrouped(
                                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                                          additionalDividerMargin: 5,
                                          header: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 20),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text('AVERGAE CALCULATION',
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                          footer: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 20),
                                              child: Opacity(
                                                  opacity: 0.5,
                                                  child: Text(
                                                      'Average calculation will ignore weights if all of them are 0 for auto-adapt enabled.',
                                                      style: TextStyle(fontSize: 13)))),
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
                                                        setState(() => Share.session.settings.autoArithmeticAverage = s)))
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
                                          })
                                    ]))))),
                    title: Text('Grades Settings', overflow: TextOverflow.ellipsis),
                    trailing: CupertinoListTileChevron()),
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'Custom Grade Values', children: [
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
                    title: Text('Custom Grade Values', overflow: TextOverflow.ellipsis),
                    trailing: CupertinoListTileChevron())
              ],
            ),
            // Settings - credits
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
              additionalDividerMargin: 5,
              children: [
                CupertinoListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CupertinoModalPage(title: 'App Info', children: [
                                  CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                                    additionalDividerMargin: 5,
                                    header: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Text('VERSION INFO',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
                                    children: [
                                      CupertinoListTile(
                                          title: Text('Version', overflow: TextOverflow.ellipsis),
                                          trailing: GestureDetector(
                                              onDoubleTap: () => Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                      builder: (context) => StatefulBuilder(
                                                          builder: ((context, setState) => CupertinoModalPage(
                                                                  title: 'Developers',
                                                                  previousPageTitle: 'App Info',
                                                                  children: [
                                                                    // Developer mode
                                                                    CupertinoListSection.insetGrouped(
                                                                        margin:
                                                                            EdgeInsets.only(left: 15, right: 15, bottom: 10),
                                                                        additionalDividerMargin: 5,
                                                                        header: Container(
                                                                            margin: EdgeInsets.symmetric(horizontal: 20),
                                                                            child: Opacity(
                                                                                opacity: 0.5,
                                                                                child: Text('FOR DEVELOPERS',
                                                                                    style: TextStyle(
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.normal)))),
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
                                                                    CupertinoListSection.insetGrouped(
                                                                        margin:
                                                                            EdgeInsets.only(left: 15, right: 15, bottom: 10),
                                                                        additionalDividerMargin: 5,
                                                                        header: Container(
                                                                            margin: EdgeInsets.symmetric(horizontal: 20),
                                                                            child: Opacity(
                                                                                opacity: 0.5,
                                                                                child: Text('APPLICATION DIALOG TESTS',
                                                                                    style: TextStyle(
                                                                                        fontSize: 13,
                                                                                        fontWeight: FontWeight.normal)))),
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
                                                                                              builder:
                                                                                                  (BuildContext context) =>
                                                                                                      CupertinoAlertDialog(
                                                                                                        title: Text(
                                                                                                            _noTitleController
                                                                                                                .text),
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
                                                                                          Share.showErrorModal.broadcast(
                                                                                              Value((
                                                                                            title: _noTitleController.text,
                                                                                            message:
                                                                                                _noContentController.text,
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
                                                                                    crossAxisAlignment:
                                                                                        CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      CupertinoButton(
                                                                                          onPressed: () {
                                                                                            try {
                                                                                              NotificationController.sendNotification(
                                                                                                  title: _noTitleController
                                                                                                      .text,
                                                                                                  content:
                                                                                                      _noContentController
                                                                                                          .text,
                                                                                                  category:
                                                                                                      NotificationCategories
                                                                                                          .register,
                                                                                                  data: jsonEncode(TimelineNotification(
                                                                                                          sessionGuid: Share
                                                                                                                  .settings
                                                                                                                  .sessions
                                                                                                                  .lastSessionId ??
                                                                                                              '')
                                                                                                      .toJson()));
                                                                                            } catch (ex) {
                                                                                              // ignored
                                                                                            }
                                                                                          },
                                                                                          padding: EdgeInsets.zero,
                                                                                          child: Text(
                                                                                              'Register notification',
                                                                                              maxLines: 1,
                                                                                              overflow:
                                                                                                  TextOverflow.ellipsis)),
                                                                                      CupertinoButton(
                                                                                          onPressed: () {
                                                                                            try {
                                                                                              NotificationController.sendNotification(
                                                                                                  title: _noTitleController
                                                                                                      .text,
                                                                                                  content:
                                                                                                      _noContentController
                                                                                                          .text,
                                                                                                  category:
                                                                                                      NotificationCategories
                                                                                                          .messages,
                                                                                                  data: jsonEncode(TimelineNotification(
                                                                                                          sessionGuid: Share
                                                                                                                  .settings
                                                                                                                  .sessions
                                                                                                                  .lastSessionId ??
                                                                                                              '',
                                                                                                          type:
                                                                                                              TimelineNotificationType
                                                                                                                  .message)
                                                                                                      .toJson()));
                                                                                            } catch (ex) {
                                                                                              // ignored
                                                                                            }
                                                                                          },
                                                                                          padding: EdgeInsets.zero,
                                                                                          child: Text(
                                                                                              'Messages notification',
                                                                                              maxLines: 1,
                                                                                              overflow:
                                                                                                  TextOverflow.ellipsis)),
                                                                                      CupertinoButton(
                                                                                          onPressed: () {
                                                                                            try {
                                                                                              NotificationController
                                                                                                  .sendNotification(
                                                                                                      title:
                                                                                                          _noTitleController
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
                                                                                              overflow:
                                                                                                  TextOverflow.ellipsis))
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
                                                                  ]))))),
                                              child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                                  child: Opacity(opacity: 0.5, child: Text(Share.buildNumber))))),
                                      CupertinoListTile(
                                          title: Text('Build', overflow: TextOverflow.ellipsis),
                                          trailing: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              child: Opacity(opacity: 0.5, child: Text(Share.buildNumber.split('.').last))))
                                    ],
                                  ),
                                  CupertinoListSection.insetGrouped(
                                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
                                    additionalDividerMargin: 5,
                                    header: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        child: Opacity(
                                            opacity: 0.5,
                                            child: Text('CONTRIBUTORS',
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))),
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
                    title: Text('App Info', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Opacity(opacity: 0.5, child: Text(Share.buildNumber))),
                      CupertinoListTileChevron()
                    ])),
                CupertinoListTile(
                    onTap: () {
                      try {
                        launchUrlString('https://github.com/Ogaku');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    title: Text('Socials', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('GitHub'))),
                      CupertinoListTileChevron()
                    ])),
                CupertinoListTile(
                    onTap: () {
                      try {
                        launchUrlString('https://ko-fi.com/ogaku_oshi');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    title: Text('Support Us', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('Ko-fi'))),
                      CupertinoListTileChevron()
                    ])),
                CupertinoListTile(
                    onTap: () {
                      try {
                        launchUrlString('https://youtu.be/dQw4w9WgXcQ');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    title: Text('Contact Us', overflow: TextOverflow.ellipsis),
                    trailing: Row(children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('Discord'))),
                      CupertinoListTileChevron()
                    ]))
              ],
            ),
          ]);
}
