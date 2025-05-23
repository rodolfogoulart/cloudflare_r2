//check for https://github.com/aws-amplify/amplify-flutter/blob/main/packages/aws_signature_v4/example/bin/example.dart

import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:cloudflare_r2/src/model/status.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import 'model/object_info.dart';

class CloudFlareR2 {
  CloudFlareR2._();
  static final CloudFlareR2 _instance = CloudFlareR2._();
  factory CloudFlareR2() => _instance;

  static String _host = '<accoundId>.r2.cloudflarestorage.com';
  static AWSSigV4Signer? _signer;
  static String? _accessKeyId;
  static String? _secretAccessKey;
  static int? _statusCode;

  ///return the last status code from the last request
  static int? get statusCode => _statusCode;

  // Set up S3 values
  static AWSCredentialScope? _scope;
  static final S3ServiceConfiguration _serviceConfiguration =
      S3ServiceConfiguration();

  ///initialize the CloudFlareR2
  ///
  ///[accoundId] - the account id
  ///
  ///[accessKeyId] - the access key id
  ///
  ///[secretAccessKey] - the secret access key
  ///
  ///[region] - the region of the bucket
  ///
  //MARK: init
  static init(
      {required String accoundId,
      required String accessKeyId,
      required String secretAccessKey,
      String region = 'us-east-1'}) {
    _host = '$accoundId.r2.cloudflarestorage.com';
    _accessKeyId = accessKeyId;
    _secretAccessKey = secretAccessKey;
    // Create a signer which uses the `default` profile from the shared
    // credentials file.
    _signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(_accessKeyId!, _secretAccessKey!)),
    );
    _scope = AWSCredentialScope(
      region: region,
      service: AWSService.s3,
    );
    _statusCode = null;
  }

  ///get the Object from R2
  ///
  ///[bucket] - the bucket name
  ///
  ///[objectName] - the object name
  ///
  ///[region] - the region of the bucket
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
  //MARK: getObject
  static Future<List<int>> getObject({
    required String bucket,
    required String objectName,
    String region = 'us-east-1',
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    assert(_signer != null,
        'Please call CloudFlareR2.init() before using this library');
    _statusCode = null;
    // Create a pre-signed URL for downloading the file
    final urlRequest = AWSHttpRequest.get(
      Uri.https(_host, '$bucket/$objectName'),
      headers: {
        AWSHeaders.host: _host,
      },
    );
    final signedUrl = await _signer!.sign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
    );

    var expectedTotalBytes = 0;

    var send = signedUrl.send()
      ..responseProgress.listen((event) {
        if (expectedTotalBytes <= 0) return;
        onReceiveProgress?.call(event, expectedTotalBytes);
      }, onDone: () {
        expectedTotalBytes = -1;
      }, onError: (e) {
        expectedTotalBytes = -1;
        throw e;
      }, cancelOnError: true);

    var response = await send.response;
    expectedTotalBytes =
        int.tryParse(response.headers['content-length'] ?? '') ?? -1;
    _statusCode = response.statusCode;

    if (statusCode != 200) {
      //https://awscli.amazonaws.com/v2/documentation/api/2.9.6/reference/s3api/get-object.html
      if (statusCode == 404) {
        throw Exception('File not found');
      }
      if (statusCode == 403) {
        throw Exception('Access Denied');
      }
      throw Exception('Failed to download file');
    }

    var data = await response.bodyBytes;
    //call onReceiveProgress with the total bytes to indicate that the download is complete
    //for some reason the listen event is called after the download is complete
    //this may result in the progress callback be called after the download is complete
    onReceiveProgress?.call(expectedTotalBytes, expectedTotalBytes);
    //set the expectedTotalBytes to -1 to indicate that the download is complete
    expectedTotalBytes = -1;

    return data;
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
  //MARK: getObjectSize
  static Future<int> getObjectSize({
    required String bucket,
    required String objectName,
    String region = 'us-east-1',
  }) async {
    return (await getObjectInfo(
            bucket: bucket, objectName: objectName, region: region))
        .size;
  }

  ///get the Object Info from R2
  ///
  ///[bucket] - the bucket name
  ///
  ///[objectName] - the object name
  ///
  ///[region] - the region of the bucket
  ///
  ///return [ObjectInfo] - the object info
  ///  * [storageClass] not available
  ///
  /// check https://docs.aws.amazon.com/AmazonS3/latest/API/API_HeadObject.html
  //MARK: getObjectInfo
  static Future<ObjectInfo> getObjectInfo({
    required String bucket,
    required String objectName,
    String region = 'us-east-1',
  }) async {
    assert(_signer != null,
        'Please call CloudFlareR2.init() before using this library');
    _statusCode = null;

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
    _statusCode = response.statusCode;
    if (statusCode != 200) {
      //https://docs.aws.amazon.com/AmazonS3/latest/API/API_HeadObject.html
      if (statusCode == 404) {
        throw Exception('File not found');
      }
      if (statusCode == 403) {
        throw Exception('Access Denied');
      }
      throw Exception('Failed to get object info: $statusCode');
    }

    final contentLength =
        int.tryParse(response.headers['content-length'] ?? '');
    final etag = response.headers['etag'];
    //use intl to not use dart io
    // final lastmodified = HttpDate.parse(response.headers['last-modified'] ?? '');
    final lastModifiedHeader = response.headers['last-modified'];
    final DateFormat httpDateFormat =
        DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
    final lastModified = lastModifiedHeader != null
        ? httpDateFormat.parseUtc(lastModifiedHeader)
        : null;

    if (contentLength == null) {
      throw Exception('Content-Length header missing');
    }
    if (etag == null) {
      throw Exception('ETag header missing');
    }
    if (lastModified == null) {
      throw Exception('Last-Modified header missing');
    }

    var objectInfo = ObjectInfo(
      key: objectName,
      size: contentLength,
      lastModified: lastModified,
      eTag: etag,
    );

    if (contentLength <= 0) {
      throw Exception('Invalid file size: $contentLength bytes');
    }

    return objectInfo;
  }

  ///put the Object to R2
  ///
  ///check https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutObject.html
  ///
  //MARK: putObject
  static Future<Status> putObject({
    required String bucket,
    required String objectName,
    required List<int> objectBytes,
    String region = 'us-east-1',
    String? contentType,
  }) async {
    assert(_signer != null,
        'Please call CloudFlareR2.init() before using this library');
    _statusCode = null;
    // Create a pre-signed URL for downloading the file
    final urlRequest = AWSHttpRequest.put(
      Uri.https(_host, '$bucket/$objectName'),
      headers: {
        AWSHeaders.host: _host,
        if (contentType != null) AWSHeaders.contentType: contentType,
        // AWSHeaders.contentType: contentType ?? 'application/octet-stream',
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

    final response = await signedUrl.send().response;
    _statusCode = response.statusCode;
    if (statusCode != 200) {
      //https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutObject.html
      //https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutObject.html#API_PutObject_Errors
      if (statusCode == 403) {
        throw Exception('Access Denied');
      }
      if (statusCode == 400) {
        throw Exception('Bad Request');
      }
      if (statusCode == 409) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#status.409
        throw Exception('Conflict');
      }
      if (statusCode == 415) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#status.415
        throw Exception('Unsupported Media Type');
      }
      throw Exception('Failed to upload file. Status Code: $statusCode');
    } else {
      ///https://www.rfc-editor.org/rfc/rfc9110.html#name-put
      String message = '';
      if (statusCode == 200) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#name-200-ok
        message = 'File uploaded successfully';
      } else if (statusCode == 201) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#name-201-created
        message = 'File created successfully';
      }
      return Status(
        status: statusCode,
        message: message,
      );
    }
  }

  ///delete the Object from R2
  //MARK: deleteObjects
  static Future<Status> deleteObject(
      {required String bucket, required String objectName}) async {
    assert(_signer != null,
        'Please call CloudFlareR2.init() before using this library');
    _statusCode = null;
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

    final response = await signedUrl.send().response;
    _statusCode = response.statusCode;

    // log('Upload File Response: $uploadStatus');
    if (![200, 202, 204].contains(statusCode)) {
      var status =
          'AWS Status Code: $statusCode\n Check https://www.rfc-editor.org/rfc/rfc9110.html#name-delete';
      if (statusCode == 400) {
        throw Exception('Bad Request. $status');
      }
      if (statusCode == 403) {
        throw Exception('Access Denied. $status');
      }
      throw Exception(
          'Failed to delete file. AWS Status Code: $statusCode\n Check https://www.rfc-editor.org/rfc/rfc9110.html#name-delete');
    } else {
      String message = '';
      if (statusCode == 200) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#name-200-ok
        message = 'File deleted successfully';
      } else if (statusCode == 204) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#name-204-no-content
        message = 'No content, file deleted successfully';
      } else if (statusCode == 202) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#status.202
        message = 'Request accepted, file will be deleted soon';
      }
      return Status(
        status: statusCode,
        message: message,
      );
    }
  }

  ///delete List of Objects from R2
  ///
  ///[bucket] - the bucket name
  ///
  ///[objectNames] - the list of object names
  ///
  ///check https://docs.aws.amazon.com/AmazonS3/latest/API/API_DeleteObjects.html
  //MARK: deleteObjects
  static Future<Status> deleteObjects(
      {required String bucket, required List<String> objectNames}) async {
    assert(_signer != null,
        'Please call CloudFlareR2.init() before using this library');
    _statusCode = null;
    // Create XML body for the delete request
    final xmlBody =
        '<Delete>${objectNames.map((name) => '<Object><Key>$name</Key></Object>').join()}</Delete>';
    // Create a pre-signed URL for downloading the file
    final urlRequest = AWSHttpRequest.post(
      Uri.https(_host, bucket, {'delete': ''}),
      headers: {
        AWSHeaders.host: _host,
        AWSHeaders.accept: '*/*',
        AWSHeaders.contentType: 'application/xml',
      },
      body: utf8.encode(xmlBody),
    );
    final signedUrl = await _signer!.sign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
    );

    final response = await signedUrl.send().response;
    _statusCode = response.statusCode;
    // log('Upload File Response: $uploadStatus');
    if (![200, 202, 204].contains(statusCode)) {
      var status =
          'AWS Status Code: $statusCode\n Check https://docs.aws.amazon.com/AmazonS3/latest/API/API_DeleteObjects.html';
      if (statusCode == 400) {
        throw Exception('Bad Request. $status');
      }
      if (statusCode == 403) {
        throw Exception('Access Denied. $status');
      }
      throw Exception('Failed to delete files. $status');
    } else {
      String message = '';
      if (statusCode == 200) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#name-200-ok
        message = 'Files deleted successfully';
      } else if (statusCode == 204) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#name-204-no-content
        message = 'No content, file deleted successfully';
      } else if (statusCode == 202) {
        //https://www.rfc-editor.org/rfc/rfc9110.html#status.202
        message = 'Request accepted, file will be deleted soon';
      }
      return Status(
        status: statusCode,
        message: message,
      );
    }
  }

  /// List objects in a bucket
  ///
  /// [bucket] - the bucket name
  ///
  /// [region] - the region of the bucket
  ///
  /// [doPagination] - whether to paginate through all objects in the bucket
  ///
  /// [maxKeys] - the maximum number of objects to return in a single response
  ///
  /// [delimiter] - a character you use to group keys
  ///
  /// [prefix] - limits the response to keys that begin with the specified prefix
  ///
  /// [encodingType] - specifies the encoding method used to encode the object keys in the response
  ///
  /// [startAfter] - specifies the key to start after when listing objects in a bucket
  ///
  /// [continuationToken] - the token to use for paginating through objects, **DO NOT** set this manually unless you know what you are doing
  ///
  /// Check https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html
  //MARK: listObjectsV2
  static Future<List<ObjectInfo>> listObjectsV2({
    required String bucket,
    String region = 'us-east-1',
    bool doPagination = true,
    int maxKeys = 1000, //default max keys
    String? delimiter,
    String? prefix,
    String? encodingType,
    String? startAfter,

    ///used to paginate through objects, do not set this manually
    String? continuationToken,
  }) async {
    assert(_signer != null,
        'Please call CloudFlareR2.init() before using this library');
    _statusCode = null;
    // Create query parameters
    final queryParams = {
      'list-type': '2',
      'max-keys': maxKeys.toString(),
      if (continuationToken != null) 'continuation-token': continuationToken,
      if (delimiter != null) 'delimiter': delimiter,
      if (prefix != null) 'prefix': prefix,
      if (encodingType != null) 'encoding-type': encodingType,
      if (startAfter != null) 'start-after': startAfter,
    };
    // Create a pre-signed URL for listing objects in the bucket
    final urlRequest = AWSHttpRequest.get(
      Uri.https(_host, bucket, queryParams),
      headers: {
        AWSHeaders.host: _host,
      },
    );
    final signedUrl = await _signer!.sign(
      urlRequest,
      credentialScope: _scope!,
      serviceConfiguration: _serviceConfiguration,
    );

    final response = await signedUrl.send().response;
    _statusCode = response.statusCode;
    if (statusCode != 200) {
      if (statusCode == 404) {
        throw Exception('Bucket not found');
      }
      if (statusCode == 403) {
        throw Exception('Access Denied');
      }
      throw Exception('Failed to list objects: $statusCode');
    }

    // Parse XML response
    final bodyBytes = await response.bodyBytes;
    final xml = String.fromCharCodes(bodyBytes);
    final document = XmlDocument.parse(xml);
    final Iterable<XmlElement> contents = document.findAllElements('Contents');
    final nextContinuationToken = document
        .findAllElements('NextContinuationToken')
        .singleOrNull
        ?.innerText;

    // Extract object names
    final List<ObjectInfo> objectNames = [];
    for (var node in contents) {
      var key = node.findElements('Key').singleOrNull?.innerText;
      var size = node.findElements('Size').singleOrNull?.innerText;
      var lastModified =
          node.findElements('LastModified').singleOrNull?.innerText;
      var eTag = node.findElements('ETag').singleOrNull?.innerText;
      var storageClass =
          node.findElements('StorageClass').singleOrNull?.innerText;

      if (key == null ||
          size == null ||
          lastModified == null ||
          eTag == null ||
          storageClass == null) {
        throw Exception('Failed to parse object info');
      }

      objectNames.add(ObjectInfo(
        key: key,
        size: int.parse(size),
        lastModified: DateTime.parse(lastModified),
        eTag: eTag,
        storageClass: storageClass,
      ));
    }
    if (doPagination == false) return objectNames;
    if (nextContinuationToken != null) {
      // Recursive call to get more objects if continuation token is present
      final nextObjectNames = await listObjectsV2(
        bucket: bucket,
        region: region,
        maxKeys: maxKeys,
        continuationToken: nextContinuationToken,
      );
      objectNames.addAll(nextObjectNames);
    }

    return objectNames;
  }
}
