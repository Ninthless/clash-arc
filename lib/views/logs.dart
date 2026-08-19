import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:clash_arc/models/models.dart';
import 'package:clash_arc/providers/providers.dart';
import 'package:clash_arc/state.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView> {
  final _logsStateNotifier = ValueNotifier<LogsState>(const LogsState());
  late ScrollController _scrollController;

  List<Log> _logs = [];

  @override
  void initState() {
    super.initState();
    _logs = ref.read(logsProvider).list;
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(logs: _logs);
    ref.listenManual(logsProvider.select((state) => VM(state.list)), (
      prev,
      next,
    ) {
      if (prev != next) {
        final isEquality = logListEquality.equals(prev?.a, next.a);
        if (!isEquality) {
          _logs = next.a;
          updateLogsThrottler();
        }
      }
    });
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        onPressed: () {
          _handleExport();
        },
        icon: const Icon(Icons.save_as_outlined),
      ),
    ];
  }

  void _onSearch(String value) {
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(query: value);
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  void dispose() {
    _logsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      return globalState.container.read(logsProvider.notifier).exportLogs();
    }, title: appLocalizations.exportLogs);
    if (res != true) return;
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.exportSuccess),
    );
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
      final isEquality = logListEquality.equals(
        _logs,
        _logsStateNotifier.value.logs,
      );
      if (isEquality) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
            logs: _logs,
          );
        }
      });
    }, duration: commonDuration);
  }

  Widget _buildLevelFilter(
    BuildContext context,
    LogLevel level,
    int count,
    bool selected,
  ) {
    return FilterChip(
      selected: selected,
      onSelected: (_) {
        if (!selected) {
          context.commonScaffoldState?.addKeyword(level.name);
        }
      },
      avatar: Icon(
        switch (level) {
          LogLevel.debug => Icons.bug_report_outlined,
          LogLevel.info => Icons.info_outline,
          LogLevel.warning => Icons.warning_amber_outlined,
          LogLevel.error => Icons.error_outline,
          LogLevel.silent => Icons.visibility_off_outlined,
        },
        color: selected
            ? context.colorScheme.onSecondaryContainer
            : level.color(context),
      ),
      label: Text('${level.name}  $count'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      actions: _buildActions(),
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      title: appLocalizations.logs,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _logsStateNotifier,
        builder: (_, state, _) {
          final autoScrollToEnd = state.autoScrollToEnd;
          return FadeRotationScaleBox(
            child: FloatingActionButton(
              key: ValueKey(autoScrollToEnd),
              onPressed: () {
                _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
                  autoScrollToEnd: !_logsStateNotifier.value.autoScrollToEnd,
                );
              },
              child: autoScrollToEnd
                  ? const Icon(Icons.block)
                  : const Icon(Icons.vertical_align_top),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<LogsState>(
        valueListenable: _logsStateNotifier,
        builder: (context, state, _) {
          final logs = state.list;
          if (logs.isEmpty) {
            return NullStatus(
              illustration: const LogEmptyIllustration(),
              label: appLocalizations.nullTip(appLocalizations.logs),
            );
          }
          final viewMode = ref.watch(viewModeProvider);
          final items = logs
              .map<Widget>(
                (log) => LogItem(
                  key: Key(log.dateTime),
                  log: log,
                  desktop: viewMode != ViewMode.mobile,
                  onClick: (value) {
                    context.commonScaffoldState?.addKeyword(value);
                  },
                ),
              )
              .separated(const Divider(height: 0))
              .toList();
          final list = Align(
            alignment: Alignment.topCenter,
            child: ScrollToEndBox(
              onCancelToEnd: () {
                _logsStateNotifier.value = _logsStateNotifier.value.copyWith(
                  autoScrollToEnd: false,
                );
              },
              controller: _scrollController,
              enable: state.autoScrollToEnd,
              dataSource: logs,
              child: CommonScrollBar(
                controller: _scrollController,
                child: SuperListView.builder(
                  physics: const NextClampingScrollPhysics(),
                  reverse: true,
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemBuilder: (_, index) {
                    return items[index];
                  },
                  itemCount: items.length,
                ),
              ),
            ),
          );
          if (viewMode == ViewMode.mobile) {
            return list;
          }
          final counts = <LogLevel, int>{
            for (final level in LogLevel.values)
              level: _logs.where((log) => log.logLevel == level).length,
          };
          return Padding(
            padding: ClashArcDesignTokens.pageInsets,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipPath.shape(
                    shape: ClashArcDesignTokens.largeShape,
                    child: Material(
                      color: context.colorScheme.surfaceContainerLow,
                      child: list,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 240,
                  child: Material(
                    color: context.colorScheme.surfaceContainerLow,
                    shape: ClashArcDesignTokens.largeShape,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            appLocalizations.logs,
                            style: context.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          for (final level in LogLevel.values) ...[
                            _buildLevelFilter(
                              context,
                              level,
                              counts[level] ?? 0,
                              state.keywords.contains(level.name),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;
  final Function(String)? onClick;
  final bool desktop;

  const LogItem({
    super.key,
    required this.log,
    this.onClick,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final item = ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {},
      title: SelectableText(
        log.payload,
        style: context.textTheme.bodyLarge?.copyWith(
          color: log.logLevel.color(context),
        ),
      ),
      subtitle: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonChip(
                onPressed: () {
                  if (onClick == null) return;
                  onClick!(log.logLevel.name);
                },
                label: log.logLevel.name,
              ),
              Text(
                log.dateTime,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.opacity80,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (!desktop) {
      return item;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: context.colorScheme.surfaceContainer,
        shape: ClashArcDesignTokens.mediumShape,
        child: item,
      ),
    );
  }
}
