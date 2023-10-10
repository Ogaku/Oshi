import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:ogaku/models/provider.dart';

class Share {
  // The data provider currently used by the app
  static IProvider? currentProvider;

  // Raised by the app to notify that the uses's just logged in
  // To subscribe: event.subscribe((args) => {})
  static Event<Value<StatefulWidget Function()>> changeBase = Event<Value<StatefulWidget Function()>>();
}
