import 'package:amazing_app/screens/capture_face_live.dart';
import 'package:amazing_app/services/test_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestFaceRecognition extends StatefulWidget {
  const TestFaceRecognition({super.key});

  static const String routeName = "TestFaceRecognition";

  @override
  State<TestFaceRecognition> createState() => _TestFaceRecognitionState();
}

class _TestFaceRecognitionState extends State<TestFaceRecognition> {
  late TestService testService;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    testService = Provider.of<TestService>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Test Face API"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(CupertinoIcons.refresh),
              onPressed: () async {
                await testService.fetchPhotos();
              },
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ElevatedButton(
                //   onPressed: () async {
                //     await testService.fetchPhotos();
                //   },
                //   child: const Text("Fetch Users"),
                // ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
            const Divider(
              thickness: 5,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: testService.userPhotos.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          CaptureFaceTestLab.routeName,
                        );

                        testService.updateInitialTestImage(
                            testService.userPhotos[index]);
                      },
                      leading: CachedNetworkImage(
                        imageUrl: testService.userPhotos[index],
                        placeholder: (context, url) => const Icon(Icons.image),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      title: Text(
                        'Tap to start testing',
                      ),
                      trailing: Icon(
                        CupertinoIcons.chevron_right_circle_fill,
                        color: Colors.deepPurple,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
