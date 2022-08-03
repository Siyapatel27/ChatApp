import 'package:chat_app/Preferences.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class ChangeTheme extends StatefulWidget {
  const ChangeTheme({Key? key}) : super(key: key);

  @override
  State<ChangeTheme> createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  int themeIndex = themeColorIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          'Change Background',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: themeColors[themeIndex].shade100,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RecieverCard(),
                  SenderCard(),
                ],
              ),
            ),
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Text(
                          'Select Color',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // UserThemePref
                            setIntPrefs(Preference.UserThemePref, themeIndex);
                            setState(() {
                              themeColorIndex = themeIndex;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: themeColors.length,
                      itemBuilder: (context, index) {
                        return Colorcard(themeColors[index], index);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget Colorcard(MaterialColor color, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          themeIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 15),
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          color: color.shade200,
          border: index == themeIndex
              ? Border.all(color: Colors.black, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget RecieverCard() {
    DateTime msgTime = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          'Set as a Chat Background ',
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
    );
  }

  Widget SenderCard() {
    DateTime msgTime = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      color: themeColors[themeIndex],
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
                          'Try Changing colours',
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
    );
  }
}
