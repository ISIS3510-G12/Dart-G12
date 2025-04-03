import 'package:dart_g12/data/services/chat_service.dart';

class ChatViewModel {
  final ChatService _chatService = ChatService();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String message) async {
    String userMessage = message.trim();
    if (userMessage.isEmpty) return;
    
    // Agregar mensaje del usuario
    messages.add({"role": "user", "content": userMessage});
    
    // Enviar el mensaje al servicio y agregar la respuesta
    String response = await _chatService.sendMessage(userMessage);
    messages.add({"role": "assistant", "content": response});
  }
}
