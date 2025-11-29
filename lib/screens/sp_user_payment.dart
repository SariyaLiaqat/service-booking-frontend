import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final int taskId;
  final int userId;
  final int spId;
  final double amount;
  final String txnId; // ✅ Add dynamic txnId
  final String ordId; // ✅ Add dynamic ordId
  final VoidCallback? onPaymentSuccess;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.taskId,
    required this.userId,
    required this.spId,
    required this.amount,
    required this.txnId,
    required this.ordId,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            setState(() => isLoading = false);
            print("🔍 WebView loaded: $url");

            if (url.contains("user-payment/uis") || url.toLowerCase().contains("success")) {
              print("✅ Payment success detected!");

              // 🔔 Notify backend with dynamic txnId and ordId
              await _notifyBackend();

              widget.onPaymentSuccess?.call();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Payment Successful")),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _notifyBackend() async {
    try {
      final backendUrl = Uri.parse("${Backend.baseUrl}/user-payment/uis");

      final response = await http.post(
        backendUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": "Service_APP",
          "password": "Demo@sp25",
          "taskId": widget.taskId,
          "userId": widget.userId,
          "spId": widget.spId,
          "amount": widget.amount,
          "status": "Success",
          "txnId": widget.txnId, // ✅ dynamic
          "ordId": widget.ordId, // ✅ dynamic
        }),
      );

      print("🔔 Backend notified: ${response.statusCode}");
      print("📦 Response: ${response.body}");
    } catch (e) {
      print("❌ Failed to notify backend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
        ],
      ),
    );
  }
}
