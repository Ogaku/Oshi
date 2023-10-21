// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:oshi/interface/cupertino/base_app.dart';
import 'package:oshi/models/provider.dart';
import 'package:oshi/share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.instance, required this.providerGuid});

  final String providerGuid;
  final IProvider instance;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map<String, TextEditingController>? credentialControllers;
  bool isWorking = false; // Logging in right now?

  @override
  Widget build(BuildContext context) {
    // Generate a map of credential controllers for the login page
    credentialControllers ??= widget.instance.credentialsConfig.keys.toMap((x) => MapEntry(x, TextEditingController()));

    var credentialEntries = widget.instance.credentialsConfig.entries
        .select((x, index) => CupertinoFormRow(
            prefix: SizedBox(width: 90, child: Text(x.value.name)),
            child: CupertinoTextFormFieldRow(
              placeholder: 'Required',
              obscureText: x.value.obscure,
              controller: credentialControllers![x.key],
              onChanged: (s) => setState(() {}),
            )))
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.withBrightness(
          color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
      navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          automaticallyImplyLeading: true,
          border: null,
          backgroundColor: CupertinoDynamicColor.withBrightness(
              color: const Color.fromARGB(255, 242, 242, 247), darkColor: const Color.fromARGB(255, 28, 28, 30)),
          trailing: CupertinoButton(
              padding: EdgeInsets.all(10),
              child: isWorking
                  ? CupertinoActivityIndicator()
                  : Text('Next',
                      style: TextStyle(
                          color: (credentialControllers!.values.every((x) => x.text.isNotEmpty))
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.inactiveGray)),
              onPressed: () async {
                if (isWorking) return; // Already handling something, give up
                if (credentialControllers!.values.every((x) => x.text.isNotEmpty)) {
                  setState(() {
                    // Mark as working, the 1st refresh is gonna take a while
                    isWorking = true;
                  });
                  if (!await tryLogin(
                      guid: widget.providerGuid,
                      credentials: credentialControllers!.entries.toMap((x) => MapEntry(x.key, x.value.text)))) {
                    setState(() {
                      // Reset the animation in case the login method hasn't finished
                      isWorking = false;
                    });
                  }
                }
              })),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Visibility(
                visible: widget.instance.providerBannerUri != null,
                child: Container(
                    margin: EdgeInsets.only(top: 30, left: 100, right: 100),
                    child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: widget.instance.providerBannerUri?.toString() ??
                            'https://i.pinimg.com/736x/6b/db/93/6bdb93f8d708c51e0431406f7e06f299.jpg'))),
            Container(
                margin: EdgeInsets.only(top: 50),
                child: credentialEntries.isNotEmpty
                    ? CupertinoFormSection.insetGrouped(children: credentialEntries)
                    : Opacity(opacity: 0.5, child: Text('No additional data required'))),
            Opacity(
                opacity: 0.7,
                child: Container(
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: Text(widget.instance.providerDescription, style: TextStyle(fontSize: 14)))),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                  opacity: 0.5,
                  child: Container(
                      margin: EdgeInsets.only(right: 20, left: 20, bottom: 20),
                      child: Text(
                        "Some login credentials may be stored by the e-register service provider, either encoded or as tokens. This data is not shared and will never leave your device for purposes other than logging in.",
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.justify,
                      ))),
            )),
          ]),
    );
  }

  Future<bool> tryLogin({required Map<String, String> credentials, required String guid}) async {
    try {
      // Create a new session: ID/name/provider are automatic
      var session = Session(providerGuid: guid);
      var result = await session.login(credentials: credentials);

      if (!result.success && result.message != null) {
        throw result.message!; // Didn't work, uh
      } else {
        var id = Uuid().v4(); // Genereate a new session identifier
        Share.settings.sessions.sessions.update(id, (s) => session, ifAbsent: () => session);
        Share.settings.sessions.lastSessionId = id; // Update
        Share.session = session; // Set as the currently active one

        await Share.settings.save(); // Save our settings now
        await Share.session.refresh(); // Refresh everything
        await Share.session.refreshMessages(); // And messages

        // Change the main page to the base application
        Share.changeBase.broadcast(Value(() => baseApp));
        return true; // Mark the operation as succeeded
      }
    } on DioException catch (e) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg: e.message ?? '$e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      }
    } on Exception catch (e) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg: '$e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      }
    }
    return false;
  }
}
