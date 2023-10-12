// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
