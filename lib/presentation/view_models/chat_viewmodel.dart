import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String message) async {
    String userMessage = message.trim();
    if (userMessage.isEmpty) return;

    _messages.add({"role": "user", "content": userMessage});
    notifyListeners(); // 🔥 Notificar a la UI

    String response = await _chatService.sendMessage(userMessage);
    _messages.add({"role": "assistant", "content": response});
    notifyListeners(); // 🔥 Actualizar la UI con la respuesta
  }
}
