import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  final String? name, chatRoomId, url, tag;

  const ImageView({Key? key, this.name, this.chatRoomId, this.url, this.tag})
      : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
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
      ),
      body: Hero(
        tag: widget.tag!,
        child: PhotoView(
          initialScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 1.5,
          minScale: PhotoViewComputedScale.contained,
          backgroundDecoration: BoxDecoration(
            color: themeColors[themeColorIndex].withOpacity(0.2),
          ),
          imageProvider: NetworkImage(
            widget.url!,
          ),
        ),
      ),
    );
  }
}
