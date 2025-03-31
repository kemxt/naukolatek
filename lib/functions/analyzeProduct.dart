import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> analyzeProduct(BuildContext context) async {
  try {
    // Inicjalizacja ImagePicker
    final ImagePicker picker = ImagePicker();

    // Otwarcie kamery i zrobienie zdjęcia
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // Możesz dostosować jakość obrazu
    );

    // Sprawdzenie czy użytkownik zrobił zdjęcie
    if (imageFile == null) {
      return null; // Użytkownik anulował operację
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 12, 0, 34).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.purple.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Analizuję produkt...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final bytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(bytes);

    final apiKey = dotenv.env['APIKEY'];
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Stworzenie zapytania
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Zidentyfikuj obiekt na zdjęciu. Zwróć TYLKO obiekt JSON z następującą strukturą: { "title": "dokładna nazwa obiektu", "category": "kategoria" } Gdzie kategoria to TYLKO jedna z: "Jedzenie", "Zainteresowania", "Edukacja", "Praca", "Zdrowie", "Inne". Nie dodawaj żadnego tekstu, komentarzy, wyjaśnień ani oznaczeń kodu.'
              },
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
              }
            ]
          }
        ],
        'max_tokens': 300
      }),
    );
    Navigator.of(context, rootNavigator: true).pop();
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));

      final String rawContent = data['choices'][0]['message']['content'];
      String cleanContent =
          rawContent.replaceAll("```json", "").replaceAll("```", "").trim();

      // Parsowanie odpowiedzi JSON
      final Map<String, dynamic> productData = jsonDecode(cleanContent);

      return productData;
    } else {
      // Obsługa błędu API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas analizy: ${response.statusCode}')),
      );
      return null;
    }
  } catch (e) {
    // Obsługa ogólnych wyjątków
    // Navigator.of(context, rootNavigator: true)
    // .pop(); // Zamknij dialog jeśli jest otwarty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Wystąpił błąd: $e')),
    );
    print(e);
    return null;
  }
}

Future<Map<String, dynamic>?> analyzeReceipt(BuildContext context) async {
  try {
    // Inicjalizacja ImagePicker
    final ImagePicker picker = ImagePicker();

    // Otwarcie kamery i zrobienie zdjęcia
    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Możesz dostosować jakość obrazu
    );

    // Sprawdzenie czy użytkownik zrobił zdjęcie
    if (imageFile == null) {
      return null; // Użytkownik anulował operację
    }

    // Pokazanie wskaźnika ładowania
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 12, 0, 34).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.purple.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Analizuję paragon...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final bytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(bytes);

    final apiKey = dotenv.env['APIKEY'];
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Stworzenie zapytania
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Zidentyfikuj ten paragon i zwróć TYLKO jego nazwę oraz kategorię TYLKO w formacie JSON. NIE ANALIZUJ PRODUKTOW. Format odpowiedzi to: {"title": "nazwa np. zakupy Biedronka, Paliwo Orlen ", "category": "kategoria sklpeu tylko z ["Jedzenie","Zainteresowania","Edukacja","Praca","Zdrowie","Inne"]}, "price": "w formacie double zczytaj cene całego paragonu". Nie dodawaj żadnego innego tekstu ani wyjaśnień. Jeśli zdjęcie nie jest paragonem, zwróc "name":"error"'
              },
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
              }
            ]
          }
        ],
        'max_tokens': 300
      }),
    );
    Navigator.of(context, rootNavigator: true).pop();
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));

      final String rawContent = data['choices'][0]['message']['content'];
      String cleanContent =
          rawContent.replaceAll("```json", "").replaceAll("```", "").trim();

      // Parsowanie odpowiedzi JSON
      final Map<String, dynamic> productData = jsonDecode(cleanContent);

      return productData;
    } else {
      // Obsługa błędu API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas analizy: ${response.statusCode}')),
      );
      return null;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Wystąpił błąd: $e')),
    );
    print(e);
    return null;
  }
}
