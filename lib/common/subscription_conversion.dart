import 'package:clash_arc/models/models.dart';

const defaultSubscriptionConverterBackend = 'https://api.asailor.org/sub';
const _aethersailorTemplateRevision =
    'a92af72e6df9566171956c97f032e604b1440d41';
const _aethersailorTemplateBase =
    'https://raw.githubusercontent.com/Aethersailor/'
    'Custom_OpenClash_Rules/$_aethersailorTemplateRevision/cfg';

enum AethersailorTemplate {
  standard('Custom_Clash.ini'),
  standardFallback('Custom_Clash_Fallback.ini'),
  lite('Custom_Clash_Lite.ini'),
  liteFallback('Custom_Clash_Lite_Fallback.ini'),
  gfw('Custom_Clash_GFW.ini'),
  gfwFallback('Custom_Clash_GFW_Fallback.ini'),
  full('Custom_Clash_Full.ini'),
  fullFallback('Custom_Clash_Full_Fallback.ini');

  final String fileName;

  const AethersailorTemplate(this.fileName);

  String get url => '$_aethersailorTemplateBase/$fileName';
}

class SubscriptionConversionRequest {
  final String backend;
  final List<String> subscriptionUrls;
  final AethersailorTemplate template;
  final String include;
  final String exclude;
  final bool emoji;
  final bool udp;

  const SubscriptionConversionRequest({
    required this.backend,
    required this.subscriptionUrls,
    required this.template,
    this.include = '',
    this.exclude = '',
    this.emoji = true,
    this.udp = true,
  });

  String buildUrl() {
    final backendUri = Uri.parse(backend.trim());
    final parameters = <String, String>{
      ...backendUri.queryParameters,
      'target': 'clash',
      'url': subscriptionUrls.map((url) => url.trim()).join('|'),
      'config': template.url,
      'emoji': emoji.toString(),
      'udp': udp.toString(),
      if (include.trim().isNotEmpty) 'include': include.trim(),
      if (exclude.trim().isNotEmpty) 'exclude': exclude.trim(),
    };
    return backendUri.replace(queryParameters: parameters).toString();
  }
}

class ConvertedProfileInput {
  final String url;
  final String label;

  const ConvertedProfileInput({required this.url, required this.label});
}

List<String> getSubscriptionSourceUrls(String profileUrl) {
  final uri = Uri.tryParse(profileUrl);
  final source = uri?.queryParameters['url'];
  final config = uri?.queryParameters['config'];
  if (source == null ||
      config == null ||
      !config.contains('/Aethersailor/Custom_OpenClash_Rules/')) {
    return const [];
  }
  return source.split('|').map((url) => url.trim()).where((url) {
    final sourceUri = Uri.tryParse(url);
    return sourceUri != null &&
        sourceUri.scheme == 'https' &&
        sourceUri.host.isNotEmpty;
  }).toList();
}

SubscriptionInfo? mergeSubscriptionInfo(Iterable<SubscriptionInfo?> values) {
  final infos = values.whereType<SubscriptionInfo>().where(
    (info) =>
        info.upload > 0 ||
        info.download > 0 ||
        info.total > 0 ||
        info.expire > 0,
  );
  if (infos.isEmpty) {
    return null;
  }
  var upload = 0;
  var download = 0;
  var total = 0;
  int? expire;
  for (final info in infos) {
    upload += info.upload;
    download += info.download;
    total += info.total;
    if (info.expire > 0 && (expire == null || info.expire < expire)) {
      expire = info.expire;
    }
  }
  return SubscriptionInfo(
    upload: upload,
    download: download,
    total: total,
    expire: expire ?? 0,
  );
}
