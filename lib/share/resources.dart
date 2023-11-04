import 'package:flutter/cupertino.dart';

class Resources {
  static Map<int, ({CupertinoDynamicColor color, String name})> accentColors = {
    0: (color: CupertinoColors.systemRed, name: 'System Red'),
    1: (color: CupertinoColors.systemPink, name: 'System Pink'),
    2: (color: CupertinoColors.systemOrange, name: 'System Orange'),
    3: (color: CupertinoColors.systemYellow, name: 'System Yellow'),
    4: (color: CupertinoColors.systemGreen, name: 'System Green'),
    5: (color: CupertinoColors.systemMint, name: 'System Mint'),
    6: (color: CupertinoColors.systemTeal, name: 'System Teal'),
    7: (color: CupertinoColors.systemCyan, name: 'System Cyan'),
    8: (color: CupertinoColors.systemBlue, name: 'System Blue'),
    9: (color: CupertinoColors.systemIndigo, name: 'System Indigo'),
    10: (color: CupertinoColors.systemPurple, name: 'System Purple')
  };

  static Map<String, String> languages = {'en': 'English'};
}
