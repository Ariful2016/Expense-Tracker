import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../data/models/expense_model.dart';
import '../utils/currency_utils.dart';
import '../utils/icon_mapper.dart';
import '../widgets/dart_theme.dart';

class BudgetSummaryScreen extends StatelessWidget {
  const BudgetSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = Get.find<ExpenseController>();
    return Scaffold(
      backgroundColor: DarkTheme.background,
      body: Obx(
            () => Column(
          children: [
            _buildHeader(context, ec),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: ec.categories.length,
                itemBuilder: (_, i) => _buildCategoryBudgetCard(ec, ec.categories[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseController ec) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1630), DarkTheme.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          height: 200,
        ),
        // Decorative orbs
        Positioned(
          top: -50,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
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
        Positioned(
          bottom: 20,
          left: 10,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DarkTheme.success.withOpacity(0.08),
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
            bottom: 0,
          ),
          child: Column(
            children: [
              // Top row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DarkTheme.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: DarkTheme.textSecondary,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Budget Summary',
                    style: TextStyle(
                      color: DarkTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: DarkTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => ec.changeMonth(-1),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: DarkTheme.textSecondary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Obx(
                              () => Text(
                            ec.monthLabel,
                            style: const TextStyle(
                              color: DarkTheme.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => ec.changeMonth(1),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: DarkTheme.textSecondary,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Overview pills
              Row(
                children: [
                  _buildPill('Total Budget', ec.monthlyBudget.value, DarkTheme.primary),
                  const SizedBox(width: 10),
                  _buildPill('Spent', ec.totalSpent, DarkTheme.danger),
                  const SizedBox(width: 10),
                  _buildPill(
                    'Remaining',
                    ec.remainingBalance,
                    ec.isOverBudget ? DarkTheme.danger : DarkTheme.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill(String label, double val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: DarkTheme.textMuted,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyUtils.formatCompact(val.abs()),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgetCard(ExpenseController ec, CategoryModel cat) {
    final color = Color(cat.colorValue);
    final spent = ec.spentForCategory(cat.id);
    final budget = cat.budgetLimit > 0 ? cat.budgetLimit : 0.0;
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final exps = ec.monthExpenses.where((e) => e.categoryId == cat.id).toList();
    final isOverBudget = spent > budget && budget > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DarkTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DarkTheme.border),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          iconColor: color,
          collapsedIconColor: DarkTheme.textMuted,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(
              AppIcons.map[cat.icon] ?? Icons.category,
              color: color,
              size: 22,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: DarkTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${CurrencyUtils.format(budget - spent)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isOverBudget
                          ? DarkTheme.danger
                          : pct > 0.7
                          ? DarkTheme.warning
                          : DarkTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyUtils.format(spent)} / ${CurrencyUtils.format(budget)}',
                    style: const TextStyle(
                      color: DarkTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isOverBudget
                          ? DarkTheme.danger
                          : pct > 0.7
                          ? DarkTheme.warning
                          : DarkTheme.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation(
                    isOverBudget
                        ? DarkTheme.danger
                        : pct > 0.7
                        ? DarkTheme.warning
                        : color,
                  ),
                ),
              ),
            ],
          ),
          subtitle: null,
          children: exps.isEmpty
              ? [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DarkTheme.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: DarkTheme.border),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: DarkTheme.textMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No expenses',
                      style: TextStyle(
                        color: DarkTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
              : exps
              .map(
                (e) => Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: DarkTheme.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DarkTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DarkTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: e.status == 'paid'
                                    ? DarkTheme.success.withOpacity(0.12)
                                    : DarkTheme.warning.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                e.status.capitalizeFirst ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: e.status == 'paid'
                                      ? DarkTheme.success
                                      : DarkTheme.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${e.date.day}/${e.date.month}/${e.date.year}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: DarkTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyUtils.format(e.amount),
                    style: const TextStyle(
                      color: DarkTheme.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

