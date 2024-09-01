// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:darq/darq.dart';
import 'package:duration/locale.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:event/event.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:format/format.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/components/shim/elements/event.dart';
import 'package:oshi/interface/components/shim/elements/grade.dart';
import 'package:oshi/interface/components/shim/modal_page.dart';
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/platform.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/new_event.dart';
import 'package:oshi/interface/shared/views/new_grade.dart';
import 'package:oshi/interface/components/cupertino/widgets/entries_form.dart';
import 'package:oshi/interface/components/cupertino/widgets/options_form.dart';
import 'package:oshi/models/data/announcement.dart';
import 'package:oshi/models/data/attendances.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/notifications.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:duration/duration.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final TextEditingController _callTimeController = TextEditingController();

  final TextEditingController _toTitleController = TextEditingController();
  final TextEditingController _noTitleController = TextEditingController();
  final TextEditingController _noContentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _callTimeController.text =
        Share.session.settings.lessonCallTime == 15 ? '' : Share.session.settings.lessonCallTime.toString();
  }

  @override
  Widget build(BuildContext context) => DataPageBase.adaptive(
          pageFlags: [
            DataPageType.noTitleSpace,
            DataPageType.keepBackgroundWatchers,
          ].flag,
          setState: setState,
          title: 'B5AAA3A1-795B-4A81-9DED-4633B9FBD874'.localized,
          previousPageTitle: '/Titles/Pages/Home'.localized,
          children: [
            // Name and school, avatar picker
            CardContainer(
                margin: Share.settings.appSettings.useCupertino
                    ? EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8)
                    : EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                filled: false,
                children: <Widget>[
                  // Cupertino - profile badge card
                  if (Share.settings.appSettings.useCupertino)
                    AdaptiveCard(
                        regular: true,
                        click: profilePageHandler,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          decoration: Share.settings.appSettings.useCupertino
                              ? null
                              : BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).colorScheme.surfaceContainer),
                          child: Row(children: [
                            Container(
                                margin: EdgeInsets.only(top: 15, bottom: 15, right: 12),
                                child: GestureDetector(
                                    onTap: (isAndroid || isIOS)
                                        ? () => ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                                              if (value == null) return;
                                              File(value.path).readAsBytes().then((result) => Share.session.settings
                                                  .setUserAvatar(result)
                                                  .then((value) => setState(() {})));
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
                        )),
                ].appendAllIf(<Widget>[
                  // Material - profile header with actions
                  // Header: avatar
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 10),
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
                                    radius: 27.5,
                                    foregroundImage: snapshot.data?.image,
                                    backgroundColor: Colors.transparent,
                                  )
                                : Icon(CupertinoIcons.person_circle_fill, size: 55))),
                  ),
                  // Header: name and school
                  Text(Share.session.data.student.account.name,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20), overflow: TextOverflow.ellipsis),
                  Opacity(
                      opacity: 0.5,
                      child: Text(Share.session.data.student.mainClass.unit.name,
                          style: TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis)),
                  // Actions
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).brightness == Brightness.light
                          ? Theme.of(context).colorScheme.surfaceContainerLowest
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TextButton(
                                onPressed: () => Share.changeBase.broadcast(Value(() => sessionsPage)),
                                style: ButtonStyle(
                                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))))),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.switch_account_outlined),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('/Sessions'.localized, textAlign: TextAlign.center),
                                  ),
                                ])),
                          ),
                          Container(width: 2, height: 90, color: Theme.of(context).colorScheme.surface),
                          Expanded(
                            child: TextButton(
                                onPressed: profilePageHandler,
                                style: ButtonStyle(
                                    shape:
                                        WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.only()))),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.person_outline),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('DC18CA52-2CF3-47E8-8FBA-5CEF06A841BF'.localized, textAlign: TextAlign.center),
                                  ),
                                ])),
                          ),
                          Container(width: 2, height: 90, color: Theme.of(context).colorScheme.surface),
                          Expanded(
                            child: TextButton(
                                onPressed: () => Share.session.unreadChanges.markAsRead(),
                                style: ButtonStyle(
                                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20), bottomRight: Radius.circular(20))))),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.check),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child:
                                        Text('CF4A7B81-8294-4616-BF7B-03621E2CB41F'.localized, textAlign: TextAlign.center),
                                  ),
                                ])),
                          ),
                        ],
                      ),
                    ),
                  ),
                ], !Share.settings.appSettings.useCupertino).toList()),
            // Settings - appearance settings
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : '6E7A921E-98C1-4C9D-87DD-154E15B06776'.localized,
              children: [
                AdaptiveCard(
                  regular: true,
                  click: () => Share.settings.appSettings.useCupertino
                      ? Navigator.push(
                          context,
                          AdaptivePageRoute(
                              builder: (context) =>
                                  ModalPageBase.adaptive(title: 'DD5CE0F4-775A-451A-B626-22E53029AF33'.localized, children: [
                                    OptionsForm(
                                        selection: Share.settings.appSettings.useCupertino,
                                        options: [
                                          OptionEntry(name: '5C484437-BB3B-4CAF-9E14-669C2A63ACF0'.localized, value: true),
                                          OptionEntry(name: 'A6E7DA42-3D93-4F31-A49A-63A33E9A376B'.localized, value: false),
                                        ],
                                        update: <T>(v) {
                                          if (Share.settings.appSettings.useCupertino == v) return;
                                          Share.settings.appSettings.useCupertino = v; // Set
                                          Share.changeBase.broadcast(); // Refresh
                                          Navigator.of(context).pop();
                                        })
                                  ])))
                      : showOptionDialog(
                          context: context,
                          title: 'DD5CE0F4-775A-451A-B626-22E53029AF33'.localized,
                          icon: Icons.style,
                          selection: Share.settings.appSettings.useCupertino,
                          options: [
                            OptionEntry(name: '5C484437-BB3B-4CAF-9E14-669C2A63ACF0'.localized, value: true),
                            OptionEntry(name: 'A6E7DA42-3D93-4F31-A49A-63A33E9A376B'.localized, value: false),
                          ],
                          onChanged: (v) {
                            if (Share.settings.appSettings.useCupertino == v) return;
                            Share.settings.appSettings.useCupertino = v; // Set
                            Share.changeBase.broadcast(); // Refresh
                            Navigator.of(context).pop();
                          }),
                  child: "DD5CE0F4-775A-451A-B626-22E53029AF33".localized,
                  after: Share.settings.appSettings.useCupertino
                      ? '5C484437-BB3B-4CAF-9E14-669C2A63ACF0'.localized
                      : '8F02FD98-C601-4CE5-A7F2-5BD05324B0AA'.localized,
                  trailingElement:
                      Share.settings.appSettings.useCupertino ? null : 'A6E7DA42-3D93-4F31-A49A-63A33E9A376B'.localized,
                ),
                if (Share.settings.appSettings.useCupertino)
                  AdaptiveCard(
                      regular: true,
                      click: () => Navigator.push(
                          context,
                          AdaptivePageRoute(
                              builder: (context) =>
                                  ModalPageBase.adaptive(title: 'F70892E6-2833-4E21-A111-91BADC1A3744'.localized, children: [
                                    OptionsForm(
                                        selection: Resources.cupertinoAccentColors.entries
                                                .firstWhereOrDefault((value) =>
                                                    value.value.color == Share.session.settings.cupertinoAccentColor.color)
                                                ?.key ??
                                            0,
                                        description: 'A7E5A03F-B158-4213-9371-CD84BE2AC1BF'.localized,
                                        options: Resources.cupertinoAccentColors.entries
                                            .select((x, index) => OptionEntry(
                                                name: x.value.name,
                                                value: x.key,
                                                decoration: Container(
                                                    margin: EdgeInsets.only(bottom: 2, right: 7),
                                                    child: Container(
                                                      height: 10,
                                                      width: 10,
                                                      decoration:
                                                          BoxDecoration(shape: BoxShape.circle, color: x.value.color),
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
                  click: () => Share.settings.appSettings.useCupertino
                      ? Navigator.push(
                          context,
                          AdaptivePageRoute(
                              builder: (context) =>
                                  ModalPageBase.adaptive(title: 'F2B4F8E4-9603-4FE9-B4D3-E9A14CEF7D89'.localized, children: [
                                    OptionsForm(
                                        selection: Share.settings.appSettings.languageCode,
                                        description: '55AD72A7-31F9-45F6-A1F1-8174F53FBCCB'.localized,
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
                                  ])))
                      : showOptionDialog(
                          context: context,
                          title: 'F2B4F8E4-9603-4FE9-B4D3-E9A14CEF7D89'.localized,
                          icon: Icons.language,
                          selection: Share.settings.appSettings.languageCode,
                          options: Share.translator.supportedLanguages
                              .select((x, index) => OptionEntry(name: x.name, value: x.code))
                              .toList(),
                          onChanged: (v) {
                            Share.settings.appSettings.languageCode = v; // Set
                            Share.translator.loadResources(Share.settings.appSettings.languageCode).then((value) {
                              Share.currentIdleSplash = Share.translator.getRandomSplash();
                              Share.currentEndingSplash = Share.translator.getRandomEndingSplash();
                              Share.refreshBase.broadcast(); // Refresh everything
                            }); // Refresh
                          }),
                  child: "F2B4F8E4-9603-4FE9-B4D3-E9A14CEF7D89".localized,
                  after: Share.settings.appSettings.useCupertino
                      ? Share.translator.localeName
                      : '76A9B9B2-1589-4669-AF3B-B051E1D1E27F'.localized,
                  trailingElement: Share.settings.appSettings.useCupertino ? null : Share.translator.localeName,
                ),
              ],
            ),
            // Settings - app settings
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : 'FC6B3F0C-DB3D-45BB-8406-33657D48D411'.localized,
              children: [
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) =>
                                  ModalPageBase.adaptive(title: 'CD1ECC4D-066E-496C-AA71-8517579A58C4'.localized, children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        children: [
                                          AdaptiveFormRow(
                                              title: '0E6DB495-34F0-44C6-A012-5EF6A7CD16F1'.localized,
                                              helper: '8A9B267A-DDF2-401B-BD0C-FBEB58328EE3'.localized,
                                              value: Share.session.settings.enableBackgroundSync,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.enableBackgroundSync = s)),
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        footer: '58A14048-EF66-4249-A62D-5DA8AAD5DDA7'.localized.format(
                                            Share.settings.appSettings.useCupertino
                                                ? ''
                                                : '83A587C7-AEA1-440D-81B8-04D9607F5016'.localized),
                                        children: [
                                          AdaptiveFormRow(
                                              title: 'DB5D169A-DCAD-4090-9450-31A47E99D7C0'.localized,
                                              helper: 'D3E2F079-C3E4-4E83-8D4A-55CE7C601C2C'.localized,
                                              value: Share.session.settings.backgroundSyncWiFiOnly,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.backgroundSyncWiFiOnly = s)),
                                          AdaptiveFormRow(
                                              title: 'BC9CAB49-765A-47AC-A2D5-A756C610C4BF'.localized,
                                              helper: '629FB62F-9A01-4FAE-8D20-58F2C9241CC2'.localized,
                                              placeholder: 'A202A6E9-C043-4450-9AB9-661EB3699F39'.localized,
                                              onChanged: <T>(value) {
                                                var result = tryParseDuration(value);
                                                if (result != null &&
                                                    (result < Duration(minutes: 15) || result > Duration(minutes: 180))) {
                                                  result = null;
                                                }
                                                Share.session.settings.backgroundSyncInterval = result?.inMinutes ?? 15;
                                                return result != null
                                                    ? prettyDuration(result,
                                                        tersity: DurationTersity.second,
                                                        upperTersity: DurationTersity.minute,
                                                        abbreviated: true,
                                                        conjunction: ', ',
                                                        spacer: '',
                                                        locale: DurationLocale.fromLanguageCode(
                                                                Share.settings.appSettings.localeCode) ??
                                                            EnglishDurationLocale())
                                                    : '';
                                              },
                                              value: Share.session.settings.backgroundSyncInterval == 15
                                                  ? ''
                                                  : prettyDuration(
                                                      Duration(minutes: Share.session.settings.backgroundSyncInterval),
                                                      tersity: DurationTersity.second,
                                                      upperTersity: DurationTersity.minute,
                                                      abbreviated: false,
                                                      conjunction: ', ',
                                                      spacer: ' ',
                                                      locale: DurationLocale.fromLanguageCode(
                                                              Share.settings.appSettings.localeCode) ??
                                                          EnglishDurationLocale())),
                                        ])
                                  ]))))),
                  child: 'CD1ECC4D-066E-496C-AA71-8517579A58C4'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : '0E6DB495-34F0-44C6-A012-5EF6A7CD16F1'.localized,
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) =>
                                  ModalPageBase.adaptive(title: 'CC433F26-6A3D-4F62-A931-80A40878AF24'.localized, children: [
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
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                clipBehavior: Clip.antiAlias,
                                                child: Image.network(
                                                    'https://github.com/szkolny-eu/szkolny-android/blob/develop/.github/readme-banner.png?raw=true'),
                                              )),
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        footer: '4F886B16-A88F-48D3-BEE1-B4148622C60C'.localized,
                                        children: [
                                          AdaptiveFormRow(
                                              title: '6632D1A9-F474-45CA-9150-1ACCB4EF39B1'.localized,
                                              helper: '1F1AA2B9-CA28-4728-8D1D-02FA2A4F7E82'.localized,
                                              value: Share.session.settings.allowSzkolnyIntegration,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.allowSzkolnyIntegration = s)),
                                          AdaptiveFormRow(
                                              title: 'F0314F48-F4E7-40CF-AF92-4E538C0516D8'.localized,
                                              helper: '32251E7A-D82A-4C14-B0F1-5835411763BA'.localized,
                                              value: Share.session.settings.allowSzkolnyIntegration &&
                                                  Share.session.settings.shareEventsByDefault,
                                              onChanged: Share.session.settings.allowSzkolnyIntegration
                                                  ? <T>(s) => setState(() => Share.session.settings.shareEventsByDefault = s)
                                                  : <T>(_) {}),
                                        ])
                                  ]))))),
                  child: 'CC433F26-6A3D-4F62-A931-80A40878AF24'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : '66D53114-ACDB-4963-A3AF-323A928FF077'.localized,
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) =>
                                  ModalPageBase.adaptive(title: 'F55B93B2-D401-43DC-B735-5BE1FAC9077F'.localized, children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        largeHeader: false,
                                        header: '29751189-B0EB-4160-B972-12C9A133921E'.localized,
                                        children: [
                                          AdaptiveCard(
                                            regular: true,
                                            child: '725BD5A2-7767-45C6-8B96-B572886EDA30'.localized,
                                            after: Share.settings.appSettings.useCupertino
                                                ? null
                                                : '9DC64E89-233B-43BD-8860-4E6A8F964657'.localized,
                                            click: () => NotificationController.requestNotificationAccess(),
                                          )
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        children: [
                                          AdaptiveFormRow(
                                              title: '8028B071-6B39-40E2-AE3C-925D555E4696'.localized,
                                              helper: '808B9438-3098-4218-A0F7-EA4424345D2F'.localized,
                                              value: true,
                                              onChanged: <T>(s) => NotificationController.sendNotification(
                                                  title: 'BAFBD98F-2A00-4F6E-8477-1835B9719705'.localized,
                                                  content: '5D3C9F9D-00DD-4B39-AF4B-629EC7D203A7'.localized,
                                                  category: NotificationCategories.other)),
                                        ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        footer: 'F184D4D6-0C94-4E94-A703-8E0D371C8D91'.localized,
                                        children: [
                                          AdaptiveFormRow(
                                              title: '49F92EF0-7E05-416B-89A7-930342F3F1CB'.localized,
                                              helper: '0DC2D946-9E89-4F0D-B468-BA98470C14FE'.localized,
                                              value: Share.session.settings.enableTimetableNotifications,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.enableTimetableNotifications = s)),
                                          AdaptiveFormRow(
                                              title: '/Titles/Pages/Grades'.localized,
                                              helper: 'E0A11D48-A95B-4713-A5D8-8754980C5ABC'.localized,
                                              value: Share.session.settings.enableGradesNotifications,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.enableGradesNotifications = s)),
                                          AdaptiveFormRow(
                                              title: '8D247486-323F-42C0-B34C-B4846C4B4B67'.localized,
                                              helper: 'F4829933-F3CF-44DE-B872-0A7E6E355697'.localized,
                                              value: Share.session.settings.enableEventsNotifications,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.enableEventsNotifications = s)),
                                          AdaptiveFormRow(
                                              title: '/Page/Absences/Attendance'.localized,
                                              helper: 'FED5F29B-1CE3-44B2-84E3-ED4E952B039B'.localized,
                                              value: Share.session.settings.enableAttendanceNotifications,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.enableAttendanceNotifications = s)),
                                          AdaptiveFormRow(
                                              title: '/Titles/Pages/Messages/Announcements'.localized,
                                              helper: '3437225F-3F91-4DB4-B23D-44A59155378F'.localized,
                                              value: Share.session.settings.enableAnnouncementsNotifications,
                                              onChanged: <T>(s) => setState(
                                                  () => Share.session.settings.enableAnnouncementsNotifications = s)),
                                          AdaptiveFormRow(
                                              title: '/Titles/Pages/Messages'.localized,
                                              helper: '1B4B8A55-5D68-419A-AF11-2B9B9DED6ED3'.localized,
                                              value: Share.session.settings.enableMessagesNotifications,
                                              onChanged: <T>(s) =>
                                                  setState(() => Share.session.settings.enableMessagesNotifications = s)),
                                        ])
                                  ]))))),
                  child: 'F55B93B2-D401-43DC-B735-5BE1FAC9077F'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : 'CDE7ED74-6C59-42E2-A3D6-BD06161D3E10'.localized,
                )
              ],
            ),
            // Settings - timetable settings
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : '87E61CE0-78E7-4121-A00C-ECE9C18E5DFB'.localized,
              children: [
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) =>
                              ModalPageBase.adaptive(title: 'D480F8E1-21BA-41AA-80C1-903375A2115D'.localized, children: [
                                CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: 'B3B19D34-8903-4983-A791-8B396D7DD34A'.localized,
                                    footer: '65A82A7E-82EE-439D-AC65-3A9F9A506041'.localized,
                                    children: [
                                      AdaptiveFormRow(
                                          title: '466F84DC-AE7A-499E-BE43-F96D13DF9585'.localized,
                                          helper: '71A4B268-BA50-4832-BC25-A35F586718AC'.localized,
                                          placeholder: 'DAFBEF7F-1E93-4BE4-877F-E234EA2F1A0E'.localized,
                                          onChanged: <T>(value) {
                                            var result = tryParseDuration(value);
                                            if (result != null &&
                                                (result > Duration(minutes: 15) || result < Duration(minutes: -15))) {
                                              result = null;
                                            }
                                            Share.session.settings.bellOffset = result ?? Duration.zero;
                                            return result != null
                                                ? prettyDuration(result,
                                                    tersity: DurationTersity.second,
                                                    upperTersity: DurationTersity.minute,
                                                    abbreviated: false,
                                                    conjunction: ', ',
                                                    spacer: ' ',
                                                    locale: DurationLocale.fromLanguageCode(
                                                            Share.settings.appSettings.localeCode) ??
                                                        EnglishDurationLocale())
                                                : '';
                                          },
                                          value: Share.session.settings.bellOffset == Duration.zero
                                              ? ''
                                              : prettyDuration(Share.session.settings.bellOffset,
                                                  tersity: DurationTersity.second,
                                                  upperTersity: DurationTersity.minute,
                                                  abbreviated: false,
                                                  conjunction: ', ',
                                                  spacer: ' ',
                                                  locale: DurationLocale.fromLanguageCode(
                                                          Share.settings.appSettings.localeCode) ??
                                                      EnglishDurationLocale())),
                                    ]),
                                CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: '12EBC2D2-19B3-41FD-9F3A-10D7D3EDF460'.localized,
                                    footer: 'EE454EE2-FC1D-4AF2-AEAB-5B3405F4DF92'.localized,
                                    children: [
                                      AdaptiveFormRow(
                                          title: '7B97D3CB-F6A8-4DC1-AD27-319F22D5002F'.localized,
                                          helper: '80F75930-2F66-4E88-91C2-E48DC5143458'.localized,
                                          placeholder: 'A202A6E9-C043-4450-9AB9-661EB3699F39'.localized,
                                          onChanged: <T>(value) {
                                            var result = tryParseDuration(value);
                                            if (result != null &&
                                                (result > Duration(minutes: 30) || result < Duration(minutes: 1))) {
                                              result = null;
                                            }
                                            Share.session.settings.lessonCallTime = result?.inMinutes ?? 15;
                                            return result != null
                                                ? prettyDuration(result,
                                                    tersity: DurationTersity.second,
                                                    upperTersity: DurationTersity.minute,
                                                    abbreviated: false,
                                                    conjunction: ', ',
                                                    spacer: '',
                                                    locale: DurationLocale.fromLanguageCode(
                                                            Share.settings.appSettings.localeCode) ??
                                                        EnglishDurationLocale())
                                                : '';
                                          },
                                          value: Share.session.settings.lessonCallTime == 15
                                              ? ''
                                              : prettyDuration(Duration(minutes: Share.session.settings.lessonCallTime),
                                                  tersity: DurationTersity.second,
                                                  upperTersity: DurationTersity.minute,
                                                  abbreviated: false,
                                                  conjunction: ', ',
                                                  spacer: ' ',
                                                  locale: DurationLocale.fromLanguageCode(
                                                          Share.settings.appSettings.localeCode) ??
                                                      EnglishDurationLocale())),
                                    ]),
                                if (Share.settings.appSettings.useCupertino)
                                  OptionsForm(
                                      pop: false,
                                      header: 'DF9019BC-3BE4-4208-976B-51FDB364F292'.localized,
                                      selection: Share.session.settings.lessonCallType,
                                      description: 'E8B922A6-7122-4328-866F-6729E660A702'.localized,
                                      options: LessonCallTypes.values
                                          .select((x, index) => OptionEntry(name: x.name, value: x))
                                          .toList(),
                                      update: <T>(v) {
                                        Share.session.settings.lessonCallType = v; // Set
                                        Share.refreshBase.broadcast(); // Refresh
                                      }),
                                if (!Share.settings.appSettings.useCupertino)
                                  CardContainer(
                                      filled: false,
                                      footer: 'E8B922A6-7122-4328-866F-6729E660A702'.localized,
                                      children: [
                                        AdaptiveCard(
                                          regular: true,
                                          child: '72AD997F-5207-4D48-AF5F-E900BEC01147'.localized,
                                          after: '860D1B1D-980C-4BE6-AFD1-6483C6AC31E5'
                                              .localized
                                              .format(Share.session.settings.lessonCallType.name.toLowerCase()),
                                          click: () => showOptionDialog(
                                              context: context,
                                              title: 'E69F660E-D46C-42BE-A8CF-EB20BF5EA040'.localized,
                                              icon: Icons.timer,
                                              selection: Share.session.settings.lessonCallType,
                                              options: LessonCallTypes.values
                                                  .select((x, index) => OptionEntry(name: x.name, value: x))
                                                  .toList(),
                                              onChanged: <T>(v) {
                                                Share.session.settings.lessonCallType = v; // Set
                                                Share.refreshBase.broadcast(); // Refresh
                                              }),
                                        ),
                                      ])
                              ]))),
                  child: 'D480F8E1-21BA-41AA-80C1-903375A2115D'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : '466F84DC-AE7A-499E-BE43-F96D13DF9585'.localized,
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) => ModalPageBase.adaptive(
                                  title: '6BEABF95-FABD-42E6-920C-2057480D3A0A'.localized,
                                  trailing: SafeArea(
                                      child: GestureDetector(
                                    onTap: () => showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => EventComposePage()).then((value) => setState(() {})),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Share.settings.appSettings.useCupertino ? CupertinoIcons.add : Icons.add,
                                        size: 25,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  )),
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
                                          regularOverride: true,
                                          header: element.key,
                                          additionalDividerMargin: 5,
                                          children: element.isEmpty
                                              // No messages to display
                                              ? [
                                                  AdaptiveCard(
                                                      secondary: true,
                                                      centered: true,
                                                      child: 'C31AC6D0-D0F1-4902-8CC7-6C911C6508BD'.localized),
                                                ]
                                              // Bindable messages layout
                                              : element.toList().asEventWidgets(
                                                  null, '', 'ACCA97A8-5C58-4D65-A827-6BBE076DDC71'.localized, setState)))
                                      .appendIfEmpty(CardContainer(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                          filled: false,
                                          additionalDividerMargin: 5,
                                          children: [
                                            AdaptiveCard(
                                                secondary: true,
                                                centered: true,
                                                child: 'C31AC6D0-D0F1-4902-8CC7-6C911C6508BD'.localized),
                                          ]))
                                      .toList()))))),
                  child: '6BEABF95-FABD-42E6-920C-2057480D3A0A'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : '8318318D-060F-4D2D-94FB-9BD3C665BDA0'.localized,
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) => StatefulBuilder(
                              builder: ((context, setState) =>
                                  ModalPageBase.adaptive(title: '5CFB8DE5-B4C1-4965-93F9-5EA55F07C098'.localized, children: [
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        largeHeader: false,
                                        header: 'AC4EDF84-EE04-4B57-B077-DACA7A954384'.localized,
                                        footer: '2AF1719A-8656-4F98-9321-D74F82F7AEBC'.localized,
                                        children: [
                                          AdaptiveFormRow(
                                              title: 'D30DEFBB-3209-41C2-AED6-A5923D461FBB'.localized,
                                              helper: Share.settings.appSettings.useCupertino
                                                  ? ''
                                                  : '363EA29A-52AD-4B1E-B326-907F535F2FC8'.localized,
                                              value: Share.session.settings.weightedAverage,
                                              onChanged: (s) => setState(() => Share.session.settings.weightedAverage = s)),
                                          AdaptiveFormRow(
                                              title: 'CCCCCA9E-242A-4059-8DC6-FED14110E23D'.localized,
                                              helper: Share.settings.appSettings.useCupertino
                                                  ? ''
                                                  : '5F3EBC40-EC4E-4101-AF66-28ECAAB544F8'.localized,
                                              value: Share.session.settings.autoArithmeticAverage,
                                              onChanged: (s) =>
                                                  setState(() => Share.session.settings.autoArithmeticAverage = s)),
                                        ]),
                                    if (Share.settings.appSettings.useCupertino)
                                      OptionsForm(
                                          pop: false,
                                          header: '2688AB1D-5E3D-4C76-B8C7-A6637CFA0F77'.localized,
                                          selection: Share.session.settings.yearlyAverageMethod,
                                          description: 'DA45DD0A-2781-40A2-A1C6-976F9DF60C8F'.localized,
                                          options: YearlyAverageMethods.values
                                              .select((x, index) => OptionEntry(name: x.name, value: x))
                                              .toList(),
                                          update: <T>(v) {
                                            Share.session.settings.yearlyAverageMethod = v; // Set
                                            Share.refreshBase.broadcast(); // Refresh
                                          }),
                                    if (!Share.settings.appSettings.useCupertino)
                                      CardContainer(
                                          filled: false,
                                          footer: 'DA45DD0A-2781-40A2-A1C6-976F9DF60C8F'.localized,
                                          children: [
                                            AdaptiveCard(
                                              regular: true,
                                              child: '04B2FDC7-C76E-430E-8F1C-5CB52852BCB0'.localized,
                                              after: '7416F5BF-2B31-4C55-BEEF-EB7A2329402D'
                                                  .localized
                                                  .format(Share.session.settings.yearlyAverageMethod.name.toLowerCase()),
                                              click: () => showOptionDialog(
                                                  context: context,
                                                  title: 'E69F660E-D46C-42BE-A8CF-EB20BF5EA040'.localized,
                                                  icon: Icons.timer,
                                                  selection: Share.session.settings.yearlyAverageMethod,
                                                  options: YearlyAverageMethods.values
                                                      .select((x, index) => OptionEntry(name: x.name, value: x))
                                                      .toList(),
                                                  onChanged: <T>(v) {
                                                    Share.session.settings.yearlyAverageMethod = v; // Set
                                                    Share.refreshBase.broadcast(); // Refresh
                                                  }),
                                            ),
                                          ]),
                                    CardContainer(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                        filled: false,
                                        additionalDividerMargin: 5,
                                        largeHeader: false,
                                        header: '5DE48056-3DDE-4939-BE9E-41E6A869C2C5'.localized,
                                        footer: '8D5843E5-EF41-4694-AB25-8D2A4DF8BC10'.localized,
                                        children: [
                                          AdaptiveCard(
                                            regular: true,
                                            click: () => Navigator.push(
                                                context,
                                                AdaptivePageRoute(
                                                    builder: (context) => StatefulBuilder(
                                                        builder: ((context, setState) => ModalPageBase.adaptive(
                                                            title: '181C196F-A8C7-4446-92A8-911CA17014ED'.localized,
                                                            previousPageTitle:
                                                                '5F65ABD5-E3A1-4A88-9012-178CE9ECD523'.localized,
                                                            trailing: SafeArea(
                                                                child: GestureDetector(
                                                              onTap: () => showCupertinoModalBottomSheet(
                                                                      context: context,
                                                                      builder: (context) => GradeComposePage())
                                                                  .then((value) => setState(() {})),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Icon(
                                                                  Share.settings.appSettings.useCupertino
                                                                      ? CupertinoIcons.add
                                                                      : Icons.add,
                                                                  size: 25,
                                                                  color: Theme.of(context).colorScheme.onSurface,
                                                                ),
                                                              ),
                                                            )),
                                                            children: Share.session.customGrades.entries
                                                                .selectMany((x, _) =>
                                                                    x.value.select((y, _) => (lesson: x.key, grade: y)))
                                                                .orderBy((x) => x.grade.date)
                                                                .groupBy((x) => x.lesson)
                                                                .select((element, index) => CardContainer(
                                                                    margin:
                                                                        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                    filled: false,
                                                                    regularOverride: true,
                                                                    header: element.key.nameExtra,
                                                                    additionalDividerMargin: 5,
                                                                    children: element.isEmpty
                                                                        // No messages to display
                                                                        ? [
                                                                            AdaptiveCard(
                                                                                secondary: true,
                                                                                centered: true,
                                                                                child: '38C6F1AA-F9E6-440A-B635-E6981415AD77'
                                                                                    .localized),
                                                                          ]
                                                                        // Bindable messages layout
                                                                        : element
                                                                            .toList()
                                                                            .select((x, _) => Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                    horizontal: 10),
                                                                                child: x.grade.asGrade(context, setState)))
                                                                            .toList()))
                                                                .appendIfEmpty(CardContainer(
                                                                    margin:
                                                                        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                    filled: false,
                                                                    additionalDividerMargin: 5,
                                                                    children: [
                                                                      AdaptiveCard(
                                                                          secondary: true,
                                                                          centered: true,
                                                                          child: '38C6F1AA-F9E6-440A-B635-E6981415AD77'
                                                                              .localized),
                                                                    ]))
                                                                .toList()))))),
                                            child: '181C196F-A8C7-4446-92A8-911CA17014ED'.localized,
                                            after: Share.settings.appSettings.useCupertino
                                                ? ''
                                                : '0197B2E2-A763-4E59-AA64-90C4ED1E051D'.localized,
                                          ),
                                        ]),
                                  ]))))),
                  child: '5CFB8DE5-B4C1-4965-93F9-5EA55F07C098'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : 'BE7A9E48-8112-4556-85CD-530593066E26'.localized,
                ),
                AdaptiveCard(
                  regular: true,
                  click: () => Navigator.push(
                      context,
                      AdaptivePageRoute(
                          builder: (context) =>
                              ModalPageBase.adaptive(title: 'F4DA9649-D96E-41CC-8528-040A2917A486'.localized, children: [
                                // Custom grade values
                                EntriesForm<double>(
                                    header: 'EB604C3E-B9CF-475F-8F72-27D936CCC1AD'.localized,
                                    description: '1DD14872-D65A-442B-B048-E171FAE0BF42'.localized,
                                    placeholder: '828F8EBE-4681-4FC9-9FFE-239540470A97'.localized,
                                    maxKeyLength: 1,
                                    update: <T>([v]) => (Share.session.settings.customGradeModifierValues =
                                            v?.cast() ?? Share.session.settings.customGradeModifierValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v)),
                                // Custom grade values
                                EntriesForm<double>(
                                    header: '52681520-1CD1-4547-8BB7-D006AAFF1295'.localized,
                                    description: '67F7DBDE-6ED3-421F-AD14-85058AA1665D'.localized,
                                    placeholder: 'Value',
                                    update: <T>([v]) => (Share.session.settings.customGradeMarginValues =
                                            v?.cast() ?? Share.session.settings.customGradeMarginValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v)),
                                // Custom grade values
                                EntriesForm<double>(
                                    header: '274B918D-51CF-4C3E-8425-EB0D9FD828FD'.localized,
                                    description: 'BBF5AE6C-FA29-40FB-B68A-050934D9998F'.localized,
                                    placeholder: '828F8EBE-4681-4FC9-9FFE-239540470A97'.localized,
                                    update: <T>([v]) => (Share.session.settings.customGradeValues =
                                            v?.cast() ?? Share.session.settings.customGradeValues)
                                        .cast(),
                                    validate: (v) => double.tryParse(v))
                              ]))),
                  child: 'F4DA9649-D96E-41CC-8528-040A2917A486'.localized,
                  after: Share.settings.appSettings.useCupertino ? '' : '838E767C-3D71-4E76-BB86-ADE91B154BF3'.localized,
                )
              ],
            ),
            // Settings - credits
            CardContainer(
              margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
              filled: false,
              additionalDividerMargin: 5,
              header: Share.settings.appSettings.useCupertino ? '' : 'B2C872FA-F50E-4EB5-A646-B5F743603522'.localized,
              children: [
                AdaptiveCard(
                    regular: true,
                    click: () => Navigator.push(
                        context,
                        AdaptivePageRoute(
                            builder: (context) =>
                                ModalPageBase.adaptive(title: '4C9277BD-392C-4ECB-8307-8AF4E09F539A'.localized, children: [
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: '4F794C4E-204D-4F7F-A7ED-6DC83C95AF3B'.localized,
                                    children: [
                                      AdaptiveCard(
                                          regular: true,
                                          child: '02B0EE84-7869-413F-B3DA-8EF6D1ED8E7A'.localized,
                                          after: Share.buildNumber,
                                          hideChevron: true,
                                          click: () => Navigator.push(
                                              context,
                                              AdaptivePageRoute(
                                                  builder: (context) => StatefulBuilder(
                                                      builder: ((context, setState) => ModalPageBase.adaptive(
                                                          title: '6775F13D-3B63-4175-9432-3356200DD4EC'.localized,
                                                          previousPageTitle:
                                                              '4C9277BD-392C-4ECB-8307-8AF4E09F539A'.localized,
                                                          children: [
                                                            // Developer mode
                                                            CardContainer(
                                                                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                filled: false,
                                                                additionalDividerMargin: 5,
                                                                largeHeader: false,
                                                                header: 'EF8D269F-FD62-4E77-859D-7ECCCF9DF865'.localized,
                                                                children: [
                                                                  AdaptiveFormRow(
                                                                      value: Share.session.settings.devMode,
                                                                      onChanged: (s) {
                                                                        setState(() => Share.session.settings.devMode = s);
                                                                        Share.refreshBase.broadcast(); // Refresh everything
                                                                      },
                                                                      title:
                                                                          '41C975B3-8284-4825-A7CE-5BE463E30DDE'.localized,
                                                                      helper:
                                                                          'B482A089-8A28-4481-AC0F-525551459EEF'.localized)
                                                                ]),
                                                            CardContainer(
                                                                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                filled: false,
                                                                additionalDividerMargin: 5,
                                                                largeHeader: false,
                                                                header: '2A51A33A-F6E7-4EFF-9F96-E27CDF749DD9'.localized,
                                                                children: [
                                                                  AdaptiveCard(
                                                                    child: '43AC10D9-619A-4B0D-A9A9-3745E2B65158'.localized,
                                                                    after: Share.settings.appSettings.useCupertino
                                                                        ? null
                                                                        : '51FCB9F8-ADBF-4562-AF92-13046E6495D0'.localized,
                                                                    click: () async {
                                                                      try {
                                                                        await Share.settingsMutex.protect<void>(() async {
                                                                          (await Hive.openBox('sessions')).clear();
                                                                          (await Hive.openBox('sessions'))
                                                                              .put('sessions', Share.settings.sessions);

                                                                          var path = (await Hive.openBox('sessions')).path;
                                                                          if (path != null) {
                                                                            var file = await File(path).readAsBytes();
                                                                            var result = await FilePicker.platform.saveFile(
                                                                                dialogTitle:
                                                                                    '2E20C624-26E9-4BF7-9106-6E1963BDDD8A'
                                                                                        .localized,
                                                                                fileName: 'sessions.hive',
                                                                                bytes: file);
                                                                            if (Platform.isWindows && result != null) {
                                                                              File(result).writeAsBytes(file);
                                                                            }
                                                                          }
                                                                        });
                                                                      } catch (ex) {
                                                                        // ignored
                                                                      }
                                                                    },
                                                                  ),
                                                                  AdaptiveCard(
                                                                    child: '1BBE5897-AB9C-4C1C-9182-2F31C11BC1E9'.localized,
                                                                    after: Share.settings.appSettings.useCupertino
                                                                        ? null
                                                                        : '1B48C70F-C2B5-402A-87C7-9E57767CDFF9'.localized,
                                                                    click: () async {
                                                                      try {
                                                                        await Share.settingsMutex.protect<void>(() async {
                                                                          var save = await FilePicker.platform.pickFiles(
                                                                              allowMultiple: false, type: FileType.any);

                                                                          if (!(save?.files.first.path?.endsWith('.hive') ??
                                                                              false)) return;

                                                                          (await Hive.openBox('sessions')).clear();
                                                                          (await Hive.openBox('sessions'))
                                                                              .put('sessions', Share.settings.sessions);

                                                                          var path = (await Hive.openBox('sessions')).path;
                                                                          if (save?.files.first.path != null &&
                                                                              path != null) {
                                                                            try {
                                                                              await Hive.close();
                                                                            } catch (ex) {
                                                                              // ignored
                                                                            }

                                                                            File(path).delete();
                                                                            File(save!.files.first.path!).copy(path);

                                                                            await Hive.initFlutter();
                                                                            await Share.settings.load();
                                                                            await Share.settings.save();
                                                                          }
                                                                        });
                                                                      } catch (ex) {
                                                                        // ignored
                                                                      }
                                                                    },
                                                                  ),
                                                                ]),
                                                            CardContainer(
                                                                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                filled: false,
                                                                additionalDividerMargin: 5,
                                                                largeHeader: false,
                                                                header: '44A2572B-0263-4AE7-AFF9-28D2B4070489'.localized,
                                                                children: [
                                                                  // Toasts
                                                                  AdaptiveCard(
                                                                      forceTrailing: true,
                                                                      after: Column(children: [
                                                                        AdaptiveTextField(
                                                                            controller: _noTitleController,
                                                                            placeholder:
                                                                                'ED8D10FC-50FE-48C5-AD57-8E7418669AC3'
                                                                                    .localized),
                                                                      ]),
                                                                      child: Flexible(
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
                                                                              child: Text(
                                                                                  '02C816FF-C7C1-4A50-8935-879751E84132'
                                                                                      .localized,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis)))),
                                                                  // Modal dialog
                                                                  AdaptiveCard(
                                                                      forceTrailing: true,
                                                                      after: Column(children: [
                                                                        AdaptiveTextField(
                                                                            controller: _noTitleController,
                                                                            placeholder:
                                                                                'ED8D10FC-50FE-48C5-AD57-8E7418669AC3'
                                                                                    .localized),
                                                                      ]),
                                                                      child: Flexible(
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
                                                                                                _noContentController.text),
                                                                                          ));
                                                                                } catch (ex) {
                                                                                  // ignored
                                                                                }
                                                                              },
                                                                              padding: EdgeInsets.zero,
                                                                              child: Text(
                                                                                  '3B71B8E7-6C95-43EE-9435-DAD5647C6130'
                                                                                      .localized,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis)))),
                                                                  // Alert dialog
                                                                  AdaptiveCard(
                                                                      forceTrailing: true,
                                                                      after: Column(children: [
                                                                        AdaptiveTextField(
                                                                            controller: _noTitleController,
                                                                            placeholder:
                                                                                'ED8D10FC-50FE-48C5-AD57-8E7418669AC3'
                                                                                    .localized),
                                                                        Container(
                                                                            margin: EdgeInsets.only(top: 6),
                                                                            child: AdaptiveTextField(
                                                                                controller: _noContentController,
                                                                                placeholder:
                                                                                    '09F07DF5-2C66-4F2B-85F5-DE1736C50A4E'
                                                                                        .localized)),
                                                                      ]),
                                                                      child: Flexible(
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
                                                                              child: Text(
                                                                                  'E6DDB694-ACDA-4912-BCE6-D04B3BF11210'
                                                                                      .localized,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis)))),
                                                                  // Notifications
                                                                  AdaptiveCard(
                                                                      forceTrailing: true,
                                                                      after: Column(children: [
                                                                        AdaptiveTextField(
                                                                            controller: _noTitleController,
                                                                            placeholder:
                                                                                'ED8D10FC-50FE-48C5-AD57-8E7418669AC3'
                                                                                    .localized),
                                                                        Container(
                                                                            margin: EdgeInsets.only(top: 6),
                                                                            child: AdaptiveTextField(
                                                                                controller: _noContentController,
                                                                                placeholder:
                                                                                    '09F07DF5-2C66-4F2B-85F5-DE1736C50A4E'
                                                                                        .localized)),
                                                                      ]),
                                                                      child: Flexible(
                                                                          flex: 2,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              CupertinoButton(
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      NotificationController
                                                                                          .sendNotification(
                                                                                              title: _noTitleController.text,
                                                                                              content:
                                                                                                  _noContentController.text,
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
                                                                                  child: Text(
                                                                                      'B57477AA-D271-437D-A814-601DF8B6F4DB'
                                                                                          .localized,
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis)),
                                                                              CupertinoButton(
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      NotificationController.sendNotification(
                                                                                          title: _noTitleController.text,
                                                                                          content: _noContentController.text,
                                                                                          category: NotificationCategories
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
                                                                                  child: Text(
                                                                                      'CC9FD9AF-9C21-4ABB-BC5F-E2D1BB3B62F5'
                                                                                          .localized,
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis)),
                                                                              CupertinoButton(
                                                                                  onPressed: () {
                                                                                    try {
                                                                                      NotificationController
                                                                                          .sendNotification(
                                                                                              title: _noTitleController.text,
                                                                                              content:
                                                                                                  _noContentController.text,
                                                                                              category:
                                                                                                  NotificationCategories
                                                                                                      .other);
                                                                                    } catch (ex) {
                                                                                      // ignored
                                                                                    }
                                                                                  },
                                                                                  padding: EdgeInsets.zero,
                                                                                  child: Text(
                                                                                      '59810958-F149-4D47-BD9F-802D75592E97'
                                                                                          .localized,
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis))
                                                                            ],
                                                                          ))),
                                                                ]),
                                                            // Codes - user
                                                            CardContainer(
                                                                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                filled: false,
                                                                additionalDividerMargin: 5,
                                                                largeHeader: false,
                                                                header: '7C52C45D-277C-4F67-9040-E4BCE6248CC3'.localized,
                                                                children: [
                                                                  AdaptiveCard(
                                                                      regular: true,
                                                                      child:
                                                                          '22AD0D77-411C-4BCB-80F5-45009292A8E7'.localized,
                                                                      after: Share.session.data.student.userCode)
                                                                ]),
                                                          ].appendAllIf([
                                                            // Codes - classes
                                                            CardContainer(
                                                                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                                                filled: false,
                                                                additionalDividerMargin: 5,
                                                                largeHeader: false,
                                                                header: '07ACB1FF-E847-4327-8E26-F26942695A38'.localized,
                                                                children: Share.session.data.student.teamCodes.entries
                                                                    .select((x, _) => AdaptiveCard(
                                                                        regular: true, child: x.value, after: x.key))
                                                                    .toList()),
                                                          ], Share.session.data.student.teamCodes.isNotEmpty))))))),
                                      AdaptiveCard(
                                          regular: true,
                                          child: '785EA92C-03D6-47D6-BFA9-A7100998A92B'.localized,
                                          after: Share.buildNumber.split('.').last)
                                    ],
                                  ),
                                  CardContainer(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                                    filled: false,
                                    additionalDividerMargin: 5,
                                    largeHeader: false,
                                    header: '84D8D5E0-43AA-4463-BAE8-FF5453F79FB2'.localized,
                                    children: [
                                      AdaptiveCard(
                                        regular: true,
                                        click: () {
                                          try {
                                            launchUrlString('https://github.com/KimihikoAkayasaki');
                                          } catch (ex) {
                                            // ignored
                                          }
                                        },
                                        child: '公彦赤屋先',
                                        after: '8C4BC4D5-81A3-432A-9B94-48D20DB8F559'.localized,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        click: () {
                                          try {
                                            launchUrlString('https://github.com/xFaiafokkusu');
                                          } catch (ex) {
                                            // ignored
                                          }
                                        },
                                        child: 'Faiafokkusu',
                                        after: '0BF14FC8-EABB-4790-A0A1-CFF39977A8CC'.localized,
                                      ),
                                      AdaptiveCard(
                                        regular: true,
                                        click: () {
                                          try {
                                            launchUrlString('https://github.com/AAhockey');
                                          } catch (ex) {
                                            // ignored
                                          }
                                        },
                                        child: 'AAhockey',
                                        after: '213B6431-B649-4837-A089-3E2A037A4625'.localized,
                                      )
                                    ],
                                  )
                                ]))),
                    child: '4C9277BD-392C-4ECB-8307-8AF4E09F539A'.localized,
                    after: Share.buildNumber),
                AdaptiveCard(
                    regular: true,
                    click: () => (Share.settings.appSettings.useCupertino
                            ? showCupertinoModalBottomSheet
                            : showMaterialModalBottomSheet)(
                        shape: Share.settings.appSettings.useCupertino
                            ? null
                            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        clipBehavior: Clip.antiAlias,
                        context: context,
                        expand: false,
                        builder: (context) => Container(
                              height: 510,
                              color: Colors.white,
                              child: LoopPageView.builder(
                                controller: LoopPageController(initialPage: (isAndroid ? 0 : (isIOS ? 1 : 2))),
                                itemCount: 3,
                                itemBuilder: (context, index) => switch (index) {
                                  0 => Table(children: [
                                      TableRow(children: [Image.asset('assets/resources/images/qr-code-android.png')]),
                                      TableRow(children: [
                                        Center(child: AdaptiveButton(title: 'Android', click: () {}, elevated: true))
                                      ])
                                    ]),
                                  1 => Table(children: [
                                      TableRow(children: [Image.asset('assets/resources/images/qr-code-ios.png')]),
                                      TableRow(children: [
                                        Center(child: AdaptiveButton(title: 'iOS', click: () {}, elevated: true))
                                      ])
                                    ]),
                                  _ => Table(children: [
                                      TableRow(children: [Image.asset('assets/resources/images/qr-code-web.png')]),
                                      TableRow(children: [
                                        Center(child: AdaptiveButton(title: 'Web', click: () {}, elevated: true))
                                      ])
                                    ]),
                                },
                              ),
                            )),
                    child: '/Share'.localized,
                    after: '4FAD3DFA-A095-448D-BA21-56726E117111'.localized),
                AdaptiveCard(
                    regular: true,
                    click: () {
                      try {
                        launchUrlString('https://github.com/Ogaku');
                      } catch (ex) {
                        // ignored
                      }
                    },
                    child: 'B3D579E5-2A27-4B61-A42A-C2DFD6150022'.localized,
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
                    child: '5352613A-B420-4441-A89D-612693727FF6'.localized,
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
                    child: '3D02B970-3502-495C-B6B8-3D5D33A92EA6'.localized,
                    after: 'Discord'),
              ],
            ),
          ]);

  FutureOr<void> profilePageHandler() => Navigator.push(
      context,
      AdaptivePageRoute(
          builder: (context) => ModalPageBase.adaptive(title: '461D2804-7071-400A-8D98-06F58B50A826'.localized, children: [
                CardContainer(
                  margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                  filled: false,
                  additionalDividerMargin: 5,
                  largeHeader: false,
                  header: '12F11FD8-0450-4D48-B8F0-6BB1AB98F2F7'.localized,
                  children: [
                    AdaptiveCard(
                        regular: true,
                        child: '8C49630C-B41B-4D50-87C8-6A3EA3FD6A3D'.localized,
                        after: Share.session.data.student.account.name),
                    AdaptiveCard(
                      regular: true,
                      child: 'B96EA577-6DBF-491C-9781-9C85CCBD4119'.localized,
                      after: Share.session.data.student.mainClass.className,
                    ),
                    AdaptiveCard(
                      regular: true,
                      child: 'AB3F62E5-579B-4E78-9810-5CC31A8AFF25'.localized,
                      after: Share.session.data.student.mainClass.classTutor.name,
                    ),
                  ],
                ),
                CardContainer(
                  margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                  filled: false,
                  additionalDividerMargin: 5,
                  largeHeader: false,
                  header: '38919EDB-6025-46CC-B6F0-7689137F27BE'.localized,
                  children: [
                    AdaptiveCard(
                      regular: true,
                      child: '288A7361-FF68-4743-88B2-6715F4D56457'.localized,
                      after: Share.session.data.student.mainClass.unit.name,
                    ),
                    AdaptiveCard(
                      regular: true,
                      child: '16288334-3CEC-4208-849D-A62BF00D75BC'.localized,
                      after: Share.session.data.student.mainClass.unit.principalName,
                    ),
                    AdaptiveCard(
                      regular: true,
                      child: 'A15AC36A-0A6A-4E6A-8E14-7185B9CAA157'.localized,
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
                      child: '2CE8A48D-BCF7-43E9-86FC-4BFA997D1024'.localized,
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
                      child: 'E5A3FE43-E428-4BE8-9E08-48E2149AC5A7'.localized,
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
                  margin: EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                  filled: false,
                  additionalDividerMargin: 5,
                  largeHeader: false,
                  header: 'EC9E3129-A646-46AF-8EBD-73C601AF15AE'.localized,
                  footer: 'F8BACC1A-63F2-4311-AA23-5C6996E826FA'.localized,
                  children: [
                    AdaptiveCard(
                        regular: true,
                        child: '/Average'.localized,
                        after: () {
                          var majors = Share.session.data.student.subjects
                              .where((x) => x.hasMajor)
                              .select((x, _) => x.topMajor!.asValue);
                          return majors.isNotEmpty
                              ? majors.average().toStringAsFixed(2)
                              : 'E91C42DF-7471-47E1-BAB8-7E3C63713154'.localized;
                        }()),
                    AdaptiveCard(
                        regular: true,
                        child: '6F98C4DC-F77D-46A0-9C6F-A95F0FBF9E43'.localized,
                        after: prettyDuration(
                            tersity: DurationTersity.minute,
                            upperTersity: DurationTersity.day,
                            conjunction: ', ',
                            Duration(
                                minutes: Share.session.data.student.attendances
                                        ?.where((x) => x.lesson.subject?.name.toLowerCase() != 'religia')
                                        .sum((x) => 45) ??
                                    0),
                            locale: DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ??
                                EnglishDurationLocale())),
                    AdaptiveCard(
                        regular: true,
                        child: 'CEE6A317-76C4-46E6-8BA3-60A92FFC07AB'.localized,
                        after: prettyDuration(
                            tersity: DurationTersity.minute,
                            upperTersity: DurationTersity.day,
                            conjunction: ', ',
                            Duration(
                                minutes: Share.session.data.student.attendances
                                        ?.where((x) => x.lesson.subject?.name.toLowerCase() == 'religia')
                                        .sum((x) => 45) ??
                                    0),
                            locale: DurationLocale.fromLanguageCode(Share.settings.appSettings.localeCode) ??
                                EnglishDurationLocale())),
                    AdaptiveCard(
                        regular: true,
                        child: '94319EB2-735E-4FDF-B65A-372DC31A4298'.localized,
                        after:
                            '${(100 * (Share.session.data.student.attendances?.count((x) => x.type == AttendanceType.present) ?? 0) / (Share.session.data.student.attendances?.count() ?? 1)).toStringAsFixed(1)}%'),
                  ],
                ),
                CardContainer(
                    margin:
                        EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                    filled: false,
                    additionalDividerMargin: 5,
                    largeHeader: false,
                    header: 'FA7F8284-A75E-46F2-B507-C0ECCB96FB38'.localized,
                    children: (Share.session.data.student.attendances
                                ?.groupBy((element) =>
                                    element.lesson.subject?.name ?? '94149CBB-5B72-4186-A155-20A9C7FB1B2C'.localized)
                                .select((element, index) => (
                                      lesson: element.key,
                                      value: element.toList().count((x) => x.type == AttendanceType.present) / element.count
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
                                                  child: Text('${(100 * element.value).toStringAsFixed(2)}%',
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
                      AdaptiveCard(regular: true, child: '', after: 'A9A27655-5B34-41D8-AEA5-BEAC6E8F6212'.localized),
                    )),
                CardContainer(
                    margin:
                        EdgeInsets.symmetric(horizontal: Share.settings.appSettings.useCupertino ? 15 : 18, vertical: 15),
                    filled: false,
                    additionalDividerMargin: 5,
                    largeHeader: false,
                    header: 'E31E0161-B2C4-450B-9CA6-047493B87431'.localized,
                    children: (Share.session.data.student.subjects
                            .select((element, index) => (lesson: element.name, value: element.gradesAverage))
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
                                              child: Text(element.value >= 0 ? element.value.toStringAsFixed(2) : '-',
                                                  style: TextStyle(
                                                      color: switch (Share
                                                              .session.settings.customGradeMarginValuesMap.entries
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
                                                  }))))
                                      : element.value >= 0
                                          ? element.value.toStringAsFixed(2)
                                          : 'E91C42DF-7471-47E1-BAB8-7E3C63713154'.localized),
                            )
                            .toList())
                        .appendIfEmpty(
                      AdaptiveCard(regular: true, child: '', after: 'A9A27655-5B34-41D8-AEA5-BEAC6E8F6212'.localized),
                    ))
              ])));
}
