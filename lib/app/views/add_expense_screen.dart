import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/expense_model.dart';
import '../utils/icon_mapper.dart';
import '../widgets/dart_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? existing;
  const AddExpenseScreen({super.key, this.existing});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final ec = Get.find<ExpenseController>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _catId = '';
  String _subItem = '';
  DateTime _date = DateTime.now();
  String _status = 'paid';

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
      backgroundColor: DarkTheme.background,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),

                  // Title
                  _label('Title'),
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      color: DarkTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Fish, Electricity Bill, Bus fare...',
                      hintStyle: const TextStyle(color: DarkTheme.textMuted),
                      prefixIcon: const Icon(
                        Icons.title_rounded,
                        color: DarkTheme.textMuted,
                        size: 18,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Category
                  _label('Category'),
                  Obx(
                        () => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: DarkTheme.border),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: ec.categories.length,
                        itemBuilder: (_, i) {
                          final cat = ec.categories[i];
                          final color = Color(cat.colorValue);
                          final isSelected = _catId == cat.id;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _catId = cat.id;
                              _subItem = '';
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color.withOpacity(0.16)
                                    : Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? color.withOpacity(0.4)
                                      : DarkTheme.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    AppIcons.map[cat.icon] ?? Icons.category,
                                    color: isSelected
                                        ? color
                                        : DarkTheme.textMuted,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                      isSelected ? color : DarkTheme.textMuted,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Sub-item if category has subs
                  Obx(() {
                    final cat = ec.categoryById(_catId);
                    if (cat == null || cat.subItems.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Item Type (optional)'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cat.subItems.map((s) {
                            final isSelected = _subItem == s;
                            final color = Color(cat.colorValue);
                            return GestureDetector(
                              onTap: () => setState(
                                    () =>
                                _subItem = isSelected ? '' : s,
                              ),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.14)
                                      : Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? color.withOpacity(0.3)
                                        : DarkTheme.border,
                                    width: isSelected ? 1.2 : 1,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? color
                                        : DarkTheme.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                      ],
                    );
                  }),

                  // Date
                  _label('Date'),
                  GestureDetector(
                    onTap: () async {
                      final p = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: DarkTheme.primary,
                              surface: DarkTheme.surface2,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (p != null) setState(() => _date = p);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DarkTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: DarkTheme.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_date),
                            style: const TextStyle(
                              color: DarkTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Status
                  _label('Status'),
                  Row(
                    children: [
                      _statusChip('paid', 'Paid', DarkTheme.success),
                      const SizedBox(width: 10),
                      _statusChip('pending', 'Pending', DarkTheme.warning),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Note
                  _label('Note (optional)'),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(
                      color: DarkTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle:
                      const TextStyle(color: DarkTheme.textMuted),
                      prefixIcon: const Icon(
                        Icons.notes_rounded,
                        color: DarkTheme.textMuted,
                        size: 18,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DarkTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _save,
                      child: Text(
                        widget.existing == null
                            ? 'Add Expense'
                            : 'Update Expense',
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        // Purple orb top-right
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
        // Green orb bottom-left
        Positioned(
          bottom: 0,
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
            bottom: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with back button
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
                  const SizedBox(width: 14),
                  Text(
                    widget.existing == null ? 'Add Expense' : 'Edit Expense',
                    style: const TextStyle(
                      color: DarkTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Big amount field
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '৳',
                    style: TextStyle(
                      color: DarkTheme.textSecondary,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      style: const TextStyle(
                        color: DarkTheme.primaryLight,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          color: Colors.white12,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      minLines: 1,
                      maxLines: 1,
                      validator: (v) =>
                      (v == null || v.isEmpty) ? '' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String value, String label, Color color) {
    final isSelected = _status == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.14) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.3) : DarkTheme.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                      : [],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : DarkTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
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
        fontWeight: FontWeight.w600,
        color: DarkTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    ),
  );

  void _save() {
    if (_catId.isEmpty) {
      Get.snackbar(
        'Error',
        'Select a category',
        backgroundColor: DarkTheme.danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    if (amount <= 0) {
      Get.snackbar(
        'Error',
        'Enter valid amount',
        backgroundColor: DarkTheme.danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
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
      backgroundColor: DarkTheme.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}

