import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'firebase_options.dart';
import 'app_auth_provider.dart';
import 'queue_provider.dart';

import 'pages/login_page.dart';
import 'pages/admin_page.dart';
import 'pages/cashier_page.dart';
import 'pages/student_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Don't initialize Functions here - let it be created after authentication
  // This ensures the auth context is properly attached

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Campus Queue System",
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFF18171B),
          cardColor: const Color(0xFF26232A),
          canvasColor: const Color(0xFF26232A),
          appBarTheme: const AppBarTheme(
            color: Color(0xFF26232A),
            foregroundColor: Color(0xFFFFFFFF),
            titleTextStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
            elevation: 0,
          ),
          colorScheme: ColorScheme.dark(
            primary: Color(0xFFFFD84A), // custom yellow
            secondary: Color(0xFFFF9800), // orange accent
            error: Color(0xFFBF232A), // your red
            background: Color(0xFF18171B),
            surface: Color(0xFF26232A),
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, color: Color(0xFFFFD84A)),
            headlineLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: Colors.white),
            titleLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: Color(0xFFFFD84A)),
            bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 17, color: Colors.white, fontWeight: FontWeight.w400),
            bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w400),
            bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFFFD84A)),
            labelLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, color: Color(0xFFFFD84A), fontSize: 14),
            labelSmall: TextStyle(fontFamily: 'Inter', color: Color(0xFFBF232A), fontWeight: FontWeight.w400, fontSize: 12),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoginPage();

        final user = snapshot.data!;

        return FutureBuilder(
          future: user.getIdToken(true), // Always fresh
          builder: (context, tokenSnap) {
            if (tokenSnap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .get(),
              builder: (context, roleSnap) {
                if (!roleSnap.hasData) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final data =
                    roleSnap.data!.data() as Map<String, dynamic>? ?? {};
                final role = data["role"] ?? "student";

                if (role == "admin") return const AdminPage();
                if (role == "cashier") return const CashierPage();
                return const StudentPage();
              },
            );
          },
        );
      },
    );
  }
}
