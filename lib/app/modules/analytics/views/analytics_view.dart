import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';

class AnalyticsView extends StatelessWidget {
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(child: Text("Add categories to see analytics"));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComparisonHeader(),
              const SizedBox(height: 30),
              const Text("Spending Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildPieChartSection(),
              const SizedBox(height: 30),
              _buildCategoryLegend(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildComparisonHeader() {
    return Row(
      children: [
        Expanded(child: _statCard("Budget", controller.totalBudget, Colors.blue)),
        const SizedBox(width: 15),
        Expanded(child: _statCard("Spent", controller.totalSpent, Colors.redAccent)),
      ],
    );
  }

  Widget _statCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 5),
          Text("${amount.toStringAsFixed(0)} Tk",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 50,
          sections: controller.categories.map((cat) {
            double spent = controller.categorySpent(cat.id);
            return PieChartSectionData(
              color: Color(cat.color),
              value: spent == 0 ? 0.1 : spent, // Avoid 0 for chart
              title: spent > 0 ? '${((spent / controller.totalSpent) * 100).toInt()}%' : '',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryLegend() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.categories.length,
      itemBuilder: (context, i) {
        final cat = controller.categories[i];
        final spent = controller.categorySpent(cat.id);
        return ListTile(
          leading: CircleAvatar(backgroundColor: Color(cat.color), radius: 6),
          title: Text(cat.name),
          trailing: Text("${spent.toStringAsFixed(0)} Tk", style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}