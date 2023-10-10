// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';

CupertinoApp get baseApp => CupertinoApp(
      title: 'Cupertino App',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Cupertino App Bar'),
        ),
        child: Center(
          child: Text('Hello World'),
        ),
      ),
    );
