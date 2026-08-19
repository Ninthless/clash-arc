import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:clash_arc/models/models.dart';
import 'package:clash_arc/providers/action.dart';
import 'package:clash_arc/providers/state.dart';
import 'package:clash_arc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(vpnStateProvider, (prev, next) {
      if (prev != next) {
        showTip(next);
      }
    });
  }

  void showTip(VpnState state) {
    throttler.call(
      FunctionTag.vpnTip,
      () {
        if (!ref.read(isStartProvider) || state == globalState.lastVpnState) {
          return;
        }
        globalState.showNotifier(
          currentAppLocalizations.vpnConfigChangeDetected,
          actionState: MessageActionState(
            actionText: currentAppLocalizations.restart,
            action: () async {
              final setupAction = ref.read(setupActionProvider.notifier);
              await setupAction.setRunning(false);
              await setupAction.setRunning(true);
            },
          ),
        );
      },
      duration: const Duration(seconds: 6),
      fire: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
