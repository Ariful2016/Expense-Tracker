import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../data/models/expense_model.dart';

class ExpenseController extends GetxController {
  late Box<ExpenseModel> _expBox;
  late Box<CategoryModel> _catBox;
  late Box _settingsBox;

  final RxDouble monthlyBudget = 30000.0.obs;
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt bottomNavIndex = 0.obs;
  final RxString selectedCategoryId = 'all'.obs;

  // ── Derived ────────────────────────────────────────────────
  List<ExpenseModel> get monthExpenses =>
      expenses
          .where(
            (e) =>
                e.date.month == selectedMonth.value &&
                e.date.year == selectedYear.value,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double get totalSpent => monthExpenses.fold(0.0, (s, e) => s + e.amount);

  double get remainingBalance => monthlyBudget.value - totalSpent;

  double get spentPct => monthlyBudget.value == 0
      ? 0
      : (totalSpent / monthlyBudget.value).clamp(0.0, 1.0);

  bool get isOverBudget => totalSpent > monthlyBudget.value;

  List<ExpenseModel> get filteredExpenses {
    if (selectedCategoryId.value == 'all') return monthExpenses;
    return monthExpenses
        .where((e) => e.categoryId == selectedCategoryId.value)
        .toList();
  }

  // Category spend
  double spentForCategory(String catId) => monthExpenses
      .where((e) => e.categoryId == catId)
      .fold(0.0, (s, e) => s + e.amount);

  double budgetForCategory(String catId) =>
      categories.firstWhereOrNull((c) => c.id == catId)?.budgetLimit ?? 0;

  Map<String, double> get categoryBreakdown {
    final m = <String, double>{};
    for (final e in monthExpenses)
      m[e.categoryId] = (m[e.categoryId] ?? 0) + e.amount;
    return m;
  }

  Map<int, double> get dailySpending {
    final m = <int, double>{};
    for (final e in monthExpenses)
      m[e.date.day] = (m[e.date.day] ?? 0) + e.amount;
    return m;
  }

  double get avgDailySpend {
    final today = DateTime.now();
    final days =
        (selectedYear.value == today.year && selectedMonth.value == today.month)
        ? today.day
        : DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;
    return days == 0 ? 0 : totalSpent / days;
  }

  CategoryModel? categoryById(String id) =>
      categories.firstWhereOrNull((c) => c.id == id);

  String get monthLabel =>
      '${_monthName(selectedMonth.value)} ${selectedYear.value}';

  String _monthName(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];

  String monthNameFull(int m) => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][m - 1];

