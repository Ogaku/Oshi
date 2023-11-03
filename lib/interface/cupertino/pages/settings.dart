// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/interface/cupertino/views/options_page.dart';
import 'package:oshi/interface/cupertino/widgets/searchable_bar.dart';
import 'package:oshi/share/config.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                          builder: (context) => OptionsPage(
                              selection: Config.useCupertino,
                              title: 'App Style',
                              description:
                                  'Note, there is no ETA for the Material interface style. Likely, the Cupertino one has to be finished first, as there is only one developer.',
                              options: [
                                OptionEntry(name: 'Cupertino', value: true),
                                OptionEntry(name: 'Material', value: false),
                              ],
                              update: (v) {}))),
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
                          builder: (context) => OptionsPage(
                              selection: Config.cupertinoAccentColor,
                              title: 'Accent Color',
                              description:
                                  'Note, this color may be overridden during certain events, such as Christmas, Easter, or Halloween.',
                              options: Resources.accentColors.entries
                                  .select((x, index) => OptionEntry(
                                      name: x.value,
                                      value: x.key,
                                      decoration: Container(
                                          margin: EdgeInsets.only(bottom: 2, right: 7),
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: x.key),
                                          ))))
                                  .toList(),
                              update: (v) {
                                if (v is! CupertinoDynamicColor) return;
                                Config.cupertinoAccentColor = v; // Set
                                Share.refreshBase.broadcast(); // Refresh
                              }))),
                  title: Text('Accent Color', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Opacity(
                            opacity: 0.5, child: Text(Resources.accentColors[Config.cupertinoAccentColor] ?? 'System Red'))),
                    CupertinoListTileChevron()
                  ])),
              CupertinoListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => OptionsPage(
                              selection: Config.languageCode,
                              title: 'Language',
                              description:
                                  'The selected language will only be reflected in the app interface. Grade, event, lesson descriptions and generated messages will not be affected.',
                              options: Resources.languages.entries
                                  .select((x, index) => OptionEntry(name: x.value, value: x.key))
                                  .toList(),
                              update: (v) {
                                if (v is! String) return;
                                Config.languageCode = v; // Set
                                Share.refreshBase.broadcast(); // Refresh
                              }))),
                  title: Text('Language', overflow: TextOverflow.ellipsis),
                  trailing: Row(children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Opacity(opacity: 0.5, child: Text(Resources.languages[Config.languageCode] ?? 'English'))),
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
                  onTap: () {},
                  title: Text('Timetable Settings', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Agenda Settings', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Custom Events', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
            ],
          ),
          // Settings - e-register settings
          CupertinoListSection.insetGrouped(
            additionalDividerMargin: 5,
            children: [
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Grades Settings', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Average Settings', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
              CupertinoListTile(
                  onTap: () {},
                  title: Text('Custom Grade Values', overflow: TextOverflow.ellipsis),
                  trailing: CupertinoListTileChevron()),
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
