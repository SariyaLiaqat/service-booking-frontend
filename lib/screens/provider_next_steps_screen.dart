// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../helpers/my_colors.dart';
// import '../helpers/backend.dart';
// import 'payment_screen.dart';
// import 'document_upload_screen.dart';

// class ProviderNextStepsScreen extends StatefulWidget {
//   final int userId;

//   const ProviderNextStepsScreen({super.key, required this.userId});

//   @override
//   State<ProviderNextStepsScreen> createState() => _ProviderNextStepsScreenState();
// }

// class _ProviderNextStepsScreenState extends State<ProviderNextStepsScreen> {
//   bool isLoadingPayment = false;

//   // 🔹 Fetch payment URL from backend
//  Future<void> _handlePayNow() async {
//   setState(() => isLoadingPayment = true);

//   try {
//     final response = await Backend.post('/payment/create', {
//       'userId': widget.userId.toString(),
//       'amount': '100', // adjust as needed
//     });
// print('PAYMENT RESPONSE: $response');
//     final paymentUrl = Backend.parsePaymentUrl(response);
//     if (paymentUrl != null) {
//       final result = await Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => PaymentScreen(userId: widget.userId,amount: 100.0,),
//   ),
// );


//       if (result == true) {
//         Fluttertoast.showToast(msg: "✅ Payment completed!");
//         _handleUploadDocs();
//       } else if (result == false) {
//         Fluttertoast.showToast(msg: "❌ Payment failed");
//       }
//     } else {
//       Fluttertoast.showToast(msg: "❌ Payment URL not received");
//     }
//   } catch (e) {
//     Fluttertoast.showToast(msg: "❌ Error: $e");
//   } finally {
//     setState(() => isLoadingPayment = false);
//   }
// }

//   void _handleUploadDocs() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DocumentUploadScreen(userId: widget.userId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: MyColors.background,
//       appBar: AppBar(
//         title: const Text("Account Created"),
//         backgroundColor: MyColors.surface,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 50),
//             const Icon(Icons.verified_user, color: MyColors.primary, size: 90),
//             const SizedBox(height: 30),
//             const Text(
//               "Thank you for registering!",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               "Please complete the next two steps to activate your provider account.",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 40),

//             // Pay Now button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.payment, color: Colors.white),
//                 label: isLoadingPayment
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         "Pay Now",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                       ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: MyColors.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 onPressed: isLoadingPayment ? null : _handlePayNow,
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Upload Documents button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.upload_file, color: Colors.white),
//                 label: const Text(
//                   "Submit Documents",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: MyColors.secondary,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 onPressed: _handleUploadDocs,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }







   ///////////////////////////////////////                                 


// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../helpers/backend.dart';
// import 'payment_screen.dart';
// import 'document_upload_screen.dart';
// import '../helpers/coolors.dart';

// class ProviderNextStepsScreen extends StatefulWidget {
//   final int userId;
//   const ProviderNextStepsScreen({super.key, required this.userId});

//   @override
//   State<ProviderNextStepsScreen> createState() => _ProviderNextStepsScreenState();
// }

// class _ProviderNextStepsScreenState extends State<ProviderNextStepsScreen> {
//   bool isLoadingPayment = false;

//   Future<void> _handlePayNow() async {
//     setState(() => isLoadingPayment = true);
//     try {
//       final response = await Backend.post('/payment/create', {
//         'userId': widget.userId.toString(),
//         'amount': '100',
//       });

//       print('PAYMENT RESPONSE: $response');
//       final paymentUrl = Backend.parsePaymentUrl(response);

//       if (paymentUrl != null) {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => PaymentScreen(userId: widget.userId, amount: 100.0),
//           ),
//         );

//         if (result == true) {
//           Fluttertoast.showToast(msg: "✅ Payment completed!");
//           _handleUploadDocs();
//         } else if (result == false) {
//           Fluttertoast.showToast(msg: "❌ Payment failed");
//         }
//       } else {
//         Fluttertoast.showToast(msg: "❌ Payment URL not received");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "❌ Error: $e");
//     } finally {
//       setState(() => isLoadingPayment = false);
//     }
//   }

