import 'package:flutter/material.dart';

class Dish {
  final String id;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final IconData icon;
  final String composition; 
  final List<String> allergens; 

  Dish({
    required this.id, 
    required this.name, 
    required this.category, 
    required this.price, 
    required this.imageUrl, 
    required this.icon,
    required this.composition,
    this.allergens = const [], 
  });
}

// Глобальная корзина
final ValueNotifier<List<Dish>> cartNotifier = ValueNotifier([]);

// Список всех блюд с реалистичными ценами для Казахстана
final List<Dish> allDishes = [
  // --- СУПЫ ---
  Dish(
    id: '1', name: 'Борщ со сметаной', category: 'Супы', price: 800, icon: Icons.soup_kitchen, 
    imageUrl: 'https://images.unsplash.com/photo-1648726445011-9fbf3a5ddb90?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Ym9yc2h8ZW58MHx8MHx8fDA%3D',
    composition: 'Свекла, капуста, картофель, говядина, морковь, лук, зелень, сметана.',
    allergens: ['Лактоза (в сметане)'],
  ),
  Dish(
    id: '2', name: 'Куриный супчик', category: 'Супы', price: 900, icon: Icons.soup_kitchen, 
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=500&q=60',
    composition: 'Куриный бульон, яичная лапша, морковь, лук, куриное филе.',
    allergens: ['Глютен (в лапше)', 'Яйцо'],
  ),
  Dish(
    id: '3', name: 'Тыквенный крем-суп', category: 'Супы', price: 900, icon: Icons.soup_kitchen, 
    imageUrl: 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?auto=format&fit=crop&w=500&q=60',
    composition: 'Пюре из запеченной тыквы, сливки 20%, тыквенные семечки, соль.',
    allergens: ['Лактоза (в сливках)'],
  ),

  // --- ВТОРОЕ ---
  Dish(
    id: '4', name: 'Плов с говядиной', category: 'Второе', price: 1200, icon: Icons.lunch_dining, 
    imageUrl: 'https://images.unsplash.com/photo-1671048116858-e8ef69175b2d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fCVEMCU5RiVEMCVCQiVEMCVCRSVEMCVCMnxlbnwwfHwwfHx8MA%3D%3D',
    composition: 'Рис, свежая говядина, морковь, лук, зира, чеснок.',
    allergens: [], 
  ),
  Dish(
    id: '5', name: 'Макароны с сыром', category: 'Второе', price: 650, icon: Icons.lunch_dining, 
    imageUrl: 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?auto=format&fit=crop&w=500&q=60',
    composition: 'Макароны из твердых сортов пшеницы, сыр Чеддер, сливочное масло, молоко.',
    allergens: ['Глютен', 'Лактоза'],
  ),
  Dish(
    id: '6', name: 'Куриная котлетка', category: 'Второе', price: 600, icon: Icons.lunch_dining, 
    imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=500&q=60',
    composition: 'Рубленое куриное филе, вымоченный в молоке мякиш, соль, панировка.',
    allergens: ['Глютен (панировка)', 'Лактоза'],
  ),

  // --- НАПИТКИ ---
  Dish(
    id: '7', name: 'Ягодный компот', category: 'Напитки', price: 300, icon: Icons.local_drink, 
    imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=500&q=60',
    composition: 'Свежемороженые ягоды (клубника, смородина, вишня), вода, сахар.',
    allergens: ['Красные ягоды'],
  ),
  Dish(
    id: '8', name: 'Чай с лимоном', category: 'Напитки', price: 250, icon: Icons.emoji_food_beverage, 
    imageUrl: 'https://plus.unsplash.com/premium_photo-1673507375644-55520bbeaaf7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fCVEMCVBNyVEMCVCMCVEMCVCOSUyMCVEMSU4MSUyMCVEMCVCQiVEMCVCOCVEMCVCQyVEMCVCRSVEMCVCRCVEMCVCRSVEMCVCQ3xlbnwwfHwwfHx8MA%3D%3D',
    composition: 'Черный чай байховый, вода, долька свежего лимона, сахар.',
    allergens: ['Цитрусовые (лимон)'],
  ),
  Dish(
    id: '9', name: 'Какао с пенкой', category: 'Напитки', price: 500, icon: Icons.coffee, 
    imageUrl: 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?auto=format&fit=crop&w=500&q=60',
    composition: 'Натуральный какао-порошок, цельное коровье молоко, сахар.',
    allergens: ['Лактоза'],
  ),

  // --- ВЫПЕЧКА ---
  Dish(
    id: '10', name: 'Булочка с корицей', category: 'Выпечка', price: 450, icon: Icons.bakery_dining, 
    imageUrl: 'https://images.unsplash.com/photo-1509365465985-25d11c17e812?auto=format&fit=crop&w=500&q=60',
    composition: 'Пшеничная мука, дрожжи, молоко, сливочное масло, сахар, молотая корица.',
    allergens: ['Глютен', 'Лактоза'],
  ),
  Dish(
    id: '11', name: 'Свежий круассан', category: 'Выпечка', price: 650, icon: Icons.bakery_dining, 
    imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=500&q=60',
    composition: 'Слоеное дрожжевое тесто (мука, сливочное масло, вода, сахар).',
    allergens: ['Глютен', 'Лактоза'],
  ),
  
  // --- ПАНКЕЙКИ ---
  Dish(
    id: '12', name: 'Панкейки с медом', category: 'Выпечка', price: 600, icon: Icons.bakery_dining, 
    imageUrl: 'https://plus.unsplash.com/premium_photo-1663854478296-dd00b6257021?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8UGFuY2FrZXxlbnwwfHwwfHx8MA%3D%3D',
    composition: 'Пышные американские блинчики на молоке, подаются с натуральным цветочным медом и кусочком сливочного масла.',
    allergens: ['Глютен', 'Лактоза', 'Яйцо', 'Мёд'],
  ),
];