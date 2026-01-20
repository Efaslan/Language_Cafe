import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/update_password_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/floating_cart_button.dart';
import 'widgets/draggable_table_bubble.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
  );

  runApp(
    // UYGULAMAYI ProviderScope İLE SARMALA
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Language Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),

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
  @override
  void initState() {
    super.initState();
    // Auth olaylarını dinle
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      // EĞER ŞİFRE SIFIRLAMA LİNKİYLE GELDİYSE
      if (event == AuthChangeEvent.passwordRecovery) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()),
        );
      }
    });
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