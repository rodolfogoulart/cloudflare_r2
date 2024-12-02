# cloudflare_r2

Flutter CloudFlare R2 plugin project. It's using a Rust FFI go access CloudFlare R2 throught AWS S3

For now only get/put/delete Object on R2 Bucket

## Getting Started

Check the Example

```dart
//call CloudFlareR2.init before using any call, this is important to initiate the Rust FFI
await CloudFlareR2.init();

//to get the Object
Uint8List object = await CloudFlareR2.getObject(
    accountId: controllerAccountId.text,
    accessId: controllerAcessId.text,
    secretAccessKey: controllerSecretAccessKey.text,
    bucket: controllerBucket.text,
    objectName: controllerObjectName.text,
  );
//upload some object
await CloudFlareR2.putObject(
  bucket: controllerBucket.text,
  accountId: controllerAccountId.text,
  accessId: controllerAcessId.text,
  secretAccessKey: controllerSecretAccessKetext,
  objectName: controllerObjectName.text,
  objectBytes: objectBytes,
  cacheControl: controllercacheControl.text,
  contentType: controllercontentType.text);


//Delete some object
await CloudFlareR2.deleteObject(
    bucket: controllerBucket.text,
    accountId: controllerAccountId.text,
    accessId: controllerAcessId.text,
    secretAccessKey: controllerSecretAccessKey.text,
    objectName: controllerObjectName.text);
```