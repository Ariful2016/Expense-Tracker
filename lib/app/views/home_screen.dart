import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/expense_model.dart';
import '../utils/currency_utils.dart';
import '../utils/icon_mapper.dart';
import '../widgets/dart_theme.dart';
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
        backgroundColor: DarkTheme.background,
        body: screens[ec.bottomNavIndex.value],
        floatingActionButton: _GlowFAB(
          onTap: () => Get.to(
                () => const AddExpenseScreen(),
            transition: Transition.downToUp,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _BottomBar(ec: ec),
      );
    });
  }
}

// ─── Glowing FAB ─────────────────────────────────────────────────────────────
class _GlowFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _GlowFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [DarkTheme.primary, DarkTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: DarkTheme.primary.withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: DarkTheme.primary.withOpacity(0.2),
              blurRadius: 60,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

// ─── Bottom Navigation Bar ───────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final ExpenseController ec;
  const _BottomBar({required this.ec});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: const Color(0xF0181825),
        elevation: 0,
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: DarkTheme.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              _navItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home'),
              _navItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Expenses'),
              const SizedBox(width: 56),
              _navItem(2, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
              _navItem(3, Icons.category_outlined, Icons.category_rounded, 'Categories'),
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
              color: isSelected ? DarkTheme.primaryLight : DarkTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? DarkTheme.primaryLight : DarkTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final ExpenseController ec;
  const _DashboardTab({required this.ec});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        //SliverToBoxAdapter(child: _buildOverviewGrid()),
        SliverToBoxAdapter(child: _buildBudgetSummary()),
        SliverToBoxAdapter(child: _buildRecentExpenses(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Obx(
          () => Stack(
        children: [
          // Glow background
          Container(
            height: 360,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1630), DarkTheme.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Purple orb top-right
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DarkTheme.primary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Green orb bottom-left
          Positioned(
            bottom: 0,
            left: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DarkTheme.success.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
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
                          style: const TextStyle(
                            color: DarkTheme.textSecondary,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'My Budget',
                          style: TextStyle(
                            color: DarkTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _headerIconBtn(
                          Icons.edit_rounded,
                          onTap: () => _showBudgetDialog(context),
                        ),
                        const SizedBox(width: 8),
                        _headerIconBtn(
                          Icons.bar_chart_rounded,
                          onTap: () => Get.to(() => const AnalyticsScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Month nav
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => ec.changeMonth(-1),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: DarkTheme.textMuted,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Obx(
                          () => Text(
                        '${ec.monthNameFull(ec.selectedMonth.value)} ${ec.selectedYear.value}',
                        style: const TextStyle(
                          color: DarkTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => ec.changeMonth(1),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: DarkTheme.textMuted,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Balance hero
                Column(
                  children: [
                    // Badge pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DarkTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DarkTheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: DarkTheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: DarkTheme.primary,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Monthly Budget',
                            style: TextStyle(
                              color: DarkTheme.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                          () => Text(
                        CurrencyUtils.format(ec.monthlyBudget.value),
                        style: const TextStyle(
                          color: DarkTheme.textPrimary,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),
                    ),
                    /*const SizedBox(height: 5),
                    Obx(
                          () => Text(
                        '${ec.monthExpenses.length} transactions this month',
                        style: const TextStyle(
                          color: DarkTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),*/
                  ],
                ),
                const SizedBox(height: 12),

                // Stat pills row
                Row(
                  children: [
                    Expanded(
                      child: _statPill(
                        'Spent',
                        CurrencyUtils.formatCompact(ec.totalSpent.abs()),
                        DarkTheme.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statPill(
                        'Remaining',
                        CurrencyUtils.formatCompact(ec.remainingBalance.abs()),
                        ec.isOverBudget ? DarkTheme.danger : DarkTheme.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _statPill(
                        'Txns',
                        ec.monthExpenses.length.toString(),
                        DarkTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress bar card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: DarkTheme.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(ec.spentPct * 100).toStringAsFixed(1)}% of budget used',
                            style: const TextStyle(
                              color: DarkTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          Obx(
                                () => Text(
                              ec.isOverBudget ? '⚠ Over Budget!' : 'On Track',
                              style: TextStyle(
                                color: ec.isOverBudget
                                    ? DarkTheme.danger
                                    : DarkTheme.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Gradient progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 6,
                          child: Stack(
                            children: [
                              Container(color: Colors.white.withOpacity(0.07)),
                              FractionallySizedBox(
                                widthFactor: ec.spentPct.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: ec.spentPct > 0.9
                                          ? [DarkTheme.danger, const Color(0xFFFF3D6B)]
                                          : ec.spentPct > 0.7
                                          ? [DarkTheme.warning, const Color(0xFFFF8C42)]
                                          : [DarkTheme.primary, DarkTheme.primaryLight],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DarkTheme.border),
        ),
        child: Icon(icon, color: DarkTheme.textSecondary, size: 16),
      ),
    );
  }

  Widget _statPill(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DarkTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: DarkTheme.textMuted,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Overview Grid ───────────────────────────────────────────────────────────
  Widget _buildOverviewGrid() {
    return Obx(() {
      if (ec.categories.isEmpty) return const SizedBox.shrink();
      final top2 = ec.categories.take(2).toList();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Overview',
                style: TextStyle(
                  color: DarkTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              children: top2.map((cat) {
                final spent = ec.spentForCategory(cat.id);
                final color = Color(cat.colorValue);
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: top2.indexOf(cat) == 0 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: DarkTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: DarkTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                AppIcons.map[cat.icon] ?? Icons.category,
                                color: color,
                                size: 18,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: DarkTheme.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '+12%',
                                style: TextStyle(
                                  color: DarkTheme.danger,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          CurrencyUtils.formatCompact(spent),
                          style: const TextStyle(
                            color: DarkTheme.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat.name,
                          style: const TextStyle(
                            color: DarkTheme.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  // ── Budget Summary ──────────────────────────────────────────────────────────
  Widget _buildBudgetSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Summary',
                style: TextStyle(
                  color: DarkTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const BudgetSummaryScreen()),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: DarkTheme.primaryLight,
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
                final budget = cat.budgetLimit > 0 ? cat.budgetLimit : 1.0;
                final pct = (spent / budget).clamp(0.0, 1.0);
                final color = Color(cat.colorValue);
                final remaining = budget - spent;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DarkTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DarkTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          AppIcons.map[cat.icon] ?? Icons.category,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: const TextStyle(
                                color: DarkTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${CurrencyUtils.format(spent)} of ${CurrencyUtils.format(budget)}',
                              style: const TextStyle(
                                color: DarkTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 7),
                            // Gradient progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 4,
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: pct,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: pct > 0.9
                                                ? [DarkTheme.danger, const Color(0xFFFF3D6B)]
                                                : pct > 0.7
                                                ? [DarkTheme.warning, const Color(0xFFFF8C42)]
                                                : [color, color.withOpacity(0.6)],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyUtils.format(remaining),
                            style: TextStyle(
                              color: pct > 0.9
                                  ? DarkTheme.danger
                                  : DarkTheme.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'left',
                            style: TextStyle(
                              color: DarkTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
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
  }

  // ── Recent Expenses ─────────────────────────────────────────────────────────
  Widget _buildRecentExpenses(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  color: DarkTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => ec.bottomNavIndex.value = 1,
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: DarkTheme.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final exps = ec.monthExpenses.take(5).toList();
            if (exps.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: DarkTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DarkTheme.border),
                ),
                child: const Center(
                  child: Text(
                    'No expenses yet. Tap + to add!',
                    style: TextStyle(color: DarkTheme.textSecondary),
                  ),
                ),
              );
            }
            return Column(
              children: exps.map((e) => _expenseRow(e)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _expenseRow(ExpenseModel e) {
    final color = ec.colorOf(e.categoryId);
    final icon = ec.iconOf(e.categoryId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DarkTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DarkTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                    color: DarkTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM yyyy').format(e.date),
                  style: const TextStyle(
                    color: DarkTheme.textMuted,
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
                  color: DarkTheme.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              _statusBadge(e.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid
            ? DarkTheme.success.withOpacity(0.12)
            : DarkTheme.warning.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.capitalizeFirst!,
        style: TextStyle(
          color: isPaid ? DarkTheme.success : DarkTheme.warning,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Budget Dialog ───────────────────────────────────────────────────────────
  void _showBudgetDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: ec.monthlyBudget.value.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DarkTheme.border),
        ),
        title: const Text(
          'Set Monthly Budget',
          style: TextStyle(
            color: DarkTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: DarkTheme.textPrimary),
              decoration: InputDecoration(
                prefixText: '৳ ',
                prefixStyle: const TextStyle(color: DarkTheme.primaryLight),
                hintText: '30000',
                hintStyle: const TextStyle(color: DarkTheme.textMuted),
                filled: true,
                fillColor: DarkTheme.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: DarkTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: DarkTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: DarkTheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [10000, 20000, 30000, 50000]
                  .map(
                    (v) => GestureDetector(
                  onTap: () => ctrl.text = v.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: DarkTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DarkTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '৳${v ~/ 1000}K',
                      style: const TextStyle(
                        color: DarkTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: DarkTheme.textSecondary),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DarkTheme.primary, DarkTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
          ),
        ],
      ),
    );
  }
}

// ─── Transactions Tab ─────────────────────────────────────────────────────────
class _TransactionsTab extends StatelessWidget {
  final ExpenseController ec;
  const _TransactionsTab({required this.ec});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkTheme.background,
      body: Column(
        children: [
          // Header
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1630), DarkTheme.background],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                height: 160,
              ),
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DarkTheme.primary.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
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
                            color: DarkTheme.textPrimary,
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
                                color: DarkTheme.textMuted,
                                size: 26,
                              ),
                            ),
                            Obx(
                                  () => Text(
                                ec.monthLabel,
                                style: const TextStyle(
                                  color: DarkTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ec.changeMonth(1),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: DarkTheme.textMuted,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Filter chips
                    Obx(
                          () => SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip('all', 'All'),
                            ...ec.categories.map((c) => _filterChip(c.id, c.name)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // List
          Expanded(
            child: Obx(() {
              final exps = ec.filteredExpenses;
              if (exps.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: DarkTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: DarkTheme.border),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: DarkTheme.textMuted,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No transactions',
                        style: TextStyle(color: DarkTheme.textSecondary),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: exps.length,
                itemBuilder: (_, i) => _buildExpItem(context, exps[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    return Obx(() {
      final isSelected = ec.selectedCategoryId.value == id;
      return GestureDetector(
        onTap: () => ec.selectedCategoryId.value = id,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? DarkTheme.primary.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? DarkTheme.primary.withOpacity(0.5)
                  : DarkTheme.border,
            ),
          ),
          child: Text(
            label.length > 10 ? label.substring(0, 10) : label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? DarkTheme.primaryLight : DarkTheme.textMuted,
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
          color: DarkTheme.danger.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DarkTheme.danger.withOpacity(0.3)),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: DarkTheme.danger,
          size: 22,
        ),
      ),
      confirmDismiss: (_) async => await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: DarkTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: DarkTheme.border),
          ),
          title: const Text(
            'Delete Expense',
            style: TextStyle(color: DarkTheme.textPrimary),
          ),
          content: Text(
            'Delete "${e.title}"?',
            style: const TextStyle(color: DarkTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: DarkTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Delete',
                style: TextStyle(color: DarkTheme.danger),
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
            color: DarkTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DarkTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(13),
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
                        color: DarkTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
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
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM yyyy').format(e.date),
                          style: const TextStyle(
                            color: DarkTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    if (e.note != null && e.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        e.note!,
                        style: const TextStyle(
                          color: DarkTheme.textMuted,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyUtils.format(e.amount),
                    style: const TextStyle(
                      color: DarkTheme.danger,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _statusBadge(e.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid
            ? DarkTheme.success.withOpacity(0.12)
            : DarkTheme.warning.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.capitalizeFirst!,
        style: TextStyle(
          color: isPaid ? DarkTheme.success : DarkTheme.warning,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

