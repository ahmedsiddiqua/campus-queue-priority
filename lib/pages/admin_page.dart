import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_auth_provider.dart';
import '../queue_provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final nameCtrl = TextEditingController();
  final cashierCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final qp = Provider.of<QueueProvider>(context);
    final auth = Provider.of<AppAuthProvider>(context, listen: false);
    // Dark red, dark yellow, orange color palette
    const bg = Color(0xFF1A0A0A); // Very dark red-black background
    const card = Color(0xFF2D1414); // Dark red card
    const accent = Color(0xFFD97706); // Dark orange/amber accent
    const accentRed = Color(0xFF991B1B); // Dark red
    const accentYellow = Color(0xFFB45309); // Dark yellow/orange

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        title: const Text("Admin • Queues"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Queue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Queue name (e.g. Canteen)",
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: cashierCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Cashier email",
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
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent, // Dark orange
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final cashier = cashierCtrl.text.trim();
                        if (name.isEmpty || cashier.isEmpty) return;
                        
                        // Show debug info
                        final user = FirebaseAuth.instance.currentUser;
                        String debugInfo = 'User: ${user?.email ?? "null"}\n';
                        debugInfo += 'UID: ${user?.uid ?? "null"}\n';
                        
                        try {
                          // Get token for debugging
                          final token = await user?.getIdToken(true);
                          debugInfo += 'Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}\n';
                          debugInfo += 'Calling createQueue...\n';
                          
                          await qp.createQueue(name, cashier);
                          nameCtrl.clear();
                          cashierCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Queue created successfully!"),
                                  const SizedBox(height: 4),
                                  Text(debugInfo, style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        } catch (e, stackTrace) {
                          debugInfo += 'ERROR: $e\n';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Error: ${e.toString()}'),
                                  const SizedBox(height: 4),
                                  Text(debugInfo, style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              backgroundColor: accentRed, // Dark red for errors
                              duration: const Duration(seconds: 10),
                            ),
                          );
                        }
                      },
                      child: const Text("Create"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: qp.queues.length,
                itemBuilder: (_, i) {
                  final q = qp.queues[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Cashier: ${q.cashierEmail}",
                          style: TextStyle(
                            color: Colors.orange.shade300, // Light orange text
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
