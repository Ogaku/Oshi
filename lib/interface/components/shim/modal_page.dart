import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:oshi/interface/components/material/modal_page.dart' as material;
import 'package:oshi/interface/components/cupertino/modal_page.dart' as cupertino;
import 'package:oshi/share/share.dart';

abstract class ModalPageBase extends StatefulWidget {
  const ModalPageBase({super.key, required this.children, required this.title, this.previousPageTitle, this.trailing});

  final String title;
  final Widget? trailing;
  final String? previousPageTitle;
  final List<Widget> children;

  static ModalPageBase adaptive({
    required String title,
    required List<Widget> children,
    Widget?trailing,
    String? previousPageTitle,
  }) =>
      Share.settings.appSettings.useCupertino
          ? cupertino.ModalPage(
              title: title,
              trailing: trailing,
              previousPageTitle: previousPageTitle,
              children: children,
            )
          : material.ModalPage(
              title: title,
              trailing: trailing,
              previousPageTitle: previousPageTitle,
              children: children,
            );
}
