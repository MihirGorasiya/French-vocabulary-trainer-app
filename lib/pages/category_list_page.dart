import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider_category.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      body: ListView.builder(
        itemCount: categoryProvider.categories.length,
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];
          return ListTile(
            title: Text(category.name),
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder:
            //           (_) => CategoryWordsPage(
            //             categoryId: category.id!,
            //             categoryName: category.name,
            //           ),
            //     ),
            //   );
            // },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => categoryProvider.deleteCategory(category.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showAddCategoryDialog(context, categoryProvider);
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoryProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Add Category"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Category name"),
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("Add"),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    provider.addCategory(controller.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }
}
