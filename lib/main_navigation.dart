import 'package:flutter/material.dart';
import 'home_page.dart';
import 'cart_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static _MainNavigationState? _instance;

  static void switchToHome(BuildContext context) {
    _instance?.setTab(0);
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0; 

  @override
  void initState() {
    super.initState();
    MainNavigation._instance = this;
  }

  void setTab(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  void dispose() {
    if (MainNavigation._instance == this) {
      MainNavigation._instance = null;
    }
    super.dispose();
  }

  final List<Widget> _pages = const [
    HomePage(), 
    CartPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: setTab,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Меню'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
        ],
      ),
    );
  }
}