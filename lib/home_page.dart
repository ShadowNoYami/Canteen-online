import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'home_types_page.dart';
import 'details_page.dart';
import 'inclusive_widgets.dart'; 
import 'app_state.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  Timer? _timer;
  
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = '';
  bool _isHandlingVoice = false; 

  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechToText();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return; 

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
  
  Future<void> _initializeSpeechToText() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => debugPrint('Error: $error'),
        onStatus: (status) => debugPrint('Status: $status'),
      );
      if (!available) {
        debugPrint('Speech to text not available');
      }
    } catch (e) {
      debugPrint('Error initializing speech to text: $e');
    }
  }
  
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  bool _isVoiceDialogOpen = false;

  void _closeVoiceDialogIfOpen() {
    if (_isVoiceDialogOpen) {
      _isVoiceDialogOpen = false;
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  // ==========================================================
  // СУПЕР-УМНЫЙ ПОИСК КАТЕГОРИЙ (Ищет по корням и опечаткам)
  // ==========================================================
  String? _getMatchedCategory(String lowerText) {
    if (lowerText.contains('суп') || lowerText.contains('перв')) return 'Супы';
    if (lowerText.contains('второ') || lowerText.contains('горяч')) return 'Второе';
    // Напитки, напиток, пить, попить, водичка и т.д.
    if (lowerText.contains('напит') || lowerText.contains('попить') || lowerText.contains('пить')) return 'Напитки';
    // Выпечка, выпичка, десерт, сладости, сладкое
    if (lowerText.contains('выпеч') || lowerText.contains('выпич') || lowerText.contains('десерт') || lowerText.contains('сладк')) return 'Выпечка';
    return null;
  }

  Dish? _findMatchingDish(String lowerText) {
    for (final dish in allDishes) {
      final dishName = dish.name.toLowerCase();
      if (lowerText.contains(dishName)) return dish;

      final words = dishName.split(' ').where((w) => w.length > 3);
      for (var word in words) {
        if (lowerText.contains(word)) return dish;
      }
    }
    return null;
  }

  bool _isTriggerWordInText(String text) {
    if (text.trim().isEmpty) return false;
    final lowerText = text.toLowerCase();
    
    if (_findMatchingDish(lowerText) != null) return true;
    if (_getMatchedCategory(lowerText) != null) return true;
    
    return false;
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      if (mounted) {
        setState(() => _isListening = false); 
      }
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool permissionGranted = await _requestMicrophonePermission();
      if (!permissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешение на микрофон не предоставлено')),
          );
        }
        return;
      }

      if (!_speechToText.isAvailable) {
        debugPrint('Speech to text is not available');
        return;
      }

      if (mounted) {
        setState(() {
          _isListening = true;
        });
      }

      try {
        await _speechToText.listen(
          onResult: (result) {
            if (!mounted) return; 
            if (_isHandlingVoice) return; 

            setState(() {
              _recognizedText = result.recognizedWords;
            });
            
            if (_isTriggerWordInText(_recognizedText)) {
              _isHandlingVoice = true; 
              _stopListening(); 
              _handleVoiceResult(_recognizedText);
              return; 
            }

            if (result.finalResult) {
              _isHandlingVoice = true; 
              _stopListening(); 
              _handleVoiceResult(_recognizedText);
            }
          },
          localeId: 'ru_RU',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2), 
        );
      } catch (e) {
        debugPrint('Error listening: $e');
        if (mounted) {
          setState(() => _isListening = false);
        }
      }
    }
  }
  
  void _handleVoiceResult(String text) {
    if (!mounted) return;

    _closeVoiceDialogIfOpen();
    
    if (text.trim().isEmpty) return; 

    final lowerText = text.toLowerCase();
    final matchingDish = _findMatchingDish(lowerText);
    
    if (matchingDish != null) {
      addToCart(matchingDish);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${matchingDish.name} добавлено в корзину!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          )
        );
      }
    } else {
      // ИЩЕМ КАТЕГОРИЮ ПО КОРНЯМ
      String? matchingCategory = _getMatchedCategory(lowerText);
      
      if (matchingCategory != null) {
        // ДОБАВЛЕНО УВЕДОМЛЕНИЕ, что категория открывается
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Открываю: $matchingCategory 🍽️'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            )
          );
        }
        _openCategory(matchingCategory);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Блюдо не найдено. Попробуй назвать другое.')),
          );
        }
      }
    }
  }

  void _showVoiceDialog() {
    _recognizedText = '';
    _isHandlingVoice = false;
    _isListening = false; 
    _isVoiceDialogOpen = true;
    
    _startListening();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, size: 60, color: Colors.orange),
                const SizedBox(height: 16),
                
                const Text(
                  'Слушаю...',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                Text(
                  _recognizedText.isNotEmpty ? _recognizedText : 'Назови блюдо или категорию',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, 
                    color: _recognizedText.isNotEmpty ? Colors.blue : Colors.grey
                  ),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _stopListening();
                        _closeVoiceDialogIfOpen();
                        if (_recognizedText.isNotEmpty && !_isHandlingVoice) {
                          _isHandlingVoice = true; 
                          _handleVoiceResult(_recognizedText);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Готово'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                         _stopListening();
                         _closeVoiceDialogIfOpen();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Отмена'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
    final popularDishes = allDishes.take(4).toList();

    return Scaffold(
      appBar: const InclusiveAppBar(title: 'Вкусная Перемена'),
      
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
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _carouselImages.length,
                onPageChanged: (index) {
                   if (mounted) {
                     setState(() => _currentCarouselIndex = index); 
                   }
                },
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.network(
                      _carouselImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.orange.shade100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.restaurant, size: 48, color: Colors.orange),
                      ),
                    ),
                  );
                },
              ),
            ),
            
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
            
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, 
              ),
              itemCount: popularDishes.length,
              itemBuilder: (context, index) {
                final dish = popularDishes[index];
                return InkWell(
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
                            child: Image.network(
                              dish.imageUrl, 
                              fit: BoxFit.cover, 
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Icon(dish.icon, size: 48, color: Colors.orange),
                              ),
                            ),
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
            const SizedBox(height: 100), 
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