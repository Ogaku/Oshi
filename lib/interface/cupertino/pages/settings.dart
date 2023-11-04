// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oshi/interface/cupertino/widgets/entries_form.dart';
import 'package:oshi/interface/cupertino/widgets/modal_page.dart';
import 'package:oshi/interface/cupertino/widgets/options_form.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return SearchableSliverNavigationBar(
        setState: setState,
        largeTitle: Text('Settings'),
        previousPageTitle: 'Home',
        disableAddons: true,
        anchor: 0.0,
        children: [
          // Name and school, avatar picker
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                  padding: EdgeInsets.only(right: 15),
                  title: Row(children: [
                    Container(
                        margin: EdgeInsets.all(15),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage('https://i.redd.it/5irxtxlxrtw41.png'),
                        )),
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
                  trailing: CupertinoListTileChevron())
            ],
          ),
          // Settings - appearance settings
          CupertinoListSection.insetGrouped(
            additionalDividerMargin: 5,
            children: [
              CupertinoListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CupertinoModalPage(title: 'App Style', children: [
                                OptionsForm(
                                    selection: Share.settings.config.useCupertino,
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
                        margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('Cupertino'))),
                    CupertinoListTileChevron()
                  ])),
              CupertinoListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CupertinoModalPage(title: 'Accent Color', children: [
                                OptionsForm(
                                    selection: Resources.cupertinoAccentColors.entries
                                            .firstWhereOrDefault(
                                                (value) => value.value == Share.settings.config.cupertinoAccentColor)
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
                                      Share.settings.config.cupertinoAccentColor = Resources.cupertinoAccentColors[v] ??
                                          Resources.cupertinoAccentColors.values.first; // Set
                                      Share.refreshBase.broadcast(); // Refresh
                                    })
                              ]))),
                  title: Text('Accent Color', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Opacity(
                            opacity: 0.5,
                            child: Text(Resources.cupertinoAccentColors[Share.settings.config.cupertinoAccentColor]?.name ??
                                'System Red'))),
                    CupertinoListTileChevron()
                  ])),
              CupertinoListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CupertinoModalPage(title: 'Language', children: [
                                OptionsForm(
                                    selection: Share.settings.config.languageCode,
                                    description:
                                        'The selected language will only be reflected in the app interface. Grade, event, lesson descriptions and generated messages will not be affected.',
                                    options: Resources.languages.entries
                                        .select((x, index) => OptionEntry(name: x.value, value: x.key))
                                        .toList(),
                                    update: <T>(v) {
                                      Share.settings.config.languageCode = v; // Set
                                      Share.refreshBase.broadcast(); // Refresh
                                    })
                              ]))),
                  title: Text('Language', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Opacity(
                            opacity: 0.5,
                            child: Text(Resources.languages[Share.settings.config.languageCode] ?? 'English'))),
                    CupertinoListTileChevron()
                  ])),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Commute', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('TODO'))),
                    CupertinoListTileChevron()
                  ])),
            ],
          ),
          // Settings - app settings
          CupertinoListSection.insetGrouped(
            additionalDividerMargin: 5,
            children: [
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Sync Settings', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('TODO'))),
                    CupertinoListTileChevron()
                  ])),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Notifications', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5), child: Opacity(opacity: 0.5, child: Text('TODO'))),
                    CupertinoListTileChevron()
                  ]))
            ],
          ),
          // Settings - timetable settings
          CupertinoListSection.insetGrouped(
            additionalDividerMargin: 5,
            children: [
              CupertinoListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CupertinoModalPage(title: 'Timetable Settings', children: [
                                CupertinoListSection.insetGrouped(
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
                                                    Share.settings.config.bellOffset =
                                                        result ?? Share.settings.config.bellOffset;
                                                    setState(() => _bellTimeController.text = result != null
                                                        ? prettyDuration(result,
                                                            tersity: DurationTersity.second,
                                                            upperTersity: DurationTersity.minute,
                                                            abbreviated: true,
                                                            conjunction: ', ',
                                                            spacer: '')
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
                                              child: Text('Lesson call time', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ConstrainedBox(
                                              constraints: BoxConstraints(maxWidth: 70),
                                              child: CupertinoTextField.borderless(
                                                  onChanged: (value) {
                                                    var result = int.tryParse(value);
                                                    if (result != null && (result > 45 || result <= 0)) result = null;
                                                    Share.settings.config.lessonCallTime =
                                                        result ?? Share.settings.config.lessonCallTime;
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
                                    selection: Share.settings.config.lessonCallType,
                                    description:
                                        'Note, this is used only for auto-generating preset messages, which may not always be accurate.',
                                    options: LessonCallTypes.values
                                        .select((x, index) => OptionEntry(name: x.name, value: x))
                                        .toList(),
                                    update: <T>(v) {
                                      Share.settings.config.lessonCallType = v; // Set
                                      Share.refreshBase.broadcast(); // Refresh
                                    })
                              ]))),
                  title: Text('Timetable Settings', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Custom Events', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
              CupertinoListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CupertinoModalPage(title: 'Grades Settings', children: [
                                CupertinoListSection.insetGrouped(
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
                                              value: Share.settings.config.weightedAverage,
                                              onChanged: (s) => Share.settings.config.weightedAverage = s)),
                                      CupertinoFormRow(
                                          prefix: Flexible(
                                              flex: 2,
                                              child: Text('Auto-adapt to grades',
                                                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          child: CupertinoSwitch(
                                              value: Share.settings.config.autoArithmeticAverage,
                                              onChanged: (s) => Share.settings.config.autoArithmeticAverage = s)),
                                    ]),
                                OptionsForm(
                                    pop: false,
                                    header: 'YEARLY AVERAGE',
                                    selection: Share.settings.config.yearlyAverageMethod,
                                    description:
                                        'Note, the average displayed by the app is calculated locally, and may not be respected by every school.',
                                    options: YearlyAverageMethods.values
                                        .select((x, index) => OptionEntry(name: x.name, value: x))
                                        .toList(),
                                    update: <T>(v) {
                                      Share.settings.config.yearlyAverageMethod = v; // Set
                                      Share.refreshBase.broadcast(); // Refresh
                                    })
                              ]))),
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
                                    update: <T>([v]) => (Share.settings.config.customGradeModifierValues =
                                            v?.cast() ?? Share.settings.config.customGradeModifierValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v)),
                                // Custom grade values
                                EntriesForm<double>(
                                    header: 'CUSTOM GRADE MARGINS',
                                    description:
                                        'These values will overwite the default grade margins, e.g. make values such as \'4.75\' count as \'5\', etc.',
                                    placeholder: 'Value',
                                    update: <T>([v]) => (Share.settings.config.customGradeMarginValues =
                                            v?.cast() ?? Share.settings.config.customGradeMarginValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v)),
                                // Custom grade values
                                EntriesForm<double>(
                                    header: 'CUSTOM GRADES',
                                    description:
                                        'These values will overwite all default grade values for the specified entries, e.g. from \'nb\' to \'1\', etc.',
                                    placeholder: 'Value',
                                    update: <T>([v]) => (Share.settings.config.customGradeValues =
                                            v?.cast() ?? Share.settings.config.customGradeValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v))
                              ]))),
                  title: Text('Custom Grade Values', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron())
            ],
          ),
          // Settings - credits
          CupertinoListSection.insetGrouped(
            additionalDividerMargin: 5,
            children: [
              CupertinoListTile(
                  onTap: () {},
                  title: Text('App Info', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Opacity(opacity: 0.5, child: Text(Share.buildNumber))),
                    CupertinoListTileChevron()
                  ])),
              CupertinoListTile(
                  onTap: () async {
                    try {
                      await launchUrlString('https://github.com/Ogaku');
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
                  onTap: () async {
                    try {
                      await launchUrlString('https://youtu.be/dQw4w9WgXcQ');
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
}
