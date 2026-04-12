import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/finance_category.dart';
import '../../services/finance_service.dart';

class EditCategoriesScreen extends StatelessWidget {
  const EditCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Categories')),
      body: Consumer<FinanceService>(
        builder: (context, svc, _) {
          final allCats = svc.categories;
          final defaultCats = FinanceCategory.defaultCategories;
          final customCats = allCats
              .where((c) => !defaultCats.any((dc) => dc.id == c.id))
              .toList();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Custom Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (customCats.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'No custom categories.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ...customCats.map(
                (c) => ListTile(
                  leading: Icon(
                    IconData(c.iconCodePoint, fontFamily: 'MaterialIcons'),
                  ),
                  title: Text(c.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      svc.deleteCategory(c.id);
                    },
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Default Categories (Cannot be deleted)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ...defaultCats.map(
                (c) => ListTile(
                  leading: Icon(
                    IconData(c.iconCodePoint, fontFamily: 'MaterialIcons'),
                  ),
                  title: Text(c.name),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddCategoryDialog(context);
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    int selectedIcon = Icons.category.codePoint;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Icon'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          Icons.star,
                          Icons.directions_bus,
                          Icons.shopping_bag,
                          Icons.pets,
                          Icons.flight,
                          Icons.build,
                          Icons.sports_esports,
                          Icons.local_cafe,
                          Icons.local_gas_station,
                          Icons.local_grocery_store,
                        ].map((iconData) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedIcon = iconData.codePoint;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedIcon == iconData.codePoint
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(iconData),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final newCat = FinanceCategory(
                        id: const Uuid().v4(),
                        name: nameCtrl.text.trim(),
                        iconCodePoint: selectedIcon,
                      );
                      context.read<FinanceService>().addCategory(newCat);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
