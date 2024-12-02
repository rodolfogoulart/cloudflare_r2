import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloudflare_r2/cloudflare_r2.dart';

Future<void> main() async {
  await CloudFlareR2.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controllerAccountId = TextEditingController(text: '');

  final controllerAcessId = TextEditingController(text: '');

  final controllerSecretAccessKey = TextEditingController(text: '');

  final controllerBucket = TextEditingController(text: '');

  final controllerObjectName = TextEditingController(text: '');
  //
  final controllercacheControl = TextEditingController(text: '');
  final controllercontentType = TextEditingController(text: '');

  String result = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                TextField(
                  controller: controllerAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Account Id',
                  ),
                ),
                TextField(
                  controller: controllerAcessId,
                  decoration: const InputDecoration(
                    labelText: 'Access Key ID',
                  ),
                ),
                TextField(
                  controller: controllerSecretAccessKey,
                  decoration: const InputDecoration(
                    labelText: 'Secret Access Key',
                  ),
                ),
                TextField(
                  controller: controllerBucket,
                  decoration: const InputDecoration(
                    labelText: 'Bucket',
                  ),
                ),
                TextField(
                  controller: controllerObjectName,
                  decoration: const InputDecoration(
                    labelText: 'Object Name',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      Stopwatch sw = Stopwatch()..start();
                      Uint8List object = await CloudFlareR2.getObject(
                        accountId: controllerAccountId.text,
                        accessId: controllerAcessId.text,
                        secretAccessKey: controllerSecretAccessKey.text,
                        bucket: controllerBucket.text,
                        objectName: controllerObjectName.text,
                      );
                      sw.stop();
                      log('${sw.elapsed.inSeconds} seconds');
                      int timeDownloaded = sw.elapsed.inSeconds;

                      File file = File(controllerObjectName.text);
                      await file.writeAsBytes(object);

                      log(file.path);
                      if (file.existsSync()) {
                        log('file exists');
                        setState(() {
                          result = 'File downloaded to: ${file.path}\n\n Time Downloaded: $timeDownloaded seconds';
                        });
                      }
                    },
                    child: const Text('Get Object')),
                const Divider(),
                TextField(
                  controller: controllercacheControl,
                  decoration: const InputDecoration(
                    labelText: 'Cache Control',
                  ),
                ),
                TextField(
                  controller: controllercontentType,
                  decoration: const InputDecoration(
                    labelText: 'Content Type',
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      File file = File(controllerObjectName.text);
                      file.writeAsStringSync('Hello World Clouldflare R2: ${DateTime.now()}');

                      Uint8List objectBytes = await file.readAsBytes();

                      Stopwatch sw = Stopwatch()..start();
                      await CloudFlareR2.putObject(
                          bucket: controllerBucket.text,
                          accountId: controllerAccountId.text,
                          accessId: controllerAcessId.text,
                          secretAccessKey: controllerSecretAccessKey.text,
                          objectName: controllerObjectName.text,
                          objectBytes: objectBytes,
                          cacheControl: controllercacheControl.text,
                          contentType: controllercontentType.text);
                      sw.stop();
                      log('${sw.elapsed.inSeconds} seconds');
                      int time = sw.elapsed.inSeconds;

                      setState(() {
                        result =
                            'File uploaded to: ${"${controllerBucket.text}/${controllerObjectName.text}"}\n\n Time Upload: $time seconds';
                      });
                    },
                    child: const Text('Put Object')),
                const Divider(),
                ElevatedButton(
                    onPressed: () async {
                      Stopwatch sw = Stopwatch()..start();
                      await CloudFlareR2.deleteObject(
                          bucket: controllerBucket.text,
                          accountId: controllerAccountId.text,
                          accessId: controllerAcessId.text,
                          secretAccessKey: controllerSecretAccessKey.text,
                          objectName: controllerObjectName.text);
                      sw.stop();
                      log('${sw.elapsed.inSeconds} seconds');
                      int time = sw.elapsed.inSeconds;

                      setState(() {
                        result =
                            'File Deleted to: ${"${controllerBucket.text}/${controllerObjectName.text}"}\n\n Time to Delete: $time seconds';
                      });
                    },
                    child: const Text('Delete Object')),
                Text(result)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
