// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

// Boiler: returned to the main application
StatefulWidget get sessionsPage => SessionsPage();

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final scrollController = ScrollController();
  bool subscribed = false;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) => MaterialApp(
              theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
              ),
              home: Scaffold(
                body: const Center(
                  child: Text('Hello World'),
                ),
              ),
            ));
  }
}
