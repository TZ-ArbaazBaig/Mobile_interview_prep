import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Background solid dark obsidian
          Container(
            color: AppColors.obsidianBg,
          ),
          // Top right subtle purple glow
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.violetPrimary.withOpacity(0.12),
                    AppColors.violetPrimary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom left subtle purple glow
          Positioned(
            bottom: -200,
            left: -150,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.violetSecondary.withOpacity(0.08),
                    AppColors.violetSecondary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Scaffold content
          SafeArea(
            child: body,
          ),
        ],
      ),
    );
  }
}
