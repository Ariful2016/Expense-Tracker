import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../controllers/app_controller.dart';
import '../../analytics/views/analytics_view.dart';
import '../../category/views/category_view.dart';
import 'dashboard_view.dart';

class MainView extends StatelessWidget {
  final controller = Get.put(AppController());
  final pageIndex = 0.obs;

  // Updated pages list
  final pages = [
    DashboardView(),
    AnalyticsView(),
    CategoryView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => pages[pageIndex.value]), // Shows the selected page
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3A6FF7),
        onPressed: () => _showAddExpenseDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    return Obx(() => BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: pageIndex.value == 0 ? const Color(0xFF3A6FF7) : Colors.grey),
              onPressed: () => pageIndex.value = 0,
            ),
            IconButton(
              icon: Icon(Icons.bar_chart, color: pageIndex.value == 1 ? const Color(0xFF3A6FF7) : Colors.grey),
              onPressed: () => pageIndex.value = 1,
            ),
            const SizedBox(width: 40), // Space for FAB
            IconButton(
              icon: Icon(Icons.category, color: pageIndex.value == 2 ? const Color(0xFF3A6FF7) : Colors.grey),
              onPressed: () => pageIndex.value = 2,
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ));
  }

// _showAddExpenseDialog and other functions go here...

  void _showAddExpenseDialog() {
    // 1. Check if categories exist first (Crucial for spreadsheet logic)
    if (controller.categories.isEmpty) {
      Get.snackbar(
        "No Categories",
        "Please create a category (e.g. Home Bazar) first!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    // We use a RxString to track the selection inside the bottom sheet
    var selectedCatId = controller.categories.first.id.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "Add New Expense",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),

              // Title Input
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "What did you buy?",
                  hintText: "e.g. Fish, Rent, Gas Bill",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
              const SizedBox(height: 15),

              // Amount Input
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (Tk)",
                  hintText: "0.00",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 15),

              // Category Dropdown
              const Text("Select Category", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCatId.value,
                    isExpanded: true,
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selectedCatId.value = val;
                    },
                  ),
                ),
              )),

              const SizedBox(height: 25),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A6FF7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
                      Get.snackbar("Error", "Please fill all fields");
                      return;
                    }

                    // Add to controller
                    controller.addExpense(
                        titleCtrl.text,
                        double.parse(amountCtrl.text),
                        selectedCatId.value
                    );

                    Get.back(); // Close bottom sheet
                    Get.snackbar("Success", "Expense added to ${controller.categories.firstWhere((c)=>c.id == selectedCatId.value).name}");
                  },
                  child: const Text(
                      "Save Expense",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 20), // Padding for bottom
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Allows keyboard to push the sheet up
    );
  }
}