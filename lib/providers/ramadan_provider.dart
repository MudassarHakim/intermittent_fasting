import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ramadan_service.dart';

class RamadanState {
  final RamadanTimes? times;
  final bool isLoading;
  final String? error;
  final bool hasLocationPermission;

  const RamadanState({
    this.times,
    this.isLoading = false,
    this.error,
    this.hasLocationPermission = false,
  });

  RamadanState copyWith({
    RamadanTimes? times,
    bool? isLoading,
    String? error,
    bool? hasLocationPermission,
  }) {
    return RamadanState(
      times: times ?? this.times,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}

class RamadanNotifier extends StateNotifier<RamadanState> {
  RamadanNotifier() : super(const RamadanState());

  Future<void> loadTimes() async {
    state = state.copyWith(isLoading: true, error: null);

    final hasPermission = await RamadanService.checkLocationPermission();
    if (!hasPermission) {
      state = state.copyWith(
        isLoading: false,
        hasLocationPermission: false,
        error: 'Location permission required for Ramadan mode',
      );
      return;
    }

    final times = await RamadanService.getTodayTimes();
    if (times == null) {
      state = state.copyWith(
        isLoading: false,
        hasLocationPermission: true,
        error: 'Could not determine prayer times',
      );
      return;
    }

    state = state.copyWith(
      times: times,
      isLoading: false,
      hasLocationPermission: true,
    );
  }

  void clear() {
    state = const RamadanState();
  }
}

final ramadanProvider =
    StateNotifierProvider<RamadanNotifier, RamadanState>((ref) {
  return RamadanNotifier();
});
