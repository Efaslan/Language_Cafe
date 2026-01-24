import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/update_password_screen.dart';
import 'widgets/floating_cart_button.dart';
import 'widgets/draggable_table_bubble.dart';
import 'constants/app_theme.dart';

import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/shared_prefs_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
  );

  runApp(
    ProviderScope(
      // 2. Hazırladığımız hafızayı Provider'a teslim et (Override)
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Language Cafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Aydınlık Kıyafet
      darkTheme: AppTheme.darkTheme, // Karanlık Kıyafet

      // 3. Modu Belirle (Provider ne derse o)
      themeMode: themeMode,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Bizim oluşturduğumuz çeviriler
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'), // Türkçe
        Locale('en'), // İngilizce
      ],

      // global cart button
      builder: (context, child) {
        return Stack(
          children: [
            // 1. Sayfalar (Navigator - Uygulamanın Kendisi)
            if (child != null) child,

            // 2. Masa Balonu (Sürüklenebilir)
            // Draggable widget'ı çalışmak için bir Overlay'e ihtiyaç duyar.
            // Bu yüzden onu kendi özel Overlay'i içine alıyoruz.
            Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => const Stack(
                    children: [
                      DraggableTableBubble(),
                    ],
                  ),
                ),
              ],
            ),

            // 3. Sepet Butonu (Sabit)
            const FloatingCartButton(),
          ],
        );
      },
      home: const AuthGate(),
    );
  }
}

// checks if the user is logged in or not, and routes the screens accordingly
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Auth olaylarını dinle
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      // EĞER ŞİFRE SIFIRLAMA LİNKİYLE GELDİYSE
      if (event == AuthChangeEvent.passwordRecovery) {
        // DÜZELTME: Async gap kontrolü
        // Widget hala ekranda mı kontrol et
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const UpdatePasswordScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Sayfa kapanırsa dinlemeyi bırak (Memory Leak önlemi)
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        final currentSession = Supabase.instance.client.auth.currentSession;

        if (session != null || currentSession != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}