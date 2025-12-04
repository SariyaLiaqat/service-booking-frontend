






// import 'package:flutter/material.dart';
// import '../models/charts.dart';
// import 'wallet.dart';
// import '../helpers/backend.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ProviderDashboardScreen extends StatefulWidget {
//   final int providerId;
//   const ProviderDashboardScreen({super.key, required this.providerId});

//   @override
//   State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
// }

// class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
//   bool isLoading = true;
//   String? error;

//   Map<String, bool> progress = {
//     "signed_up": false,
//     "payment_done": false,
//     "documents_submitted": false,
//     "under_review": false,
//     "approved": false,
//     "rejected": false,
//   };

//   int totalBookings = 0;
//   int completedTasks = 0;
//   int pendingPayments = 0;
//   double totalEarnings = 0.0;
//   double walletBalance = 0.0;
//   List<Map<String, dynamic>> bookingHistory = [];

//   Map<String, dynamic>? provider;
//   Map<String, dynamic>? latestPayment;

//   @override
//   void initState() {
//     super.initState();
//     fetchProviderDashboard();
//   }




//   Future<void> fetchProviderDashboard() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final statusUrl = '${Backend.baseUrl}/provider/status/${widget.providerId}';
//       final statusRes = await http.get(Uri.parse(statusUrl));
//       if (statusRes.statusCode != 200) throw Exception('Failed to fetch provider status');
//       final statusData = jsonDecode(statusRes.body);
//       provider = statusData['provider'];
//       latestPayment = statusData['payment'];
//       final overallStatus = statusData['overall_status'];
//       // 🔥 ADD THIS — Fetch task summary
//       final summaryUrl =
//           '${Backend.baseUrl}/tasks/summary?provider_id=${widget.providerId}';
//       final summaryRes = await http.get(Uri.parse(summaryUrl));
//       if (summaryRes.statusCode != 200) throw Exception('Failed to fetch task summary');
//       final summaryData = jsonDecode(summaryRes.body);

//       totalBookings = summaryData['totalTasks'];
//       completedTasks = summaryData['completedTasks'];
//       pendingPayments = summaryData['pendingTasks'];
//       totalEarnings = double.tryParse(summaryData['totalEarnings'].toString()) ?? 0.0;

//       final dashboardUrl = '${Backend.baseUrl}/provider/${widget.providerId}/dashboard';
//       final dashboardRes = await http.get(Uri.parse(dashboardUrl));
//       if (dashboardRes.statusCode != 200) throw Exception('Failed to fetch dashboard');
//      // final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];

//      // walletBalance = double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;
     

//       progress = {
//         "signed_up": true,
//         "payment_done": latestPayment != null &&
//             (latestPayment!['payment_record_status'] == 'paid' ||
//                 latestPayment!['payment_record_status'] == 'completed'),
//         "documents_submitted": provider!['documents_uploaded'] == true,
//         "under_review": overallStatus == 'under_review',
//         "approved": provider!['provider_status'] == 'approved',
//         "rejected": provider!['provider_status'] == 'rejected',
//       };

//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   bool get isApproved => progress["approved"] == true;

//   // ----------------- UI Widgets -----------------

//   Widget buildSummaryCards() {
//     return SizedBox(
//       height: 140,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         children: [
//           summaryCard("Earnings", "PKR ${totalEarnings.toStringAsFixed(2)}", Icons.attach_money, Colors.green),
//           summaryCard("Completed", "$completedTasks", Icons.check_circle, Colors.blue),
//           summaryCard("Pending", "$pendingPayments", Icons.pending_actions, Colors.orange),
//           summaryCard("Bookings", "$totalBookings", Icons.book_online, Colors.purple),
//         ],
//       ),
//     );
//   }

//   Widget summaryCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 12),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 28),
//               const SizedBox(height: 8),
//               Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 4),
//               Text(title, style: const TextStyle(fontSize: 14)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//  Widget buildTimeline() {
//   final steps = [
//     {"key": "signed_up", "label": "Signed Up"},
//     {"key": "payment_done", "label": "Payment"},
//     {"key": "documents_submitted", "label": "Documents"},
//     {"key": "under_review", "label": "Under Review"},
//     {"key": "approved", "label": "Approved"},
//     {"key": "rejected", "label": "Rejected"},
//   ];

