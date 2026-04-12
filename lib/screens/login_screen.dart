import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../utils/custom_toast.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090b10),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Animate(
            effects: [
              FadeEffect(duration: 1000.ms),
              SlideEffect(
                begin: const Offset(0, -0.2),
                duration: 1000.ms,
                curve: Curves.easeOutBack,
              ),
            ],
            child: Column(
              children: [
                Text(
                  'Kernel',
                  style: ShadTheme.of(context).textTheme.h1.copyWith(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Manage Everything',
                  style: ShadTheme.of(context).textTheme.small.copyWith(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),
          Animate(
            effects: [
              FadeEffect(delay: 300.ms, duration: 1000.ms),
              SlideEffect(
                begin: const Offset(0, 0.2),
                delay: 300.ms,
                duration: 1000.ms,
                curve: Curves.easeOutBack,
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ShadButton(
                  onPressed: () async {
                    try {
                      await context.read<AuthService>().signInWithGoogle();
                    } catch (e) {
                      if (!context.mounted) return;
                      showCustomToast(
                        context,
                        'Sign In Failed',
                        e.toString(),
                        CustomToastType.error,
                      );
                    }
                  },
                  backgroundColor: Colors.grey[900],
                  hoverBackgroundColor: Colors.grey[800],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.public, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Sign in with Google',
                        style: ShadTheme.of(
                          context,
                        ).textTheme.large.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
