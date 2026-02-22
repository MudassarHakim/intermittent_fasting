import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../services/storage_service.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(StorageService.getSettings());

  UserSettings _copyWith({
    String? selectedPlanId,
    bool? notificationsEnabled,
    bool? isPremium,
    int? customFastHours,
    int? customEatHours,
    bool? hasAcceptedDisclaimer,
    bool? ramadanModeEnabled,
    String? fastingGoal,
    bool? showMetabolicPhases,
    bool? milestoneNotifications,
  }) {
    return UserSettings(
      selectedPlanId: selectedPlanId ?? state.selectedPlanId,
      notificationsEnabled: notificationsEnabled ?? state.notificationsEnabled,
      isPremium: isPremium ?? state.isPremium,
      customFastHours: customFastHours ?? state.customFastHours,
      customEatHours: customEatHours ?? state.customEatHours,
      hasAcceptedDisclaimer:
          hasAcceptedDisclaimer ?? state.hasAcceptedDisclaimer,
      ramadanModeEnabled: ramadanModeEnabled ?? state.ramadanModeEnabled,
      fastingGoal: fastingGoal ?? state.fastingGoal,
      showMetabolicPhases: showMetabolicPhases ?? state.showMetabolicPhases,
      milestoneNotifications:
          milestoneNotifications ?? state.milestoneNotifications,
    );
  }

  void _save(UserSettings s) {
    state = s;
    StorageService.saveSettings(s);
  }

  void updatePlan(String planId) =>
      _save(_copyWith(selectedPlanId: planId));

  void toggleNotifications() =>
      _save(_copyWith(notificationsEnabled: !state.notificationsEnabled));

  void setCustomHours(int fastHours, int eatHours) =>
      _save(_copyWith(customFastHours: fastHours, customEatHours: eatHours));

  void setPremium(bool premium) =>
      _save(_copyWith(isPremium: premium));

  void acceptDisclaimer() =>
      _save(_copyWith(hasAcceptedDisclaimer: true));

  void toggleRamadanMode() =>
      _save(_copyWith(ramadanModeEnabled: !state.ramadanModeEnabled));

  void setFastingGoal(String goal) =>
      _save(_copyWith(fastingGoal: goal));

  void toggleMetabolicPhases() =>
      _save(_copyWith(showMetabolicPhases: !state.showMetabolicPhases));

  void toggleMilestoneNotifications() =>
      _save(_copyWith(milestoneNotifications: !state.milestoneNotifications));
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});
