import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final VoidCallback? onPaymentSuccess; // 👈 callback for refreshing parent screen

  const PaymentWebViewScreen({
    super.key,
    required this.url,
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
          onPageFinished: (url) {
            setState(() => isLoading = false);

            // ✅ Detect success page or callback URL
            if (url.contains("payment/uis") || url.contains("Success")) {
              widget.onPaymentSuccess?.call(); // refresh task list in parent
              Navigator.pop(context); // close WebView
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Payment Successful")),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
        ],
      ),
    );
  }
}
