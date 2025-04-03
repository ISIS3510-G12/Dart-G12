import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/repositories/home_repository.dart';

class ChatService {
  final String apiKey = "TU_API_KEY";
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  final SupabaseClient supabase = SupabaseService().client;
  final HomeRepository homeRepository = HomeRepository();

  Future<String> sendMessage(String message) async {
    try {
      // 🔍 1. Obtener datos de Supabase
      List<Map<String, dynamic>> locations = await homeRepository.fetchLocations();
      List<Map<String, dynamic>> recommendations = await homeRepository.fetchRecommendations();
      Map<String, dynamic>? mostSearchedLocation = await homeRepository.fetchMostSearchedLocation();

      // 📝 2. Construir el contexto con los datos obtenidos
      String systemMessage = "Eres un asistente especializado en la Universidad de Los Andes (Uniandes). "
          "Solo puedes responder preguntas relacionadas con esta universidad, su movilidad, eventos y lugares dentro del campus. "
          "Si el usuario pregunta sobre otra universidad, responde: 'Lo siento, solo puedo proporcionar información sobre la Universidad de Los Andes (Uniandes).'";

      if (locations.isNotEmpty) {
        systemMessage += "\n📍 **Lugares disponibles en la universidad:** ${locations.map((l) => l['name']).join(', ')}.";
      }
      
      if (recommendations.isNotEmpty) {
        systemMessage += "\n🎭 **Eventos recomendados:** ${recommendations.map((e) => '${e['name']} en ${e['locations']['name']}').join(', ')}.";
      }
      
      if (mostSearchedLocation != null) {
        systemMessage += "\n🔥 **Lugar más buscado:** ${mostSearchedLocation['name']}.";
      }

      // 🔥 3. Enviar la solicitud a ChatGPT con el contexto de Supabase
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {"role": "system", "content": systemMessage},
            {"role": "user", "content": message}
          ],
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData["choices"][0]["message"]["content"];
      } else {
        return "Error: ${response.body}";
      }
    } catch (e) {
      return "Error al conectar con la API: $e";
    }
  }
}
