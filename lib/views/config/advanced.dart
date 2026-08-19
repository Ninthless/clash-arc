import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/models/clash_config.dart';
import 'package:clash_arc/providers/config.dart';
import 'package:clash_arc/state.dart';
import 'package:clash_arc/views/config/dns.dart';
import 'package:clash_arc/views/config/material_settings.dart';
import 'package:clash_arc/views/config/network.dart';
import 'package:clash_arc/views/config/on_demand.dart';
import 'package:clash_arc/views/config/scripts.dart';
import 'package:clash_arc/widgets/list.dart';
import 'package:clash_arc/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rules.dart';

class AdvancedConfigView extends StatelessWidget {
  const AdvancedConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final List<Widget> items = [
      ListItem.open(
        title: Text(appLocalizations.network),
        subtitle: Text(appLocalizations.networkDesc),
        leading: const Icon(Icons.vpn_key),
        blur: false,
        widget: BaseScaffold(
          title: appLocalizations.network,
          body: const NetworkListView(),
        ),
      ),
      ListItem.open(
        title: Text(appLocalizations.onDemand),
        subtitle: Text(appLocalizations.onDemandDesc),
        leading: const Icon(Icons.ssid_chart, fontWeight: FontWeight.w900),
        widget: const OnDemandView(),
        blur: false,
      ),
      ListItem.open(
        title: const Text('DNS'),
        subtitle: Text(appLocalizations.dnsDesc),
        leading: const Icon(Icons.dns),
        widget: BaseScaffold(
          title: 'DNS',
          actions: [
            Consumer(
              builder: (_, ref, _) {
                return IconButton(
                  onPressed: () async {
                    final res = await globalState.showMessage(
                      title: appLocalizations.reset,
                      message: TextSpan(text: appLocalizations.resetTip),
                    );
                    if (res != true) {
                      return;
                    }
                    ref
                        .read(patchClashConfigProvider.notifier)
                        .update((state) => state.copyWith(dns: defaultDns));
                  },
                  tooltip: appLocalizations.reset,
                  icon: const Icon(Icons.replay),
                );
              },
            ),
          ],
          body: const DnsListView(),
        ),
        blur: false,
      ),
      ListItem.open(
        title: Text(appLocalizations.addedRules),
        subtitle: Text(appLocalizations.controlGlobalAddedRules),
        leading: const Icon(Icons.library_books),
        widget: const AddedRulesView(),
        blur: false,
      ),
      ListItem.open(
        title: Text(appLocalizations.script),
        subtitle: Text(appLocalizations.overrideScript),
        leading: const Icon(Icons.rocket, fontWeight: FontWeight.w900),
        widget: const ScriptsView(),
        blur: false,
      ),
    ];
    return BaseScaffold(
      title: appLocalizations.advancedConfig,
      body: MaterialSettingsList(
        children: [MaterialSettingsSection(children: items)],
      ),
    );
  }
}
