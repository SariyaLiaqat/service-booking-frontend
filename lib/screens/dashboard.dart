
// import 'package:flutter/material.dart';
// import 'wallet.dart';
// import '../helpers/backend.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/charts.dart';
// import '../helpers/coolors.dart';

// class DashboardScreen extends StatefulWidget {
//   final int userId;
//   final String role;

//   const DashboardScreen({super.key, required this.userId, required this.role});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // Logic remains untouched
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
//   int rejectedTasks = 0;
//   int pendingPayments = 0;
//   double totalEarnings = 0.0;
//   double walletBalance = 0.0;
//   double dashboardTotalEarnings = 0.0;

//   bool get isProvider => widget.role == 'provider';
//   bool get isApproved => progress["approved"] == true;

//   @override
//   void initState() {
//     super.initState();
//     if (isProvider) {
//       fetchProviderDashboard();
//     } else {
//       fetchUserDashboard();
//     }
//   }

//   // --- Logic Methods (Kept exactly same) ---
//   Future<void> fetchProviderDashboard() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//     try {
//       final userId = widget.userId;
//       final statusRes = await http.get(
//         Uri.parse('${Backend.baseUrl}/provider/status/$userId'),
//       );
//       if (statusRes.statusCode != 200)
//         throw Exception('Failed to fetch provider status');
//       final statusData = jsonDecode(statusRes.body);
//       final provider = statusData['provider'];
//       final latestPayment = statusData['payment'];
//       final overallStatus = statusData['overall_status'];

//       final summaryRes = await http.get(
//         Uri.parse('${Backend.baseUrl}/tasks/summary?user_id=$userId'),
//       );
//       final summaryData = jsonDecode(summaryRes.body);

//       totalBookings = summaryData['totalTasks'] ?? 0;
//       completedTasks = summaryData['completedTasks'] ?? 0;
//       rejectedTasks = summaryData['rejectedTasks'] ?? 0;
//       pendingPayments = summaryData['pendingTasks'] ?? 0;
//       totalEarnings =
//           double.tryParse(summaryData['totalEarnings'].toString()) ?? 0.0;

//       final dashboardRes = await http.get(
//         Uri.parse('${Backend.baseUrl}/provider/$userId/dashboard'),
//       );
//       final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];
//       walletBalance =
//           double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;

//       progress = {
//         "signed_up": true,
//         "payment_done":
//             latestPayment != null &&
//             (latestPayment['payment_record_status'] == 'paid' ||
//                 latestPayment['payment_record_status'] == 'completed'),
//         "documents_submitted": provider?['documents_uploaded'] == true,
//         "under_review": overallStatus == 'under_review',
//         "approved": provider?['provider_status'] == 'approved',
//         "rejected": provider?['provider_status'] == 'rejected',
//       };
//       setState(() => isLoading = false);
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchUserDashboard() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//     try {
//       final url = '${Backend.baseUrl}/users/${widget.userId}/dashboard';
//       final response = await http.get(Uri.parse(url));
//       final data = jsonDecode(response.body)['dashboard'];
//       setState(() {
//         totalBookings = data['totalBookings'] ?? 0;
//         completedTasks = data['completedTasks'] ?? 0;
//         rejectedTasks = data['rejectedTasks'] ?? 0;
//         pendingPayments = data['pendingTasks'] ?? 0;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   // --- UI Layout Design (Matching Image) ---

//   Widget buildSummaryCards() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           if (isProvider)
//             summaryCard(
//               "Earnings",
//               "PKR\n${totalEarnings.toStringAsFixed(2)}",
//               Icons.monetization_on_outlined,
//               const Color(0xFF4CAF50),
//             ),
//           summaryCard(
//             "Completed",
//             "$completedTasks",
//             Icons.check_circle_outline,
//             const Color(0xFF42A5F5),
//           ),
//           summaryCard(
//             "Pending",
//             "$pendingPayments",
//             Icons.arrow_circle_down,
//             const Color(0xFFFFA726),
//           ),
//           summaryCard(
//             "Bookings",
//             "$totalBookings",
//             Icons.menu_book_rounded,
//             const Color(0xFF9575CD),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget summaryCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       width: 100,
//       height: 120,
//       margin: const EdgeInsets.only(right: 10),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Icon(icon, color: Colors.white, size: 24),
//         ],
//       ),
//     );
//   }

//   Widget buildTimeline() {
//     if (!isProvider) return const SizedBox.shrink();
//     final steps = [
//       {"key": "signed_up", "label": "Signed Up"},
//       {"key": "payment_done", "label": "Payment"},
//       {"key": "documents_submitted", "label": "Documents"},
//       {"key": "under_review", "label": "Under Review"},
//       {"key": "approved", "label": "Approved"},
//     ];

