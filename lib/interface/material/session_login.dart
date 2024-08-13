// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:format/format.dart';
import 'package:oshi/interface/material/base_app.dart';
import 'package:oshi/models/progress.dart';
import 'package:oshi/models/provider.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';
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
  String? _progressMessage;

  bool isWorking = false; // Logging in right now?
  bool shakeFields = false; // Shake login fields

  @override
  Widget build(BuildContext context) {
    // Generate a map of credential controllers for the login page
    credentialControllers ??= widget.instance.credentialsConfig.keys.toMap((x) => MapEntry(x, TextEditingController()));

    var credentialEntries = widget.instance.credentialsConfig.entries
        .map((x) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                enabled: !isWorking,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: x.value.name,
                  hintText: '/Required'.localized,
                ),
                obscureText: x.value.obscure,
                autofillHints: [x.value.obscure ? AutofillHints.password : AutofillHints.username],
                controller: credentialControllers![x.key],
                onChanged: (s) => setState(() {}),
              ),
            ))
        .toList();

    return PopScope(
      canPop: !isWorking,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _progressMessage ?? 'Log in to ${widget.instance.providerName}',
            style: TextStyle(fontSize: _progressMessage != null ? 14 : 22),
          ), // TODO: Translate
          actions: [
            Container(
              padding: EdgeInsets.only(right: 10),
              child: TextButton(
                  child: isWorking
                      ? CupertinoActivityIndicator()
                      : Text('/Next'.localized,
                          style: TextStyle(
                              color: (credentialControllers!.values.every((x) => x.text.isNotEmpty))
                                  ? CupertinoTheme.of(context).primaryColor
                                  : CupertinoColors.inactiveGray)),
                  onPressed: () async {
                    if (isWorking) return; // Already handling something, give up
                    if (credentialControllers!.values.every((x) => x.text.isNotEmpty)) {
                      TextInput.finishAutofillContext(); // Hide autofill if present
                      setState(() {
                        // Mark as working, the 1st refresh is gonna take a while
                        isWorking = true;
                      });

                      var progress = Progress<({double? progress, String? message})>();
                      progress.progressChanged.subscribe((args) => setState(() => _progressMessage = args?.value.message));

                      if (!await tryLogin(
                          progress: progress,
                          guid: widget.providerGuid,
                          credentials: credentialControllers!.entries.toMap((x) => MapEntry(x.key, x.value.text)))) {
                        setState(() {
                          // Reset the animation in case the login method hasn't finished
                          isWorking = false;
                          shakeFields = true;

                          progress.progressChanged.unsubscribeAll();
                          _progressMessage = null; // Reset the message
                        });

                        // Reset the shake
                        Future.delayed(Duration(milliseconds: 300)).then((value) => setState(() => shakeFields = false));
                      }
                    }
                  }),
            )
          ],
        ),
        body: Column(
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
                  margin: EdgeInsets.only(top: 35),
                  child: credentialEntries.isNotEmpty
                      ? ShakeWidget(
                          shakeConstant: ShakeHorizontalConstant2(),
                          autoPlay: shakeFields,
                          enableWebMouseHover: false,
                          child: AutofillGroup(
                              child: Container(
                                  margin: EdgeInsets.only(left: 20, right: 20), child: Column(children: credentialEntries))))
                      : Opacity(opacity: 0.5, child: Text('/Session/Login/Data/Complete'.localized))),
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
                          '/Session/Login/Data/Info'.localized,
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.justify,
                        ))),
              )),
            ]),
      ),
    );
  }

  Future<bool> tryLogin(
      {required Map<String, String> credentials,
      required String guid,
      IProgress<({double? progress, String? message})>? progress}) async {
    try {
      // Create a new session: ID/name/provider are automatic
      progress?.report((progress: 0.1, message: '/Session/Login/Splash/Session'.localized));
      var session = Session(providerGuid: guid);
      var result = await session.tryLogin(credentials: credentials, progress: progress, showErrors: true);

      if (!result.success && result.message != null) {
        return false; // Didn't work, uh
      } else {
        var id = Uuid().v4(); // Genereate a new session identifier
        Share.settings.sessions.sessions.update(id, (s) => session, ifAbsent: () => session);
        Share.settings.sessions.lastSessionId = id; // Update
        Share.session = session; // Set as the currently active one

        progress?.report((progress: 0.2, message: '/Session/Login/Splash/Settings'.localized));
        await Share.settings.save(); // Save our settings now
        var result = await Share.session.refreshAll(progress: progress, saveChanges: false);
        if (!result.success && result.message != null) return false; // Didn't work, uh

        // Change the main page to the base application
        Share.changeBase.broadcast(Value(() => baseApp));
        return true; // Mark the operation as succeeded
      }
    } on DioException catch (ex, stack) {
      Share.showErrorModal.broadcast(Value((
        title: '/Session/Login/Error/Title'.localized,
        message: '/Session/Login/Error/Message'.localized.format(ex.message ?? ex),
        actions: {
          '/Session/Login/Error/Exception'.localized: () async =>
              await Clipboard.setData(ClipboardData(text: ex.toString())),
          '/Session/Login/Error/Stack'.localized: () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
    } on Exception catch (ex, stack) {
      Share.showErrorModal.broadcast(Value((
        title: '/Session/Login/Error/Title'.localized,
        message: '/Session/Login/Error/Message'.localized.format(ex),
        actions: {
          '/Session/Login/Error/Exception'.localized: () async =>
              await Clipboard.setData(ClipboardData(text: ex.toString())),
          '/Session/Login/Error/Stack'.localized: () async => await Clipboard.setData(ClipboardData(text: stack.toString())),
        }
      )));
    }
    return false;
  }
}
