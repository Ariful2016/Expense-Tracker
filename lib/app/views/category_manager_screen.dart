import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/expense_model.dart';
import '../utils/currency_utils.dart';
import '../utils/icon_mapper.dart';
import '../widgets/dart_theme.dart';


class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = Get.find<ExpenseController>();
    return Scaffold(
      backgroundColor: DarkTheme.background,
      body: Column(
        children: [
          // Header with gradient
          Stack(
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
                height: 130,
              ),
              // Purple orb top-right
              Positioned(
                top: -30,
                right: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        DarkTheme.primary.withOpacity(0.15),
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
                  bottom: 16,
                ),
                child: Row(
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
                    const Expanded(
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          color: DarkTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddCategorySheet(context, ec),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: DarkTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DarkTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: DarkTheme.primaryLight,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Category list
          Expanded(
            child: Obx(
                  () => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: ec.categories.length,
                itemBuilder: (_, i) => _buildCategoryCard(
                  context,
                  ec,
                  ec.categories[i],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      ExpenseController ec,
      CategoryModel cat,
      ) {
    final color = Color(cat.colorValue);
    final spent = ec.spentForCategory(cat.id);
    final budget = cat.budgetLimit;
    final pct = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final expCount = ec.monthExpenses.where((e) => e.categoryId == cat.id).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DarkTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DarkTheme.border),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                AppIcons.map[cat.icon] ?? Icons.category,
                color: color,
                size: 22,
              ),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: DarkTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '$expCount expenses this month',
              style: const TextStyle(
                fontSize: 11,
                color: DarkTheme.textMuted,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyUtils.format(spent),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: DarkTheme.textMuted,
                    size: 20,
                  ),
                  color: DarkTheme.surface2,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: DarkTheme.border),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') {
                      _showAddCategorySheet(context, Get.find<ExpenseController>(),
                          existing: cat);
                    }
                    if (v == 'budget') {
                      _showBudgetDialog(context, Get.find<ExpenseController>(), cat);
                    }
                    if (v == 'delete') {
                      _confirmDelete(context, Get.find<ExpenseController>(), cat);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: DarkTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(color: DarkTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'budget',
                      child: Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 16,
                            color: DarkTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Set Budget',
                            style: TextStyle(color: DarkTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 16,
                            color: DarkTheme.danger,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: DarkTheme.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (budget > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar with gradient
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 6,
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
                                  colors: [
                                    pct > 0.9
                                        ? DarkTheme.danger
                                        : pct > 0.7
                                        ? DarkTheme.warning
                                        : color,
                                    (pct > 0.9
                                        ? DarkTheme.danger
                                        : pct > 0.7
                                        ? DarkTheme.warning
                                        : color)
                                        .withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget: ${CurrencyUtils.format(budget)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: DarkTheme.textMuted,
                        ),
                      ),
                      Text(
                        '${(pct * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(
                          fontSize: 11,
                          color: pct > 0.9 ? DarkTheme.danger : DarkTheme.textMuted,
                          fontWeight: pct > 0.9 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Sub-items
          if (cat.subItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cat.subItems
                    .map(
                      (s) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showBudgetDialog(
      BuildContext context,
      ExpenseController ec,
      CategoryModel cat,
      ) {
    final ctrl = TextEditingController(
      text: cat.budgetLimit > 0 ? cat.budgetLimit.toInt().toString() : '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DarkTheme.border),
        ),
        title: Text(
          'Budget for ${cat.name}',
          style: const TextStyle(
            color: DarkTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: DarkTheme.textPrimary),
          decoration: InputDecoration(
            prefixText: '৳ ',
            prefixStyle: const TextStyle(color: DarkTheme.textSecondary),
            hintText: 'e.g. 5000',
            hintStyle: const TextStyle(color: DarkTheme.textMuted),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
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
              borderSide: const BorderSide(
                color: DarkTheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: DarkTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? 0;
              ec.setCategoryBudget(cat.id, v);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context,
      ExpenseController ec,
      CategoryModel cat,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: DarkTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DarkTheme.border),
        ),
        title: const Text(
          'Delete Category',
          style: TextStyle(
            color: DarkTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Delete "${cat.name}"? Expenses will be moved to another category.',
          style: const TextStyle(color: DarkTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: DarkTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              ec.deleteCategory(cat.id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Add/Edit Category Bottom Sheet ────────────────────────────────────────
void _showAddCategorySheet(
    BuildContext context,
    ExpenseController ec, {
      CategoryModel? existing,
    }) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final subCtrl = TextEditingController();
  final subs = RxList<String>(existing?.subItems ?? []);
  final selColor = Rx<int>(existing?.colorValue ?? AppTheme.paletteColors[0].value);
  final selIcon = RxString(existing?.icon ?? _iconOptions[0]['key']);
  final budgetCtrl = TextEditingController(
    text: existing?.budgetLimit != null && existing!.budgetLimit > 0
        ? existing.budgetLimit.toInt().toString()
        : '',
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Obx(
          () => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: DarkTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: DarkTheme.border),
            left: BorderSide(color: DarkTheme.border),
            right: BorderSide(color: DarkTheme.border),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DarkTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Text(
                    existing == null ? 'New Category' : 'Edit Category',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DarkTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: DarkTheme.border),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: DarkTheme.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _label('Category Name'),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(
                        color: DarkTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Education, Daily Bazar...',
                        hintStyle: const TextStyle(color: DarkTheme.textMuted),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
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
                          borderSide: const BorderSide(
                            color: DarkTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Budget
                    _label('Monthly Budget (optional)'),
                    TextField(
                      controller: budgetCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: DarkTheme.textPrimary),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        prefixStyle: const TextStyle(color: DarkTheme.textSecondary),
                        hintText: '0',
                        hintStyle: const TextStyle(color: DarkTheme.textMuted),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
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
                          borderSide: const BorderSide(
                            color: DarkTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Color picker
                    _label('Color'),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: AppTheme.paletteColors.map((c) {
                        final isSelected = selColor.value == c.value;
                        return GestureDetector(
                          onTap: () => selColor.value = c.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                  color: DarkTheme.textPrimary,
                                  width: 3)
                                  : Border.all(
                                  color: Colors.transparent,
                                  width: 3),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: c.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                                  : [],
                            ),
                            child: isSelected
                                ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Icon picker
                    _label('Icon'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: _iconOptions.length,
                      itemBuilder: (_, i) {
                        final option = _iconOptions[i];
                        final isSelected = selIcon.value == option['key'];
                        final color = Color(selColor.value);

                        return GestureDetector(
                          onTap: () => selIcon.value = option['key'],
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.16)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? color.withOpacity(0.4)
                                    : DarkTheme.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Icon(
                              option['icon'],
                              color: isSelected ? color : DarkTheme.textMuted,
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sub-items
                    _label('Sub-items (optional)'),
                    const Text(
                      'Add items like Rent, Electricity under this category',
                      style:
                      TextStyle(fontSize: 11, color: DarkTheme.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: subCtrl,
                            style: const TextStyle(
                              color: DarkTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Add item...',
                              hintStyle:
                              const TextStyle(color: DarkTheme.textMuted),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.04),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: DarkTheme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: DarkTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: DarkTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (v) {
                              if (v.trim().isNotEmpty) {
                                subs.add(v.trim());
                                subCtrl.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(selColor.value),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (subCtrl.text.trim().isNotEmpty) {
                              subs.add(subCtrl.text.trim());
                              subCtrl.clear();
                            }
                          },
                          child: const Icon(Icons.add_rounded, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (subs.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subs
                            .map(
                              (s) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(selColor.value)
                                  .withOpacity(0.12),
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(selColor.value)
                                    .withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(selColor.value),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => subs.remove(s),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color:
                                    Color(selColor.value),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(selColor.value),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final budget =
                              double.tryParse(budgetCtrl.text) ?? 0;
                          if (existing == null) {
                            ec.addCategory(
                              name: nameCtrl.text.trim(),
                              colorValue: selColor.value,
                              iconCodePoint: selIcon.value,
                              budgetLimit: budget,
                              subItems: subs.toList(),
                            );
                          } else {
                            existing.name = nameCtrl.text.trim();
                            existing.colorValue = selColor.value;
                            existing.icon = selIcon.value;
                            existing.budgetLimit = budget;
                            existing.subItems = subs.toList();
                            ec.updateCategory(existing);
                          }
                          Get.back();
                          Get.snackbar(
                            'Saved',
                            existing == null
                                ? 'Category created!'
                                : 'Category updated!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: DarkTheme.success,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Text(
                          existing == null
                              ? 'Create Category'
                              : 'Update Category',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _label(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(
    t,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: DarkTheme.textPrimary,
      letterSpacing: 0.3,
    ),
  ),
);

const List<Map<String, dynamic>> _iconOptions = [
  {'label': 'Home', 'key': 'home', 'icon': Icons.home},
  {'label': 'Food', 'key': 'food', 'icon': Icons.fastfood},
  {'label': 'Shopping', 'key': 'shopping', 'icon': Icons.shopping_cart},
  {'label': 'Transport', 'key': 'transport', 'icon': Icons.directions_bus},
  {'label': 'Health', 'key': 'health', 'icon': Icons.local_hospital},
  {'label': 'Education', 'key': 'education', 'icon': Icons.school},
  {'label': 'Savings', 'key': 'savings', 'icon': Icons.savings},
  {'label': 'Loan', 'key': 'loan', 'icon': Icons.account_balance},
  {'label': 'Give Loan', 'key': 'give_loan', 'icon': Icons.handshake},
  {'label': 'Bike', 'key': 'bike', 'icon': Icons.two_wheeler},
  {'label': 'Car', 'key': 'car', 'icon': Icons.directions_car},
  {
    'label': 'Entertainment',
    'key': 'entertainment',
    'icon': Icons.movie
  },
  {'label': 'Travel', 'key': 'travel', 'icon': Icons.flight},
  {'label': 'Phone', 'key': 'phone', 'icon': Icons.phone_android},
  {'label': 'Wifi', 'key': 'wifi', 'icon': Icons.wifi},
  {'label': 'Electric', 'key': 'electric', 'icon': Icons.electric_bolt},
  {'label': 'Water', 'key': 'water', 'icon': Icons.water_drop},
  {'label': 'Gas', 'key': 'gas', 'icon': Icons.local_gas_station},
  {'label': 'Sports', 'key': 'sports', 'icon': Icons.sports_soccer},
  {'label': 'Kids', 'key': 'kids', 'icon': Icons.child_care},
  {'label': 'Clothing', 'key': 'clothing', 'icon': Icons.checkroom},
  {'label': 'Pet', 'key': 'pet', 'icon': Icons.pets},
  {'label': 'Gift', 'key': 'gift', 'icon': Icons.card_giftcard},
  {'label': 'Coffee', 'key': 'coffee', 'icon': Icons.coffee},
];

