import 'package:material_ui/material_ui.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oshi/interface/components/cupertino/message_compose.dart';
import 'package:oshi/interface/components/material/message_compose.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/share.dart';

/// Adaptive message composer, picks the Cupertino or the Material implementation
/// based on the current application settings.
class MessageComposePage extends StatelessWidget {
  const MessageComposePage({super.key, this.receivers, this.subject, this.message, this.signature});

  final List<Teacher>? receivers;
  final String? subject;
  final String? message;
  final String? signature;

  @override
  Widget build(BuildContext context) => Share.settings.appSettings.useCupertino
      ? CupertinoMessageComposePage(receivers: receivers, subject: subject, message: message, signature: signature)
      : MaterialMessageComposePage(receivers: receivers, subject: subject, message: message, signature: signature);
}

/// Opens the message composer in the way that is native to the current design:
/// a modal sheet on Cupertino, a full-screen route on Material.
Future<void> openMessageCompose(
  BuildContext context, {
  List<Teacher>? receivers,
  String? subject,
  String? message,
  String? signature,
}) async {
  final page = MessageComposePage(receivers: receivers, subject: subject, message: message, signature: signature);

  if (Share.settings.appSettings.useCupertino) {
    await showCupertinoModalBottomSheet(context: context, builder: (context) => page);
  } else {
    await Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => page));
  }
}

