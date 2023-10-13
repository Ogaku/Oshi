// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/base_app.dart';
import 'package:ogaku/models/provider.dart';
import 'package:ogaku/share/share.dart';
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
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isWorking = false; // Logging in right now?

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
          ? CupertinoColors.systemBackground
          : CupertinoColors.secondarySystemBackground,
      navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          automaticallyImplyLeading: true,
          border: null,
          backgroundColor: WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
              ? CupertinoColors.systemBackground
              : CupertinoColors.secondarySystemBackground,
          trailing: CupertinoButton(
              padding: EdgeInsets.all(10),
              child: isWorking
                  ? CupertinoActivityIndicator()
                  : Text('Next',
                      style: TextStyle(
                          color: (loginController.text.isNotEmpty && passwordController.text.isNotEmpty)
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.inactiveGray)),
              onPressed: () async {
                if (isWorking) return; // Already handling something, give up
                if (loginController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                  setState(() {
                    // Mark as working, the 1st refresh is gonna take a while
                    isWorking = true;
                  });
                  if (!await tryLogin(
                      guid: widget.providerGuid, login: loginController.text, pass: passwordController.text)) {
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
                child: CupertinoFormSection.insetGrouped(children: [
                  CupertinoFormRow(
                      prefix: SizedBox(width: 90, child: Text('Username')),
                      child: CupertinoTextFormFieldRow(
                        placeholder: 'Required',
                        controller: loginController,
                        onChanged: (s) => setState(() {}),
                      )),
                  CupertinoFormRow(
                      prefix: SizedBox(width: 90, child: Text('Password')),
                      child: CupertinoTextFormFieldRow(
                        obscureText: true,
                        placeholder: 'Required',
                        controller: passwordController,
                        onChanged: (s) => setState(() {}),
                      ))
                ])),
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
                        "Some login credentials may be locally stored by the e-register service provider, either as encoded text or a computed access token. This data is not, and will never be shared with neither the project team nor any third-parties.",
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.justify,
                      ))),
            )),
          ]),
    );
  }

  Future<bool> tryLogin({required String login, required String pass, required String guid}) async {
    try {
      // Create a new session: ID/name/provider are automatic
      var session = Session(providerGuid: guid);
      var result = await session.login(username: login, password: pass);

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
