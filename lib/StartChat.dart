import 'package:chat_app/ChatRoom.dart';
import 'package:chat_app/Preferences.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StartChat extends StatefulWidget {
  final String? userId;

  const StartChat({Key? key, this.userId}) : super(key: key);

  @override
  State<StartChat> createState() => _StartChatState();
}

class _StartChatState extends State<StartChat> {
  List<String> chatRooms = [];

  @override
  void initState() {
    super.initState();
    getChatRoomData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColors[themeColorIndex].shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Start Chat',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemBuilder: (context, index) {
              return userCard(snapshot, index);
            },
          );
        },
      ),
    );
  }

  Widget userCard(AsyncSnapshot snapshot, int index) {
    if (snapshot.data!.docs[index]['userId'] == widget.userId) {
      return Container();
    }

    return GestureDetector(
      onTap: () {
        createChat(snapshot.data!.docs[index]);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: themeColors[themeColorIndex],
                shape: BoxShape.circle,
              ),
              child: Text(
                snapshot.data!.docs[index]['name'][0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                snapshot.data!.docs[index]['name'],
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

  getChatRoomData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    List<String> chatRoomsTemp = [];

    await db.collection("chatRooms").get().then((value) {
      for (var i in value.docs) {
        chatRoomsTemp.add(i.id);
      }

      setState(() {
        chatRoomsTemp = chatRooms;
      });
    });
  }

  createChat(QueryDocumentSnapshot snapshot) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    int user1 = int.parse(widget.userId!);
    int user2 = int.parse(snapshot['userId']);

    String chatRoomId =
        (user1 > user2) ? "${user2}_${user1}" : "${user1}_${user2}";

    //Check if chat already exists
    if (chatRooms.contains(chatRoomId)) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChatRoom(
                    chatRoomId: chatRoomId,
                    name: snapshot['name'],
                  )));
    } else {
      final Map<String, dynamic> userData1 = {
        "name": snapshot['name'],
        "chatRoomId": chatRoomId
      };
      db
          .collection("users")
          .doc("${widget.userId}")
          .collection("chats")
          .doc(snapshot['userId'])
          .set(userData1);

      String name = await getStringPrefs(Preference.NamePref);
      final Map<String, dynamic> userData2 = {
        "name": name,
        "chatRoomId": chatRoomId
      };
      db
          .collection("users")
          .doc(snapshot['userId'])
          .collection("chats")
          .doc(widget.userId)
          .set(userData2);

      final Map<String, dynamic> chatRoomData = {
        "${widget.userId}_action": "reqeusted",
        "${snapshot['userId']}_action": "pending",
        "requestedBy": "${widget.userId}",
      };
      db.collection("chatRooms").doc(chatRoomId).set(chatRoomData);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChatRoom(
                    chatRoomId: chatRoomId,
                    name: snapshot['name'],
                  )));
    }
  }
}
