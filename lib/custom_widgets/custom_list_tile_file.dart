import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomListTileFile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool? isFolder;
  final bool? isEncrypted;
  final bool? isDownloaded;
  const CustomListTileFile(
      {super.key,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap,
      this.onLongPress,
      this.isFolder,
      this.isEncrypted,
      this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing != null ? Text(trailing!) : null,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isEncrypted == true
              ? const Icon(
                  Icons.lock,
                  color: Colors.white,
                )
              : isDownloaded == true
                  ? const Icon(
                      Icons.download_done,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.file_copy,
                      color: Colors.white,
                    ),
        ),
      ),
    );
  }
}
