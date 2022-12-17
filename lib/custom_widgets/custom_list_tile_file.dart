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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: Colors.deepPurple[100]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: ListTile(
            onTap: onTap,
            onLongPress: onLongPress,
            title: Text(title),
            subtitle: subtitle != null ? Text(subtitle!) : null,
            trailing: trailing != null ? Text(trailing!) : null,
            leading: Container(
              width: 50,
              height: 50,
              // decoration: BoxDecoration(
              //   color: Colors.blueGrey,
              //   borderRadius: BorderRadius.circular(10),
              // ),
              child: Center(
                child: isEncrypted == true
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.lock_outlined,
                          color: Colors.amber,
                        ),
                        // color: Colors.amber,
                      )
                    : isDownloaded == true
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.download_done_outlined,
                              color: Colors.amber,
                            ),
                            // color: Colors.amber,
                          )
                        : IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.file_present,
                              color: Colors.amber,
                            ),
                            // color: Colors.amber,
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
