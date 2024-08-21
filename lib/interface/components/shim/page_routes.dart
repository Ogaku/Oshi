import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/share/share.dart';

// ignore: non_constant_identifier_names
PageRoute AdaptivePageRoute({required Widget Function(BuildContext) builder}) =>
    Share.settings.appSettings.useCupertino ? CupertinoPageRoute(builder: builder) : MaterialPageRoute(builder: builder);
