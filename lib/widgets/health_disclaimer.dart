import 'package:flutter/material.dart';
import '../app/theme.dart';

class HealthDisclaimer extends StatelessWidget {
  final VoidCallback onAccept;

  const HealthDisclaimer({
    super.key,
    required this.onAccept,
  });

  // ─── Show Modal ─────────────────────────────────────────────
  static void show(BuildContext context, VoidCallback onAccept) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => HealthDisclaimer(onAccept: onAccept),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Title ──────────────────────────────────────────
          Text(
            'Health Disclaimer',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // ─── Body ───────────────────────────────────────────
          Text(
            'This app is for informational and tracking purposes only. '
            'It does not provide medical advice, diagnosis, or treatment. '
            'Always consult a healthcare professional before starting any '
            'fasting regimen. Intermittent fasting may not be suitable for '
            'pregnant or nursing women, people with diabetes, those on '
            'medication, or minors.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),

          // ─── Accept Button ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAccept();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'I Understand',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
