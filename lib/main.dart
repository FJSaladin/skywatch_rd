import 'package:flutter/material.dart';
import 'package:skywatch_rd/core/theme/app_theme.dart';

void main() {
  runApp(const SkywatchRD());
}

class SkywatchRD extends StatelessWidget {
  
  const SkywatchRD({super.key});
  @override
  Widget build(BuildContext context) {

    return  MaterialApp(
        title: 'Skywatch RD',
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Text('🌟 SkyWatch', style: TextStyle(fontSize: 32)),
          ),
        ),
    );

  }
}
