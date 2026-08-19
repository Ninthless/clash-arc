import 'package:clash_arc/common/subscription_conversion.dart';
import 'package:clash_arc/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a converter URL with encoded subscriptions and template', () {
    const request = SubscriptionConversionRequest(
      backend: 'https://converter.example/sub?token=backend-token',
      subscriptionUrls: [
        'https://one.example/sub?token=one',
        'https://two.example/sub?token=two',
      ],
      template: AethersailorTemplate.liteFallback,
      include: '香港|日本',
      exclude: '过期|剩余',
      emoji: false,
      udp: true,
    );

    final uri = Uri.parse(request.buildUrl());

    expect(uri.scheme, 'https');
    expect(uri.host, 'converter.example');
    expect(uri.path, '/sub');
    expect(uri.queryParameters['token'], 'backend-token');
    expect(uri.queryParameters['target'], 'clash');
    expect(
      uri.queryParameters['url'],
      'https://one.example/sub?token=one|'
      'https://two.example/sub?token=two',
    );
    expect(
      uri.queryParameters['config'],
      AethersailorTemplate.liteFallback.url,
    );
    expect(
      uri.queryParameters['config'],
      contains('a92af72e6df9566171956c97f032e604b1440d41'),
    );
    expect(uri.queryParameters['include'], '香港|日本');
    expect(uri.queryParameters['exclude'], '过期|剩余');
    expect(uri.queryParameters['emoji'], 'false');
    expect(uri.queryParameters['udp'], 'true');
  });

  test('omits empty optional filters', () {
    const request = SubscriptionConversionRequest(
      backend: defaultSubscriptionConverterBackend,
      subscriptionUrls: ['https://example.com/sub'],
      template: AethersailorTemplate.standard,
    );

    final parameters = Uri.parse(request.buildUrl()).queryParameters;

    expect(parameters, isNot(contains('include')));
    expect(parameters, isNot(contains('exclude')));
  });

  test('extracts source URLs only from built-in conversion profiles', () {
    const request = SubscriptionConversionRequest(
      backend: defaultSubscriptionConverterBackend,
      subscriptionUrls: ['https://one.example/sub', 'https://two.example/sub'],
      template: AethersailorTemplate.standard,
    );

    expect(getSubscriptionSourceUrls(request.buildUrl()), [
      'https://one.example/sub',
      'https://two.example/sub',
    ]);
    expect(
      getSubscriptionSourceUrls('https://example.com/profile.yaml'),
      isEmpty,
    );
  });

  test('merges traffic and uses the earliest expiration', () {
    final merged = mergeSubscriptionInfo([
      const SubscriptionInfo(upload: 10, download: 20, total: 100, expire: 300),
      const SubscriptionInfo(upload: 30, download: 40, total: 200, expire: 200),
    ]);

    expect(merged?.upload, 40);
    expect(merged?.download, 60);
    expect(merged?.total, 300);
    expect(merged?.expire, 200);
  });
}
