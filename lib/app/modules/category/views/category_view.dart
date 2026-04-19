import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';

class CategoryView extends StatelessWidget {
  final controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () => _showAddCategoryDialog(), icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(child: Text("No categories created yet."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.categories.length,
          itemBuilder: (context, i) {
            final cat = controller.categories[i];
            return Dismissible(
              key: Key(cat.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.fromLTRB(0,0,20,0),
                color: Colors.redAccent,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => controller.deleteCategory(cat.id),
              child: _buildCategoryItem(cat),
            );
          },
        );
      }),
    );
  }

  Widget _buildCategoryItem(cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(cat.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.folder_open, color: Color(cat.color)),
        ),
        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Budget: ${cat.budget.toStringAsFixed(0)} Tk"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          // You could navigate to a detailed view of items in this category here
          Get.snackbar("Category Info", "${cat.name} Sub-total: ${controller.categorySpent(cat.id)} Tk");
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    Get.defaultDialog(
      title: "New Category",
      content: Column(
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name (e.g. Rent)")),
          TextField(controller: budgetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Budget")),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (nameCtrl.text.isNotEmpty && budgetCtrl.text.isNotEmpty) {
            controller.addCategory(nameCtrl.text, double.parse(budgetCtrl.text));
            Get.back();
          }
        },
        child: const Text("Add"),
      ),
    );
  }
}