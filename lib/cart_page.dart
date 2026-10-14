import 'package:flutter/material.dart';
import 'inclusive_widgets.dart';
import 'app_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String selectedTime = '12:30 (Перерыв)'; // Время по умолчанию

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InclusiveAppBar(title: 'Мой заказ'),
      body: ValueListenableBuilder<List<Dish>>(
        valueListenable: cartNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Твоя корзина пока пуста', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          int total = cartItems.fold(0, (sum, item) => sum + item.price);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.price} ₸'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            cartNotifier.value = List.from(cartNotifier.value)..removeAt(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('К оплате:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('$total ₸', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Выберите время выдачи:'),
                    const SizedBox(height: 8),
                    
                    // Выбор времени
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      items: ['12:15', '12:30 (Перерыв)', '13:00', '13:45'].map((time) {
                        return DropdownMenuItem(value: time, child: Text(time));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedTime = val!),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Кнопка Заказать
                    ElevatedButton(
                      onPressed: () {
                        cartNotifier.value = []; // Чистим корзину
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessScreen(time: selectedTime)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Заказать', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

// ЭКРАН УСПЕХА С QR-КОДОМ
class SuccessScreen extends StatelessWidget {
  final String time;
  const SuccessScreen({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 16),
                const Text('Заказ оплачен!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Забери в $time', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 24),
                
                // Имитация QR кода
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.black87,
                  child: const Center(child: Icon(Icons.qr_code_2, color: Colors.white, size: 180)),
                ),
                
                const SizedBox(height: 24),
                const Text('Покажи этот QR-код на зоне выдачи', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextButton(
                  // Возвращает на самый первый экран в стеке (в меню)
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Вернуться в меню', style: TextStyle(fontSize: 18, color: Colors.orange)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}