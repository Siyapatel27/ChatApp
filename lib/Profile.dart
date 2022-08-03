import 'dart:io';

import 'package:chat_app/ChangeTheme.dart';
import 'package:chat_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'Preferences.dart';
import 'SignUp.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  Future? data;
  FirebaseAuth? auth;
  String? userName, emailId;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    getData();
  }

  getData() async {
    String? uName = await getStringPrefs(Preference.NamePref);
    String? eId = await getStringPrefs(Preference.EmailPref);

    setState(() {
      userName = uName;
      emailId = eId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeColors[themeColorIndex],
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(26),
                    child: Text(
                      userName == null ? '' : userName![0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    userName ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    emailId ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeTheme()))
                          .whenComplete(() {
                        setState(() {});
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeColors[themeColorIndex].withOpacity(0.1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.color_lens,
                            size: 24,
                            color: themeColors[themeColorIndex],
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Theme',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 20,
                            color: themeColors[themeColorIndex],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      await auth?.signOut();
                      prefs?.clear();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                          (Route<dynamic> route) => false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: themeColors[themeColorIndex].withOpacity(0.1),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 24,
                            color: themeColors[themeColorIndex],
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 20,
                            color: themeColors[themeColorIndex],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
}
