import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Penguncian rotasi layar ke Portrait Only sesuai spesifikasi proyek
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi Supabase Backend
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    publishableKey: SupabaseConstants.supabasePublishableKey,
  );

  runApp(const GasHubApp());
}

class GasHubApp extends StatelessWidget {
  const GasHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14432A),
          primary: const Color(0xFF14432A),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14432A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('GasHub Operational System'),
        ),
      ),
    );
  }
}
