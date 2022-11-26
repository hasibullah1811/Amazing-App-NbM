import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class DownloadedFilesScreen extends StatefulWidget {
  const DownloadedFilesScreen({super.key});

  @override
  State<DownloadedFilesScreen> createState() => _DownloadedFilesScreenState();
}

class _DownloadedFilesScreenState extends State<DownloadedFilesScreen> {
  late AuthService authService;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    authService = Provider.of<AuthService>(context);

    authService.retrieveDownloadedFileLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new ListView.builder(
        itemCount: authService.fileMap.length,
        itemBuilder: (BuildContext context, int index) {
          String key = authService.fileMap.keys.elementAt(index);
          return new Column(
            children: <Widget>[
              new ListTile(
                title: new Text("$key"),
                subtitle: new Text("${authService.fileMap[key]}"),
              ),
              new Divider(
                height: 2.0,
              ),
            ],
          );
        },
      ),
    );
  }
}
