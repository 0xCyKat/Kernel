import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../services/finance_service.dart';
import '../../models/expense.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_overlay.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? existingExpense;
  final DateTime? initialDate;

  const AddExpenseSheet({super.key, this.existingExpense, this.initialDate});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<ShadFormState>();

  late String _name;
  late double _amount;

  late String _selectedCategoryId;
  late DateTime _selectedDate;
  late String _selectedPaymentType;

  @override
  void initState() {
    super.initState();
    final e = widget.existingExpense;
    _name = e?.name ?? '';
    _amount = e?.amount ?? 0.0;
    _selectedCategoryId = e?.categoryId ?? 'others';
    _selectedDate = e?.date ?? widget.initialDate ?? DateTime.now();
    _selectedPaymentType = e?.paymentType ?? 'UPI';
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final svc = context.read<FinanceService>();

    final expense = Expense(
      id: widget.existingExpense?.id ?? const Uuid().v4(),
      name: _name,
      categoryId: _selectedCategoryId,
      description: '', // Simplified as desc is optional and was removed from form
      date: _selectedDate,
      paymentType: _selectedPaymentType,
      amount: _amount,
    );

    LoadingOverlay.show(context);
    try {
      if (widget.existingExpense == null) {
        await svc.addExpense(expense);
      } else {
        await svc.updateExpense(expense);
      }
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }

    if (mounted) Navigator.pop(context);
  }

  void _delete() async {
    if (widget.existingExpense != null) {
      LoadingOverlay.show(context);
      try {
        await context.read<FinanceService>().deleteExpense(
          widget.existingExpense!.id,
        );
      } finally {
        if (mounted) LoadingOverlay.hide(context);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final svc = context.watch<FinanceService>();
    final categories = svc.categories;
    final paymentTypes = svc.paymentTypes;

    // Ensure selected category exists in the list
    if (!categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = 'others';
    }

    // Ensure selected payment type exists in the list
    if (!paymentTypes.contains(_selectedPaymentType)) {
      _selectedPaymentType = 'Cash';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      child: ShadForm(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingExpense == null ? 'Add Expense' : 'Edit Expense',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.existingExpense != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      onPressed: _delete,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ShadInputFormField(
                id: 'name',
                initialValue: _name,
                label: const Text('Expense Name'),
                placeholder: const Text('e.g. Starbucks Coffee'),
                onSaved: (v) => _name = v ?? '',
                validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              ShadInputFormField(
                id: 'amount',
                initialValue: _amount == 0.0 ? '' : _amount.toString(),
                label: const Text('Amount (₹)'),
                placeholder: const Text('0.00'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _amount = double.tryParse(v ?? '') ?? 0.0,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid amount' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        ShadSelect<String>(
                          initialValue: _selectedCategoryId,
                          options: categories.map((c) => ShadOption(
                            value: c.id,
                            child: Row(
                              children: [
                                Icon(IconData(c.iconCodePoint, fontFamily: 'MaterialIcons'), size: 16),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          )).toList(),
                          selectedOptionBuilder: (context, value) {
                            final cat = categories.firstWhere((c) => c.id == value);
                            return Text(cat.name);
                          },
                          onChanged: (v) => setState(() => _selectedCategoryId = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        ShadSelect<String>(
                          initialValue: _selectedPaymentType,
                          options: paymentTypes.map((p) => ShadOption(value: p, child: Text(p))).toList(),
                          selectedOptionBuilder: (context, value) => Text(value ?? ''),
                          onChanged: (v) => setState(() => _selectedPaymentType = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Date', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppUtils.formatDate(_selectedDate).split(',')[0],
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: _save,
                  backgroundColor: AppColors.textPrimary,
                  child: Text(
                    widget.existingExpense == null ? 'Add Expense' : 'Update Expense',
                    style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
