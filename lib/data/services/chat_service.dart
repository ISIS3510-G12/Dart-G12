import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dart_g12/data/services/supabase_service.dart';
import 'package:dart_g12/data/repositories/home_repository.dart';

class ChatService {
  final String apiKey = "A";
  final String apiUrl = "https://api.openai.com/v1/chat/completions";
  final SupabaseClient supabase = SupabaseService().client;
  final HomeRepository homeRepository = HomeRepository();

  Future<String> sendMessage(String message) async {
    try {
      // 🔍 1. Obtener datos de Supabase
      List<Map<String, dynamic>> locations = await homeRepository.fetchLocations();
      // 📝 2. Construir el contexto con los datos obtenidos
      String systemMessage = """
      Eres un asistente de la Universidad de Los Andes (Uniandes).
      Solo puedes responder preguntas sobre esta universidad, su movilidad, eventos y lugares dentro del campus.
      
      Si el usuario menciona un lugar, incluye su ID en la respuesta. 
      Formato de respuesta:
      - Texto normal de respuesta
      - Si hay un lugar relevante: {"id": "id_lugar", "name": "nombre_lugar"}
      """;

      if (locations.isNotEmpty) {
        systemMessage += "\n📍 **Lugares en la universidad:**\n";
        systemMessage += locations.map((l) => "- ${l['name']} (ID: ${l['location_id']})").join('\n');
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
