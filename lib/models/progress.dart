import 'package:event/event.dart';

// https://learn.microsoft.com/en-us/dotnet/api/system.progress

abstract class IProgress<T> {
  void report(T value);
}

class Progress<T> implements IProgress<T> {
  @override // Reports a progress change
  void report(T value) {
    progressChanged.broadcast(Value(value));
  }

  // Raised for each reported progress value
  // To subscribe: event.subscribe((args) => {})
  Event<Value<T>> progressChanged = Event<Value<T>>();
}
