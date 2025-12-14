import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentQRPage extends StatelessWidget {
  final String queueId;
  final String email;
  final String queueName;

  const StudentQRPage({
    super.key,
    required this.queueId,
    required this.email,
    required this.queueName,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0C10);
    const card = Color(0xFF151821);

    final payload = jsonEncode({
      'queueId': queueId,
      'email': email,
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: card,
        title: Text("Token • $queueName"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: QrImageView(
            data: payload,
            version: QrVersions.auto,
            size: 260,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
