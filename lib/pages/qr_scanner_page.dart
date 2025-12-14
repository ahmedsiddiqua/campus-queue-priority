import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../queue_provider.dart';

class QRScannerPage extends StatefulWidget {
  final String queueId;

  const QRScannerPage({super.key, required this.queueId});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool handled = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0C10);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151821),
        title: const Text("Scan Student QR"),
      ),
      body: MobileScanner(
        onDetect: (capture) async {
          if (handled) return;

          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return; // very important safety check

          final raw = barcodes.first.rawValue;

          if (raw == null) return;

          handled = true;
          final qp = Provider.of<QueueProvider>(context, listen: false);

          try {
            final decoded = jsonDecode(raw) as Map<String, dynamic>;
            final queueId = decoded['queueId'] as String?;

            if (queueId == widget.queueId) {
              await qp.clearCurrent(widget.queueId);

              if (!mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Token served.")),
              );
            } else {
              throw Exception("Queue mismatch");
            }
          } catch (e) {
            handled = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Invalid QR: $e")),
            );
          }
        },
      ),
    );
  }
}
