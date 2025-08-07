import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zootopia/Doctor/ChatScreen_Doctor.dart';
import 'package:zootopia/Doctor/Function_Doctor/doc_Appbar.dart';
// import 'chatScreen.dart';
class ChatList_Doctor extends StatefulWidget {
  @override
  _ChatList_DoctorState createState() => _ChatList_DoctorState();
}
class _ChatList_DoctorState extends State<ChatList_Doctor> {
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
      appBar: DocAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("chat_rooms").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            print("Snapshot has no data");
            return Center(child: Text("No chats available"));
          }
          if (snapshot.data!.docs.isEmpty) {
            print("Fetched chat_rooms collection but found no documents");
            return Center(child: Text("No chats available"));
          }
          for (var doc in snapshot.data!.docs) {
            print("Chat Room Found: ${doc.id}");
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No chats available"));
          }
          var chatRooms = snapshot.data!.docs.where((doc) {
// Check if the current user is part of the chat room
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
                future: _firestore.collection("Users").doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox.shrink();
                  var userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
                  String otherUserName = userData["name"] ?? "Unknown User";
                  String imageUrl = userData["imageUrl"] ?? "";

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
                          leading: CircleAvatar(
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : AssetImage("assets/default_profile.png") as ImageProvider,
                          ),
                          title: Text(otherUserName),
                          subtitle: Text(lastMessageText),
                          trailing: Text(_formatTimestamp(lastMessageTime)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen_Doctor(otherUserId, otherUserName),
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
    return DateFormat('hh:mm a').format(date); // 12-hour format with AM/PM
  }
}