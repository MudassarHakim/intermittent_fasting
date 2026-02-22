import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../services/storage_service.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(StorageService.getSettings());

  void updatePlan(String planId) {
    state = UserSettings(
      selectedPlanId: planId,
      notificationsEnabled: state.notificationsEnabled,
      isPremium: state.isPremium,
      customFastHours: state.customFastHours,
      customEatHours: state.customEatHours,
    );
    StorageService.saveSettings(state);
  }

  void toggleNotifications() {
    state = UserSettings(
      selectedPlanId: state.selectedPlanId,
      notificationsEnabled: !state.notificationsEnabled,
      isPremium: state.isPremium,
      customFastHours: state.customFastHours,
      customEatHours: state.customEatHours,
    );
    StorageService.saveSettings(state);
  }

  void setCustomHours(int fastHours, int eatHours) {
    state = UserSettings(
      selectedPlanId: state.selectedPlanId,
      notificationsEnabled: state.notificationsEnabled,
      isPremium: state.isPremium,
      customFastHours: fastHours,
      customEatHours: eatHours,
    );
    StorageService.saveSettings(state);
  }

  void setPremium(bool premium) {
    state = UserSettings(
      selectedPlanId: state.selectedPlanId,
      notificationsEnabled: state.notificationsEnabled,
      isPremium: premium,
      customFastHours: state.customFastHours,
      customEatHours: state.customEatHours,
    );
    StorageService.saveSettings(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});