//   void _handleUploadDocs() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DocumentUploadScreen(userId: widget.userId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//   appBar: AppBar(
//     backgroundColor: Colors.transparent,
//     elevation: 0,
//     title: const Text(
//       "Provider Setup",
//       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//     ),
//     centerTitle: true,
//   ),
//   body: Container(
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(
//         colors: [kPrimaryColor, kSecondaryColor],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     child: Center(
//       child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: kCardColor,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Icon(Icons.verified_user_rounded,
//                     color: kPrimaryColor, size: 90),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome to ServiceSphere!",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: kTextPrimary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   "Your provider account has been created successfully.",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: kTextSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Now, let’s complete the final two steps to activate your profile.",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: kTextHint,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),

//                 // Step Indicator
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: kSecondaryColor.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     "Step 1 of 2 — Payment Setup",
//                     style: TextStyle(
//                       color: kSecondaryColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Pay Now Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: isLoadingPayment
//                         ? const SizedBox(
//                             width: 22,
//                             height: 22,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2.5,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.payment_rounded, color: Colors.white),
//                     label: Text(
//                       isLoadingPayment ? "Processing..." : "Pay Now",
//                       style: const TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kPrimaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: isLoadingPayment ? null : _handlePayNow,
//                   ),
//                 ),

//                 const SizedBox(height: 24),
//                 const Divider(color: kDividerColor, height: 1),
//                 const SizedBox(height: 24),

//                 // Step 2 Indicator
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: kPrimaryColor.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     "Step 2 of 2 — Upload Documents",
//                     style: TextStyle(
//                       color: kPrimaryColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Upload Docs Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.cloud_upload_rounded,
//                         color: Colors.white),
//                     label: const Text(
//                       "Submit Documents",
//                       style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: kSecondaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: _handleUploadDocs,
//                   ),
//                 ),

//                 const SizedBox(height: 30),
//                 const Text(
//                   "Once you finish these steps, our team will review your details within 24 hours.",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: kTextSecondary,
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   "Let’s get you ready to start serving customers!",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: kPrimaryColor,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//   )
//     );
//   }
// }
                                 












// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:confetti/confetti.dart';
// import '../helpers/backend.dart';
// import 'payment_screen.dart';
// import 'document_upload_screen.dart';
// import '../helpers/coolors.dart';

// class ProviderNextStepsScreen extends StatefulWidget {
//   final int userId;
//   const ProviderNextStepsScreen({super.key, required this.userId});

//   @override
//   State<ProviderNextStepsScreen> createState() =>
//       _ProviderNextStepsScreenState();
// }

// class _ProviderNextStepsScreenState extends State<ProviderNextStepsScreen> {
//   bool isLoadingPayment = false;
//   late ConfettiController _confettiController;

//   @override
//   void initState() {
//     super.initState();
//     _confettiController =
//         ConfettiController(duration: const Duration(seconds: 2));
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     super.dispose();
//   }

//   Future<void> _handlePayNow() async {
//     setState(() => isLoadingPayment = true);
//     try {
//       final response = await Backend.post('/payment/create', {
//         'userId': widget.userId.toString(),
//         'amount': '100',
//       });

//       print('PAYMENT RESPONSE: $response');
//       final paymentUrl = Backend.parsePaymentUrl(response);

//       if (paymentUrl != null) {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 PaymentScreen(userId: widget.userId, amount: 100.0),
//           ),
//         );

//         if (result == true) {
//           Fluttertoast.showToast(msg: "✅ Payment completed!");
//           _confettiController.play();
//           _handleUploadDocs();
//         } else if (result == false) {
//           Fluttertoast.showToast(msg: "❌ Payment failed");
//         }
//       } else {
//         Fluttertoast.showToast(msg: "❌ Payment URL not received");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "❌ Error: $e");
//     } finally {
//       setState(() => isLoadingPayment = false);
//     }
//   }

//   void _handleUploadDocs() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DocumentUploadScreen(userId: widget.userId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.white,
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [kPrimaryColor, kSecondaryColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: SafeArea(
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 20),

//                       // 🌟 Soft Glow Verify Icon
//                       Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.white.withOpacity(0.5),
//                               blurRadius: 30,
//                               spreadRadius: 8,
//                             ),
//                           ],
//                         ),
//                         child: const Icon(
//                           Icons.verified_user,
//                           color: Colors.white,
//                           size: 80,
//                         ),
//                       ),

//                       const SizedBox(height: 30),

//                       // ✨ Headings
//                       const Text(
//                         "Account Created 🎉",
//                         style: TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 0.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         "You're just two simple steps away from going live as a verified service provider.",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 16,
//                           height: 1.5,
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // 🟩 Step 1 — Payment
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: kCardColor,
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 12,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             const Text(
//                               "Step 1: Payment Setup",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: kTextPrimary,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             const Text(
//                               "Pay a one-time verification fee to activate your provider account.",
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 color: kTextSecondary,
//                                 height: 1.5,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 20),

//                             // 💳 Pay Now Button
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                 icon: isLoadingPayment
//                                     ? const SizedBox(
//                                         width: 22,
//                                         height: 22,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2.5,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : const Icon(Icons.payment_rounded,
//                                         color: Colors.white),
//                                 label: Text(
//                                   isLoadingPayment
//                                       ? "Processing..."
//                                       : "Pay Now",
//                                   style: const TextStyle(
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: kPrimaryColor,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(14),
//                                   ),
//                                 ),
//                                 onPressed:
//                                     isLoadingPayment ? null : _handlePayNow,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 30),

//                       // 🟦 Step 2 — Document Upload
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: kCardColor,
//                           borderRadius: BorderRadius.circular(24),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 12,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             const Text(
//                               "Step 2: Document Submission",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: kTextPrimary,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             const Text(
//                               "Upload your CNIC, service license or any verification document to finalize your account.",
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 color: kTextSecondary,
//                                 height: 1.5,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 20),

//                             // ☁ Upload Button
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                 icon: const Icon(Icons.cloud_upload_rounded,
//                                     color: Colors.white),
//                                 label: const Text(
//                                   "Submit Documents",
//                                   style: TextStyle(
//                                       fontSize: 17,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: kPrimaryColor,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(14),
//                                   ),
//                                 ),
//                                 onPressed: _handleUploadDocs,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       const Text(
//                         "Once completed, your account will be reviewed within 24 hours. You’ll be notified via email once verified.",
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 15,
//                           height: 1.6,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                       const SizedBox(height: 20),
//                       const Text(
//                         "Keep shining — you're almost ready to start your journey 🚀",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // 🎉 Confetti Animation Layer
//           ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirectionality: BlastDirectionality.explosive,
//             shouldLoop: false,
//             colors: const [kPrimaryColor, kSecondaryColor, Colors.white],
//           ),
//         ],
//       ),
//     );
//   }
// }













import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:confetti/confetti.dart';
import '../helpers/backend.dart';
import 'payment_screen.dart';
import 'document_upload_screen.dart';
import '../helpers/coolors.dart';

class ProviderNextStepsScreen extends StatefulWidget {
  final int userId;
  const ProviderNextStepsScreen({super.key, required this.userId});

  @override
  State<ProviderNextStepsScreen> createState() =>
      _ProviderNextStepsScreenState();
}

class _ProviderNextStepsScreenState extends State<ProviderNextStepsScreen> {
  bool isLoadingPayment = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handlePayNow() async {
    setState(() => isLoadingPayment = true);
    try {
      final response = await Backend.post('/payment/create', {
        'userId': widget.userId.toString(),
        'amount': '100',
      });

      final paymentUrl = Backend.parsePaymentUrl(response);

      if (paymentUrl != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PaymentScreen(userId: widget.userId, amount: 100.0),
          ),
        );

        if (result == true) {
          Fluttertoast.showToast(msg: "✅ Payment completed!");
          _confettiController.play();
          _handleUploadDocs();
        } else if (result == false) {
          Fluttertoast.showToast(msg: "❌ Payment failed");
        }
      } else {
        Fluttertoast.showToast(msg: "❌ Payment URL not received");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Error: $e");
    } finally {
      setState(() => isLoadingPayment = false);
    }
  }

  void _handleUploadDocs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentUploadScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // ✅ White background
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // ✅ Verified Icon with subtle shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: kPrimaryColor,
                        size: 80,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ✅ Headings
                    const Text(
                      "Account Created 🎉",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "You're just two simple steps away from going live as a verified service provider.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ✅ Step 1 — Payment Card
                    _buildStepCard(
                      title: "Step 1: Payment Setup",
                      description:
                          "Pay a one-time verification fee to activate your provider account.",
                      icon: Icons.payment_rounded,
                      buttonText: isLoadingPayment ? "Processing..." : "Pay Now",
                      onPressed: isLoadingPayment ? null : _handlePayNow,
                      isLoading: isLoadingPayment,
                    ),

                    const SizedBox(height: 30),

                    // ✅ Step 2 — Document Upload Card
                    _buildStepCard(
                      title: "Step 2: Document Submission",
                      description:
                          "Upload your CNIC, service license or any verification document to finalize your account.",
                      icon: Icons.cloud_upload_rounded,
                      buttonText: "Submit Documents",
                      onPressed: _handleUploadDocs,
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "Once completed, your account will be reviewed within 24 hours. You’ll be notified via email once verified.",
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Keep shining — you're almost ready to start your journey 🚀",
                      style: TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // 🎉 Confetti Animation (same as original)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [kPrimaryColor, kSecondaryColor, Colors.black],
          ),
        ],
      ),
    );
  }

  // 🔹 Step Card Builder
  Widget _buildStepCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: kTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: Colors.white),
              label: Text(
                buttonText,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
