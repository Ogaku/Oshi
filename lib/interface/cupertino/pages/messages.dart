// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:ogaku/interface/cupertino/views/searchable_bar.dart';

// Boiler: returned to the app tab builder
StatefulWidget get messagesPage => MessagesPage();

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SearchableSliverNavigationBar(
      largeTitle: Text('Messages'),
      searchController: searchController,
      trailing: Icon(CupertinoIcons.pencil),
      children: [
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        Text('message', style: TextStyle(fontSize: 50),),
        ],
    );
  }
}
