import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'services/finance_service.dart';
import 'services/gym_service.dart';
import 'services/habits_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FinanceService()),
        ChangeNotifierProvider(create: (_) => GymService()),
        ChangeNotifierProvider(create: (_) => HabitsService()),
      ],
      child: const KernelApp(),
    ),
  );
}

class KernelApp extends StatelessWidget {
  const KernelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Kernel',
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return ShadToaster(child: child ?? const SizedBox.shrink());
      },
      darkTheme: ShadThemeData(
        colorScheme: const ShadZincColorScheme.dark(),
        brightness: Brightness.dark,
      ),
      materialThemeBuilder: (context, theme) {
        return theme.copyWith(
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xCC111111), // glassy dark
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              side: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
        );
      },
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isLoggedIn) {
            return const MainLayout();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
