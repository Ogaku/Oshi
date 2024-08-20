// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:darq/darq.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:extended_wrap/extended_wrap.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/pages/home.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/share/extensions.dart';
import 'package:oshi/share/resources.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

// Boiler: returned to the app tab builder
StatefulWidget get gradesPage => GradesPage();

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    Share.refreshAll.unsubscribe(refresh);
    super.dispose();
  }

  void refresh(args) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Re-subscribe to all events
    Share.refreshAll.unsubscribe(refresh);
    Share.refreshAll.subscribe(refresh);

    Share.gradesNavigate.unsubscribeAll();
    Share.gradesNavigate.subscribe((args) {
      if (args?.value == null) return;
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => GradesDetailedPage(
                    lesson: args!.value,
                  )));
    });

    var subjectsToDisplay = Share.session.data.student.subjects
        .where((x) =>
            x.name.contains(RegExp(searchController.text, caseSensitive: false)) ||
            x.teacher.name.contains(RegExp(searchController.text, caseSensitive: false)))
        .orderBy((x) => x.name)
        .toList();

    var hasSecondSemester = subjectsToDisplay.any((x) => x.allGrades.any((y) => y.semester == 2));
    var subjectsWidget = CupertinoListSection.insetGrouped(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
      additionalDividerMargin: 5,
      children: subjectsToDisplay.isEmpty
          // No messages to display
          ? [
              CupertinoListTile(
                  title: Opacity(
                      opacity: 0.5,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            '/Grades/NoLessons'.localized,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ))))
            ]
          // Bindable messages layout
          : subjectsToDisplay.select((x, index) {
              var grades = x.allGrades.where((x) => x.semester == 2).appendAllIfEmpty(x.allGrades);

              return Builder(
                  builder: (context) => CupertinoListTile(
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => GradesDetailedPage(
                                    lesson: x,
                                  ))),
                      trailing: Container(margin: EdgeInsets.only(left: 3), child: CupertinoListTileChevron()),
                      title: Container(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      UnreadDot(unseen: () => x.hasUnseen, margin: EdgeInsets.only(right: 6)),
                                      Expanded(
                                          child: Container(
                                              margin: EdgeInsets.only(right: 10),
                                              child: Text(
                                                x.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                              ))),
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                          visible: grades.isNotEmpty,
                                          child: Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only(top: 8),
                                                  child: ExtendedWrap(
                                                      maxLines: 1,
                                                      overflowWidget: Text('...'),
                                                      spacing: 5,
                                                      children: grades
                                                          .where((y) => !y.major)
                                                          .orderByDescending((y) => y.addDate)
                                                          .distinct((x) =>
                                                              mapPropsToHashCode([x.resitPart ? 0 : UniqueKey(), x.name]))
                                                          .select((y, index) => Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 4),
                                                                decoration: BoxDecoration(
                                                                    color: y.major
                                                                        ? (y.isFinal || y.isSemester)
                                                                            ? y.asColor()
                                                                            : null
                                                                        : y.asColor(),
                                                                    border: Border.all(
                                                                        color: y.asColor(),
                                                                        width: 1,
                                                                        strokeAlign: BorderSide.strokeAlignInside),
                                                                    borderRadius: BorderRadius.all(Radius.circular(4))),
                                                                child: Text(y.value,
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        fontSize: 13,
                                                                        color:
                                                                            (y.isFinalProposition || y.isSemesterProposition)
                                                                                ? CupertinoDynamicColor.resolve(
                                                                                    CupertinoDynamicColor.withBrightness(
                                                                                        color: CupertinoColors.black,
                                                                                        darkColor: CupertinoColors.white),
                                                                                    context)
                                                                                : CupertinoColors.black)),
                                                              ))
                                                          .prependIf(Container(width: 3), grades.any((y) => y.major))
                                                          .prependAll(grades
                                                              .where((y) => y.major)
                                                              .orderByDescending((y) => y.isFinal ? 1 : 0)
                                                              .orderByDescending((y) => y.isSemester ? 1 : 0)
                                                              .thenByDescending((y) => y.addDate)
                                                              .take(1)
                                                              .select((y, index) => Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                                                    decoration: BoxDecoration(
                                                                        color: y.major
                                                                            ? (y.isFinal || y.isSemester)
                                                                                ? y.asColor()
                                                                                : null
                                                                            : y.asColor(),
                                                                        border: Border.all(
                                                                            color: y.asColor(),
                                                                            width: 1,
                                                                            strokeAlign: BorderSide.strokeAlignInside),
                                                                        borderRadius: BorderRadius.all(Radius.circular(4))),
                                                                    child: Text(y.value,
                                                                        textAlign: TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: (y.isFinalProposition ||
                                                                                    y.isSemesterProposition)
                                                                                ? CupertinoDynamicColor.resolve(
                                                                                    CupertinoDynamicColor.withBrightness(
                                                                                        color: CupertinoColors.black,
                                                                                        darkColor: CupertinoColors.white),
                                                                                    context)
                                                                                : CupertinoColors.black)),
                                                                  )))
                                                          .prependIf(
                                                              Container(
                                                                  margin: EdgeInsets.only(right: 3),
                                                                  child: Text("/Semesters/First".localized,
                                                                      textAlign: TextAlign.center,
                                                                      style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: CupertinoColors.secondaryLabel
                                                                              .resolveFrom(context)))),
                                                              hasSecondSemester && grades.all((y) => y.semester == 1))
                                                          .toList()))))
                                    ]),
                                Visibility(
                                    visible: grades.isEmpty,
                                    child: Opacity(
                                        opacity: 0.5,
                                        child: Container(
                                            margin: EdgeInsets.only(top: 5),
                                            child: Text(
                                              x.teacher.name,
                                              style: TextStyle(fontSize: 16),
                                            )))),
                              ]))));
            }).toList(),
    );

    return DataPageBase.adaptive(
      pageFlags: [DataPageType.searchable, DataPageType.refreshable].flag,
      setState: setState,
      title: '/Grades'.localized,
      searchController: searchController,
      children: [subjectsWidget]
          .appendIf(
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.only(left: 15, right: 15, top: 5),
                additionalDividerMargin: 5,
                children: [
                  CupertinoListTile(
                      title: Text('/Average'.localized, overflow: TextOverflow.ellipsis),
                      trailing: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Opacity(
                              opacity: 0.5,
                              child: Text(() {
                                var majors = Share.session.data.student.subjects
                                    .where((x) => x.hasMajor)
                                    .select((x, _) => x.topMajor!.asValue);
                                return majors.isNotEmpty ? majors.average().toStringAsFixed(2) : 'Unavailable';
                              }()))))
                ],
              ),
              searchController.text.isEmpty && Share.session.data.student.subjects.any((x) => x.hasMajor))
          // The average graph
          .appendIf(
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.only(left: 15, right: 15, top: 15),
                additionalDividerMargin: 5,
                children: [
                  CupertinoListTile(
                      title: Container(
                          transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                          margin: EdgeInsets.only(top: 20, bottom: 10),
                          child: FittedBox(
                              alignment: Alignment.topLeft,
                              child: SizedBox(width: 400, height: 220, child: LineChartSample1()))))
                ],
              ),
              searchController.text.isEmpty && Share.session.data.student.mainClass.averages.isNotEmpty),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return LineChart(sampleData2);
  }

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 0,
        maxX: ((Share.session.data.student.mainClass.averages.keys.first
                        .difference(Share.session.data.student.mainClass.averages.keys.last)
                        .inDays) /
                    -30.0)
                .round() *
            1.0,
        maxY: 6,
        minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
            sideTitles: leftTitles(), axisNameWidget: Opacity(opacity: 0.7, child: Text('Class average')), axisNameSize: 30),
      );

  List<LineChartBarData> get lineBarsData2 => [lineChartBarData2_1, lineChartBarData2_2];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );
    return Text(value.toString(), style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
    );

    return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: Text(
            DateFormat.MMM(Share.settings.appSettings.localeCode)
                .format(Share.session.data.student.mainClass.averages.keys.first.add(Duration(days: (value * 30).round()))),
            style: style));
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: CupertinoColors.systemGreen,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: Share.session.data.student.mainClass.averages.entries
            .select((x, _) => FlSpot(
                (Share.session.data.student.mainClass.averages.keys.first.difference(x.key).inDays) / -30.0,
                x.value.student))
            .toList(),
      );

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
        isCurved: true,
        color: CupertinoColors.systemPink,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: CupertinoColors.systemPink.withOpacity(0.1),
        ),
        spots: Share.session.data.student.mainClass.averages.entries
            .select((x, _) => FlSpot(
                (Share.session.data.student.mainClass.averages.keys.first.difference(x.key).inDays) / -30.0, x.value.level))
            .toList(),
      );
}

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _LineChart();
  }
}
