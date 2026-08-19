import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/core/controller.dart';
import 'package:clash_arc/models/common.dart';
import 'package:clash_arc/providers/action.dart';
import 'package:clash_arc/providers/app.dart';
import 'package:clash_arc/providers/config.dart';
import 'package:clash_arc/state.dart';
import 'package:clash_arc/views/config/material_settings.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  Widget _getDeveloperList(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return MaterialSettingsSection(
      title: appLocalizations.options,
      children: [
        ListItem(
          title: Text(appLocalizations.messageTest),
          minVerticalPadding: 12,
          onTap: () {
            context.showNotifier(appLocalizations.messageTestTip);
          },
        ),
        ListItem(
          title: Text(appLocalizations.logsTest),
          minVerticalPadding: 12,
          onTap: () {
            for (int i = 0; i < 1000; i++) {
              globalState.container
                  .read(logsProvider.notifier)
                  .add(
                    Log.app(
                      '[$i]${utils.generateRandomString(maxLength: 200, minLength: 20)}',
                    ),
                  );
            }
          },
        ),
        ListItem(
          title: Text(appLocalizations.pruneCache),
          minVerticalPadding: 12,
          onTap: () async {
            await globalState.container
                .read(storeActionProvider.notifier)
                .shakingStore();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final enable = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    return BaseScaffold(
      title: appLocalizations.developerMode,
      body: SingleChildScrollView(
        padding: ClashArcDesignTokens.pageInsets,
        child: Column(
          children: [
            MaterialSettingsSection(
              children: [
                ListItem.toggle(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  title: Text(appLocalizations.developerMode),
                  value: enable,
                  onChanged: (value) {
                    ref
                        .read(appSettingProvider.notifier)
                        .update(
                          (state) => state.copyWith(developerMode: value),
                        );
                  },
                ),
              ],
            ),
            _getDeveloperList(context, ref),
            MaterialSettingsSection(
              title: appLocalizations.action,
              dangerous: true,
              children: [
                if (globalState.canCrashCore)
                  ListItem(
                    title: Text(
                      appLocalizations.crashTest,
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                    minVerticalPadding: 12,
                    onTap: () async {
                      final res = await globalState.showMessage(
                        message: TextSpan(
                          text: appLocalizations.confirmForceCrashCore,
                        ),
                      );
                      if (res != true) {
                        return;
                      }
                      coreController.crash();
                    },
                  ),
                ListItem(
                  title: Text(
                    appLocalizations.clearData,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                  minVerticalPadding: 12,
                  onTap: () async {
                    final res = await globalState.showMessage(
                      message: TextSpan(
                        text: appLocalizations.confirmClearAllData,
                      ),
                    );
                    if (res != true) {
                      return;
                    }
                    await globalState.container
                        .read(storeActionProvider.notifier)
                        .handleClear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
