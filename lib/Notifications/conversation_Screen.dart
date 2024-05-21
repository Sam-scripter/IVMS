import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String username;
  final String email;

  const ConversationScreen({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String messageText;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadMessages();
  }

  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _loadMessages() async {
    final user = _auth.currentUser;
    final otherUserEmail = widget.email;

    List<String> ids = [user!.email!, otherUserEmail];
    ids.sort();
    String chatRoomId = ids.join("_");

    var query = _firestore
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    await for (var snapshot in query.snapshots()) {
      _messages.clear(); // Clear existing messages before adding new ones

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final messageText = data['text'] as String;
        final sender = data['sender'] as String;
        final timestamp = (data['timestamp'] as Timestamp).toDate();

        setState(() {
          _messages.add(
            ChatMessage(
              text: messageText,
              isSender: sender == user.email,
              time: _formatTimestamp(timestamp),
            ),
          );
        });
      }
    }
    _scrollDown();
  }

  void _sendMessage(String text, String receiverId) async {
    final user = _auth.currentUser;
    DateTime currentTime = DateTime.now();

    List<String> ids = [user!.email!, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'sender': user.email,
      'receiver': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _messages.add(ChatMessage(
          text: text,
          isSender: true,
          time: '${currentTime.hour}:${currentTime.minute}'));
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    String hour = timestamp.hour.toString().padLeft(2, '0');
    String minute = timestamp.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Color(0xFF111328),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: Colors.white), // Text color
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey), // Hint text color
                    border: InputBorder.none, // No border
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_messageController.text, widget.email);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSender;
  final String time;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isSender,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, right: 18, left: 18),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSender ? Colors.blue : Colors.purple,
                borderRadius: isSender
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        topRight: Radius.circular(30))
                    : const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
