import 'package:amazing_app/services/test_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        title: const Text("Test Face Recognition"),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await testService.fetchPhotos();
                  },
                  child: const Text("Fetch Users"),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // await testService.fetchUserPhotos();
                  },
                  child: const Text("Add Test photo"),
                ),
              ],
            ),
            Text('added photo'),
            const Divider(
              thickness: 5,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: testService.userPhotos.length,
                itemBuilder: (context, index) {
                  // return SizedBox(
                  //   height: 100,
                  //   width: 100,
                  //   child: Image.network(testService.userPhotos[index]),
                  // );
                  return Card(
                    child: ListTile(
                      title: CachedNetworkImage(
                        imageUrl: testService.userPhotos[index],
                        placeholder: (context, url) => const Icon(Icons.image),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
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
