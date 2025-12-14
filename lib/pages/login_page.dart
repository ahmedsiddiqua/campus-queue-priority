import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);

    // Dark red, dark yellow, orange color palette
    const accent = Color(0xFFD97706); // Dark orange/amber accent
    const accentRed = Color(0xFF991B1B); // Dark red
    const accentYellow = Color(0xFFB45309); // Dark yellow/orange
    const bg = Color(0xFF1A0A0A); // Very dark red-black background
    const card = Color(0xFF2D1414); // Dark red card

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accentRed.withOpacity(0.3), width: 1),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black54,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Campus Queue",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD84A),
                    fontSize: 30,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                // Subheading
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF9800),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 24),

                // EMAIL
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: const Color(0xFF1F2230),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // PASSWORD
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.orange.shade200),
                    filled: true,
                    fillColor: const Color(0xFF3D1F1F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accentRed.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accentRed.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (loading) const CircularProgressIndicator(),

                if (!loading)
                  Column(
                    children: [
                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: accent, // Dark orange
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                          ),
                          onPressed: () async {
                            setState(() => loading = true);
                            try {
                              await auth.login(
                                emailCtrl.text.trim(),
                                passCtrl.text.trim(),
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                            if (mounted) setState(() => loading = false);
                          },
                          child: const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentYellow, // Dark yellow
                            side: BorderSide(color: accentYellow, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          onPressed: () async {
                            setState(() => loading = true);
                            try {
                              await auth.register(
                                emailCtrl.text.trim(),
                                passCtrl.text.trim(),
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Registered. Now login.")),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                            if (mounted) setState(() => loading = false);
                          },
                          child: const Text("Register"),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // GOOGLE LOGIN
                      TextButton(
                        onPressed: () async {
                          setState(() => loading = true);
                          try {
                            await auth.loginWithGoogle();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                          if (mounted) setState(() => loading = false);
                        },
                        child: const Text("Sign in with Google"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
