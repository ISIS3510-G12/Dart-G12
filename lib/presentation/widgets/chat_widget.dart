import 'package:flutter/material.dart';
import 'package:dart_g12/data/services/chat_service.dart';
import 'dart:convert';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});
  
  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": userMessage});
    });
    _controller.clear();

    String response = await _chatService.sendMessage(userMessage);
    setState(() {
      _messages.add({"role": "assistant", "content": response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message["role"] == "user";
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[200] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message["content"]!,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 16), // Asegura compatibilidad de caracteres
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}