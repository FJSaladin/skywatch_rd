import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SkyEmptyState extends StatelessWidget {
  const SkyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.nights_stay_outlined,
              size: 80, color: AppTheme.cosmicGrey.withValues(alpha:0.5)),
          const SizedBox(height: 16),
          const Text(
            'El cielo está vacío...',
            style: TextStyle(
              color:    AppTheme.cosmicGrey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca ✦ para registrar tu primera observación',
            style: TextStyle(color: AppTheme.cosmicGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}