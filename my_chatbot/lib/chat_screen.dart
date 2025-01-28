import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_chatbot/const.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // ✅ Animation package

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> messages = [];
  final types.User _user = const types.User(id: '1');
  final types.User bot = const types.User(id: '2', firstName: 'ThilanBot');
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  bool isBotTyping = false;

  Future<void> handleThilanBotResponse(String userMessage) async {
    setState(() {
      isBotTyping = true;
    });

    final content = [Content.text(userMessage)];

    try {
      final response = await model.generateContent(content);

      print("User: $userMessage");
      print("Bot Response: ${response.text}");

      final botMessage = types.TextMessage(
        author: bot,
        createdAt: DateTime.now().microsecondsSinceEpoch,
        id: const Uuid().v4(),
        text: response.text?.trim().isNotEmpty == true
            ? response.text!
            : "Sorry, I couldn't generate a response.",
      );

      setState(() {
        isBotTyping = false;
        messages.insert(0, botMessage);
      });
    } catch (e) {
      print("Error generating response: $e");
      setState(() {
        isBotTyping = false;
        messages.insert(
          0,
          types.TextMessage(
            author: bot,
            createdAt: DateTime.now().microsecondsSinceEpoch,
            id: const Uuid().v4(),
            text: "Oops! Something went wrong. Please try again.",
          ),
        );
      });
    }
  }

  /// Handles user message send action
  void handleSend(types.PartialText message) {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().microsecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      messages.insert(0, userMessage);
    });

    handleThilanBotResponse(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thilan ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: messages,
              onSendPressed: handleSend,
              user: _user,
            ),
          ),
          if (isBotTyping) _buildTypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 14,
            child: Icon(Icons.android, size: 16),
          ),
          const SizedBox(width: 8),
          const SpinKitThreeBounce(
            color: Colors.grey,
            size: 20.0,
          ),
        ],
      ),
    );
  }
}
