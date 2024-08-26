import 'package:flutter/widgets.dart';
import 'package:oshi/models/provider.dart';

import 'package:oshi/interface/components/material/sessions.dart' as material;
import 'package:oshi/interface/components/cupertino/sessions.dart' as cupertino;
import 'package:oshi/share/share.dart';

abstract class LoginPageBase extends StatefulWidget {
  const LoginPageBase({super.key, required this.instance, required this.providerGuid});

  final String providerGuid;
  final IProvider instance;

  static LoginPageBase adaptive({required IProvider instance, required String providerGuid}) {
    return Share.settings.appSettings.useCupertino
        ? cupertino.LoginPage(instance: instance, providerGuid: providerGuid)
        : material.LoginPage(instance: instance, providerGuid: providerGuid);
  }
}
