// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../helpers/backend.dart';

// class PaymentScreen extends StatefulWidget {
//   final String paymentUrl;
//   final int userId;

//   const PaymentScreen({super.key, required this.paymentUrl, required this.userId});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   late final WebViewController _controller;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     // Use hybrid composition for Android
//    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (url) {
//             setState(() => isLoading = false);
//           },
//           onNavigationRequest: (request) {
//             final url = request.url;
//             print('NAVIGATION: $url');

//             // ✅ Detect callback_url from PayPro redirect
//             if (url.contains("/paypro/uis")) {
//               Fluttertoast.showToast(msg: "✅ Payment Completed!");
//               Navigator.pop(context, true); // Return success to previous screen
//               return NavigationDecision.prevent;
//             }

//             return NavigationDecision.navigate;
//           },
//         ),
//       );

//     // Append callback_url to the paymentUrl (if backend didn't already)
//     String callbackUrl = "${Backend.baseUrl}/paypro/uis?username=Service_APP&password=Demo@sp25";
//    // Direct successful URL from PayPro demo
// String finalUrl = "${Backend.baseUrl}/paypro/create";

// // Append callback_url if you want to detect it in Flutter
// finalUrl = "$finalUrl&callback_url=${Uri.encodeComponent(callbackUrl)}";


//     _controller.loadRequest(Uri.parse(finalUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Payment")),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }








///////////////////////////////////




// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';

// class PaymentScreen extends StatefulWidget {
//   final int userId;
//   final double amount;

//   const PaymentScreen({super.key, required this.userId, required this.amount});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   late final WebViewController _controller;
//   bool isLoading = true;
//   String? paymentUrl;

//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

//     _controller.setNavigationDelegate(
//       NavigationDelegate(
//         onPageFinished: (url) {
//           setState(() => isLoading = false);
//         },
//         onNavigationRequest: (request) {
//           final url = request.url;
//           print('NAVIGATION: $url');

//           if (url.contains("/paypro/uis")) {
//             Fluttertoast.showToast(msg: "✅ Payment Completed!");
//             Navigator.pop(context, true); // Return success to previous screen
//             return NavigationDecision.prevent;
//           }

//           return NavigationDecision.navigate;
//         },
//       ),
//     );

//     // Start payment creation
//     _createPayment();
//   }

//   Future<void> _createPayment() async {
//     try {
//       final url = Uri.parse('${Backend.baseUrl}/paypro/create');

//       final res = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'userId': widget.userId,
//           'amount': widget.amount,
//           // Add more fields if needed, like name/email/mobile
//         }),
//       );

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         paymentUrl = data['payment_url'];

//         // Append callback URL if not already present
//         final callbackUrl = "${Backend.baseUrl}/paypro/uis?username=Service_APP&password=Demo@sp25";
//         if (!paymentUrl!.contains('callback_url')) {
//           paymentUrl = paymentUrl!.contains('?')
//               ? "${paymentUrl!}&callback_url=${Uri.encodeComponent(callbackUrl)}"
//               : "${paymentUrl!}?callback_url=${Uri.encodeComponent(callbackUrl)}";
//         }

//         // Load WebView
//         _controller.loadRequest(Uri.parse(paymentUrl!));

//         print('✅ Payment URL loaded: $paymentUrl');
//       } else {
//         print('❌ Failed to create payment: ${res.body}');
//         Fluttertoast.showToast(msg: "Payment creation failed. Check backend logs.");
//       }
//     } catch (e) {
//       print('❌ Error creating payment: $e');
//       Fluttertoast.showToast(msg: "Payment creation error. See console.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Payment")),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }




// ////////////////////
// ///










////////////////////////////////




import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/backend.dart';

class PaymentScreen extends StatefulWidget {
  final int userId;
  final double amount;

  const PaymentScreen({super.key, required this.userId, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _createPayment();
  }

  Future<void> _createPayment() async {
    try {
      final url = Uri.parse('${Backend.baseUrl}/payment/create');

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'amount': widget.amount,
        }),
      );
print('🔍 PAYPRO RESPONSE STATUS: ${res.statusCode}');
print('🔍 PAYPRO RESPONSE BODY: ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String? paymentUrl = data['payment_url'];

        if (paymentUrl == null || paymentUrl.isEmpty) {
          Fluttertoast.showToast(msg: "❌ No payment URL received");
          Navigator.pop(context, false);
          return;
        }

        // Append callback URL if needed
        final callbackUrl = "${Backend.baseUrl}/paypro/uis?username=Service_APP&password=Demo@sp25";
        if (!paymentUrl.contains('callback_url')) {
          paymentUrl = paymentUrl.contains('?')
              ? "$paymentUrl&callback_url=${Uri.encodeComponent(callbackUrl)}"
              : "$paymentUrl?callback_url=${Uri.encodeComponent(callbackUrl)}";
        }

        // ✅ Open in external browser
        // ✅ Open payment page
final uri = Uri.parse(paymentUrl);
try {
  final launched = await launchUrl(
    uri,
    mode: LaunchMode.inAppBrowserView, // 👈 Pehle yaha external tha
  );

  if (!launched) {
    // fallback if inAppBrowser fails
    Fluttertoast.showToast(msg: "Opening in external browser...");
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    Fluttertoast.showToast(msg: "Redirecting to PayPro...");
  }
} catch (e) {
  Fluttertoast.showToast(msg: "❌ Could not open payment link: $e");
  print("❌ URL Launch error: $e");
}


        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(msg: "Payment creation failed");
        Navigator.pop(context, false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Error: $e");
      Navigator.pop(context, false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Redirecting to Payment")),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