//   return Card(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//     elevation: 3,
//     margin: const EdgeInsets.symmetric(vertical: 12),
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: steps.map((step) {
//           final done = progress[step['key']] ?? false;
//           final isRejected = step['key'] == 'rejected' && progress['rejected'] == true;
//           final color = isRejected ? Colors.red : done ? Colors.green : Colors.grey;
//           final icon = isRejected
//               ? Icons.cancel
//               : done
//                   ? Icons.check_circle
//                   : Icons.radio_button_unchecked;
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Row(
//               children: [
//                 Icon(icon, color: color, size: 28),
//                 const SizedBox(width: 12),
//                 Text(
//                   step['label']!,
//                   style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: done || isRejected ? FontWeight.bold : FontWeight.normal,
//                       color: color),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     ),
//   );
// }

//   Widget buildGraphsPlaceholder() {
//     // Placeholder for line chart
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       child: SizedBox(
//         height: 200,
//         child: Center(child: Text("Graphs Placeholder (Earnings/Bookings)")),
//       ),
//     );
//   }

//   Widget buildBookingHistory() {
//     if (bookingHistory.isEmpty) return const Center(child: Text("No bookings yet"));

//     return Column(
//       children: bookingHistory.map((b) {
//         final isPaid = b['payment_status'].toString().toLowerCase() == 'paid' ||
//             b['payment_status'].toString().toLowerCase() == 'completed';

//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: ListTile(
//             title: Text(b['title'] ?? "Task #${b['id']}"),
//             subtitle: Text("Date: ${b['scheduled_date']}"),
//             trailing: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text("PKR ${b['amount'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(isPaid ? "Paid" : "Pending",
//                     style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget buildActionButtons() {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//             onPressed: isApproved ? () {} : null,
//             icon: const Icon(Icons.add_box_outlined),
//             label: const Text("Create Service")),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: isApproved ? () {} : null,
//             icon: const Icon(Icons.check_circle_outline),
//             label: const Text("Accept Bookings")),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: isApproved ? () {} : null,
//             icon: const Icon(Icons.book_online),
//             label: const Text("View Bookings")),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: isApproved
//                 ? () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => ProviderWalletScreen(providerId: widget.providerId)));
//                   }
//                 : null,
//             icon: const Icon(Icons.account_balance_wallet_outlined),
//             label: const Text("View Wallet")),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Provider Dashboard")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//               ? Center(child: Text(error!))
//               : Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: ListView(
//                     children: [
//                       buildSummaryCards(),
//                       buildTimeline(),
//                      buildEarningsChart(),
//     buildBookingsChart(),
//                       if (!isApproved && !progress['rejected']!)
//                         Container(
//                           color: Colors.yellow[200],
//                           padding: const EdgeInsets.all(16),
//                           child: const Text(
//                             "Awaiting verification — you cannot access provider features until approved.",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                           ),
//                         ),
//                       const SizedBox(height: 16),
//                       buildBookingHistory(),
//                       const SizedBox(height: 16),
//                       buildActionButtons(),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }




























import 'package:flutter/material.dart';
import '../models/charts.dart';
import 'wallet.dart';
import '../helpers/backend.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProviderDashboardScreen extends StatefulWidget {
  final int providerId;
  const ProviderDashboardScreen({super.key, required this.providerId});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool isLoading = true;
  String? error;

  Map<String, bool> progress = {
    "signed_up": false,
    "payment_done": false,
    "documents_submitted": false,
    "under_review": false,
    "approved": false,
    "rejected": false,
  };

  int totalBookings = 0;
  int completedTasks = 0;
  int pendingPayments = 0;
  double totalEarnings = 0.0;
  double walletBalance = 0.0;
  List<Map<String, dynamic>> bookingHistory = [];
  double dashboardTotalEarnings = 0.0;


  Map<String, dynamic>? provider;
  Map<String, dynamic>? latestPayment;

  @override
  void initState() {
    super.initState();
    fetchProviderDashboard();
  }




  Future<void> fetchProviderDashboard() async {
  setState(() {
    isLoading = true;
    error = null;
  });

  try {
    // ---------------- Provider Status ----------------
    final statusUrl = '${Backend.baseUrl}/provider/status/${widget.providerId}';
    final statusRes = await http.get(Uri.parse(statusUrl));
    if (statusRes.statusCode != 200) throw Exception('Failed to fetch provider status');

    final statusData = jsonDecode(statusRes.body);
    provider = statusData['provider'];
    latestPayment = statusData['payment'];
    final overallStatus = statusData['overall_status'];

    // ---------------- Task Summary ----------------
    final summaryUrl =
        '${Backend.baseUrl}/tasks/summary?provider_id=${widget.providerId}';
    final summaryRes = await http.get(Uri.parse(summaryUrl));
    if (summaryRes.statusCode != 200) throw Exception('Failed to fetch task summary');

    final summaryData = jsonDecode(summaryRes.body);

    totalBookings = summaryData['totalTasks'] ?? 0;
    completedTasks = summaryData['completedTasks'] ?? 0;
    pendingPayments = summaryData['pendingTasks'] ?? 0;
    totalEarnings =
        double.tryParse(summaryData['totalEarnings'].toString()) ?? 0.0;

    // ---------------- DASHBOARD ----------------
    final dashboardUrl =
    
        '${Backend.baseUrl}/provider/${widget.providerId}/dashboard';
        print("Sending providerId: ${widget.providerId}");

        print('Fetching dashboard from: $dashboardUrl');
    final dashboardRes = await http.get(Uri.parse(dashboardUrl));
    if (dashboardRes.statusCode != 200) throw Exception('Failed to fetch dashboard');

    final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];

    walletBalance =
        double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;

    /// 🎯 VERY IMPORTANT — use correct key!
    final dashboardEarnings =
        double.tryParse(dashboardData['total_earned'].toString()) ?? 0.0;

    // If you want dashboard earnings separately:
    dashboardTotalEarnings = dashboardEarnings;

    // ---------------- Progress ----------------
    progress = {
      "signed_up": true,
      "payment_done": latestPayment != null &&
          (latestPayment!['payment_record_status'] == 'paid' ||
              latestPayment!['payment_record_status'] == 'completed'),
      "documents_submitted": provider!['documents_uploaded'] == true,
      "under_review": overallStatus == 'under_review',
      "approved": provider!['provider_status'] == 'approved',
      "rejected": provider!['provider_status'] == 'rejected',
    };

    setState(() => isLoading = false);
  } catch (e) {
    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}


  bool get isApproved => progress["approved"] == true;

  // ----------------- UI Widgets -----------------

  Widget buildSummaryCards() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          summaryCard("Earnings", "PKR ${totalEarnings.toStringAsFixed(2)}", Icons.attach_money, Colors.green),
          summaryCard("Completed", "$completedTasks", Icons.check_circle, Colors.blue),
          summaryCard("Pending", "$pendingPayments", Icons.pending_actions, Colors.orange),
          summaryCard("Bookings", "$totalBookings", Icons.book_online, Colors.purple),
        ],
      ),
    );
  }

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

 Widget buildTimeline() {
  final steps = [
    {"key": "signed_up", "label": "Signed Up"},
    {"key": "payment_done", "label": "Payment"},
    {"key": "documents_submitted", "label": "Documents"},
    {"key": "under_review", "label": "Under Review"},
    {"key": "approved", "label": "Approved"},
    {"key": "rejected", "label": "Rejected"},
  ];

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: steps.map((step) {
          final done = progress[step['key']] ?? false;
          final isRejected = step['key'] == 'rejected' && progress['rejected'] == true;
          final color = isRejected ? Colors.red : done ? Colors.green : Colors.grey;
          final icon = isRejected
              ? Icons.cancel
              : done
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  step['label']!,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: done || isRejected ? FontWeight.bold : FontWeight.normal,
                      color: color),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}

  Widget buildGraphsPlaceholder() {
    // Placeholder for line chart
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 200,
        child: Center(child: Text("Graphs Placeholder (Earnings/Bookings)")),
      ),
    );
  }

  Widget buildBookingHistory() {
    if (bookingHistory.isEmpty) return const Center(child: Text("No bookings yet"));

    return Column(
      children: bookingHistory.map((b) {
        final isPaid = b['payment_status'].toString().toLowerCase() == 'paid' ||
            b['payment_status'].toString().toLowerCase() == 'completed';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(b['title'] ?? "Task #${b['id']}"),
            subtitle: Text("Date: ${b['scheduled_date']}"),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("PKR ${b['amount'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(isPaid ? "Paid" : "Pending",
                    style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
            onPressed: isApproved ? () {} : null,
            icon: const Icon(Icons.add_box_outlined),
            label: const Text("Create Service")),
        const SizedBox(height: 12),
        ElevatedButton.icon(
            onPressed: isApproved ? () {} : null,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Accept Bookings")),
        const SizedBox(height: 12),
        ElevatedButton.icon(
            onPressed: isApproved ? () {} : null,
            icon: const Icon(Icons.book_online),
            label: const Text("View Bookings")),
        const SizedBox(height: 12),
        ElevatedButton.icon(
            onPressed: isApproved
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProviderWalletScreen(providerId: widget.providerId)));
                  }
                : null,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text("View Wallet")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Provider Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView(
                    children: [
                      buildSummaryCards(),
                      buildTimeline(),
                     buildEarningsChart(),
    buildBookingsChart(),
                      if (!isApproved && !progress['rejected']!)
                        Container(
                          color: Colors.yellow[200],
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            "Awaiting verification — you cannot access provider features until approved.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 16),
                      buildBookingHistory(),
                      const SizedBox(height: 16),
                      buildActionButtons(),
                    ],
                  ),
                ),
    );
  }
}
