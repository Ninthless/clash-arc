import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/core/controller.dart';
import 'package:clash_arc/core/method.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:clash_arc/models/models.dart';
import 'package:clash_arc/providers/app.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'item.dart';

class ConnectionsView extends ConsumerStatefulWidget {
  final Future<List<TrackerInfo>> Function()? connectionsReader;

  const ConnectionsView({super.key, @visibleForTesting this.connectionsReader});

  @override
  ConsumerState<ConnectionsView> createState() => _ConnectionsViewState();
}

class _ConnectionsViewState extends ConsumerState<ConnectionsView>
    with WidgetsBindingObserver, ActivePollingMixin<ConnectionsView> {
  final _connectionsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  final ScrollController _scrollController = ScrollController();
  TrackerInfo? _selectedConnection;

  @override
  Duration get pollInterval => const Duration(seconds: 1);

  List<Widget> _buildActions() {
    return [
      IconButton(
        onPressed: () async {
          coreController.closeConnections();
          await _refreshConnections();
        },
        icon: const Icon(Icons.delete_sweep_outlined),
      ),
    ];
  }

  void _onSearch(String value) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      query: value,
    );
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !isCurrent()) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<void> _refreshConnections() async {
    final trackerInfos = await _readConnections();
    if (trackerInfos == null || !mounted) {
      return;
    }
    _applyConnections(trackerInfos);
  }

  Future<List<TrackerInfo>?> _readConnections() async {
    try {
      final connectionsReader = widget.connectionsReader;
      return connectionsReader != null
          ? await connectionsReader()
          : await coreController.getConnections();
    } catch (error) {
      commonPrint.log(
        'updateConnections error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  void _applyConnections(List<TrackerInfo> trackerInfos) {
    _connectionsStateNotifier.value = _connectionsStateNotifier.value.copyWith(
      trackerInfos: trackerInfos,
    );
    final selectedConnection = _selectedConnection;
    if (selectedConnection == null) {
      return;
    }
    final selectedIndex = trackerInfos.indexWhere(
      (trackerInfo) => trackerInfo.id == selectedConnection.id,
    );
    setState(() {
      _selectedConnection = selectedIndex == -1
          ? null
          : trackerInfos[selectedIndex];
    });
  }

  Future<void> _handleBlockConnection(String id) async {
    await coreController.closeConnection(id);
    await _refreshConnections();
  }

  void _selectConnection(TrackerInfo trackerInfo) {
    setState(() {
      _selectedConnection = trackerInfo;
    });
  }

  @override
  void dispose() {
    _connectionsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.connections,
      onKeywordsUpdate: _onKeywordsUpdate,
      searchState: AppBarSearchState(onSearch: _onSearch),
      actions: _buildActions(),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _connectionsStateNotifier,
        builder: (context, state, _) {
          final connections = state.list;
          if (connections.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.connections),
              illustration: const ConnectionEmptyIllustration(),
            );
          }
          final viewMode = ref.watch(viewModeProvider);
          final list = SuperListView.separated(
            controller: _scrollController,
            itemCount: connections.length,
            separatorBuilder: (_, _) => viewMode == ViewMode.mobile
                ? const Divider(height: 0)
                : const SizedBox(height: 2),
            itemBuilder: (_, index) {
              final trackerInfo = connections[index];
              return TrackerInfoItem(
                key: Key(trackerInfo.id),
                trackerInfo: trackerInfo,
                isSelected: _selectedConnection?.id == trackerInfo.id,
                onSelected: _selectConnection,
                onClickKeyword: (value) {
                  context.commonScaffoldState?.addKeyword(value);
                },
                trailing: IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: appLocalizations.delete,
                  icon: const Icon(Icons.block),
                  onPressed: () {
                    _handleBlockConnection(trackerInfo.id);
                  },
                ),
                detailTitle: appLocalizations.details(
                  appLocalizations.connection,
                ),
              );
            },
          );
          if (viewMode == ViewMode.mobile) {
            return list;
          }
          return Padding(
            padding: ClashArcDesignTokens.pageInsets,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: list),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: ClipPath.shape(
                    shape: ClashArcDesignTokens.largeShape,
                    child: _selectedConnection == null
                        ? Material(
                            color: context.colorScheme.surfaceContainerLow,
                            child: Center(
                              child: Icon(
                                Icons.touch_app_outlined,
                                size: 48,
                                color: context
                                    .colorScheme
                                    .onSurfaceVariant
                                    .opacity60,
                              ),
                            ),
                          )
                        : TrackerInfoDetailView(
                            key: ValueKey(_selectedConnection!.id),
                            trackerInfo: _selectedConnection!,
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
