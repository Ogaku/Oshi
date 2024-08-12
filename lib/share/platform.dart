import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';

bool get isIOS => !kIsWeb && Platform.isIOS;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isMacOS => !kIsWeb && Platform.isMacOS;
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
bool get isWeb => kIsWeb;
