class UserSettings {
  String selectedPlanId;
  bool notificationsEnabled;
  bool isPremium;
  int customFastHours;
  int customEatHours;
  bool hasAcceptedDisclaimer;
  bool ramadanModeEnabled;
  String fastingGoal; // 'fat_loss', 'metabolic_health', 'autophagy'
  bool showMetabolicPhases;
  bool milestoneNotifications;

  UserSettings({
    this.selectedPlanId = '16_8',
    this.notificationsEnabled = true,
    this.isPremium = false,
    this.customFastHours = 16,
    this.customEatHours = 8,
    this.hasAcceptedDisclaimer = false,
    this.ramadanModeEnabled = false,
    this.fastingGoal = 'metabolic_health',
    this.showMetabolicPhases = true,
    this.milestoneNotifications = true,
  });

  Map<String, dynamic> toJson() => {
        'selectedPlanId': selectedPlanId,
        'notificationsEnabled': notificationsEnabled,
        'isPremium': isPremium,
        'customFastHours': customFastHours,
        'customEatHours': customEatHours,
        'hasAcceptedDisclaimer': hasAcceptedDisclaimer,
        'ramadanModeEnabled': ramadanModeEnabled,
        'fastingGoal': fastingGoal,
        'showMetabolicPhases': showMetabolicPhases,
        'milestoneNotifications': milestoneNotifications,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        selectedPlanId: json['selectedPlanId'] ?? '16_8',
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        isPremium: json['isPremium'] ?? false,
        customFastHours: json['customFastHours'] ?? 16,
        customEatHours: json['customEatHours'] ?? 8,
        hasAcceptedDisclaimer: json['hasAcceptedDisclaimer'] ?? false,
        ramadanModeEnabled: json['ramadanModeEnabled'] ?? false,
        fastingGoal: json['fastingGoal'] ?? 'metabolic_health',
        showMetabolicPhases: json['showMetabolicPhases'] ?? true,
        milestoneNotifications: json['milestoneNotifications'] ?? true,
      );
}
