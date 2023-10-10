// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:ogaku/share/share.dart';
import 'package:ogaku/providers/librus/librus_data.dart' show LibrusDataReader;
import 'package:ogaku/share/config.dart' show Config;

import 'package:ogaku/interface/cupertino/login.dart' as cupertinoapp show loginPage;
import 'package:ogaku/interface/material/login.dart' as materialapp show loginPage;

void main() async {
  // try {
  //   var reader = LibrusDataReader();
  //   await reader.login(session: '81C59CC9-AA58-4FF4-BE69-91B1028F1C04', username: 'LOGIN', password: 'PASS');

  //   await reader.refresh();
  //   await reader.refreshMessages();

  //   print('');
  // } on Exception catch (e) {
  //   print(e);
  // }

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Widget Function() child = Config.useCupertino ? () => cupertinoapp.loginPage : () => materialapp.loginPage;

  @override
  Widget build(BuildContext context) {
    Share.changeBase.subscribe((args) {
      setState(() {
        if (args != null) child = args.value;
      });
    });

    return child();
  }
}
