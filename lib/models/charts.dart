import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

// Earnings line chart
Widget buildEarningsChart() {
  final List<FlSpot> spots = [
    FlSpot(0, 500),
    FlSpot(1, 1200),
    FlSpot(2, 800),
    FlSpot(3, 1500),
    FlSpot(4, 2000),
  ];

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Earnings Over Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(enabled: true, touchTooltipData: LineTouchTooltipData(
                 // tooltipBgColor: Colors.grey.shade200,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((t) {
                    return LineTooltipItem(
                      "PKR ${t.y.toStringAsFixed(0)}",
                      const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                )),
                gridData: FlGridData(show: true, drawVerticalLine: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Day ${value.toInt() + 1}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "PKR ${value.toInt()}",
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                  left: BorderSide(color: Colors.black, width: 1),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                )),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.green,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Bookings bar chart
Widget buildBookingsChart() {
  final List<BarChartGroupData> barGroups = [
    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.blue, width: 18)]),
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 18)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.blue, width: 18)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: Colors.blue, width: 18)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6, color: Colors.blue, width: 18)]),
  ];

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bookings Over Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Day ${value.toInt() + 1}",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true, border: const Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                  left: BorderSide(color: Colors.black, width: 1),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                )),
                barTouchData: BarTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
