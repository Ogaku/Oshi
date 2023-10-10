// ignore_for_file: prefer_const_constructors

import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/base_app.dart';
import 'package:ogaku/share/share.dart';

CupertinoApp get loginPage => CupertinoApp(
      title: 'Cupertino App',
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Cupertino App Bar'),
        ),
        child: Center(
            child: CupertinoButton(
                child: Text('Click to log in'), onPressed: () => Share.changeBase.broadcast(Value(() => baseApp)))),
      ),
    );
