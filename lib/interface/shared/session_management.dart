// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:oshi/share/share.dart';

import 'package:oshi/interface/components/material/sessions.dart' as material;
import 'package:oshi/interface/components/cupertino/sessions.dart' as cupertino;

import 'package:oshi/interface/components/material/application.dart' as material;
import 'package:oshi/interface/components/cupertino/application.dart' as cupertino;

// Boiler: base application
StatefulWidget get baseApplication => Share.settings.appSettings.useCupertino ? cupertino.BaseApp() : material.BaseApp();

// Boiler: session manager
StatefulWidget get sessionsPage =>
    Share.settings.appSettings.useCupertino ? cupertino.SessionsPage() : material.SessionsPage();

// Boiler: new session
StatefulWidget get newSessionPage =>
    Share.settings.appSettings.useCupertino ? cupertino.NewSessionPage(asApp: true) : material.NewSessionPage();
