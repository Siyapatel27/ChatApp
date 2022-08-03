import 'package:chat_app/ChatRoom.dart';
import 'package:chat_app/Preferences.dart';
import 'package:chat_app/Profile.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'StartChat.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  CollectionReference? users;
  String userId = "1";

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  getUsers() async {
    String userID = await getStringPrefs(Preference.UserIdPref);
    int themeIndex = await getIntPrefs(Preference.UserThemePref);

    setState(() {
      userId = userID;
      themeColorIndex = themeIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColors[themeColorIndex].shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Let's Chat",
          style: TextStyle(
              fontFamily: 'Lobster',
              color: themeColors[themeColorIndex].shade600,
              fontSize: 24,
              fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Profile()))
                    .whenComplete(() {
                  setState(() {});
                });
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColors[themeColorIndex].withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.person,
                  size: 22,
                ),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("chats")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                  .copyWith(top: 20),
              itemCount: snapshot.data!.docs.length,
              physics: BouncingScrollPhysics(),
              //controller: scrcontroller,
              // reverse: true,
              itemBuilder: (_, index) {
                return Contact(snapshot.data!.docs[index]);
              });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StartChat(userId: userId)))
              .whenComplete(() {
            setState(() {});
          });
        },
        backgroundColor: themeColors[themeColorIndex],
        icon: Icon(Icons.add),
        label: Text('Start Chat'),
      ),
    );
  }

  Widget Contact(QueryDocumentSnapshot data) {
    String? name = data['name'];
    String? chatRoomId = data['chatRoomId'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatRoom(name: name, chatRoomId: chatRoomId)))
            .whenComplete(() {
          setState(() {});
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: themeColors[themeColorIndex],
                shape: BoxShape.circle,
              ),
              child: Text(
                name![0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
