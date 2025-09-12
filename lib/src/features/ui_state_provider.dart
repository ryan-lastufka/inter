import 'package:flutter_riverpod/flutter_riverpod.dart';

class UiState {
  const UiState({this.isNavPanelVisible = true, this.isDetailPanelVisible = false});
  final bool isNavPanelVisible;
  final bool isDetailPanelVisible;
  UiState copyWith({bool? isNavPanelVisible, bool? isDetailPanelVisible}) {
    return UiState(
      isNavPanelVisible: isNavPanelVisible ?? this.isNavPanelVisible,
      isDetailPanelVisible: isDetailPanelVisible ?? this.isDetailPanelVisible,
    );
  }
}

class UiNotifier extends Notifier<UiState> {
  @override
  UiState build() {
    return const UiState();
  }
  void toggleNavPanel() {
    state = state.copyWith(isNavPanelVisible: !state.isNavPanelVisible);
  }
  void toggleDetailPanel() {
    state = state.copyWith(isDetailPanelVisible: !state.isDetailPanelVisible);
  }
}

final uiStateProvider = NotifierProvider<UiNotifier, UiState>(UiNotifier.new);
