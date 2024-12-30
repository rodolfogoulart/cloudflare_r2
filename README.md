# cloudflare_r2

Flutter CloudFlare R2 plugin project. It's using a [aws_signature_v4](https://pub.dev/packages/aws_signature_v4) to access CloudFlare R2

For now only **get/put/delete** Object on R2 Bucket

## `Tested on`


| Platform | get       | put       | delete    |
| ---------- | ----------- | ----------- | ----------- |
| Windows  | 👍        | 👍        | 👍        |
| Android  | 👍        | 👍        | 👍        |
| Linux    | need test | need test | need test |
| MacOS    | need test | need test | need test |
| Ios      | need test | need test | need test |

## Getting Started

Check the Example

```dart
//call CloudFlareR2.init before using any call
CloudFlareR2.init(
  accoundId: 'your accound ID',
  accessKeyId: 'your access id', 
  secretAccessKey: 'your secret acess key',   
);


//to get the Object
await CloudFlareR2.getObject(
    bucket: 'bucket name',
    objectName: 'name of the object',
    pathToSave: 'path to save the file',
    onReceiveProgress: (total, received) {
      //do the progress of the download here
    },
  );

  //to get the Object Size
  //return the size in bytes
  await CloudFlareR2.getObjectSize(
    bucket: 'bucket name',
    objectName: 'name of the object',
  );

//upload some object
await CloudFlareR2.putObject(
  bucket: 'bucket name',
  objectName: 'name of the object',
  objectBytes: objectBytes,
  contentType: 'content type of the file here');


//Delete some object
await CloudFlareR2.deleteObject(
    bucket: 'bucket name',
    objectName: 'name of the object');
```

## Migration from 0.0.3 to 0.04

## Before init

```dart
await CloudFlareR2.init();
```

## Now init

```dart
CloudFlareR2.init(
  accoundId: 'your accound ID',
  accessKeyId: 'your access id', 
  secretAccessKey: 'your secret acess key',   
);
```

## Before getObject

```dart
//to get the Object
Uint8List object = await CloudFlareR2.getObject(
    accountId: controllerAccountId.text,
    accessId: controllerAcessId.text,
    secretAccessKey: controllerSecretAccessKey.text,
    bucket: controllerBucket.text,
    objectName: controllerObjectName.text,
  );
```

## Now getObject

```dart
await CloudFlareR2.getObject(
    bucket: controllerBucket.text,
    objectName: controllerObjectName.text,
    pathToSave: 'path to save the file',
    onReceiveProgress: (total, received) {
      //do the progress of the download here
    },
  );
```

## Before putObject

```dart
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
```

## Now putObject

```dart
await CloudFlareR2.putObject(
  bucket: controllerBucket.text,
  objectName: controllerObjectName.text,
  objectBytes: objectBytes,
  contentType: 'content type of the file here');
```

## Before deleteObject

```dart
//Delete some object
await CloudFlareR2.deleteObject(
    bucket: controllerBucket.text,
    accountId: controllerAccountId.text,
    accessId: controllerAcessId.text,
    secretAccessKey: controllerSecretAccessKey.text,
    objectName: controllerObjectName.text);
```

## Now deleteObject

```dart
//Delete some object
await CloudFlareR2.deleteObject(
    bucket: controllerBucket.text,
    objectName: controllerObjectName.text);
```
