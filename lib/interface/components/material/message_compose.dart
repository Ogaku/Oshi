import 'package:material_ui/material_ui.dart';
import 'package:oshi/models/data/teacher.dart';
import 'package:oshi/share/share.dart';
import 'package:oshi/share/translator.dart';

/// Material 3 message composer. Self-contained: it doesn't rely on the shared
/// `DataPage`, so it works both as a full-screen route and inside a modal sheet.
class MaterialMessageComposePage extends StatefulWidget {
  const MaterialMessageComposePage({super.key, this.receivers, this.subject, this.message, this.signature});

  final List<Teacher>? receivers;
  final String? subject;
  final String? message;
  final String? signature;

  @override
  State<MaterialMessageComposePage> createState() => _MaterialMessageComposePageState();
}

class _MaterialMessageComposePageState extends State<MaterialMessageComposePage> {
  bool isWorking = false;

  late final List<Teacher> receivers = List<Teacher>.of(widget.receivers ?? const []);
  late final TextEditingController subjectController = TextEditingController(text: widget.subject);
  late final TextEditingController messageController = TextEditingController(text: widget.message);
  late final TextEditingController signatureController = TextEditingController(text: widget.signature);
  final TextEditingController receiverController = TextEditingController();

  bool get canSend =>
      !isWorking && receivers.isNotEmpty && subjectController.text.trim().isNotEmpty && messageController.text.isNotEmpty;

  @override
  void dispose() {
    subjectController.dispose();
    messageController.dispose();
    signatureController.dispose();
    receiverController.dispose();
    super.dispose();
  }

  Iterable<Teacher> get suggestions {
    final query = receiverController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return Share.session.data.messages.receivers.where((x) => x.name.toLowerCase().contains(query));
  }

  Future<void> send() async {
    if (!canSend) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);

    setState(() => isWorking = true);
    try {
      final signature = signatureController.text;
      final result = await Share.session.sendMessage(
        List<Teacher>.of(receivers),
        subjectController.text.replaceAll('\n', ' ').trim(),
        messageController.text +
            (signature.isEmpty ? '' : 'F263B8B0-0EFA-4486-836D-ED1FF801B2C2'.localized.format(signature)),
      );

      if (!mounted) return;
      if (result.success) {
        navigator.pop();
      } else {
        setState(() => isWorking = false);
        messenger?.showSnackBar(SnackBar(content: Text('${result.message ?? 'Nie udało się wysłać wiadomości'}')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isWorking = false);
      messenger?.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final matches = suggestions.toList();

    return PopScope(
      canPop: !isWorking,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'D91ED34B-BB94-4EFF-8DF8-D5F4FF8906BF'.localized,
            icon: const Icon(Icons.close),
            onPressed: isWorking ? null : () => Navigator.of(context).pop(),
          ),
          title: Text(
            subjectController.text.trim().isEmpty ? 'B8C5F980-D32F-42C9-A7E0-FF7667884776'.localized : subjectController.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (isWorking)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))),
              )
            else
              IconButton(
                tooltip: 'Send',
                icon: const Icon(Icons.send),
                color: scheme.primary,
                onPressed: canSend ? send : null,
              ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // Recipients
              if (receivers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: [
                      for (final receiver in receivers)
                        InputChip(
                          label: Text(receiver.name),
                          onDeleted: isWorking ? null : () => setState(() => receivers.remove(receiver)),
                        ),
                    ],
                  ),
                ),
              TextField(
                controller: receiverController,
                enabled: !isWorking,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_search_outlined),
                  hintText: 'EECC0427-E5ED-4A10-96D4-734FE2AA7804'.localized,
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1),

              if (receiverController.text.trim().isNotEmpty) ...[
                // Recipient search results
                if (matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        '81B09857-201A-4036-807F-7A32F0C23575'.localized,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  Card.filled(
                    margin: const EdgeInsets.only(top: 12),
                    clipBehavior: Clip.antiAlias,
                    color: scheme.surfaceContainerHigh,
                    child: Column(
                      children: [
                        for (final teacher in matches)
                          ListTile(
                            enabled: !receivers.contains(teacher),
                            leading: const Icon(Icons.person_outline),
                            title: Text(teacher.name),
                            trailing: receivers.contains(teacher) ? const Icon(Icons.check) : null,
                            onTap: () => setState(() {
                              receivers.add(teacher);
                              receiverController.clear();
                            }),
                          ),
                      ],
                    ),
                  ),
              ] else ...[
                // Subject
                TextField(
                  controller: subjectController,
                  enabled: !isWorking,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: InputDecoration(
                    hintText: 'AC7FCED9-3CEA-4C69-9512-8B409015DF2C'.localized,
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),

                // Message
                TextField(
                  controller: messageController,
                  enabled: !isWorking,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 8,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'DFE8DC1D-FB74-48C0-9016-0F03A5EBD128'.localized,
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),

                // Signature
                TextField(
                  controller: signatureController,
                  enabled: !isWorking,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 6,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.draw_outlined),
                    hintText: 'EB947AC4-561E-4D63-9EAD-7E80C18C48B9'.localized,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

