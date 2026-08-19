import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:clash_arc/providers/app.dart';
import 'package:clash_arc/state.dart';
import 'package:flutter/material.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class ConnectivityManager extends StatefulWidget {
  final Function(List<ConnectivityResult> results)? onConnectivityChanged;
  final Widget child;

  const ConnectivityManager({
    super.key,
    this.onConnectivityChanged,
    required this.child,
  });

  @override
  State<ConnectivityManager> createState() => _ConnectivityManagerState();
}

class _ConnectivityManagerState extends State<ConnectivityManager> {
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.wifi)) {
        WifiSsidManager.instance.getSsid().then((ssid) {
          globalState.container.read(currentSSIDProvider.notifier).value = ssid;
          commonPrint.log('Wi-fi SSID: $ssid ', logLevel: LogLevel.info);
        });
      } else {
        globalState.container.read(currentSSIDProvider.notifier).value = null;
      }
      if (widget.onConnectivityChanged != null) {
        widget.onConnectivityChanged!(results);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
