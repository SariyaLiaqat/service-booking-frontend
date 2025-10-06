// import 'package:flutter/material.dart';
// import '../models/razorpay.dart'; // ✅ Make sure path is correct
// import '../helpers/backend.dart';
// import 'my_tasks_screen.dart';
// //import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void showPaymentOptionDialog(
//     BuildContext context, int taskId,
//      double amount,
//       int userId,
//        int providerId,
//     String userPhoneNumber, // 📌 add this
//     String userEmail,       // 📌 add this
    
//     ) {
//   showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text("Payment Option"),
//       content: const Text("Do you want to pay now or later?"),
//       actions: [
//         // ---------- PAY LATER ----------
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(ctx);
//             final res = await http.post(
//               Uri.parse("${Backend.baseUrl}/payments/tasks/pay_later"),
//               headers: {"Content-Type": "application/json"},
//               body: jsonEncode({"taskId": taskId}),
//             );

//             if (res.statusCode == 200) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Marked as Pay Later")),
//               );

//               // ✅ Redirect to MyTasksScreen
//              Navigator.pushReplacement(
//   context,
//   MaterialPageRoute(
//     builder: (_) => MyTasksScreen(
//       role: "user",
//       currentUserId: userId,
//       currentUser: {
//         'phoneNumber': userPhoneNumber,
//         'email': userEmail,
//       },
//     ),
//   ),
// );

//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Failed to mark Pay Later ❌")),
//               );
//             }
//           },
//           child: const Text("Pay Later"),
//         ),

//         // ---------- PAY NOW ----------
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(ctx);

//             // ✅ First create order from backend
//             final res = await http.post(
//               Uri.parse("${Backend.baseUrl}/payments/create"),
//               headers: {"Content-Type": "application/json"},
//               body: jsonEncode({
//                 "task_id": taskId,
//                 "user_id": userId,
//                 "provider_id": providerId,
//                 "amount": amount,
//               }),
//             );

//            if (res.statusCode == 200) {
//   final data = jsonDecode(res.body);
//   final orderId = data['order']['id'];

//   // ✅ Ab PaymentScreen kholo aur orderId pass karo
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => PaymentScreen(
//         taskId: taskId,
//         amount: amount,
//         orderId: orderId, // 🔹 yahan bhejna important hai
//         userContact: userPhoneNumber, // user ka mobile number
//       userEmail: userEmail,    
//       ),
//     ),
//   );
// } else {
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text("Failed to create order ❌")),
//   );
// }
//       },
//           child: const Text("Pay Now"),
//         ),
//       ],
//     ),
//   );
// }