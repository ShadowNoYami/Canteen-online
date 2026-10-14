import 'package:flutter/material.dart';
import 'dart:async';
import 'home_types_page.dart';
import 'details_page.dart';
import 'inclusive_widgets.dart'; // Наш инклюзивный AppBar
import 'app_state.dart'; // Наша база данных блюд

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _timer;

  // Яркие картинки для карусели
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentCarouselIndex < _carouselImages.length - 1) {
        _currentCarouselIndex++;
      } else {
        _currentCarouselIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentCarouselIndex, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeIn
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Окно для микрофона (Инклюзивность)
  void _showVoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, size: 60, color: Colors.orange),
            SizedBox(height: 16),
            Text('Говорите...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Например: "Хочу суп"', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Функция для открытия нужной категории
  void _openCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeTypesPage(categoryName: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Берем первые 4 блюда из app_state.dart для блока "Популярное"
    final popularDishes = allDishes.take(4).toList();

    return Scaffold(
      appBar: const InclusiveAppBar(title: 'Вкусная Перемена'),
      
      // Плавающая кнопка (Микрофон)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showVoiceDialog,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.mic, color: Colors.white),
        label: const Text('Сказать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Карусель
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _carouselImages.length,
                onPageChanged: (index) => setState(() => _currentCarouselIndex = index),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(image: NetworkImage(_carouselImages[index]), fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            
            // 2. Категории с переходом
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(Icons.soup_kitchen, 'Супы', () => _openCategory('Супы')),
                  _buildCategoryItem(Icons.lunch_dining, 'Второе', () => _openCategory('Второе')),
                  _buildCategoryItem(Icons.local_drink, 'Напитки', () => _openCategory('Напитки')),
                  _buildCategoryItem(Icons.bakery_dining, 'Выпечка', () => _openCategory('Выпечка')),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Популярное меню', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            
            // 3. Сетка популярных блюд (Динамическая)
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Пропорция карточки
              ),
              itemCount: popularDishes.length,
              itemBuilder: (context, index) {
                final dish = popularDishes[index];
                return InkWell(
                  // Переход на детальную страницу блюда
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsPage(dish: dish))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16), 
                      boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(dish.imageUrl, fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dish.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('${dish.price} ₸', style: TextStyle(fontSize: 16, color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // 4. Блок обратной связи (Смайлики)
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade100)
              ),
              child: Column(
                children: [
                  const Text('Тебе всё понятно?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeedbackEmoji(context, '😊', 'Понял'),
                      _buildFeedbackEmoji(context, '😐', 'Не понял'),
                      _buildFeedbackEmoji(context, '😢', 'Сложно'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 100), // Место под плавающую кнопку
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackEmoji(BuildContext context, String emoji, String tooltip) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ответ "$tooltip" отправлен!'), duration: const Duration(seconds: 1)));
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 4),
          Text(tooltip, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.orange.shade100, child: Icon(icon, color: Colors.orange, size: 30)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}