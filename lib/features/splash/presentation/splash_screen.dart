import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

/// Minimalist, premium splash screen with vertical forest green-to-white gradient.
/// Features a centered horizontal logo mark with semibold 'GasHub' typography.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Auto navigate to home after 2.5 seconds
    _navTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.50, 0.78, 1.0],
              colors: [
                Color(0xFF0A2B19), // Deep Pine Green at top
                Color(0xFF14432A), // Rich Brand Forest Green across the center
                Color(0xFF5CAE7E), // Smooth mint transition below center
                Colors.white,      // Pure White at bottom
              ],
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Pure White Logo Icon (Instant Render)
                  Icon(
                    Icons.propane_tank,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(width: AppDimensions.space12),

                  // 2. Pure White Semibold Brand Name
                  Text(
                    'GasHub',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: Colors.white,
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
