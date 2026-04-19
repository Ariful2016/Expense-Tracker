import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';


class DashboardView extends StatelessWidget {
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Obx(() => Column(
        children: [
          _buildBlueHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              itemCount: controller.categories.length,
              itemBuilder: (context, i) => _buildCategoryCard(controller.categories[i]),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildBlueHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220, width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF3A6FF7),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
          ),
          padding: const EdgeInsets.only(top: 60, left: 25, right: 25),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Budgets", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Monthly Overview", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        Positioned(
          top: 140, left: 20, right: 20,
          child: _buildMainSummaryCard(),
        ),
      ],
    );
  }

  Widget _buildMainSummaryCard() {
    double progress = controller.totalBudget > 0 ? (controller.totalSpent / controller.totalBudget) : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(height: 70, width: 70, child: CircularProgressIndicator(value: progress, strokeWidth: 8, color: const Color(0xFF3A6FF7), backgroundColor: Colors.grey[200])),
            Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Remaining Balance", style: TextStyle(color: Colors.grey)),
            Text("${controller.totalRemaining.toStringAsFixed(0)} Tk", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            Text("from ${controller.totalBudget} Tk", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(cat) {
    double spent = controller.categorySpent(cat.id);
    double progress = cat.budget > 0 ? (spent / cat.budget) : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(children: [
            CircleAvatar(backgroundColor: Color(cat.color).withOpacity(0.1), child: Icon(Icons.shopping_cart, color: Color(cat.color))),
            const SizedBox(width: 15),
            Expanded(child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            Text("${(cat.budget - spent).toStringAsFixed(0)} Tk", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress > 1 ? 1 : progress, color: Color(cat.color), backgroundColor: Colors.grey[200], minHeight: 6),
        ],
      ),
    );
  }
}