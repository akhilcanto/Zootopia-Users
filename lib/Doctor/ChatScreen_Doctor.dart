import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen_Doctor extends StatefulWidget {
  final String userId;
  final String userName;

  ChatScreen_Doctor(this.userId, this.userName, {super.key});

  @override
  State<ChatScreen_Doctor> createState() => _ChatScreen_DoctorState();
}

class _ChatScreen_DoctorState extends State<ChatScreen_Doctor> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? "";
  }

  String _getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return users.join("_");
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String chatRoomId = _getChatRoomId(currentUserId, widget.userId);
    DocumentReference chatRoomRef =
        _firestore.collection("chat_rooms").doc(chatRoomId);
    await chatRoomRef.set({
      "users": [currentUserId, widget.userId],
      "lastMessage": _messageController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

// Send the message
    await chatRoomRef.collection("messages").add({
      "senderId": currentUserId,
      "message": _messageController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  }

  Stream<QuerySnapshot> _getMessages() {
    String chatRoomId = _getChatRoomId(currentUserId, widget.userId);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.black,
            toolbarHeight: 70,
            title: Text("Chat with ${widget.userName}",
                style: TextStyle(color: Colors.white))),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/chatbg.jpg"),
              // make sure this image exists
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getMessages(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var messages = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        bool isMe = message["senderId"] == currentUserId;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message["message"],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
