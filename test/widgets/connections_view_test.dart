import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/l10n/l10n.dart';
import 'package:clash_arc/models/models.dart';
import 'package:clash_arc/state.dart';
import 'package:clash_arc/providers/providers.dart';
import 'package:clash_arc/views/connection/connections.dart';
import 'package:clash_arc/views/connection/item.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() {
    container.dispose();
  });

  List<TrackerInfo> buildConnections(int count) {
    return List.generate(
      count,
      (index) => TrackerInfo(
        id: '$index',
        start: DateTime(2024),
        metadata: Metadata(
          network: 'tcp',
          host: 'host-$index.com',
          destinationPort: '443',
        ),
        chains: const ['proxy-a'],
        rule: 'MATCH',
        rulePayload: '',
      ),
    );
  }

  Future<void> pumpConnections(
    WidgetTester tester, {
    required Future<List<TrackerInfo>> Function() connectionsReader,
    bool isPageActive = true,
    Size size = const Size(600, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    container.read(viewSizeProvider.notifier).value = size;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: PageActivityScope(
            isActive: isPageActive,
            child: ConnectionsView(connectionsReader: connectionsReader),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('ConnectionsView lazily builds every connection', (tester) async {
    final connections = buildConnections(100);

    await pumpConnections(tester, connectionsReader: () async => connections);
    await tester.pump();

    final builtItems = find.byType(TrackerInfoItem).evaluate().length;
    expect(builtItems, greaterThan(0));
    expect(builtItems, lessThan(connections.length));
    expect(find.text('tcp://host-0.com:443'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('tcp://host-99.com:443'),
      800,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            widget.axisDirection == AxisDirection.down &&
            widget.controller != null,
      ),
    );

    expect(find.text('tcp://host-99.com:443'), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ConnectionsView shows inline details on desktop', (
    tester,
  ) async {
    final connections = buildConnections(2);

    await pumpConnections(
      tester,
      connectionsReader: () async => connections,
      size: const Size(1200, 800),
    );
    await tester.pump();

    expect(find.byType(TrackerInfoDetailView), findsNothing);

    await tester.tap(find.text('tcp://host-0.com:443'));
    await tester.pump();

    expect(find.byType(TrackerInfoDetailView), findsOneWidget);
    expect(find.text('MATCH'), findsOneWidget);
    expect(find.byType(AdaptiveSheetScaffold), findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ConnectionsView keeps sheet details on mobile', (tester) async {
    final connections = buildConnections(1);

    await pumpConnections(tester, connectionsReader: () async => connections);
    await tester.pump();

    await tester.tap(find.text('tcp://host-0.com:443'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AdaptiveSheetScaffold), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ConnectionsView polls only while the page is active', (
    tester,
  ) async {
    var readCount = 0;

    Future<List<TrackerInfo>> readConnections() async {
      readCount++;
      return const [];
    }

    await pumpConnections(
      tester,
      connectionsReader: readConnections,
      isPageActive: false,
    );
    await tester.pump(const Duration(seconds: 3));

    expect(readCount, 0);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: PageActivityScope(
            isActive: true,
            child: ConnectionsView(connectionsReader: readConnections),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(readCount, 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(readCount, 2);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _TestApp(
          child: PageActivityScope(
            isActive: false,
            child: ConnectionsView(connectionsReader: readConnections),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    expect(readCount, 2);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ConnectionsView stops polling while the app is paused', (
    tester,
  ) async {
    var readCount = 0;

    Future<List<TrackerInfo>> readConnections() async {
      readCount++;
      return const [];
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpConnections(tester, connectionsReader: readConnections);
    await tester.pump();

    expect(readCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 4));

    expect(readCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(readCount, 2);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.measure = Measure.of(context, 1);
        globalState.theme = CommonTheme.of(context, 1);
        return child!;
      },
      home: child,
    );
  }
}
