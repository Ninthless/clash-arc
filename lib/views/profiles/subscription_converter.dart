import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SubscriptionConverterDialog extends StatefulWidget {
  const SubscriptionConverterDialog({super.key});

  @override
  State<SubscriptionConverterDialog> createState() =>
      _SubscriptionConverterDialogState();
}

class _SubscriptionConverterDialogState
    extends State<SubscriptionConverterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _backendController = TextEditingController(
    text: defaultSubscriptionConverterBackend,
  );
  final _labelController = TextEditingController();
  final _subscriptionController = TextEditingController();
  final _includeController = TextEditingController();
  final _excludeController = TextEditingController();
  AethersailorTemplate _template = AethersailorTemplate.standard;
  bool _emoji = true;
  bool _udp = true;

  List<String> get _subscriptionUrls => _subscriptionController.text
      .split(RegExp(r'[\r\n]+'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();

  bool _isHttpsUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  String _templateLabel(BuildContext context, AethersailorTemplate template) {
    final appLocalizations = context.appLocalizations;
    return switch (template) {
      AethersailorTemplate.standard =>
        appLocalizations.subscriptionTemplateStandard,
      AethersailorTemplate.standardFallback =>
        appLocalizations.subscriptionTemplateStandardFallback,
      AethersailorTemplate.lite => appLocalizations.subscriptionTemplateLite,
      AethersailorTemplate.liteFallback =>
        appLocalizations.subscriptionTemplateLiteFallback,
      AethersailorTemplate.gfw => appLocalizations.subscriptionTemplateGfw,
      AethersailorTemplate.gfwFallback =>
        appLocalizations.subscriptionTemplateGfwFallback,
      AethersailorTemplate.full => appLocalizations.subscriptionTemplateFull,
      AethersailorTemplate.fullFallback =>
        appLocalizations.subscriptionTemplateFullFallback,
    };
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final request = SubscriptionConversionRequest(
      backend: _backendController.text,
      subscriptionUrls: _subscriptionUrls,
      template: _template,
      include: _includeController.text,
      exclude: _excludeController.text,
      emoji: _emoji,
      udp: _udp,
    );
    Navigator.of(context).pop(
      ConvertedProfileInput(
        url: request.buildUrl(),
        label: _labelController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _backendController.dispose();
    _labelController.dispose();
    _subscriptionController.dispose();
    _includeController.dispose();
    _excludeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.subscriptionConversion,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(appLocalizations.convertAndImport),
        ),
      ],
      child: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: context.colorScheme.errorContainer,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: context.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appLocalizations.subscriptionConversionPrivacy,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.name,
                    hintText: appLocalizations.subscriptionNameHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _backendController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: appLocalizations.subscriptionConverterBackend,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !_isHttpsUrl(value)) {
                      return appLocalizations.httpsUrlRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subscriptionController,
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: appLocalizations.subscriptionUrls,
                    helperText: appLocalizations.subscriptionUrlsDesc,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (_) {
                    final urls = _subscriptionUrls;
                    if (urls.isEmpty) {
                      return appLocalizations.profileUrlNullValidationDesc;
                    }
                    if (urls.any((url) => !_isHttpsUrl(url))) {
                      return appLocalizations.httpsUrlRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AethersailorTemplate>(
                  initialValue: _template,
                  decoration: InputDecoration(
                    labelText: appLocalizations.subscriptionTemplate,
                    border: const OutlineInputBorder(),
                  ),
                  items: AethersailorTemplate.values
                      .map(
                        (template) => DropdownMenuItem(
                          value: template,
                          child: Text(_templateLabel(context, template)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _template = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _includeController,
                        decoration: InputDecoration(
                          labelText: appLocalizations.includeNodes,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _excludeController,
                        decoration: InputDecoration(
                          labelText: appLocalizations.excludeNodes,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(appLocalizations.addEmoji),
                  value: _emoji,
                  onChanged: (value) => setState(() => _emoji = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(appLocalizations.enableUdp),
                  value: _udp,
                  onChanged: (value) => setState(() => _udp = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
