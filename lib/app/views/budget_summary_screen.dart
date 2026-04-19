import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../utils/currency_utils.dart';

class BudgetSummaryScreen extends StatelessWidget {
  const BudgetSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = Get.find<ExpenseController>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() => Column(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 20),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              const Text('Budget Summary', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  GestureDetector(onTap: () => ec.changeMonth(-1),
                      child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 20)),
                  Obx(() => Text(ec.monthLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                  GestureDetector(onTap: () => ec.changeMonth(1),
                      child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20)),
                ]),
              ),
            ]),
            const SizedBox(height: 16),
            // Overview row
            Row(children: [
              _pill('Total Budget', ec.monthlyBudget.value),
              const SizedBox(width: 10),
              _pill('Spent', ec.totalSpent),
              const SizedBox(width: 10),
              _pill('Left', ec.remainingBalance),
            ]),
          ]),
        ),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ec.categories.length,
          itemBuilder: (_, i) {
            final cat    = ec.categories[i];
            final color  = Color(cat.colorValue);
            final icon   = IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');
            final spent  = ec.spentForCategory(cat.id);
            final budget = cat.budgetLimit > 0 ? cat.budgetLimit : (ec.monthlyBudget.value / ec.categories.length);
            final pct    = (spent / budget).clamp(0.0, 1.0);
            final exps   = ec.monthExpenses.where((e) => e.categoryId == cat.id).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: color, size: 20)),
                  title: Row(children: [
                    Expanded(child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary))),
                    Text(CurrencyUtils.format(budget - spent),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                            color: pct > 1 ? AppTheme.danger : AppTheme.success)),
                  ]),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 4),
                    Text('${CurrencyUtils.format(spent)} from ${CurrencyUtils.format(budget)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const SizedBox(height: 5),
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                      value: pct, minHeight: 6, backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation(pct > 0.9 ? AppTheme.danger : pct > 0.7 ? AppTheme.warning : color),
                    )),
                    const SizedBox(height: 2),
                    Text('Remaining', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                  ]),
                  children: exps.isEmpty
                    ? [const Padding(padding: EdgeInsets.all(12), child: Text('No expenses', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))]
                    : exps.map((e) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        title: Text(e.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                        subtitle: Text('${e.status} · ${e.date.day}/${e.date.month}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        trailing: Text(CurrencyUtils.format(e.amount),
                            style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700, fontSize: 13)),
                      )).toList(),
                ),
              ),
            );
          },
        )),
      ])),
    );
  }

  Widget _pill(String label, double val) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      const SizedBox(height: 2),
      Text(CurrencyUtils.formatCompact(val.abs()), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  ));
}
