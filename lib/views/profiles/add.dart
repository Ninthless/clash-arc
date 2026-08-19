import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:clash_arc/pages/scan.dart';
import 'package:clash_arc/providers/action.dart';
import 'package:clash_arc/state.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';

import 'subscription_converter.dart';

class AddProfileView extends StatelessWidget {
  final BuildContext context;

  const AddProfileView({super.key, required this.context});

  Future<void> _handleAddProfileFormFile() async {
    globalState.container
        .read(profilesActionProvider.notifier)
        .addProfileFormFile();
  }

  Future<void> _handleAddProfileFormURL(String url) async {
    globalState.container
        .read(profilesActionProvider.notifier)
        .addProfileFormURL(url);
  }

  Future<void> _toScan() async {
    if (system.isDesktop) {
      globalState.container
          .read(profilesActionProvider.notifier)
          .addProfileFormQrCode();
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAddProfileFormURL(url);
      });
    }
  }

  Future<void> _toAdd() async {
    final appLocalizations = context.appLocalizations;
    final url = await globalState.showCommonDialog<String>(
      child: InputDialog(
        autovalidateMode: AutovalidateMode.onUnfocus,
        title: appLocalizations.importFromURL,
        labelText: appLocalizations.url,
        value: '',
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('').trim();
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip('').trim();
          }
          return null;
        },
      ),
    );
    if (url != null) {
      _handleAddProfileFormURL(url);
    }
  }

  Future<void> _toSubscriptionConverter() async {
    final input = await globalState.showCommonDialog<ConvertedProfileInput>(
      child: const SubscriptionConverterDialog(),
    );
    if (input != null) {
      globalState.container
          .read(profilesActionProvider.notifier)
          .addConvertedProfile(input);
    }
  }

  @override
  Widget build(context) {
    final appLocalizations = context.appLocalizations;
    final items = [
      (
        icon: Icons.qr_code_sharp,
        title: appLocalizations.qrcode,
        subtitle: appLocalizations.qrcodeDesc,
        onTap: _toScan,
      ),
      (
        icon: Icons.upload_file_sharp,
        title: appLocalizations.file,
        subtitle: appLocalizations.fileDesc,
        onTap: _handleAddProfileFormFile,
      ),
      (
        icon: Icons.cloud_download_sharp,
        title: appLocalizations.url,
        subtitle: appLocalizations.urlDesc,
        onTap: _toAdd,
      ),
      (
        icon: Icons.tune,
        title: appLocalizations.subscriptionConversion,
        subtitle: appLocalizations.subscriptionConversionDesc,
        onTap: _toSubscriptionConverter,
      ),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        final columns =
            constraints.maxWidth >= ClashArcDesignTokens.mediumBreakpoint
            ? 3
            : constraints.maxWidth >= ClashArcDesignTokens.compactBreakpoint
            ? 2
            : 1;
        return GridView.builder(
          padding: constraints.maxWidth < ClashArcDesignTokens.compactBreakpoint
              ? ClashArcDesignTokens.compactPageInsets
              : ClashArcDesignTokens.pageInsets,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];
            return CommonCard(
              type: CommonCardType.filled,
              radius: ClashArcDesignTokens.largeRadius,
              onPressed: item.onTap,
              child: ListItem(
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
              ),
            );
          },
        );
      },
    );
  }
}

class URLFormDialog extends StatefulWidget {
  const URLFormDialog({super.key});

  @override
  State<URLFormDialog> createState() => _URLFormDialogState();
}

class _URLFormDialogState extends State<URLFormDialog> {
  final _urlController = TextEditingController();

  Future<void> _handleAddProfileFormURL() async {
    final url = _urlController.value.text;
    if (url.isEmpty) return;
    Navigator.of(context).pop<String>(url);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.importFromURL,
      actions: [
        TextButton(
          onPressed: _handleAddProfileFormURL,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: SizedBox(
        width: 300,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextField(
              keyboardType: TextInputType.url,
              minLines: 1,
              maxLines: 5,
              inputFormatters: TextInputLimits.limit(TextInputLimits.url),
              onSubmitted: (_) {
                _handleAddProfileFormURL();
              },
              onEditingComplete: _handleAddProfileFormURL,
              controller: _urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: appLocalizations.url,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
