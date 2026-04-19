import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/expense_model.dart';
import '../utils/currency_utils.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ec = Get.find<ExpenseController>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(children: [
        // Blue header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 20),
          child: Row(children: [
            GestureDetector(onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            const Expanded(child: Text('Categories', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))),
            GestureDetector(
              onTap: () => _showAddCategorySheet(context, ec),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),

        Expanded(
          child: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ec.categories.length,
            itemBuilder: (_, i) => _buildCategoryCard(context, ec, ec.categories[i], ec),
          )),
        ),
      ]),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ExpenseController ec, CategoryModel cat, ExpenseController ctrl) {
    final color   = Color(cat.colorValue);
    final icon    = IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');
    final spent   = ec.spentForCategory(cat.id);
    final budget  = cat.budgetLimit;
    final pct     = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final expCount= ec.monthExpenses.where((e) => e.categoryId == cat.id).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 15)),
          subtitle: Text('$expCount expenses this month', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(CurrencyUtils.format(spent),
              style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16)),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'edit')   _showAddCategorySheet(context, ec, existing: cat);
                if (v == 'budget') _showBudgetDialog(context, ec, cat);
                if (v == 'delete' && cat.isCustom) _confirmDelete(context, ec, cat);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value:'edit',   child: Text('Edit')),
                const PopupMenuItem(value:'budget', child: Text('Set Budget')),
                if (cat.isCustom) const PopupMenuItem(value:'delete', child: Text('Delete', style: TextStyle(color: AppTheme.danger))),
              ],
            ),
          ]),
        ),
        if (budget > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 6,
                  backgroundColor: AppTheme.divider,
                  valueColor: AlwaysStoppedAnimation(pct > 0.9 ? AppTheme.danger : pct > 0.7 ? AppTheme.warning : color),
                ),
              ),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Budget: ${CurrencyUtils.format(budget)}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text('${(pct*100).toStringAsFixed(0)}% used', style: TextStyle(fontSize: 11, color: pct > 0.9 ? AppTheme.danger : AppTheme.textSecondary)),
              ]),
            ]),
          ),
        // Sub-items
        if (cat.subItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(spacing: 6, runSpacing: 4,
              children: cat.subItems.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                child: Text(s, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
              )).toList(),
            ),
          ),
      ]),
    );
  }

  void _showBudgetDialog(BuildContext context, ExpenseController ec, CategoryModel cat) {
    final ctrl = TextEditingController(text: cat.budgetLimit > 0 ? cat.budgetLimit.toInt().toString() : '');
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Budget for ${cat.name}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
      content: TextField(
        controller: ctrl, keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(prefixText: '৳ ', hintText: 'e.g. 5000'),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () {
            final v = double.tryParse(ctrl.text) ?? 0;
            ec.setCategoryBudget(cat.id, v);
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  void _confirmDelete(BuildContext context, ExpenseController ec, CategoryModel cat) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Category', style: TextStyle(color: AppTheme.textPrimary)),
      content: Text('Delete "${cat.name}"? Expenses will be moved to another category.'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () { ec.deleteCategory(cat.id); Get.back(); },
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}

// ─── Add/Edit Category Bottom Sheet ────────────────────────────────────────
void _showAddCategorySheet(BuildContext context, ExpenseController ec, {CategoryModel? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final subCtrl  = TextEditingController();
  final subs     = RxList<String>(existing?.subItems ?? []);
  final selColor = Rx<int>(existing?.colorValue ?? AppTheme.paletteColors[0].value);
  final selIcon  = Rx<int>(existing?.iconCodePoint ?? _iconOptions[0]['code'] as int);
  final budgetCtrl = TextEditingController(text: existing?.budgetLimit != null && existing!.budgetLimit > 0 ? existing.budgetLimit.toInt().toString() : '');

  showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => Obx(() => Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        // Handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            Text(existing == null ? 'New Category' : 'Edit Category',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const Spacer(),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name
            _label('Category Name'),
            TextField(controller: nameCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Education, Daily Bazar...'),
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Budget
            _label('Monthly Budget (optional)'),
            TextField(controller: budgetCtrl, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(prefixText: '৳ ', hintText: '0'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 20),

            // Color picker
            _label('Color'),
            Wrap(spacing: 10, runSpacing: 10,
              children: AppTheme.paletteColors.map((c) {
                final isSelected = selColor.value == c.value;
                return GestureDetector(
                  onTap: () => selColor.value = c.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppTheme.textPrimary, width: 3) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Icon picker
            _label('Icon'),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: _iconOptions.length,
              itemBuilder: (_, i) {
                final code = _iconOptions[i]['code'] as int;
                final isSelected = selIcon.value == code;
                final color = Color(selColor.value);
                return GestureDetector(
                  onTap: () => selIcon.value = code,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? Border.all(color: color, width: 1.5) : null,
                    ),
                    child: Icon(IconData(code, fontFamily: 'MaterialIcons'),
                        color: isSelected ? color : AppTheme.textSecondary, size: 22),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Sub-items
            _label('Sub-items (optional)'),
            const Text('Add items like Rent, Electricity under this category',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: subCtrl,
                decoration: const InputDecoration(hintText: 'Add item...', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                onSubmitted: (v) { if (v.trim().isNotEmpty) { subs.add(v.trim()); subCtrl.clear(); } },
              )),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(selColor.value), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  if (subCtrl.text.trim().isNotEmpty) { subs.add(subCtrl.text.trim()); subCtrl.clear(); }
                },
                child: const Text('Add'),
              ),
            ]),
            const SizedBox(height: 10),
            if (subs.isNotEmpty)
              Wrap(spacing: 6, runSpacing: 6,
                children: subs.map((s) => Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => subs.remove(s),
                  backgroundColor: Color(selColor.value).withOpacity(0.1),
                  deleteIconColor: Color(selColor.value),
                  labelStyle: TextStyle(color: Color(selColor.value)),
                  side: BorderSide.none,
                )).toList(),
              ),
            const SizedBox(height: 32),

            // Save
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(selColor.value), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final budget = double.tryParse(budgetCtrl.text) ?? 0;
                  if (existing == null) {
                    ec.addCategory(name: nameCtrl.text.trim(), colorValue: selColor.value,
                        iconCodePoint: selIcon.value, budgetLimit: budget, subItems: subs.toList());
                  } else {
                    existing.name = nameCtrl.text.trim();
                    existing.colorValue = selColor.value;
                    existing.iconCodePoint = selIcon.value;
                    existing.budgetLimit = budget;
                    existing.subItems = subs.toList();
                    ec.updateCategory(existing);
                  }
                  Get.back();
                  Get.snackbar('Saved', existing == null ? 'Category created!' : 'Category updated!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.success, colorText: Colors.white,
                    margin: const EdgeInsets.all(16), borderRadius: 12, duration: const Duration(seconds: 2));
                },
                child: Text(existing == null ? 'Create Category' : 'Update Category',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        )),
      ]),
    )),
  );
}

