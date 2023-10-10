// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dio/dio.dart';
import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/base_app.dart';
import 'package:ogaku/share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Boiler: returned to the main application
StatefulWidget get loginPage => LoginPage();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Cupertino App',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          trailing: Icon(CupertinoIcons.info_circle),
          middle: FittedBox(
              fit: BoxFit.fitWidth,
              child: Container(
                margin: EdgeInsets.only(right: 25),
                child: Text('Log in to ${Share.currentProvider?.providerName}'),
              )),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.only(top: 60, left: 20, right: 20),
                width: 320,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(margin: EdgeInsets.only(bottom: 3, left: 3), child: Text('Username')),
                    CupertinoTextField(
                      onChanged: (s) => setState(() {}),
                      controller: loginController,
                    ),
                    Opacity(
                        opacity: 0.5,
                        child: Container(
                            margin: EdgeInsets.only(left: 3),
                            child: Text(Share.currentProvider?.loginAnnotation ?? '', style: TextStyle(fontSize: 14)))),
                  ]),
                  Container(
                    margin: EdgeInsets.only(top: 25),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(margin: EdgeInsets.only(bottom: 3, left: 3), child: Text('Password')),
                      CupertinoTextField(
                        onChanged: (s) => setState(() {}),
                        controller: passwordController,
                      ),
                      Opacity(
                          opacity: 0.5,
                          child: Container(
                              margin: EdgeInsets.only(left: 3),
                              child: Text(Share.currentProvider?.passAnnotation ?? '', style: TextStyle(fontSize: 14)))),
                    ]),
                  ),
                ]),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Opacity(
                    opacity: 0.6,
                    child: Container(
                        width: 320,
                        margin: EdgeInsets.only(right: 20, left: 20),
                        child: Text(
                          "Your login credentials won't be kept by the app, but may be locally saved by the e-register service provider, either as encoded text or an access token. This data is not, and will never be shared with neither us nor any third-parties.",
                          style: TextStyle(fontSize: 13),
                          textAlign: TextAlign.justify,
                        ))),
              )),
              Opacity(
                  opacity: (loginController.text.isNotEmpty && passwordController.text.isNotEmpty) ? 1.0 : 0.4,
                  child: Container(
                    width: 320,
                    margin: EdgeInsets.only(top: 15, bottom: 20, left: 20, right: 20),
                    child: CupertinoButton.filled(
                        child: const Text('Log in'),
                        onPressed: () => (loginController.text.isNotEmpty && passwordController.text.isNotEmpty)
                            ? tryLogin(login: loginController.text, pass: passwordController.text)
                            : null),
                  )),
            ]),
      ),
    );
  }

  void tryLogin({required String login, required String pass}) async {
    try {
      var result = await Share.currentProvider!
          .login(session: '81C59CC9-AA58-4FF4-BE69-91B1028F1C04', username: login, password: pass);

      if (!result.success && result.message != null) {
        throw result.message!;
      } else {
        Share.changeBase.broadcast(Value(() => baseApp));
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? '$e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );
    }
  }
}