//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Progress",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF333333),
//               ),
//             ),
//             const Divider(),
//             ...steps.map((step) {
//               final isDone = progress[step['key']] ?? false;
//               final color = isDone ? Colors.green : Colors.grey.shade400;
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           isDone ? Icons.check_circle : Icons.circle,
//                           color: color,
//                           size: 22,
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           step['label']!,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                             color: isDone
//                                 ? Colors.green.shade700
//                                 : Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       isDone ? "Approved" : "",
//                       style: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 12,
//                       ),
//                     ),
//                     Icon(
//                       isDone ? Icons.check_circle_outline : Icons.circle,
//                       color: isDone ? Colors.green : Colors.grey.shade300,
//                       size: 20,
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildActionButtons() {
//     if (!isProvider) return const SizedBox.shrink();
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 3.5,
//       mainAxisSpacing: 10,
//       crossAxisSpacing: 10,
//       children: [
//         actionButton(
//           "Create Service",
//           Icons.add,
//           Colors.white,
//           Colors.black,
//           isApproved,
//           () {},
//         ),
//         actionButton(
//           "ElevateButton",
//           null,
//           const Color(0xFF4CAF50),
//           Colors.white,
//           isApproved,
//           () {},
//         ),
//         actionButton(
//           "Accept Bookings",
//           Icons.check_circle_outline,
//           Colors.white,
//           Colors.black,
//           isApproved,
//           () {},
//         ),
//         actionButton(
//           "View Bookings",
//           null,
//           Colors.white,
//           Colors.black,
//           isApproved,
//           () {},
//         ),
//         actionButton(
//           "View Bookings",
//           Icons.wallet_travel,
//           Colors.white,
//           Colors.black,
//           isApproved,
//           () {},
//         ),
//         actionButton(
//           "View Wallet",
//           null,
//           const Color(0xFF4CAF50),
//           Colors.white,
//           isApproved,
//           () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProviderWalletScreen(providerId: widget.userId),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget actionButton(
//     String label,
//     IconData? icon,
//     Color bgColor,
//     Color textColor,
//     bool enabled,
//     VoidCallback onTap,
//   ) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: bgColor,
//         foregroundColor: textColor,
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         padding: EdgeInsets.zero,
//       ),
//       onPressed: enabled ? onTap : null,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 5)],
//           Text(
//             label,
//             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor, // Light grey background like image
//       appBar: AppBar(
//         backgroundColor: navbarColor, // Dark header from image
//         elevation: 0,
//         leading: const Icon(Icons.menu, color: Colors.white),
//         title: Text(
//           isProvider ? "Provider Dashboard" : "User Dashboard",
//           style: const TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(child: Text(error!))
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 buildSummaryCards(),
//                 const SizedBox(height: 10),
//                 buildTimeline(),
//                 const SizedBox(height: 10),
//                 // Graphs Placeholder matching image style
//                 Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: DashboardGraphs(
//                       userId: widget.userId,
//                       role: widget.role,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//                 buildActionButtons(),
//               ],
//             ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'wallet.dart';
import '../helpers/backend.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charts.dart';
import '../helpers/coolors.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String role;

  const DashboardScreen({super.key, required this.userId, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- PRESERVED LOGIC ---
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
  int rejectedTasks = 0;
  int pendingPayments = 0;
  double totalEarnings = 0.0;
  double walletBalance = 0.0;

  bool get isProvider => widget.role == 'provider';
  bool get isApproved => progress["approved"] == true;

  @override
  void initState() {
    super.initState();
    isProvider ? fetchProviderDashboard() : fetchUserDashboard();
  }

  Future<void> fetchProviderDashboard() async {
    setState(() { isLoading = true; error = null; });
    try {
      final userId = widget.userId;
      final statusRes = await http.get(Uri.parse('${Backend.baseUrl}/provider/status/$userId'));
      if (statusRes.statusCode != 200) throw Exception('Failed to fetch provider status');
      
      final statusData = jsonDecode(statusRes.body);
      final provider = statusData['provider'];
      final latestPayment = statusData['payment'];
      final overallStatus = statusData['overall_status'];

      final summaryRes = await http.get(Uri.parse('${Backend.baseUrl}/tasks/summary?user_id=$userId'));
      final summaryData = jsonDecode(summaryRes.body);

      totalBookings = summaryData['totalTasks'] ?? 0;
      completedTasks = summaryData['completedTasks'] ?? 0;
      rejectedTasks = summaryData['rejectedTasks'] ?? 0;
      pendingPayments = summaryData['pendingTasks'] ?? 0;
      totalEarnings = double.tryParse(summaryData['totalEarnings'].toString()) ?? 0.0;

      final dashboardRes = await http.get(Uri.parse('${Backend.baseUrl}/provider/$userId/dashboard'));
      final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];
      walletBalance = double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;

      progress = {
        "signed_up": true,
        "payment_done": latestPayment != null && (latestPayment['payment_record_status'] == 'paid' || latestPayment['payment_record_status'] == 'completed'),
        "documents_submitted": provider?['documents_uploaded'] == true,
        "under_review": overallStatus == 'under_review',
        "approved": provider?['provider_status'] == 'approved',
        "rejected": provider?['provider_status'] == 'rejected',
      };
      setState(() => isLoading = false);
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }

  Future<void> fetchUserDashboard() async {
    setState(() { isLoading = true; error = null; });
    try {
      final url = '${Backend.baseUrl}/users/${widget.userId}/dashboard';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body)['dashboard'];
      setState(() {
        totalBookings = data['totalBookings'] ?? 0;
        completedTasks = data['completedTasks'] ?? 0;
        rejectedTasks = data['rejectedTasks'] ?? 0;
        pendingPayments = data['pendingTasks'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }

  // --- MODERN UI DESIGN ---

  Widget buildSummaryCards() {
    return Container(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          if (isProvider)
            _buildStatCard("Total Revenue", "PKR ${totalEarnings.toStringAsFixed(0)}", Icons.account_balance_wallet_rounded, kPrimaryColor),
          _buildStatCard("Active Bookings", "$totalBookings", Icons.assignment_rounded, const Color(0xFF2D3436)),
          _buildStatCard("Completed", "$completedTasks", Icons.task_alt_rounded, kSuccessColor),
          _buildStatCard("Pending", "$pendingPayments", Icons.hourglass_empty_rounded, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15, bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kDividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: accentColor.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: accentColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextPrimary)),
              Text(title, style: const TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTimeline() {
    if (!isProvider) return const SizedBox.shrink();
    final steps = [
      {"label": "Registration", "key": "signed_up"},
      {"label": "Payment Verification", "key": "payment_done"},
      {"label": "Document Audit", "key": "documents_submitted"},
      {"label": "Internal Review", "key": "under_review"},
      {"label": "Live Activation", "key": "approved"},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kDividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Account Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kTextPrimary)),
          const SizedBox(height: 20),
          ...steps.map((step) {
            bool isDone = progress[step['key']] ?? false;
            int index = steps.indexOf(step);
            return Row(
              children: [
                Column(
                  children: [
                    Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, 
                         color: isDone ? kSuccessColor : kTextHint, size: 22),
                    if (index != steps.length - 1)
                      Container(width: 2, height: 25, color: isDone ? kSuccessColor : kDividerColor),
                  ],
                ),
                const SizedBox(width: 15),
                Text(step['label']!, 
                     style: TextStyle(color: isDone ? kTextPrimary : kTextSecondary, 
                     fontWeight: isDone ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    if (!isProvider) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          children: [
            _expandedActionBtn("My Wallet", Icons.account_balance_wallet_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderWalletScreen(providerId: widget.userId)));
            }, isPrimary: true),
            const SizedBox(width: 12),
            _expandedActionBtn("New Service", Icons.add_box_outlined, () {}, isPrimary: false),
          ],
        ),
      ],
    );
  }

  Widget _expandedActionBtn(String label, IconData icon, VoidCallback onTap, {required bool isPrimary}) {
    return Expanded(
      child: InkWell(
        onTap: isApproved ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? kPrimaryColor : kCardColor,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: kDividerColor),
            boxShadow: isPrimary ? [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.white : kTextPrimary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isPrimary ? Colors.white : kTextPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

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
        title: Text(isProvider ? "Provider Console" : "My Dashboard", 
               style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: kTextPrimary), onPressed: () {}),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : error != null
              ? Center(child: Text("Error: $error"))
              : RefreshIndicator(
                  onRefresh: isProvider ? fetchProviderDashboard : fetchUserDashboard,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      const Text("Performance Overview", style: TextStyle(fontSize: 14, color: kTextSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),
                      buildSummaryCards(),
                      buildTimeline(),
                      const Text("Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kTextPrimary)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: kDividerColor.withOpacity(0.5))),
                        child: DashboardGraphs(userId: widget.userId, role: widget.role),
                      ),
                      const SizedBox(height: 25),
                      buildActionButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}