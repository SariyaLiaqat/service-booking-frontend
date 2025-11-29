import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';

class ProviderWalletScreen extends StatefulWidget {
  final int providerId;
  const ProviderWalletScreen({required this.providerId});

  @override
  _ProviderWalletScreenState createState() => _ProviderWalletScreenState();
}

class _ProviderWalletScreenState extends State<ProviderWalletScreen> {
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
    final url = Uri.parse(
      "${Backend.baseUrl}/provider/wallet/${widget.providerId}",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        walletBalance = double.tryParse(data['wallet_balance'].toString()) ?? 0.0;

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      print("❌ Failed to fetch wallet");
    }
  }

  Future<void> fetchHistory() async {
    final url = Uri.parse(
     "${Backend.baseUrl}/provider/wallet/${widget.providerId}/history",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        transactions = data['transactions'] ?? [];
      });
    } else {
      print("❌ Failed to fetch transaction history");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Wallet")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await fetchWallet();
                await fetchHistory();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                "Wallet Balance",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "PKR ${walletBalance.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (transactions.isEmpty)
                        const Text("No transactions yet 😕"),
                      ...transactions.map(
                        (tx) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(
                              Icons.task_alt,
                              color: Colors.blue,
                            ),
                            title: Text(
                              tx['task_title'] ?? 'Task #${tx['task_id']}',
                            ),
                            subtitle: Text(
                              "Amount: PKR ${tx['amount']}\nStatus: ${tx['status']}",
                            ),
                            trailing: Text(
                              tx['created_at'] != null
                                  ? tx['created_at'].toString().split('T')[0]
                                  : '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final controller = TextEditingController();
                          final amount = await showDialog<double>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Withdraw Funds"),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Enter amount (PKR)",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      ctx,
                                      double.tryParse(controller.text),
                                    );
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            ),
                          );

                          if (amount != null && amount > 0) {
                            final url = Uri.parse(
                              "${Backend.baseUrl}/provider/${widget.providerId}/withdraw",
                            );
                            final response = await http.post(
                              url,
                              headers: {"Content-Type": "application/json"},
                              body: json.encode({"amount": amount}),
                            );

                            final data = json.decode(response.body);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(data['message'] ?? "Error"),
                              ),
                            );

                            if (response.statusCode == 200) {
                              fetchWallet(); // refresh wallet balance
                            }
                          }
                        },
                        icon: const Icon(Icons.money_outlined),
                        label: const Text("Withdraw"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
