import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_auth_provider.dart';
import '../queue_provider.dart';
import 'qr_scanner_page.dart';

class CashierPage extends StatelessWidget {
  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {
    final qp = Provider.of<QueueProvider>(context);
    final auth = Provider.of<AppAuthProvider>(context);
    final email = auth.email ?? "";

    // Dark red, dark yellow, orange color palette
    const bg = Color(0xFF1A0A0A); // Very dark red-black background
    const card = Color(0xFF2D1414); // Dark red card
    const accent = Color(0xFFD97706); // Dark orange/amber accent
    const accentRed = Color(0xFF991B1B); // Dark red
    const accentYellow = Color(0xFFB45309); // Dark yellow/orange

    final myQueues =
        qp.queues.where((q) => q.cashierEmail == email).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        title: const Text("Cashier Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: myQueues.isEmpty
          ? Center(
              child: Text(
                "No queues assigned to you.",
                style: TextStyle(color: Colors.orange.shade300),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myQueues.length,
              itemBuilder: (context, i) {
                final q = myQueues[i];
                final tokensRef = FirebaseFirestore.instance
                    .collection('queues')
                    .doc(q.id)
                    .collection('tokens');

                final currentRef = FirebaseFirestore.instance
                    .collection('queues')
                    .doc(q.id)
                    .collection('current')
                    .doc('token');

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: tokensRef.snapshots(),
                    builder: (context, tokenSnap) {
                      final waiting = tokenSnap.data?.docs ?? [];

                      return StreamBuilder<DocumentSnapshot>(
                        stream: currentRef.snapshots(),
                        builder: (context, currentSnap) {
                          final snap = currentSnap.data;
                          final currentData = snap != null
                              ? snap.data() as Map<String, dynamic>?
                              : null;

                          final currentEmail = currentData?['email'];

                          return Column(
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
                                "Current: ${currentEmail ?? 'None'}",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Waiting: ${waiting.length}",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: accent, // Dark orange
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        await qp.callNext(q.id);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    },
                                    child: const Text("Call Next"),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: accentYellow, // Dark yellow
                                      side: BorderSide(color: accentYellow, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              QRScannerPage(queueId: q.id),
                                        ),
                                      );
                                    },
                                    child: const Text("Scan QR"),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
