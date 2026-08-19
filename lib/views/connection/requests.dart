import 'package:clash_arc/common/common.dart';
import 'package:clash_arc/common/theme.dart';
import 'package:clash_arc/enum/enum.dart';
import 'package:clash_arc/models/models.dart';
import 'package:clash_arc/providers/providers.dart';
import 'package:clash_arc/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'item.dart';

class RequestsView extends ConsumerStatefulWidget {
  const RequestsView({super.key});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView> {
  final _requestsStateNotifier = ValueNotifier<TrackerInfosState>(
    const TrackerInfosState(),
  );
  List<TrackerInfo> _requests = [];
  late final ScrollController _scrollController;
  String? _selectedRequestId;

  void _onSearch(String value) {
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      query: value,
    );
  }

  void _onKeywordsUpdate(List<String> keywords) {
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      keywords: keywords,
    );
  }

  @override
  void initState() {
    super.initState();
    _requests = ref.read(requestsProvider).list;
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
      trackerInfos: _requests,
    );
    ref.listenManual(requestsProvider.select((state) => VM(state.list)), (
      prev,
      next,
    ) {
      _requests = next.a;
      updateRequestsThrottler();
    });
  }

  @override
  void dispose() {
    _requestsStateNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void updateRequestsThrottler() {
    throttler.call(FunctionTag.requests, () {
      if (!mounted) {
        return;
      }
      final isEquality = trackerInfoListEquality.equals(
        _requests,
        _requestsStateNotifier.value.trackerInfos,
      );
      if (isEquality) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _requestsStateNotifier.value = _requestsStateNotifier.value.copyWith(
            trackerInfos: _requests,
          );
        }
      });
    }, duration: commonDuration);
  }

  void _selectRequest(TrackerInfo trackerInfo) {
    setState(() {
      _selectedRequestId = trackerInfo.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonScaffold(
      title: appLocalizations.requests,
      searchState: AppBarSearchState(onSearch: _onSearch),
      onKeywordsUpdate: _onKeywordsUpdate,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _requestsStateNotifier,
        builder: (_, state, _) {
          final autoScrollToEnd = state.autoScrollToEnd;
          return FadeRotationScaleBox(
            child: FloatingActionButton(
              key: ValueKey(autoScrollToEnd),
              onPressed: () {
                _requestsStateNotifier.value = _requestsStateNotifier.value
                    .copyWith(
                      autoScrollToEnd:
                          !_requestsStateNotifier.value.autoScrollToEnd,
                    );
              },
              child: autoScrollToEnd
                  ? const Icon(Icons.block)
                  : const Icon(Icons.vertical_align_top),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<TrackerInfosState>(
        valueListenable: _requestsStateNotifier,
        builder: (context, state, _) {
          final requests = state.list;
          if (requests.isEmpty) {
            return NullStatus(
              label: appLocalizations.nullTip(appLocalizations.requests),
            );
          }
          final viewMode = ref.watch(viewModeProvider);
          final selectedIndex = requests.indexWhere(
            (trackerInfo) => trackerInfo.id == _selectedRequestId,
          );
          final selectedRequest = selectedIndex == -1
              ? null
              : requests[selectedIndex];
          final list = Align(
            alignment: Alignment.topCenter,
            child: CommonScrollBar(
              trackVisibility: false,
              controller: _scrollController,
              child: ScrollToEndBox(
                controller: _scrollController,
                dataSource: requests,
                enable: state.autoScrollToEnd,
                onCancelToEnd: () {
                  _requestsStateNotifier.value = _requestsStateNotifier.value
                      .copyWith(autoScrollToEnd: false);
                },
                child: SuperListView.separated(
                  reverse: true,
                  shrinkWrap: true,
                  physics: const NextClampingScrollPhysics(),
                  controller: _scrollController,
                  itemCount: requests.length,
                  separatorBuilder: (_, _) => viewMode == ViewMode.mobile
                      ? const Divider(height: 0)
                      : const SizedBox(height: 2),
                  itemBuilder: (_, index) {
                    final trackerInfo = requests[index];
                    return TrackerInfoItem(
                      key: Key(trackerInfo.id),
                      trackerInfo: trackerInfo,
                      isSelected: selectedRequest?.id == trackerInfo.id,
                      onSelected: _selectRequest,
                      onClickKeyword: (value) {
                        context.commonScaffoldState?.addKeyword(value);
                      },
                      detailTitle: appLocalizations.details(
                        appLocalizations.request,
                      ),
                    );
                  },
                ),
              ),
            ),
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
                    child: selectedRequest == null
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
                            key: ValueKey(selectedRequest.id),
                            trackerInfo: selectedRequest,
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
