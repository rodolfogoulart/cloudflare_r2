// library cloudflare_r2;

import 'dart:typed_data';

import 'src/rust/api/cloudflare_r2.dart' as api;
import 'src/rust/frb_generated.dart';

///Ensure to call [CloudFlareR2.init] before using this library
///
class CloudFlareR2 {
  CloudFlareR2._();
  static final CloudFlareR2 _instance = CloudFlareR2._();
  factory CloudFlareR2() => _instance;

  ///check if flutter_rust_bridge is initialized
  bool _isInitialized = false;

  ///initialize flutter_rust_bridge
  static Future<void> init() async {
    //prevent error: Bad state: Should not initialize flutter_rust_bridge twice
    if (!_instance._isInitialized) {
      await RustLib.init();
    }
    _instance._isInitialized = true;
  }

  ///get the Object from R2
  static Future<Uint8List> getObject(
      {required String bucket,
      required String accountId,
      required String accessId,
      required String secretAccessKey,
      required String objectName}) async {
    //just in case call for init before
    await init();
    return api.getObject(
        bucket: bucket, accountId: accountId, accessId: accessId, secretAccessKey: secretAccessKey, objectName: objectName);
  }

  ///put the Object to R2
  static Future<void> putObject(
      {required String bucket,
      required String accountId,
      required String accessId,
      required String secretAccessKey,
      required String objectName,
      required List<int> objectBytes,
      required String cacheControl,
      required String contentType}) async {
    //just in case call for init before
    await init();
    return api.putObject(
        bucket: bucket,
        accountId: accountId,
        acessId: accessId,
        secretAcessKey: secretAccessKey,
        objectName: objectName,
        objectBytes: objectBytes,
        cacheControl: cacheControl,
        contentType: contentType);
  }

  ///delete the Object from R2
  static Future<void> deleteObject(
      {required String bucket,
      required String accountId,
      required String accessId,
      required String secretAccessKey,
      required String objectName}) async {
    //just in case call for init before
    await init();
    return api.deleteObject(
        bucket: bucket, accountId: accountId, accessId: accessId, secretAccessKey: secretAccessKey, objectName: objectName);
  }
}
