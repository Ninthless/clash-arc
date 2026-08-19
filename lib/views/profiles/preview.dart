import 'package:clash_arc/common/task.dart';
import 'package:clash_arc/models/profile.dart';
import 'package:clash_arc/pages/editor.dart';
import 'package:clash_arc/providers/action.dart';
import 'package:clash_arc/state.dart';
import 'package:flutter/material.dart';

class PreviewProfileView extends StatefulWidget {
  final Profile profile;

  const PreviewProfileView({super.key, required this.profile});

  @override
  State<PreviewProfileView> createState() => _PreviewProfileViewState();
}

class _PreviewProfileViewState extends State<PreviewProfileView> {
  final contentNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final configMap = await globalState.container
          .read(setupActionProvider.notifier)
          .getProfileWithId(widget.profile.id);
      final content = await encodeYamlTask(configMap);
      if (!mounted) {
        return;
      }
      contentNotifier.value = content;
    });
  }

  @override
  void dispose() {
    contentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: contentNotifier,
      builder: (_, content, _) {
        final title = widget.profile.realLabel;

        return EditorPage(
          key: const Key('content'),
          title: title,
          content: content,
        );
      },
    );
  }
}
