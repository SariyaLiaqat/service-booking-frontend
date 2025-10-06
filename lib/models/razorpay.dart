// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// import '../helpers/backend.dart';
// import '../screens/my_tasks_screen.dart';
// class PaymentScreen extends StatefulWidget {
//   final int taskId;
//   final double amount;
// final String orderId;
// final String userContact; // add
//   final String userEmail;   // add
//   const PaymentScreen({super.key, required this.taskId, required this.amount,required this.orderId,required this.userContact,
//     required this.userEmail, });

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   // inside _PaymentScreenState
// void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//   print("Payment success ✅");
//   print("Order ID: ${response.orderId}");
//   print("Payment ID: ${response.paymentId}");
//   print("Signature: ${response.signature}");

//   try {
//     final data = await Backend.post('/api/payments/verify', {
//       'razorpay_order_id': response.orderId,
//       'razorpay_payment_id': response.paymentId,
//       'razorpay_signature': response.signature,
//       'taskId': widget.taskId,
//       'amount': widget.amount,
//     });

//     if (data != null && data['status'] == 'success') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment verified ✅")),
//       );
      
//       // ✅ Redirect to MyTasksScreen here
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MyTasksScreen(
//             currentUserId: widget.taskId, // or pass correct user ID
//             currentUser: {/* pass the current user map here */},
//             role: 'user',
//           ),
//         ),
//       );
//       // yahan tum TaskScreen pe redirect kar sakti ho
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Payment verification failed ❌: ${data?['message'] ?? 'Unknown error'}")),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error verifying payment ❌: $e")),
//     );
//   }
// }

// void _handlePaymentError(PaymentFailureResponse response) async {
//   print("Payment failed: ${response.code} - ${response.message}");

//   // 1️⃣ Show a snackbar
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(
//         "❌ Payment failed: ${response.message ?? 'Please try again'}",
//         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//       backgroundColor: Colors.red.shade600,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       duration: const Duration(seconds: 3),
//     ),
//   );

//   // 2️⃣ Log failure to backend
//   try {
//     await Backend.post('/api/payments/failure', {
//       'code': response.code,
//       'message': response.message ?? '',
//       'taskId': widget.taskId,
//       // 🔹 No paymentId here
//     });
//   } catch (e) {
//     print("Failed to log payment error to backend: $e");
//   }

//   // 3️⃣ Retry dialog
//   showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text("Payment Failed"),
//       content: const Text("Would you like to retry the payment?"),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(ctx);
//           },
//           child: const Text("Cancel"),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(ctx);
//             _openCheckout(); // Retry payment
//           },
//           child: const Text("Retry"),
//         ),
//       ],
//     ),
//   );
// }


//   void _handleExternalWallet(ExternalWalletResponse response) {
//   print("External wallet selected: ${response.walletName}");

//   // Show a snackbar so user knows an external wallet was selected
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(
//         "💳 External wallet selected: ${response.walletName}",
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: Colors.blue.shade700,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       duration: const Duration(seconds: 3),
//     ),
//   );

//   // Optional: You could trigger additional logic here if needed,
//   // like adjusting UI or waiting for the actual payment success callback.
// }


//   // 🔹 Must be inside the class
//   void _openCheckout() {
//     var options = {
//       'key': 'RAZORPAY_KEY_HERE', // Replace with your Razorpay Key
//       'amount': (widget.amount * 100).toInt(), // in paise
//       'name': 'Your App Name',
//       'description': 'Payment for Task #${widget.taskId}',
//       'order_id': widget.orderId,
//       'prefill': {
//         'contact': widget.userContact,
//   'email': widget.userEmail,
//       },
//       'external': {
//         'wallets': ['paytm']
//       }
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print("Error opening Razorpay checkout: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Payment")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _openCheckout,
//           child: const Text("Pay Now"),
//         ),
//       ),
//     );
//   }
// }
