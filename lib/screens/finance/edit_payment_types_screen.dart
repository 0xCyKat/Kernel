import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/finance_service.dart';

class EditPaymentTypesScreen extends StatelessWidget {
  const EditPaymentTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Payment Types')),
      body: Consumer<FinanceService>(
        builder: (context, svc, _) {
          final defaultPayments = ['Cash', 'UPI', 'Card', 'Pluxee'];
          final allPayments = svc.paymentTypes;
          final customPayments = allPayments
              .where((p) => !defaultPayments.contains(p))
              .toList();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Custom Payment Types',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (customPayments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'No custom payment types.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ...customPayments.map(
                (p) => ListTile(
                  leading: const Icon(Icons.payment),
                  title: Text(p),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      svc.deletePaymentType(p);
                    },
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Default Payment Types (Cannot be deleted)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ...defaultPayments.map(
                (p) => ListTile(
                  leading: const Icon(Icons.payment),
                  title: Text(p),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddPaymentTypeDialog(context);
        },
      ),
    );
  }

  void _showAddPaymentTypeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Payment Type'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Payment Type Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  context.read<FinanceService>().addPaymentType(name);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
