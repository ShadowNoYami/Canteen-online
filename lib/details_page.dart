import 'package:flutter/material.dart';
// Обрати внимание: мы больше не импортируем flutter_tts напрямую сюда,
// так как используем globalTts из inclusive_widgets.dart
import 'inclusive_widgets.dart'; 
import 'app_state.dart'; 

class DetailsPage extends StatefulWidget {
  final Dish dish; 

  const DetailsPage({super.key, required this.dish});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  @override
  void initState() {
    super.initState();
    // ГЛАВНАЯ МАГИЯ: Если глобальный режим озвучки включен, 
    // блюдо само начнет себя зачитывать при открытии экрана!
    if (autoVoiceNotifier.value) {
      _speakDishInfo();
    }
  }

  Future<void> _speakDishInfo() async {
    await globalTts.setLanguage("ru-RU");
    await globalTts.setSpeechRate(0.65); 
    await globalTts.setPitch(1.0);

    // Добавил озвучку цены!
    String textToSpeak = "Блюдо: ${widget.dish.name}. Цена: ${widget.dish.price} тенге. ";
    
    if (widget.dish.allergens.isNotEmpty) {
      textToSpeak += "Внимание, присутствуют аллергены: ${widget.dish.allergens.join(', ')}.";
    } else {
      textToSpeak += "В этом блюде нет аллергенов.";
    }

    await globalTts.speak(textToSpeak);
  }

  @override
  void dispose() {
    // Если пользователь закрыл блюдо, не дослушав - голос замолкает
    globalTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InclusiveAppBar(
        title: 'О блюде', 
        showBackButton: true,
        onSpeak: _speakDishInfo, // Если захотят послушать еще раз - нажмут на кнопку
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.dish.imageUrl, 
                  height: 300, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: Icon(widget.dish.icon, size: 80, color: Colors.orange),
                  ),
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
                      '${widget.dish.price} ₸', 
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
                  Text(
                    widget.dish.name, 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 24),
                  
                  if (widget.dish.allergens.isNotEmpty) ...[
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
                                Text(widget.dish.allergens.join(', '), style: const TextStyle(fontSize: 16, color: Colors.black87)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

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
                      widget.dish.composition, 
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      addToCart(widget.dish);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.dish.name} добавлено в корзину!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                      Navigator.pop(context); 
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