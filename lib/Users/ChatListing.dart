import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';
import 'chatScreen.dart';
class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}
class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;
  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? "";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("chat_rooms").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No chats available"));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats available"));
          }
          for (var doc in snapshot.data!.docs) {
            print("Chat Room Found: ${doc.id}");
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats available"));
          }
          var chatRooms = snapshot.data!.docs.where((doc) {
// current user is part of the chat room anno ennu check cheyan
            List<String> userIds = doc.id.split("_");
            return userIds.contains(currentUserId);

          }).toList();
          if (chatRooms.isEmpty) {
            return Center(child: Text("No active chats found"));
          }
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              var chatRoom = chatRooms[index];
              List<String> userIds = chatRoom.id.split("_");
              String otherUserId =
              userIds.firstWhere((id) => id != currentUserId);
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection("Doctors").doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox.shrink();
                  var userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
                  String otherUserName = userData["doctorname"] ?? "Unknown User";
                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("chat_rooms")
                        .doc(chatRoom.id)
                        .collection("messages")
                        .orderBy("timestamp", descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      if (!messageSnapshot.hasData ||
                          messageSnapshot.data!.docs.isEmpty) {
                        return SizedBox.shrink(); // Hide empty chats
                      }
                      var lastMessage = messageSnapshot.data!.docs.first;
                      String lastMessageText = lastMessage["message"];
                      Timestamp lastMessageTime = lastMessage["timestamp"];
                      return Card(
                        child: ListTile(
                          title: Text(otherUserName),
                          subtitle: Text(lastMessageText),
                          trailing: Text(_formatTimestamp(lastMessageTime)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(otherUserId, otherUserName),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );

            },
          );
        },
      ),
    );
  }
  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute}"; // Format as HH:MM
  }
}