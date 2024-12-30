//check for https://github.com/aws-amplify/amplify-flutter/blob/main/packages/aws_signature_v4/example/bin/example.dart

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:dio/dio.dart';

class CloudFlareR2 {
  CloudFlareR2._();
  static final CloudFlareR2 _instance = CloudFlareR2._();
  factory CloudFlareR2() => _instance;

  static String _host = '<accoundId>.r2.cloudflarestorage.com';
  static AWSSigV4Signer? _signer;
  static String? _accessKeyId;
  static String? _secretAccessKey;

  // Set up S3 values
  static AWSCredentialScope? _scope;
  static final S3ServiceConfiguration _serviceConfiguration = S3ServiceConfiguration();

  static init(
      {required String accoundId, required String accessKeyId, required String secretAccessKey, String region = 'us-east-1'}) {
    _host = '$accoundId.r2.cloudflarestorage.com';
    _accessKeyId = accessKeyId;
    _secretAccessKey = secretAccessKey;
    // Create a signer which uses the `default` profile from the shared
    // credentials file.
    _signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(AWSCredentials(_accessKeyId!, _secretAccessKey!)),
    );
    _scope = AWSCredentialScope(
      region: region,
      service: AWSService.s3,
    );
  }

  ///get the Object from R2
  ///
  ///[bucket] - the bucket name
  ///
  ///[objectName] - the object name
  ///
  ///[region] - the region of the bucket
  ///
  ///[pathToSave] - the path to save the object
  ///
  ///onReceiveProgress
  ///
  ///[received] - the received bytes
  ///
  ///[total] - the total bytes
  ///
  ///```dart
  ///onReceiveProgress: (received, total) {
  ///   if (total != -1) {
  ///     print((received / total * 100).toStringAsFixed(0) + '%');
  ///   }
  /// }
  /// ```
  static Future getObject({
    required String bucket,
    required String objectName,
    String region = 'us-east-1',
    required String pathToSave,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    assert(_signer != null, 'Please call CloudFlareR2.init() before using this library');

    // Create a pre-signed URL for downloading the file
    final urlRequest = AWSHttpRequest.get(
      Uri.https(_host, '$bucket/$objectName'),
      headers: {
        AWSHeaders.host: _host,
      },
    );
    final signedUrl = await _signer!.presign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
      expiresIn: const Duration(minutes: 10),
    );

    Dio dio = Dio();
    Response response = await dio.downloadUri(
      signedUrl,
      pathToSave,
      onReceiveProgress: (received, total) {
        onReceiveProgress?.call(received, total);
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to download file');
    }
    return response.data;
  }

  ///get File SIZE from R2
  ///
  ///return the size of the object in `bytes`
  ///
  ///To get the size of the object in `MB` use the following code
  ///```dart
  ///var size = await CloudFlareR2.getObjectSize('your bucket', 'your object name');
  ///mbSize = size / 1024 / 1024;
  ///print('Size in bytes: $size');
  ///print('Size in MB: ${mbSize.toStringAsFixed(2)} MB');
  ///```
  ///
  ///*code from [@jesussmile](https://github.com/rodolfogoulart/cloudflare_r2/issues/4)*
  static Future<int> getObjectSize({
    required String bucket,
    required String objectName,
    String region = 'us-east-1',
  }) async {
    assert(_signer != null, 'Please call CloudFlareR2.init() before using this library');

    final urlRequest = AWSHttpRequest.head(
      Uri.https(_host, '$bucket/$objectName'),
      headers: {
        AWSHeaders.host: _host,
        'Accept-Encoding': 'identity',
      },
    );

    final signedRequest = await _signer!.sign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
    );

    final response = await signedRequest.send().response;

    // log('All Headers: ${response.headers}');

    if (response.statusCode != 200) {
      throw Exception('Failed to get object size: ${response.statusCode}');
    }

    // Get content-length as String
    final contentLengthStr = response.headers['content-length'];
    if (contentLengthStr == null || contentLengthStr.isEmpty) {
      throw Exception('Content-Length header missing');
    }

    // Parse size with error handling
    int? size;
    try {
      size = int.parse(contentLengthStr);
    } catch (e) {
      //log('Error parsing content length: $e');
      throw Exception('Failed to parse content length: $contentLengthStr');
    }

    if (size <= 0) {
      throw Exception('Invalid file size: $size bytes');
    }

    return size;
  }

  ///put the Object to R2
  ///
  static Future<void> putObject({
    required String bucket,
    required String objectName,
    required List<int> objectBytes,
    String region = 'us-east-1',
    String? contentType,
  }) async {
    assert(_signer != null, 'Please call CloudFlareR2.init() before using this library');
    // Create a pre-signed URL for downloading the file
    final urlRequest = AWSHttpRequest.put(
      Uri.https(_host, '$bucket/$objectName'),
      headers: {
        AWSHeaders.host: _host,
        AWSHeaders.contentType: contentType ?? 'application/octet-stream',
        AWSHeaders.contentLength: objectBytes.length.toString(),
        // if (contentType != null && contentType.isNotEmpty) AWSHeaders.contentType: contentType,
      },
      body: objectBytes,
    );
    final signedUrl = await _signer!.sign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
    );

    final uploadResponse = await signedUrl.send().response;

    final uploadStatus = uploadResponse.statusCode;
    // log('Upload File Response: $uploadStatus');
    if (uploadStatus != 200) {
      throw Exception('Failed to download file');
    }
  }

  ///delete the Object from R2
  static Future<void> deleteObject({required String bucket, required String objectName}) async {
    assert(_signer != null, 'Please call CloudFlareR2.init() before using this library');

    // Create a pre-signed URL for downloading the file
    final urlRequest = AWSHttpRequest.delete(
      Uri.https(_host, '$bucket/$objectName'),
      headers: {
        AWSHeaders.host: _host,
        AWSHeaders.accept: '*/*',
      },
    );
    final signedUrl = await _signer!.sign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
      // expiresIn: const Duration(minutes: 1),
    );

    final uploadResponse = await signedUrl.send().response;

    final uploadStatus = uploadResponse.statusCode;
    // log('Upload File Response: $uploadStatus');
    if (![200, 202, 204].contains(uploadStatus)) {
      throw Exception(
          'Failed to download file. AWS Status Code: $uploadStatus\n Check https://www.rfc-editor.org/rfc/rfc9110.html#name-delete');
    }
  }
}
