import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

import '../data/models/category.dart';

class AppController extends GetxController {
  final box = GetStorage();
  var categories = <Category>[].obs;
  var expenses = <Expense>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Calculations
  double get totalBudget => categories.fold(0, (sum, cat) => sum + cat.budget);
  double get totalSpent => expenses.fold(0, (sum, exp) => sum + exp.amount);
  double get totalRemaining => totalBudget - totalSpent;

  double categorySpent(String catId) =>
      expenses.where((e) => e.categoryId == catId).fold(0, (sum, e) => sum + e.amount);

  // Storage
  void loadData() {
    List? catData = box.read('categories');
    List? expData = box.read('expenses');
    if (catData != null) categories.assignAll(catData.map((e) => Category.fromJson(e)).toList());
    if (expData != null) expenses.assignAll(expData.map((e) => Expense.fromJson(e)).toList());
  }

  void saveData() {
    box.write('categories', categories.map((e) => e.toJson()).toList());
    box.write('expenses', expenses.map((e) => e.toJson()).toList());
  }

  // Actions
  void addCategory(String name, double budget) {
    categories.add(Category(id: const Uuid().v4(), name: name, color: 0xFF3A6FF7, budget: budget));
    saveData();
  }

  void addExpense(String title, double amount, String catId) {
    expenses.add(Expense(id: const Uuid().v4(), title: title, amount: amount, categoryId: catId, date: DateTime.now()));
    saveData();
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
    expenses.removeWhere((e) => e.categoryId == id);
    saveData();
  }
}