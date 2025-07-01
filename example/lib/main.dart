import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloudflare_r2/cloudflare_r2.dart';

import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // await CloudFlareR2.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controllerAccountId = TextEditingController(text: '');

  final controllerAccessId = TextEditingController(text: '');

  final controllerSecretAccessKey = TextEditingController(text: '');

  final controllerBucket = TextEditingController(text: '');

  final controllerObjectName = TextEditingController(text: '');
  //
  // final controllercacheControl = TextEditingController(text: '');
  final controllercontentType = TextEditingController(text: '');

  String result = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('CloudFlare R2 Example')),
        body: Center(
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .5,
                child: Column(
                  children: [
                    TextField(
                      controller: controllerAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Account Id',
                      ),
                    ),
                    TextField(
                      controller: controllerAccessId,
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

                    // TextField(
                    //   controller: controllercacheControl,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Cache Control',
                    //   ),
                    // ),
                    TextField(
                      controller: controllercontentType,
                      decoration: const InputDecoration(
                        labelText: 'Content Type',
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: Column(
                  children: [
                    Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              Stopwatch sw = Stopwatch()..start();
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              var path =
                                  (await getApplicationSupportDirectory()).path;
                              path =
                                  '$path${Platform.pathSeparator}${controllerObjectName.text}';
                              log(path);
                              List<int> object = await CloudFlareR2.getObject(
                                //removed pathToSave
                                // pathToSave: path,
                                onReceiveProgress: (int received, int total) {
                                  if (total >= 0) {
                                    var persentage =
                                        '${(received / total * 100).toStringAsFixed(2)}%';
                                    log(persentage);
                                    setState(() {
                                      result = 'Downloading: $persentage\n\n';
                                    });
                                  }
                                },
                                bucket: controllerBucket.text,
                                objectName: controllerObjectName.text,
                              );
                              sw.stop();
                              log('${sw.elapsed.inSeconds} seconds');
                              int timeDownloaded = sw.elapsed.inSeconds;

                              File file = File(path);
                              await file.writeAsBytes(object);

                              log(file.path);
                              if (file.existsSync()) {
                                log('file exists');
                                setState(() {
                                  result =
                                      'File downloaded to: ${file.path}\n\n Time Downloaded: $timeDownloaded seconds';
                                });
                              }
                            },
                            child: const Text('Get Object')),
                        //get the object size
                        ElevatedButton(
                            onPressed: () async {
                              Stopwatch sw = Stopwatch()..start();
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              var size = await CloudFlareR2.getObjectSize(
                                bucket: controllerBucket.text,
                                objectName: controllerObjectName.text,
                              );
                              sw.stop();
                              log('${sw.elapsed.inSeconds} seconds');
                              int time = sw.elapsed.inSeconds;

                              setState(() {
                                result =
                                    'File Size: $size bytes , ${(size / 1024 / 1024).toStringAsFixed(2)} MB\n\n Duration: $time seconds';
                              });
                            },
                            child: const Text('Get Object Size')),
                        //
                        ElevatedButton(
                            onPressed: () async {
                              Stopwatch sw = Stopwatch()..start();
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              var obj = await CloudFlareR2.getObjectInfo(
                                bucket: controllerBucket.text,
                                objectName: controllerObjectName.text,
                              );
                              sw.stop();
                              log('${sw.elapsed.inSeconds} seconds');

                              setState(() {
                                result =
                                    'File: ${obj.key} - Size: ${(obj.size / 1024 / 1024).toStringAsFixed(2)} MB - Date: ${obj.lastModified.toIso8601String()}';
                              });
                            },
                            child: const Text('Get Object Info')),

                        //

                        ElevatedButton(
                            onPressed: () async {
                              Stopwatch sw = Stopwatch()..start();
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              List<ObjectInfo> objects =
                                  await CloudFlareR2.listObjectsV2(
                                bucket: controllerBucket.text,
                                // delimiter: '/',
                              );
                              sw.stop();
                              log('${sw.elapsed.inSeconds} seconds');
                              int time = sw.elapsed.inSeconds;

                              setState(() {
                                result =
                                    'Objects on Bucket: ${objects.length}\n\n Duration: $time seconds\n\n';
                                result += objects
                                    .map((e) =>
                                        '${e.key} - ${e.size} bytes - ${(e.size / 1024 / 1024).toStringAsFixed(2)} MB')
                                    .join('\n');
                              });
                            },
                            child: const Text('List Objects on Bucket')),
                        ElevatedButton(
                            onPressed: () async {
                              var path =
                                  (await getApplicationSupportDirectory()).path;
                              path =
                                  '$path${Platform.pathSeparator}${controllerObjectName.text}';
                              log(path);
                              File file = File(path);
                              file.writeAsStringSync(List.generate(
                                      10000,
                                      (a) =>
                                          'Hello World Clouldflare R2 $a: ${DateTime.now()}')
                                  .join('\n'));

                              Uint8List objectBytes = await file.readAsBytes();
                              //
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              //
                              Stopwatch sw = Stopwatch()..start();
                              await CloudFlareR2.putObject(
                                  bucket: controllerBucket.text,
                                  objectName: controllerObjectName.text,
                                  objectBytes: objectBytes,
                                  // cacheControl: controllercacheControl.text,
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
                        ElevatedButton(
                            onPressed: () async {
                              Stopwatch sw = Stopwatch()..start();
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              await CloudFlareR2.deleteObject(
                                  bucket: controllerBucket.text,
                                  objectName: controllerObjectName.text);
                              sw.stop();
                              log('${sw.elapsed.inSeconds} seconds');
                              int time = sw.elapsed.inSeconds;
                              log(CloudFlareR2.statusCode.toString());
                              setState(() {
                                result =
                                    'File Deleted to: ${"${controllerBucket.text}/${controllerObjectName.text}"}\n\n Time to Delete: $time seconds';
                              });
                            },
                            child: const Text('Delete Object')),
                        ElevatedButton(
                            onPressed: () async {
                              Stopwatch sw = Stopwatch()..start();
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              await CloudFlareR2.deleteObjects(
                                bucket: controllerBucket.text,
                                objectNames:
                                    controllerObjectName.text.split(','),
                              );
                              sw.stop();
                              log('${sw.elapsed.inSeconds} seconds');
                              int time = sw.elapsed.inSeconds;

                              setState(() {
                                result =
                                    'Files Deleted to: ${"${controllerBucket.text}/${controllerObjectName.text.split(',')}"}\n\n Time to Delete: $time seconds';
                              });
                            },
                            child: const Text('Delete Objects')),
                        ElevatedButton(
                            onPressed: () async {
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              String presignedUrl =
                                  await CloudFlareR2.getPresignedUrl(
                                bucket: controllerBucket.text,
                                objectName: controllerObjectName.text,
                                expiresIn: const Duration(hours: 1),
                              );
                              setState(() {
                                result =
                                    'Presigned GET URL (valid for 1 hour):\n\n$presignedUrl';
                              });
                            },
                            child: const Text('Get Presigned URL')),
                        ElevatedButton(
                            onPressed: () async {
                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );
                              String presignedUrl =
                                  await CloudFlareR2.putPresignedUrl(
                                bucket: controllerBucket.text,
                                objectName: controllerObjectName.text,
                                expiresIn: const Duration(minutes: 30),
                                contentType: controllercontentType.text,
                              );
                              setState(() {
                                result =
                                    'Presigned PUT URL (valid for 30 minutes):\n\n$presignedUrl';
                              });
                            },
                            child: const Text('Put Presigned URL')),
                        ElevatedButton(
                            onPressed: () async {
                              // Создаем тестовый файл
                              var path =
                                  (await getApplicationSupportDirectory()).path;
                              path =
                                  '$path${Platform.pathSeparator}test_presigned_${DateTime.now().millisecondsSinceEpoch}.txt';
                              File file = File(path);
                              file.writeAsStringSync(
                                  'Test upload via presigned URL: ${DateTime.now()}');

                              Uint8List objectBytes = await file.readAsBytes();

                              CloudFlareR2.init(
                                accountId: controllerAccountId.text,
                                accessKeyId: controllerAccessId.text,
                                secretAccessKey: controllerSecretAccessKey.text,
                              );

                              // Получаем предподписанную ссылку
                              String presignedUrl =
                                  await CloudFlareR2.putPresignedUrl(
                                bucket: controllerBucket.text,
                                objectName:
                                    'test_presigned_${DateTime.now().millisecondsSinceEpoch}.txt',
                                expiresIn: const Duration(minutes: 5),
                                contentType: 'text/plain',
                              );

                              // Загружаем файл через предподписанную ссылку
                              Stopwatch sw = Stopwatch()..start();
                              try {
                                final response = await HttpClient()
                                    .putUrl(Uri.parse(presignedUrl))
                                    .then((request) {
                                  request.headers
                                      .set('Content-Type', 'text/plain');
                                  request.headers.set('Content-Length',
                                      objectBytes.length.toString());
                                  request.add(objectBytes);
                                  return request.close();
                                });

                                sw.stop();
                                final statusCode = response.statusCode;

                                setState(() {
                                  if (statusCode == 200) {
                                    result =
                                        'File uploaded successfully via presigned URL!\n\nTime: ${sw.elapsed.inMilliseconds}ms\nStatus: $statusCode';
                                  } else {
                                    result =
                                        'Upload failed!\n\nStatus: $statusCode';
                                  }
                                });
                              } catch (e) {
                                setState(() {
                                  result = 'Upload error: $e';
                                });
                              }
                            },
                            child: const Text('Test Upload via Presigned URL')),
                      ],
                    ),
                    SelectableText(result)
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
