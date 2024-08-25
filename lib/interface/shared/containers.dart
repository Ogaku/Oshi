// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/interface/components/cupertino/application.dart';
import 'package:oshi/interface/shared/input.dart';
import 'package:oshi/interface/shared/views/grades_detailed.dart';
import 'package:oshi/share/share.dart';

class CardContainer extends StatefulWidget {
  const CardContainer({
    super.key,
    this.largeHeader = true,
    this.header,
    this.footer,
    this.children = const [],
    this.additionalDividerMargin = 5,
    this.dividerMargin = 14,
    this.noDivider = false,
    this.filled = true,
    this.backgroundColor,
    this.margin,
    this.regularOverride,
  });

  final bool largeHeader;
  final dynamic header;
  final dynamic footer;
  final List<Widget> children;

  final double additionalDividerMargin;
  final double dividerMargin;
  final bool noDivider;
  final bool filled;
  final bool? regularOverride;

  final Color? backgroundColor;
  final EdgeInsets? margin;

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer> {
  @override
  Widget build(BuildContext context) {
    if (Share.settings.appSettings.useCupertino) {
      return CupertinoListSection.insetGrouped(
        margin: widget.margin ?? const EdgeInsets.only(left: 15, right: 15, bottom: 10),
        additionalDividerMargin: widget.additionalDividerMargin,
        dividerMargin: widget.dividerMargin,
        separatorColor: widget.noDivider ? Colors.transparent : null,
        backgroundColor: widget.noDivider ? Colors.transparent : CupertinoColors.systemGroupedBackground,
        hasLeading: false,
        header: (widget.header is String && widget.header.isNotEmpty)
            ? (widget.largeHeader
                ? Text((widget.header as String).toUpperCase())
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Opacity(
                        opacity: 0.5,
                        child: Text((widget.header as String).toUpperCase(),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)))))
            : ((widget.header is Widget) ? widget.header : null),
        footer: (widget.footer is String && widget.footer.isNotEmpty)
            ? (Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Opacity(opacity: 0.5, child: Text(widget.footer, style: TextStyle(fontSize: 13)))))
            : widget.footer,
        children: widget.children,
      );
    } else {
      var regular = widget.regularOverride ??
          ((widget.children.first is AdaptiveCard && (widget.children.first as AdaptiveCard).regular) ||
              widget.children.first is AdaptiveFormRow);

      return Container(
        margin: regular ? EdgeInsets.only() : (widget.margin ?? const EdgeInsets.only(left: 10, right: 10, bottom: 10)),
        child: Table(children: [
          if (widget.header is! String && widget.header != null) TableRow(children: [widget.header]),
          if (widget.header is String && widget.header.isNotEmpty)
            TableRow(children: [
              Container(
                margin: regular ? EdgeInsets.only(left: 23, top: 25, bottom: 10) : EdgeInsets.only(left: 5, top: 10),
                child: Text(
                  (widget.header as String).toLowerCase().capitalize(),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ]),
          TableRow(children: [
            (widget.filled || widget.backgroundColor != null)
                ? Card(
                    clipBehavior: Clip.antiAlias,
                    color: widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Column(
                      children: widget.children,
                    ),
                  )
                : Column(
                    children: widget.children,
                  )
          ]),
          if (widget.footer is! String && widget.footer != null) TableRow(children: [widget.footer]),
          if (widget.footer is String && widget.footer.isNotEmpty)
            TableRow(children: [
              Container(
                margin: regular
                    ? EdgeInsets.only(left: 22, bottom: 10, top: 10, right: 20)
                    : EdgeInsets.only(left: 5, bottom: 6),
                child: Text(
                  widget.footer,
                  style: TextStyle(color: Theme.of(context).dividerColor),
                ),
              ),
            ]),
        ]),
      );
    }
  }
}

class AdaptiveCard extends StatefulWidget {
  const AdaptiveCard({
    super.key,
    this.hideChevron = false,
    this.secondary = false,
    this.centered = false,
    this.click,
    required this.child,
    this.after,
    this.roundedFocus = true,
    this.regular = false,
    this.unreadDot,
    this.trailingElement,
    this.forceTrailing = false,
    this.margin,
  });

  final bool hideChevron;
  final bool secondary;
  final bool centered;
  final bool roundedFocus;
  final bool regular;
  final bool forceTrailing;
  final EdgeInsets? margin;

  final FutureOr<void> Function()? click;
  final dynamic child;
  final dynamic after;
  final dynamic trailingElement;
  final UnreadDot? unreadDot;

