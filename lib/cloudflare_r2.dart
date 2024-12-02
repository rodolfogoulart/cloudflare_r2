library cloudflare_r2;

import 'dart:typed_data';

import 'src/rust/api/cloudflare_r2.dart' as api;
import 'src/rust/frb_generated.dart';

///Ensure to call [CloudFlareR2.init] before using this library
///
class CloudFlareR2 {
  CloudFlareR2._();
  static final CloudFlareR2 _instance = CloudFlareR2._();
  factory CloudFlareR2() => _instance;

  static Future<void> init() async => await RustLib.init();

  static Future<Uint8List> getObject(
          {required String bucket,
          required String accountId,
          required String accessId,
          required String secretAccessKey,
          required String objectName}) =>
      api.getObject(
          bucket: bucket, accountId: accountId, accessId: accessId, secretAccessKey: secretAccessKey, objectName: objectName);

  static Future<void> putObject(
          {required String bucket,
          required String accountId,
          required String accessId,
          required String secretAccessKey,
          required String objectName,
          required List<int> objectBytes,
          required String cacheControl,
          required String contentType}) =>
      api.putObject(
          bucket: bucket,
          accountId: accountId,
          accessId: accessId,
          secretAccessKey: secretAccessKey,
          objectName: objectName,
          objectBytes: objectBytes,
          cacheControl: cacheControl,
          contentType: contentType);

  static Future<void> deleteObject(
          {required String bucket,
          required String accountId,
          required String accessId,
          required String secretAccessKey,
          required String objectName}) =>
      api.deleteObject(
          bucket: bucket, accountId: accountId, accessId: accessId, secretAccessKey: secretAccessKey, objectName: objectName);
}
