import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../helpers/my_colors.dart';
import '../helpers/backend.dart';
import 'payment_screen.dart';
import 'document_upload_screen.dart';

class ProviderNextStepsScreen extends StatefulWidget {
  final int userId;

  const ProviderNextStepsScreen({super.key, required this.userId});

  @override
  State<ProviderNextStepsScreen> createState() => _ProviderNextStepsScreenState();
}

class _ProviderNextStepsScreenState extends State<ProviderNextStepsScreen> {
  bool isLoadingPayment = false;

  // 🔹 Fetch payment URL from backend
 Future<void> _handlePayNow() async {
  setState(() => isLoadingPayment = true);

  try {
    final response = await Backend.post('/payment/create', {
      'userId': widget.userId.toString(),
      'amount': '100', // adjust as needed
    });
print('PAYMENT RESPONSE: $response');
    final paymentUrl = Backend.parsePaymentUrl(response);
    if (paymentUrl != null) {
      final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PaymentScreen(userId: widget.userId,amount: 100.0,),
  ),
);


      if (result == true) {
        Fluttertoast.showToast(msg: "✅ Payment completed!");
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
      backgroundColor: MyColors.background,
      appBar: AppBar(
        title: const Text("Account Created"),
        backgroundColor: MyColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.verified_user, color: MyColors.primary, size: 90),
            const SizedBox(height: 30),
            const Text(
              "Thank you for registering!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Please complete the next two steps to activate your provider account.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // Pay Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment, color: Colors.white),
                label: isLoadingPayment
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Pay Now",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isLoadingPayment ? null : _handlePayNow,
              ),
            ),

            const SizedBox(height: 20),

            // Upload Documents button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text(
                  "Submit Documents",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _handleUploadDocs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







                                    