  // ── Init ───────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    _expBox = await Hive.openBox<ExpenseModel>('expenses_v2');
    _catBox = await Hive.openBox<CategoryModel>('categories_v2');
    _settingsBox = await Hive.openBox('settings_v2');
    monthlyBudget.value = _settingsBox.get('budget', defaultValue: 30000.0);
    if (_catBox.isEmpty) _seedCategories();
    _load();
  }

  void _load() {
    final list = _catBox.values.toList();

    list.sort((a, b) => a.order.compareTo(b.order));

    categories.assignAll(list);
    expenses.assignAll(_expBox.values.toList());
  }

  // Default categories matching spreadsheet
  static List<Map<String, dynamic>> get defaultCategories => [
    {
      'id': 1,
      'name': 'Home',
      'color': 0xFF2F6FED,
      'icon': 0xe88a,
      'subs': [
        'Rent',
        'Gas Bill',
        'Electricity',
        'Internet Bill',
        'Bua',
        'Service Charge',
        'Others',
      ],
    },
    {
      'id': 2,
      'name': 'Home Bazar',
      'color': 0xFF18C76E,
      'icon': 0xe59c,
      'subs': ['vegetables', 'Fish', 'Meat', 'Oil', 'Fruits', 'Rice', 'Soap' ,'shampoo', 'Other']
    },
    {
      'id': 3,
      'name': 'Outside Food',
      'color': 0xFFFF6D00,
      'icon': 0xef55,
      'subs': ['Office Party', 'Others', 'Iftar', 'Office Boishaki Voj'],
    },
    {
      'id': 4,
      'name': 'Medical',
      'color': 0xFFFF5252,
      'icon': 0xe548,
      'subs': ['Gym Fee', 'Fees', 'Medicines'],
    },

    {'id': 5, 'name': 'Shopping', 'color': 0xFFE91E63, 'icon': 0xef69, 'subs': []},
    {'id': 6, 'name': 'Education', 'color': 0xFF3F51B5, 'icon': 0xe80c, 'subs': []},
    {'id': 7, 'name': 'Transport', 'color': 0xFF00BCD4, 'icon': 0xe1d0, 'subs': []},
    {'id': 8, 'name': 'Savings', 'color': 0xFF4CAF50, 'icon': 0xe227, 'subs': []},
    {'id': 9, 'name': 'Entertainment', 'color': 0xFFFFB300, 'icon': 0xe040, 'subs': []},
  ];

  void _seedCategories() {
    for (final d in defaultCategories) {
      final cat = CategoryModel(
        id: const Uuid().v4(),
        order: d['id'],
        name: d['name'],
        colorValue: d['color'],
        iconCodePoint: d['icon'],
        subItems: List<String>.from(d['subs']),
      );
      _catBox.put(cat.id, cat);
    }
  }

  // ── Expenses ───────────────────────────────────────────────
  Future<void> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    String status = 'paid',
  }) async {
    final e = ExpenseModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      note: note,
      status: status,
    );
    await _expBox.put(e.id, e);
    _load();
  }

  Future<void> updateExpense(ExpenseModel e) async {
    await _expBox.put(e.id, e);
    _load();
  }

  Future<void> deleteExpense(String id) async {
    await _expBox.delete(id);
    _load();
  }

  // ── Categories ────────────────────────────────────────────
  Future<void> addCategory({
    required String name,
    required int colorValue,
    required int iconCodePoint,
    double budgetLimit = 0,
    List<String>? subItems,
  }) async {
    final maxOrder = categories.isEmpty
        ? 0
        : categories.map((c) => c.order).reduce((a, b) => a > b ? a : b);
    final c = CategoryModel(
      id: const Uuid().v4(),
      order: maxOrder + 1,
      name: name,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      budgetLimit: budgetLimit,
      isCustom: true,
      subItems: subItems ?? [],
    );
    await _catBox.put(c.id, c);
    _load();
  }

  Future<void> updateCategory(CategoryModel c) async {
    await _catBox.put(c.id, c);
    _load();
  }

  Future<void> deleteCategory(String id) async {
    // move expenses to 'Other' or first category
    final fallback = categories.firstWhereOrNull((c) => c.id != id)?.id ?? '';
    for (final e in expenses.where((e) => e.categoryId == id)) {
      e.categoryId = fallback;
      await _expBox.put(e.id, e);
    }
    await _catBox.delete(id);
    _load();
  }

  Future<void> setCategoryBudget(String catId, double limit) async {
    final cat = _catBox.get(catId);
    if (cat != null) {
      cat.budgetLimit = limit;
      await _catBox.put(catId, cat);
      _load();
    }
  }

  // ── Settings ──────────────────────────────────────────────
  Future<void> setMonthlyBudget(double v) async {
    monthlyBudget.value = v;
    await _settingsBox.put('budget', v);
  }

  void changeMonth(int d) {
    final dt = DateTime(selectedYear.value, selectedMonth.value + d);
    selectedMonth.value = dt.month;
    selectedYear.value = dt.year;
  }

  Color colorOf(String catId) =>
      Color(categoryById(catId)?.colorValue ?? 0xFF2F6FED);

  IconData iconOf(String catId) => IconData(
    categoryById(catId)?.iconCodePoint ?? 0xe88a,
    fontFamily: 'MaterialIcons',
  );
}
