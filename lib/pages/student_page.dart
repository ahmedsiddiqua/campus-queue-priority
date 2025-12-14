import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_auth_provider.dart';
import '../queue_provider.dart';
import 'student_qr_page.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: qp.queues.length,
        itemBuilder: (context, i) {
          final q = qp.queues[i];

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
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: tokensRef.snapshots(),
                builder: (context, tokenSnap) {
                  final waiting = tokenSnap.data?.docs ?? [];

                  final alreadyWaiting = waiting.any(
                    (d) =>
                        (d.data() as Map<String, dynamic>)['email'] == email,
                  );

                  return StreamBuilder<DocumentSnapshot>(
                    stream: currentRef.snapshots(),
                    builder: (context, currentSnap) {
                      final snap = currentSnap.data;
                      final currentData =
                          snap != null ? snap.data() as Map<String, dynamic>? : null;

                      final currentEmail = currentData?['email'] as String?;
                      final isCurrent = currentEmail == email;

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
                            "Waiting: ${waiting.length}",
                            style: TextStyle(
                              color: Colors.orange.shade300, // Light orange text
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (!alreadyWaiting && !isCurrent)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accentYellow, // Dark yellow for booking
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    try {
                                      await qp.bookToken(q.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Token booked for ${q.name}."),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Book"),
                                ),

                              if (alreadyWaiting && !isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: accentYellow.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: accentYellow, width: 1),
                                  ),
                                  child: Text(
                                    "Waiting...",
                                    style: TextStyle(
                                      color: accentYellow,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              if (isCurrent)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: accent, // Orange for current
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StudentQRPage(
                                          queueId: q.id,
                                          email: email,
                                          queueName: q.name,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Show QR"),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