Widget _label(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.3)),
);

const List<Map<String, dynamic>> _iconOptions = [
  {'label':'Home',         'code': 0xe88a},
  {'label':'Food',         'code': 0xef55},
  {'label':'Shopping',     'code': 0xef69},
  {'label':'Transport',    'code': 0xe1d0},
  {'label':'Health',       'code': 0xe548},
  {'label':'Education',    'code': 0xe80c},
  {'label':'Savings',      'code': 0xe227},
  {'label':'Loan',         'code': 0xe870},
  {'label':'Give Loan',    'code': 0xe8b2},
  {'label':'Bike',         'code': 0xe54f},
  {'label':'Car',          'code': 0xe531},
  {'label':'Entertainment','code': 0xe040},
  {'label':'Travel',       'code': 0xe7c4},
  {'label':'Phone',        'code': 0xe325},
  {'label':'Wifi',         'code': 0xe63e},
  {'label':'Electric',     'code': 0xe518},
  {'label':'Water',        'code': 0xe798},
  {'label':'Gas',          'code': 0xf192},
  {'label':'Sports',       'code': 0xe52f},
  {'label':'Kids',         'code': 0xe7ef},
  {'label':'Clothing',     'code': 0xf042},
  {'label':'Pet',          'code': 0xe91d},
  {'label':'Gift',         'code': 0xe8f6},
  {'label':'Coffee',       'code': 0xef6f},
];
