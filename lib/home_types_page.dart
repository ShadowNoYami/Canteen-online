import 'package:flutter/material.dart';
import 'inclusive_widgets.dart';
import 'details_page.dart';
import 'app_state.dart'; 

class HomeTypesPage extends StatelessWidget {
  final String categoryName; 

  const HomeTypesPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final filteredDishes = allDishes.where((d) => d.category == categoryName).toList();

    return Scaffold(
      appBar: InclusiveAppBar(title: categoryName, showBackButton: true),
      body: filteredDishes.isEmpty 
        ? Center(child: Text('Тут пока пусто 😢', style: TextStyle(fontSize: 20, color: Colors.grey.shade400)))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: filteredDishes.length,
            itemBuilder: (context, index) {
              final dish = filteredDishes[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(dish: dish)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(dish.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dish.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('${dish.price} ₸', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}