import 'package:flutter/material.dart';
import 'package:szkolny/providers/librus/librus_data.dart' show LibrusDataReader;

void main() async {
  try {
    var reader = LibrusDataReader();
    await reader.login(session: '81C59CC9-AA58-4FF4-BE69-91B1028F1C04', username: 'USERNAME', password: 'PASS');

    await reader.refresh();
    await reader.refreshMessages();

    print('');
  } on Exception catch (e) {
    print(e);
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
