import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/backend.dart';
import '../helpers/coolors.dart'; // Using your provided colors
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardGraphs extends StatefulWidget {
  final int userId;
  final String role;

  const DashboardGraphs({super.key, required this.userId, required this.role});

  @override
  State<DashboardGraphs> createState() => _DashboardGraphsState();
}

class _DashboardGraphsState extends State<DashboardGraphs> {
  bool isLoading = true;
  String? error;

  int completed = 0;
  int inProgress = 0;
  int rejected = 0;
  int pending = 0;

  Map<String, double> paymentsPerMonth = {};

  @override
  void initState() {
    super.initState();
    fetchGraphsData();
  }

  // --- Logic kept same as requested ---
  Future<void> fetchGraphsData() async {
    setState(() { isLoading = true; error = null; });
    try {
      final tasksUrl = Uri.parse('${Backend.baseUrl}/tasks/summary?user_id=${widget.userId}');
      final tasksRes = await http.get(tasksUrl);
      if (tasksRes.statusCode != 200) throw Exception('Failed to fetch tasks');
      final tasksData = jsonDecode(tasksRes.body);

      completed = tasksData['completedTasks'] ?? 0;
      inProgress = tasksData['inProgressTasks'] ?? 0;
      rejected = tasksData['rejectedTasks'] ?? 0;
      pending = tasksData['pendingTasks'] ?? 0;

      if (widget.role == 'provider') {
        final paymentsUrl = Uri.parse('${Backend.baseUrl}/provider/wallet/${widget.userId}/history');
        final paymentsRes = await http.get(paymentsUrl);
        if (paymentsRes.statusCode == 200) {
          final paymentsData = jsonDecode(paymentsRes.body)['transactions'] as List;
          paymentsPerMonth.clear();
          for (var txn in paymentsData) {
            final date = DateTime.parse(txn['created_at']);
            final month = "${date.month}/${date.year.toString().substring(2)}";
            final amount = double.tryParse(txn['amount'].toString()) ?? 0.0;
            paymentsPerMonth[month] = (paymentsPerMonth[month] ?? 0) + amount;
          }
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }

  // --- 1️⃣ Pie Chart for Tasks (Fixes Overflow & Looks Better) ---
  Widget tasksPieChart() {
    int total = completed + inProgress + rejected + pending;
    if (total == 0) return const Center(child: Text("No Data Available", style: TextStyle(color: kTextSecondary)));

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(value: completed.toDouble(), color: kSuccessColor, radius: 40, showTitle: false),
                  PieChartSectionData(value: inProgress.toDouble(), color: kPrimaryColor, radius: 40, showTitle: false),
                  PieChartSectionData(value: rejected.toDouble(), color: redAccent, radius: 40, showTitle: false),
                  PieChartSectionData(value: pending.toDouble(), color: kWarningColor, radius: 40, showTitle: false),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _indicator(kSuccessColor, "Done"),
              _indicator(kPrimaryColor, "In Prog"),
              _indicator(kWarningColor, "Pend"),
              _indicator(redAccent, "Rej"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicator(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: kTextPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 2️⃣ Line Chart (Fixed Styles & Colors) ---
 Widget paymentsLineChart() {
  if (paymentsPerMonth.isEmpty) return const Center(child: Text("No payments yet", style: TextStyle(color: kTextSecondary)));

  final months = paymentsPerMonth.keys.toList();
  final values = months.map((m) => paymentsPerMonth[m] ?? 0.0).toList();

  return SizedBox(
    height: 180,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: true, horizontalInterval: 1000),
        borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(), left: BorderSide())),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1000, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                if (val.toInt() < 0 || val.toInt() >= months.length) return const SizedBox.shrink();
                return Text(months[val.toInt()], style: const TextStyle(fontSize: 10, color: kTextSecondary));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
            isCurved: true,
            color: kPrimaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: kPrimaryColor.withOpacity(0.1)),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!, style: const TextStyle(color: redAccent)));

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _chartCard("Tasks Overview", tasksPieChart()),
          if (widget.role == 'provider') ...[
            const SizedBox(height: 16),
            _chartCard("Earnings Trend", paymentsLineChart()),
          ],
        ],
      ),
    );
  }

  Widget _chartCard(String title, Widget chart) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextPrimary)),
          const SizedBox(height: 12),
          chart,
        ],
      ),
    );
  }
}