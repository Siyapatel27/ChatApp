import 'dart:io';

import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'ChangeTheme.dart';
import 'ImageView.dart';
import 'Preferences.dart';

class ChatRoom extends StatefulWidget {
  final String? name, chatRoomId;

  const ChatRoom({Key? key, this.name, this.chatRoomId}) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController txtController = new TextEditingController();
  String userId = "1";

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  getUsers() async {
    String userID = await getStringPrefs(Preference.UserIdPref);
    setState(() {
      userId = userID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColors[themeColorIndex].shade100,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 8, 15),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColors[themeColorIndex],
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.name![0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: 60,
          ),
          PopupMenuButton<int>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text(
                  'Change Background',
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ChangeTheme()))
                    .whenComplete(() {
                  setState(() {});
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chatRooms")
                  .doc("${widget.chatRoomId}")
                  .collection("chats")
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: themeColors[themeColorIndex],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.name![0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          "Start the chat with 'Hi'",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: 14),
                    itemBuilder: (_, index) {
                      // Map<String, dynamic> data = snapshot
                      //     .data!.docs[index] as Map<String, dynamic>;
                      if (snapshot.data!.docs[index]['sentBy'] == userId) {
                        return SenderCard(snapshot.data!.docs[index]);
                      }
                      return RecieverCard(snapshot.data!.docs[index]);
                    });
              },
            ),
          ),
          chatInput(),
        ],
      ),
    );
  }

  void _send(int type, {String? imageUrl}) async {
    //Type:: 0 - Text message, 1 - Image message
    FirebaseFirestore db = FirebaseFirestore.instance;
    final user = <String, dynamic>{
      "message": type == 0 ? txtController.text.trim() : imageUrl,
      "time": DateTime.now().millisecondsSinceEpoch,
      "sentBy": userId,
      "messageType": type,
    };

    db
        .collection("chatRooms")
        .doc("${widget.chatRoomId}")
        .collection("chats")
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(user);

    txtController.text = "";
  }

  Widget chatInput() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      child: BottomAppBar(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Type here...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none),
                      controller: txtController,
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Select an Image',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 14),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            pickImage(ImageSource.camera),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: themeColors[themeColorIndex]
                                                .shade50,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.camera,
                                                size: 30,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Capture Image',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            pickImage(ImageSource.gallery),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: themeColors[themeColorIndex]
                                                .shade50,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.photo,
                                                size: 30,
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Pick an Image',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Icon(
                      Icons.attach_file,
                      color: themeColors[themeColorIndex].shade600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (txtController.text.trim().isNotEmpty) {
                        _send(0);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: themeColors[themeColorIndex]),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemp = File(image.path);

      Navigator.pop(context);
      showImageLoading();

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance
          .ref()
          .child('${widget.chatRoomId}/$fileName');

      UploadTask uploadTask = reference.putFile(imageTemp);

      uploadTask.then((value) async {
        String url = await value.ref.getDownloadURL();
        Navigator.pop(context);
        _send(1, imageUrl: url);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Widget RecieverCard(QueryDocumentSnapshot data) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(data['time']);

    if (data['messageType'] == 1) {
      return receiverImageCard(data);
    }

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        'Copy Text',
                      ),
                      onTap: () {
                        Clipboard.setData(
                            new ClipboardData(text: data['message']));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    //height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            data['message'],
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${msgTime.hour}:${msgTime.minute}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
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
    );
  }

  Widget SenderCard(QueryDocumentSnapshot data) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(data['time']);

    if (data['messageType'] == 1) {
      return senderImageCard(data);
    }

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        'Copy Text',
                      ),
                      onTap: () {
                        Clipboard.setData(
                            new ClipboardData(text: data['message']));
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Unsend Message',
                      ),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          transaction.delete(data.reference);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              );
            });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: themeColors[themeColorIndex],
                        // color: Color(0xff6e3ffe),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.zero)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            data['message'],
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${msgTime.hour}:${msgTime.minute}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
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
    );
  }

  showImageLoading() {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: themeColors[themeColorIndex],
                ),
                SizedBox(width: 20),
                Text(
                  'Please wait...',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget receiverImageCard(QueryDocumentSnapshot data) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(data['time']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageView(
                      name: widget.name,
                      chatRoomId: widget.chatRoomId,
                      url: data['message'],
                      tag: data['time'].toString(),
                    )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.zero),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Hero(
                            tag: '${data['time']}',
                            child: Image.network(
                              data['message'],
                              height: 130,
                              width: 230,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Text(
                              '${msgTime.hour}:${msgTime.minute}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500),
                            ),
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
    );
  }

  Widget senderImageCard(QueryDocumentSnapshot data) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(data['time']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageView(
                      name: widget.name,
                      chatRoomId: widget.chatRoomId,
                      url: data['message'],
                      tag: data['time'].toString(),
                    )));
      },
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        'Unsend Message',
                      ),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .runTransaction((transaction) async {
                          transaction.delete(data.reference);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              );
            });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: themeColors[themeColorIndex],
                      // color: Color(0xff6e3ffe),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.zero),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Hero(
                            tag: '${data['time']}',
                            child: Image.network(
                              data['message'],
                              height: 130,
                              width: 230,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10)),
                              gradient: LinearGradient(
                                colors: [
                                  themeColors[themeColorIndex].withOpacity(0.0),
                                  themeColors[themeColorIndex].withOpacity(0.3),
                                  themeColors[themeColorIndex].withOpacity(0.7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Text(
                              '${msgTime.hour}:${msgTime.minute}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
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
    );
  }
}
