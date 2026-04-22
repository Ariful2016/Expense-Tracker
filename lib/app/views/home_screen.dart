import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/expense_model.dart';
import '../utils/currency_utils.dart';
import '../utils/icon_mapper.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'category_manager_screen.dart';
import 'budget_summary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = Get.find<ExpenseController>();
    return Obx(() {
      final screens = [
        _DashboardTab(ec: ec),
        _TransactionsTab(ec: ec),
        const AnalyticsScreen(),
        const CategoryManagerScreen(),
      ];
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: screens[ec.bottomNavIndex.value],
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(
            () => const AddExpenseScreen(),
            transition: Transition.downToUp,
          ),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _BottomBar(ec: ec),
      );
    });
  }
}

// ─── Bottom Navigation Bar ──────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final ExpenseController ec;

  const _BottomBar({required this.ec});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _navItem(
                1,
                Icons.receipt_long_outlined,
                Icons.receipt_long_rounded,
                'Expenses',
              ),
              const SizedBox(width: 56),
              _navItem(
                2,
                Icons.bar_chart_outlined,
                Icons.bar_chart_rounded,
                'Analytics',
              ),
              _navItem(
                3,
                Icons.category_outlined,
                Icons.category_rounded,
                'Categories',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData inactive, IconData active, String label) {
    final isSelected = ec.bottomNavIndex.value == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => ec.bottomNavIndex.value = idx,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? active : inactive,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Tab ───────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final ExpenseController ec;

  const _DashboardTab({required this.ec});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: _buildBudgetSummarySection()),
        SliverToBoxAdapter(child: _buildRecentExpenses(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) => Obx(
    () => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primary,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Text(
                    'My Budget',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showBudgetDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.to(() => const AnalyticsScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Month nav
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => ec.changeMonth(-1),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => Text(
                  '${ec.monthNameFull(ec.selectedMonth.value)} ${ec.selectedYear.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => ec.changeMonth(1),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Summary cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _showBudgetDialog(context),
                child: _headerCard(
                  'Total Budget',
                  ec.monthlyBudget.value,
                  AppTheme.accent,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Get.to(() => const CategoryManagerScreen()),
                child: _headerCard('Spent', ec.totalSpent, AppTheme.danger),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Get.to(() => const AnalyticsScreen()),
                child: _headerCard(
                  'Remaining',
                  ec.remainingBalance,
                  ec.isOverBudget ? AppTheme.danger : AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ec.spentPct,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(
                    ec.spentPct > 0.9
                        ? AppTheme.danger
                        : ec.spentPct > 0.7
                        ? AppTheme.warning
                        : AppTheme.success,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(ec.spentPct * 100).toStringAsFixed(1)}% used',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Obx(
                    () => Text(
                      ec.isOverBudget
                          ? 'OVER BUDGET!'
                          : '${ec.monthExpenses.length} transactions',
                      style: TextStyle(
                        color: ec.isOverBudget
                            ? AppTheme.warning
                            : Colors.white70,
                        fontSize: 11,
                        fontWeight: ec.isOverBudget
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _headerCard(String label, double val, Color color) => Container(
    width: 100,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatCompact(val.abs()),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _buildBudgetSummarySection() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budgets Summary',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const BudgetSummaryScreen()),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: ec.categories.map((cat) {
              final spent = ec.spentForCategory(cat.id);
              final budget = cat.budgetLimit > 0 ? cat.budgetLimit : 0.0;
              final pct = (spent / budget).clamp(0.0, 1.0);
              final color = Color(cat.colorValue);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppIcons.map[cat.icon] ?? Icons.category,
                        color: color,
                        size: 20,
                      ),
                    ), //Icon(iconData, color: color, size: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                CurrencyUtils.format(budget - spent),
                                style: TextStyle(
                                  color: pct > 0.9
                                      ? AppTheme.danger
                                      : AppTheme.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${CurrencyUtils.format(spent)} from ${CurrencyUtils.format(budget)}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                'Remaining',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 5,
                              backgroundColor: AppTheme.divider,
                              valueColor: AlwaysStoppedAnimation(
                                pct > 0.9
                                    ? AppTheme.danger
                                    : pct > 0.7
                                    ? AppTheme.warning
                                    : color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildRecentExpenses(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Expenses',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => ec.bottomNavIndex.value = 1,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final exps = ec.monthExpenses.take(5).toList();
          if (exps.isEmpty)
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'No expenses yet. Tap + to add!',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            );
          return Column(children: exps.map((e) => _expenseRow(e)).toList());
        }),
      ],
    ),
  );

  Widget _expenseRow(ExpenseModel e) {
    final color = ec.colorOf(e.categoryId);
    final icon = ec.iconOf(e.categoryId);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('d MMM').format(e.date),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.format(e.amount),
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: e.status == 'paid'
                      ? AppTheme.success.withOpacity(0.12)
                      : AppTheme.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  e.status.capitalizeFirst!,
                  style: TextStyle(
                    fontSize: 9,
                    color: e.status == 'paid'
                        ? AppTheme.success
                        : AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: ec.monthlyBudget.value.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Monthly Budget',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '৳ ',
                hintText: '30000',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [10000, 20000, 30000, 50000]
                  .map(
                    (v) => GestureDetector(
                      onTap: () => ctrl.text = v.toString(),
                      child: Chip(
                        label: Text('৳${v ~/ 1000}K'),
                        backgroundColor: AppTheme.background,
                        side: BorderSide.none,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ec.setMonthlyBudget(
                double.tryParse(ctrl.text) ?? ec.monthlyBudget.value,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Transactions Tab ────────────────────────────────────────────────────────
class _TransactionsTab extends StatelessWidget {
  final ExpenseController ec;

  const _TransactionsTab({required this.ec});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => ec.changeMonth(-1),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Obx(
                        () => Text(
                          ec.monthLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ec.changeMonth(1),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filter chips
              Obx(
                () => SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip('all', 'All', ec),
                      ...ec.categories.map((c) => _chip(c.id, c.name, ec)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final exps = ec.filteredExpenses;
            if (exps.isEmpty)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 60,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No transactions',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: exps.length,
              itemBuilder: (_, i) => _buildExpItem(context, exps[i]),
            );
          }),
        ),
      ],
    ),
  );

  Widget _chip(String id, String label, ExpenseController ec) {
    return Obx(() {
      final isSelected = ec.selectedCategoryId.value == id;
      return GestureDetector(
        onTap: () => ec.selectedCategoryId.value = id,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label.length > 10 ? label.substring(0, 10) : label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.primary : Colors.white70,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExpItem(BuildContext context, ExpenseModel e) {
    final color = ec.colorOf(e.categoryId);
    final icon = ec.iconOf(e.categoryId);
    final catName = ec.categoryById(e.categoryId)?.name ?? '';
    return Dismissible(
      key: Key(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: AppTheme.danger,
          size: 22,
        ),
      ),
      confirmDismiss: (_) async => await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Expense',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Text('Delete "${e.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.danger),
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => ec.deleteExpense(e.id),
      child: GestureDetector(
        onTap: () => Get.to(
          () => AddExpenseScreen(existing: e),
          transition: Transition.downToUp,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            catName,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('d MMM yyyy').format(e.date),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    if (e.note != null && e.note!.isNotEmpty)
                      Text(
                        e.note!,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.format(e.amount),
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: e.status == 'paid'
                          ? AppTheme.success.withOpacity(0.1)
                          : AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      e.status.capitalizeFirst!,
                      style: TextStyle(
                        fontSize: 9,
                        color: e.status == 'paid'
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
