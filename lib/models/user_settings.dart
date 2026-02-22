class UserSettings {
  String selectedPlanId;
  bool notificationsEnabled;
  bool isPremium;
  int customFastHours;
  int customEatHours;

  UserSettings({
    this.selectedPlanId = '16_8',
    this.notificationsEnabled = true,
    this.isPremium = false,
    this.customFastHours = 16,
    this.customEatHours = 8,
  });

  Map<String, dynamic> toJson() => {
        'selectedPlanId': selectedPlanId,
        'notificationsEnabled': notificationsEnabled,
        'isPremium': isPremium,
        'customFastHours': customFastHours,
        'customEatHours': customEatHours,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        selectedPlanId: json['selectedPlanId'] ?? '16_8',
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        isPremium: json['isPremium'] ?? false,
        customFastHours: json['customFastHours'] ?? 16,
        customEatHours: json['customEatHours'] ?? 8,
      );
}
