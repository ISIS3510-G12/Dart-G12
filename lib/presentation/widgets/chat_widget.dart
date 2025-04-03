import 'package:flutter/material.dart';
import 'package:dart_g12/presentation/view_models/chat_viewmodel.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  ChatWidgetState createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  final ChatViewModel _viewModel = ChatViewModel();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;

  void _sendMessage(String message) async {
    String trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return;

    await _viewModel.sendMessage(trimmedMessage);

    // Actualiza la UI para reflejar los cambios en el ViewModel.
    setState(() {});
    _controller.clear();
    _searchController.clear();
  }

  void _toggleChat() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    // Si ya existe el overlay, solo se llama markNeedsBuild para actualizarlo.
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.3), // Fondo semitransparente
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _removeOverlay,
                  child: Container(color: Colors.transparent),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isExpanded
                    ? MediaQuery.of(context).size.width
                    : 300,
                height: _isExpanded
                    ? MediaQuery.of(context).size.height * 0.75
                    : 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: _isExpanded
                      ? BorderRadius.zero
                      : BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    // Header del Chat
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ChatBot",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_isExpanded
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen),
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = !_isExpanded;
                                  });
                                  _overlayEntry?.markNeedsBuild();
                                },
                              ),
                              IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: _removeOverlay),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Lista de Mensajes
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: _viewModel.messages.length,
                        itemBuilder: (context, index) {
                          final message = _viewModel.messages[index];
                          final isUser = message["role"] == "user";
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.6),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(message["content"]!,
                                  style: TextStyle(fontSize: 16)),
                            ),
                          );
                        },
                      ),
                    ),
                    // Input del Chat
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: "Escribe un mensaje...",
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white),
                              onPressed: () =>
                                  _sendMessage(_controller.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Where to go?",
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.only(left: 30), // Padding izquierdo
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _sendMessage(_searchController.text);
              }
              _toggleChat();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
