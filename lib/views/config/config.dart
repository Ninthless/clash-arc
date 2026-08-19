import 'package:clash_arc/common/context.dart';
import 'package:clash_arc/views/config/general.dart';
import 'package:clash_arc/views/config/material_settings.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: context.appLocalizations.basicConfig,
      body: MaterialSettingsList(
        children: [MaterialSettingsSection(children: generalItems)],
      ),
    );
  }
}