  @override
  State<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends State<AdaptiveCard> {
  @override
  Widget build(BuildContext context) {
    if (Share.settings.appSettings.useCupertino) {
      return CupertinoListTile(
          onTap: widget.click,
          trailing: widget.after != null
              ? (widget.after is String
                  ? Text(
                      widget.after as String,
                      style: TextStyle(fontWeight: FontWeight.normal),
                    )
                  : widget.after)
              : (widget.click != null && !widget.hideChevron
                  ? Container(
                      margin: EdgeInsets.only(left: 2),
                      child: Transform.scale(
                          scale: 0.7, child: Icon(CupertinoIcons.chevron_forward, color: CupertinoColors.inactiveGray)))
                  : null),
          title: widget.child is String
              ? Opacity(
                  opacity: widget.secondary ? 0.5 : 1.0,
                  child: Container(
                      alignment: widget.centered ? Alignment.center : null,
                      child: Text(
                        widget.child as String,
                        style: TextStyle(fontWeight: FontWeight.normal),
                      )))
              : widget.child);
    } else {
      return ListTile(
          onTap: widget.click,
          contentPadding: widget.margin ?? (widget.regular
                  ? EdgeInsets.symmetric(horizontal: 23, vertical: 6)
                  : EdgeInsets.symmetric(horizontal: widget.centered ? 0 : 15)),
          shape: widget.roundedFocus
              ? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)))
              : null,
          trailing: widget.forceTrailing && widget.after is Widget
              ? SizedBox(child: widget.after, width: 100, height: 100)
              : (widget.trailingElement is Widget
                  ? widget.trailingElement
                  : (widget.trailingElement is String && widget.click != null
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              padding: EdgeInsets.symmetric(horizontal: 27, vertical: 15)),
                          onPressed: widget.click,
                          child: Text(widget.trailingElement as String,
                              style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSecondary)),
                        )
                      : null)),
          title: Table(children: [
            TableRow(children: [
              Table(
                  columnWidths: widget.unreadDot != null ? const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth(1)} : null,
                  children: [
                    TableRow(children: [
                      if (widget.unreadDot != null)
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: widget.unreadDot ?? Container(),
                        ),
                      widget.child is String
                          ? Opacity(
                              opacity: widget.secondary ? 0.5 : 1.0,
                              child: Container(
                                  alignment: widget.centered ? Alignment.center : null,
                                  child: Text(
                                    widget.child as String,
                                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: widget.regular ? 20 : 17),
                                  )))
                          : widget.child
                    ])
                  ])
            ]),
            if (widget.after != null && !widget.forceTrailing)
              TableRow(children: [
                if (widget.after is String)
                  Opacity(
                    opacity: 0.75,
                    child: Text(
                      widget.after as String,
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ),
                if (widget.after is Widget) widget.after
              ])
          ]));
    }
  }
}

(ColorScheme light, ColorScheme dark) generateDynamicColourSchemes(ColorScheme lightDynamic, ColorScheme darkDynamic) {
  var lightBase = ColorScheme.fromSeed(seedColor: lightDynamic.primary);
  var darkBase = ColorScheme.fromSeed(seedColor: darkDynamic.primary, brightness: Brightness.dark);

  var lightAdditionalColours = _extractAdditionalColours(lightBase);
  var darkAdditionalColours = _extractAdditionalColours(darkBase);

  var lightScheme = _insertAdditionalColours(lightBase, lightAdditionalColours);
  var darkScheme = _insertAdditionalColours(darkBase, darkAdditionalColours);

  return (lightScheme.harmonized(), darkScheme.harmonized());
}

List<Color> _extractAdditionalColours(ColorScheme scheme) => [
      scheme.surface,
      scheme.surfaceDim,
      scheme.surfaceBright,
      scheme.surfaceContainerLowest,
      scheme.surfaceContainerLow,
      scheme.surfaceContainer,
      scheme.surfaceContainerHigh,
      scheme.surfaceContainerHighest,
    ];

ColorScheme _insertAdditionalColours(ColorScheme scheme, List<Color> additionalColours) => scheme.copyWith(
      surface: additionalColours[0],
      surfaceDim: additionalColours[1],
      surfaceBright: additionalColours[2],
      surfaceContainerLowest: additionalColours[3],
      surfaceContainerLow: additionalColours[4],
      surfaceContainer: additionalColours[5],
      surfaceContainerHigh: additionalColours[6],
      surfaceContainerHighest: additionalColours[7],
    );
