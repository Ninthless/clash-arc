import 'dart:async';

import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/l10n/l10n.dart';
import 'package:clash_arc/providers/providers.dart';
import 'package:clash_arc/state.dart';
import 'package:clash_arc/views/config/material_settings.dart';
import 'package:clash_arc/widgets/list.dart';
import 'package:clash_arc/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Contributor {
  final String avatar;
  final String name;
  final String link;

  const Contributor({
    required this.avatar,
    required this.name,
    required this.link,
  });
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<void> _checkUpdate(BuildContext context) async {
    final data = await globalState.safeRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: context.appLocalizations.checkUpdate,
    );
    globalState.container
        .read(commonActionProvider.notifier)
        .checkUpdateResultHandle(data: data, isUser: true);
  }

  Widget _buildMoreSection(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return MaterialSettingsSection(
      title: appLocalizations.more,
      children: [
        ListItem(
          title: Text(appLocalizations.checkUpdate),
          onTap: () {
            _checkUpdate(context);
          },
        ),
        ListItem(
          title: const Text('Telegram'),
          onTap: () {
            globalState.openUrl('https://t.me/Clash Arc');
          },
          trailing: const Icon(Icons.launch),
        ),
        ListItem(
          title: Text(appLocalizations.project),
          onTap: () {
            globalState.openUrl('https://github.com/$repository');
          },
          trailing: const Icon(Icons.launch),
        ),
        ListItem(
          title: Text(appLocalizations.core),
          onTap: () {
            globalState.openUrl(
              'https://github.com/chen08209/Clash.Meta/tree/Clash Arc',
            );
          },
          trailing: const Icon(Icons.launch),
        ),
      ],
    );
  }

  Widget _buildContributorsSection(AppLocalizations appLocalizations) {
    const contributors = [
      Contributor(
        avatar: 'assets/images/avatar/june2.jpg',
        name: 'June2',
        link: 'https://t.me/Jibadong',
      ),
      Contributor(
        avatar: 'assets/images/avatar/arue.jpg',
        name: 'Arue',
        link: 'https://t.me/xrcm6868',
      ),
    ];
    return MaterialSettingsSection(
      title: appLocalizations.otherContributors,
      children: [
        ListItem(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 24,
              children: [
                for (final contributor in contributors)
                  Avatar(contributor: contributor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final items = <Widget>[
      Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: context.colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: ClashArcDesignTokens.largeShape,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (_, ref, _) {
                  return _DeveloperModeDetector(
                    child: Wrap(
                      spacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/images/icon.png',
                            width: 64,
                            height: 64,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              globalState.packageInfo.version,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                    onEnterDeveloperMode: () {
                      ref
                          .read(appSettingProvider.notifier)
                          .update(
                            (state) => state.copyWith(developerMode: true),
                          );
                      context.showNotifier(
                        appLocalizations.developerModeEnableTip,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                appLocalizations.desc,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      _buildContributorsSection(appLocalizations),
      _buildMoreSection(context),
    ];
    return BaseScaffold(
      title: appLocalizations.about,
      body: MaterialSettingsList(children: items),
    );
  }
}

class Avatar extends StatelessWidget {
  final Contributor contributor;

  const Avatar({super.key, required this.contributor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircleAvatar(
              foregroundImage: AssetImage(contributor.avatar),
            ),
          ),
          const SizedBox(height: 4),
          Text(contributor.name, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.child,
    required this.onEnterDeveloperMode,
  });

  @override
  State<_DeveloperModeDetector> createState() => _DeveloperModeDetectorState();
}

class _DeveloperModeDetectorState extends State<_DeveloperModeDetector> {
  int _counter = 0;
  Timer? _timer;

  void _handleTap() {
    _counter++;
    if (_counter >= 5) {
      widget.onEnterDeveloperMode();
      _resetCounter();
    } else {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 1), _resetCounter);
    }
  }

  void _resetCounter() {
    _counter = 0;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}
