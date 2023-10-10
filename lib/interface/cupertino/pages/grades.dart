// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';

import 'package:ogaku/interface/cupertino/views/navigation_bar.dart' show SliverNavigationBar;

// Boiler: returned to the app tab builder
StatefulWidget get gradesPage => GradesPage();

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverNavigationBar(
            scrollController: scrollController,
            leading: Icon(CupertinoIcons.person_2),
            largeTitle: Text('Grades'),
            trailing: Icon(CupertinoIcons.gear),
          ),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [Text('Hey vsauce, GradesPage here!')],
            ),
          )
        ],
      ),
    );
  }
}
