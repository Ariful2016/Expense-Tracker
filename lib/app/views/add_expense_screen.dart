import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/expense_model.dart';
class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? existing;
  const AddExpenseScreen({super.key, this.existing});
  @override State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ec = Get.find<ExpenseController>();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  final _formKey    = GlobalKey<FormState>();
  String   _catId   = '';
  String   _subItem = '';
  DateTime _date    = DateTime.now();
  String   _status  = 'paid';

 /* @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _titleCtrl.text  = e.title;
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _noteCtrl.text   = e.note ?? '';
      _catId   = e.categoryId;
      _date    = e.date;
      _status  = e.status;
    } else {
      _catId = ec.categories.isNotEmpty ? ec.categories.first.id : '';
    }
  }*/

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (widget.existing != null) {
        final e = widget.existing!;
        _titleCtrl.text = e.title;
        _amountCtrl.text = e.amount.toStringAsFixed(0);
        _noteCtrl.text = e.note ?? '';
        _catId = e.categoryId;
        _date = e.date;
        _status = e.status;
      } else {
        if (ec.categories.isNotEmpty) {
          setState(() {
            _catId = ec.categories.first.id;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Form(
        key: _formKey,
        child: Column(children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 20, right: 20, bottom: 28),
            child: Column(children: [
              Row(children: [
                GestureDetector(onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Text(widget.existing == null ? 'Add Expense' : 'Edit Expense',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 20),
              // Big amount field
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('৳', style: TextStyle(color: Colors.white60, fontSize: 32, fontWeight: FontWeight.w300)),
                const SizedBox(width: 4),
                IntrinsicWidth(
                  child: TextFormField(
                    controller: _amountCtrl, keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(
                      hintText: '0', border: InputBorder.none, filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 40, fontWeight: FontWeight.w800),
                    ),
                    textAlign: TextAlign.center, minLines: 1, maxLines: 1,
                    validator: (v) => (v == null || v.isEmpty) ? '' : null,
                  ),
                ),
              ]),
            ]),
          ),

          Expanded(child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Title
              _fieldLabel('Title'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Fish, Electricity Bill, Bus fare...',
                    prefixIcon: Icon(Icons.title_rounded, color: AppTheme.textSecondary, size: 20)),
                style: const TextStyle(color: AppTheme.textPrimary),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Category
              _fieldLabel('Category'),
              Obx(() => Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider)),
                child: GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.85),
                  itemCount: ec.categories.length,
                  itemBuilder: (_, i) {
                    final cat    = ec.categories[i];
                    final color  = Color(cat.colorValue);
                    final icon   = IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');
                    final isSelected = _catId == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() { _catId = cat.id; _subItem = ''; }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.12) : AppTheme.background,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? Border.all(color: color, width: 1.5) : null,
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(icon, color: isSelected ? color : AppTheme.textSecondary, size: 22),
                          const SizedBox(height: 4),
                          Text(cat.name, textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 9, color: isSelected ? color : AppTheme.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    );
                  },
                ),
              )),
              const SizedBox(height: 16),

              // Sub-item if category has subs
              Obx(() {
                final cat = ec.categoryById(_catId);
                if (cat == null || cat.subItems.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fieldLabel('Item Type (optional)'),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: cat.subItems.map((s) {
                      final isSelected = _subItem == s;
                      final color = Color(cat.colorValue);
                      return GestureDetector(
                        onTap: () => setState(() => _subItem = isSelected ? '' : s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.12) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? color : AppTheme.divider),
                          ),
                          child: Text(s, style: TextStyle(fontSize: 12,
                              color: isSelected ? color : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ]);
              }),

              // Date
              _fieldLabel('Date'),
              GestureDetector(
                onTap: () async {
                  final p = await showDatePicker(context: context,
                    initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now(),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
                      child: child!,
                    ));
                  if (p != null) setState(() => _date = p);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Text(DateFormat('dd MMMM yyyy').format(_date),
                        style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Status
              _fieldLabel('Status'),
              Row(children: [
                _statusChip('paid',    'Paid',    AppTheme.success),
                const SizedBox(width: 10),
                _statusChip('pending', 'Pending', AppTheme.warning),
              ]),
              const SizedBox(height: 16),

              // Note
              _fieldLabel('Note (optional)'),
              TextField(
                controller: _noteCtrl, maxLines: 2,
                decoration: const InputDecoration(hintText: 'Add a note...',
                    prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.textSecondary, size: 20)),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 28),

              SizedBox(height: 52, child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _save,
                child: Text(widget.existing == null ? 'Add Expense' : 'Update Expense',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(height: 20),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final isSelected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppTheme.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: isSelected ? color : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _fieldLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary, letterSpacing: 0.3)),
  );

  void _save() {
    //if (!_formKey.currentState!.validate()) return;

    if (_catId.isEmpty) {
      Get.snackbar('Error', 'Select a category',
          backgroundColor: AppTheme.danger,
          colorText: Colors.white);
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    if (amount <= 0) {
      Get.snackbar('Error', 'Enter valid amount',
          backgroundColor: AppTheme.danger,
          colorText: Colors.white);
      return;
    }

    final title = _subItem.isNotEmpty
        ? '$_subItem (${_titleCtrl.text.trim()})'
        : _titleCtrl.text.trim();

    if (widget.existing == null) {
      ec.addExpense(
        title: title,
        amount: amount,
        categoryId: _catId,
        date: _date,
        note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
        status: _status,
      );
    } else {
      widget.existing!
        ..title = title
        ..amount = amount
        ..categoryId = _catId
        ..date = _date
        ..note = _noteCtrl.text.isEmpty ? null : _noteCtrl.text
        ..status = _status;

      ec.updateExpense(widget.existing!);
    }

    Get.back();

    Get.snackbar(
      widget.existing == null ? 'Added!' : 'Updated!',
      title,
      backgroundColor: AppTheme.success,
      colorText: Colors.white,
    );
  }
}
