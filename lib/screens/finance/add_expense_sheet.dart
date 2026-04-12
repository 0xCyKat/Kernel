import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/finance_service.dart';
import '../../models/expense.dart';
import '../../models/finance_category.dart';
import 'package:intl/intl.dart';
import '../../widgets/loading_overlay.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpenseSheet({super.key, this.existingExpense});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;

  late String _selectedCategoryId;
  late DateTime _selectedDate;
  late String _selectedPaymentType;

  @override
  void initState() {
    super.initState();
    final e = widget.existingExpense;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(text: e?.amount.toString() ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _selectedCategoryId = e?.categoryId ?? 'others';
    _selectedDate = e?.date ?? DateTime.now();
    _selectedPaymentType = e?.paymentType ?? 'UPI';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final svc = context.read<FinanceService>();
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;

    final expense = Expense(
      id: widget.existingExpense?.id ?? const Uuid().v4(),
      name: _nameCtrl.text,
      categoryId: _selectedCategoryId,
      description: _descCtrl.text,
      date: _selectedDate,
      paymentType: _selectedPaymentType,
      amount: amount,
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
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

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existingExpense == null ? 'Add Expense' : 'Edit Expense',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => double.tryParse(v ?? '') == null
                    ? 'Enter valid amount'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              Icon(
                                IconData(
                                  c.iconCodePoint,
                                  fontFamily: 'MaterialIcons',
                                ),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategoryId = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedPaymentType,
                      decoration: const InputDecoration(
                        labelText: 'Payment',
                        border: OutlineInputBorder(),
                      ),
                      items: paymentTypes
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPaymentType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade700),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.existingExpense != null)
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: _delete,
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
