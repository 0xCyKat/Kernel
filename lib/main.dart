import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'services/finance_service.dart';
import 'services/gym_service.dart';
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
        inputTheme: ShadInputTheme(
          decoration: ShadDecoration(
            border: ShadBorder.all(
              color: const Color(0x1AFFFFFF),
              width: 1,
              radius: BorderRadius.circular(12),
            ),
            focusedBorder: ShadBorder.all(
              color: const Color(0xFFFAFAFA),
              width: 1,
              radius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      materialThemeBuilder: (context, theme) {
        return theme.copyWith(
          scaffoldBackgroundColor: const Color(0xFF09090B), // Deep Zinc 950
          cardColor: const Color(0xFF121214), // Subtle elevation
          tabBarTheme: TabBarThemeData(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: const Color(0xFFFAFAFA),
            unselectedLabelColor: const Color(0xFFA1A1AA),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            indicator: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          colorScheme: theme.colorScheme.copyWith(
            primary: const Color(0xFFFAFAFA),
            error: const Color(0xFFE11D48), // Refined rose/crimson
            surface: const Color(0xFF121214),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF09090B),
            elevation: 0,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color(0xFF09090B),
            indicatorColor: Color(0xFF27272A), // Zinc 800
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF09090B),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xEE121214), // Glassy dark
            contentTextStyle: TextStyle(
              color: Color(0xFFFAFAFA),
              fontWeight: FontWeight.w500,
            ),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              side: BorderSide(color: Color(0x1AFFFFFF), width: 1),
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF121214),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
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
