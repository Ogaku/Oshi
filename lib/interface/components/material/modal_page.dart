import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oshi/interface/components/shim/application_data_page.dart';
import 'package:oshi/interface/components/shim/modal_page.dart';

class ModalPage<T> extends ModalPageBase {
  const ModalPage({
    super.key,
    required super.children,
    required super.title,
    super.previousPageTitle,
    super.trailing,
  });

  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState<T> extends State<ModalPage<T>> {
  late ScrollController scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollPositionUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.removeListener(scrollPositionUpdated);
    scrollController.dispose();
  }

  void scrollPositionUpdated() {
    if (scrollController.offset >= 16 && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (scrollController.offset < 16 && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => DataPageBase.adaptive(
      title: widget.title,
      previousPageTitle: widget.previousPageTitle,
      // leading: widget.trailing,
      trailing: widget.trailing,
      children: widget.children);
}
