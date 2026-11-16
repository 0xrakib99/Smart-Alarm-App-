import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_alarm/app/theme/app_colors.dart';
import 'package:smart_alarm/core/constants/app_constants.dart';
import 'package:smart_alarm/features/splash/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;

  @override
  void initState() {
    super.initState();

    // Resolving the controller starts the splash navigation timer.
    Get.find<SplashController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _markOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
    );
    _textOffset = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FadeTransition(
                    opacity: _markOpacity,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.alarm_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textOffset,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mission-based alarm',
                            style: TextStyle(
                              color: AppColors.lightTextMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
