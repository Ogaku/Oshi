// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

MaterialApp get baseApp => MaterialApp(
      title: 'Material App',
      home: Scaffold(
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
