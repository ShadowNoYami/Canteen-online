import 'package:flutter/material.dart';
import 'inclusive_widgets.dart'; 
import 'app_state.dart'; 

class DetailsPage extends StatelessWidget {
  final Dish dish; // Сюда передается блюдо, на которое кликнули

  const DetailsPage({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InclusiveAppBar(
        title: 'О блюде', 
        showBackButton: true
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ДИНАМИЧЕСКАЯ КАРТИНКА БЛЮДА
            Stack(
              children: [
                Image.network(
                  dish.imageUrl, // Берем картинку из выбранного блюда
                  height: 300, 
                  width: double.infinity, 
                  fit: BoxFit.cover
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]
                    ),
                    child: Text(
                      '${dish.price} ₸', // ДИНАМИЧЕСКАЯ ЦЕНА
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.orange)
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. ДИНАМИЧЕСКОЕ НАЗВАНИЕ
                  Text(
                    dish.name, 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 24),
                  
                  // 3. АЛЛЕРГЕНЫ (Если есть, показываем блок)
                  if (dish.allergens.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200, width: 2)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Внимание, аллергены!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 4),
                                // Выводим список аллергенов через запятую
                                Text(dish.allergens.join(', '), style: const TextStyle(fontSize: 16, color: Colors.black87)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. ДИНАМИЧЕСКИЙ СОСТАВ
                  const Text(
                    'Из чего это приготовлено:', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      dish.composition, // Берем состав из базы данных
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Кнопка добавления в корзину
                  ElevatedButton.icon(
                    onPressed: () {
                      cartNotifier.value = List.from(cartNotifier.value)..add(dish);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dish.name} добавлено в корзину!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                      Navigator.pop(context); // Закрываем детали и возвращаемся в меню
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 30),
                    label: const Text('Добавить в корзину', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}