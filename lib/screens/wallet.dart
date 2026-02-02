// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';

// class ProviderWalletScreen extends StatefulWidget {
//   final int providerId;
//   const ProviderWalletScreen({required this.providerId});

//   @override
//   _ProviderWalletScreenState createState() => _ProviderWalletScreenState();
// }

// class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
//   double walletBalance = 0;
//   bool isLoading = true;
//   List transactions = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchWallet();
//     fetchHistory();
//   }

//   Future<void> fetchWallet() async {
//     final url = Uri.parse(
//       "${Backend.baseUrl}/provider/wallet/${widget.providerId}",
//     );
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         walletBalance = double.tryParse(data['wallet_balance'].toString()) ?? 0.0;

//         isLoading = false;
//       });
//     } else {
//       setState(() => isLoading = false);
//       print("❌ Failed to fetch wallet");
//     }
//   }

//   Future<void> fetchHistory() async {
//     final url = Uri.parse(
//      "${Backend.baseUrl}/provider/wallet/${widget.providerId}/history",
//     );
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         transactions = data['transactions'] ?? [];
//       });
//     } else {
//       print("❌ Failed to fetch transaction history");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Wallet")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await fetchWallet();
//                 await fetchHistory();
//               },
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Card(
//                         elevation: 5,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             children: [
//                               const Text(
//                                 "Wallet Balance",
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 "PKR ${walletBalance.toStringAsFixed(2)}",
//                                 style: const TextStyle(
//                                   fontSize: 30,
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 25),
//                       const Text(
//                         "Transaction History",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       if (transactions.isEmpty)
//                         const Text("No transactions yet 😕"),
//                       ...transactions.map(
//                         (tx) => Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             leading: const Icon(
//                               Icons.task_alt,
//                               color: Colors.blue,
//                             ),
//                             title: Text(
//                               tx['task_title'] ?? 'Task #${tx['task_id']}',
//                             ),
//                             subtitle: Text(
//                               "Amount: PKR ${tx['amount']}\nStatus: ${tx['status']}",
//                             ),
//                             trailing: Text(
//                               tx['created_at'] != null
//                                   ? tx['created_at'].toString().split('T')[0]
//                                   : '',
//                               style: const TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: 30),
//                       ElevatedButton.icon(
//                         onPressed: () async {
//                           final controller = TextEditingController();
//                           final amount = await showDialog<double>(
//                             context: context,
//                             builder: (ctx) => AlertDialog(
//                               title: const Text("Withdraw Funds"),
//                               content: TextField(
//                                 controller: controller,
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                   hintText: "Enter amount (PKR)",
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(ctx),
//                                   child: const Text("Cancel"),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(
//                                       ctx,
//                                       double.tryParse(controller.text),
//                                     );
//                                   },
//                                   child: const Text("Confirm"),
//                                 ),
//                               ],
//                             ),
//                           );

//                           if (amount != null && amount > 0) {
//                             final url = Uri.parse(
//                               "${Backend.baseUrl}/provider/${widget.providerId}/withdraw",
//                             );
//                             final response = await http.post(
//                               url,
//                               headers: {"Content-Type": "application/json"},
//                               body: json.encode({"amount": amount}),
//                             );

//                             final data = json.decode(response.body);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(data['message'] ?? "Error"),
//                               ),
//                             );

//                             if (response.statusCode == 200) {
//                               fetchWallet(); // refresh wallet balance
//                             }
//                           }
//                         },
//                         icon: const Icon(Icons.money_outlined),
//                         label: const Text("Withdraw"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 30,
//                             vertical: 12,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import '../helpers/coolors.dart';

class ProviderWalletScreen extends StatefulWidget {
  final int providerId;
  const ProviderWalletScreen({super.key, required this.providerId});

  @override
  _ProviderWalletScreenState createState() => _ProviderWalletScreenState();
}

class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
  // --- PRESERVED LOGIC ---
  double walletBalance = 0;
  bool isLoading = true;
  List transactions = [];

  @override
  void initState() {
    super.initState();
    fetchWallet();
    fetchHistory();
  }

  Future<void> fetchWallet() async {
    try {
      final url = Uri.parse("${Backend.baseUrl}/provider/wallet/${widget.providerId}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          walletBalance = double.tryParse(data['wallet_balance'].toString()) ?? 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchHistory() async {
    try {
      final url = Uri.parse("${Backend.baseUrl}/provider/wallet/${widget.providerId}/history");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = data['transactions'] ?? [];
        });
      }
    } catch (e) {
      print("❌ History Error: $e");
    }
  }

  // --- MODERN UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Wallet & Payouts",
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: () async {
                await fetchWallet();
                await fetchHistory();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildBalanceCard(),
                    const SizedBox(height: 30),
                    _buildSectionHeader("Transaction Activity"),
                    const SizedBox(height: 15),
                    _buildTransactionList(),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildWithdrawButton(),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "PKR ${walletBalance.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Verified Provider Account",
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextPrimary),
    );
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 50, color: kTextHint.withOpacity(0.5)),
              const SizedBox(height: 10),
              const Text("No recent transactions found", style: TextStyle(color: kTextSecondary)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: kDividerColor),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final bool isWithdrawal = tx['status'].toString().toLowerCase() == 'withdrawn' || tx['status'].toString().toLowerCase() == 'pending';
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: isWithdrawal ? Colors.red.withOpacity(0.1) : kSuccessColor.withOpacity(0.1),
              child: Icon(
                isWithdrawal ? Icons.call_made_rounded : Icons.call_received_rounded,
                color: isWithdrawal ? Colors.red : kSuccessColor,
                size: 20,
              ),
            ),
            title: Text(
              tx['task_title'] ?? 'Task #${tx['task_id']}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary, fontSize: 14),
            ),
            subtitle: Text(
              tx['created_at']?.toString().split('T')[0] ?? '',
              style: const TextStyle(color: kTextSecondary, fontSize: 12),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${isWithdrawal ? '-' : '+'} PKR ${tx['amount']}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isWithdrawal ? Colors.red : kSuccessColor,
                    fontSize: 15,
                  ),
                ),
                Text(
                  tx['status'].toString().toUpperCase(),
                  style: TextStyle(color: kTextHint, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _showWithdrawDialog,
          icon: const Icon(Icons.account_balance_rounded, color: Colors.white),
          label: const Text("Withdraw to Bank Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D3436), // Professional charcoal gray
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  Future<void> _showWithdrawDialog() async {
    final controller = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Withdraw Funds", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Amount (PKR)",
            prefixText: "PKR ",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: kTextSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, double.tryParse(controller.text)),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text("Request Payout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (amount != null && amount > 0) {
      _processWithdrawal(amount);
    }
  }

  Future<void> _processWithdrawal(double amount) async {
    final url = Uri.parse("${Backend.baseUrl}/provider/${widget.providerId}/withdraw");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"amount": amount}),
    );

    final data = json.decode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? "Error"), behavior: SnackBarBehavior.floating),
    );

    if (response.statusCode == 200) {
      fetchWallet();
      fetchHistory();
    }
  }
}









