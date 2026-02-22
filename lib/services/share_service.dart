import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../app/theme.dart';
import '../models/fasting_session.dart';
import '../widgets/fasting_share_card.dart';

class ShareService {
  static final ScreenshotController _screenshotController = ScreenshotController();

  /// Capture the FastingShareCard widget and share via native share sheet
  static Future<void> shareCompletionCard({
    required BuildContext context,
    required FastingSession session,
    required int streak,
  }) async {
    try {
      final widget = MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(
            child: FastingShareCard(session: session, streak: streak),
          ),
        ),
      );

      final image = await _screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fasting_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Just completed my ${session.planName} fast! 🎉💪 #IntermittentFasting #FastingTimer',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
