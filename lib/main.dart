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
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1A0A0A), // Dark red-black
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2D1414), // Dark red card
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardColor: const Color(0xFF2D1414), // Dark red card
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD97706), // Dark orange
            secondary: Color(0xFFB45309), // Dark yellow/orange
            error: Color(0xFF991B1B), // Dark red
            surface: Color(0xFF2D1414), // Dark red card
            background: Color(0xFF1A0A0A), // Very dark red-black
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
