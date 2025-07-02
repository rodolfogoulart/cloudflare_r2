# cloudflare_r2

Dart CloudFlare R2 plugin project. It's using a [aws_signature_v4](https://pub.dev/packages/aws_signature_v4) to access CloudFlare R2

For now only **get [object, size]/put/delete/list object** Object on R2 Bucket

| Function          |
| ---------------   |
| Get Object        |
| Get Object Size   |
| Get Object Info   |
| Put Object        |
| Delete Object     |
| List Objects      |
| Get Presigned Url |
| Put Presigned Url |

## Getting Started

Check the Example

```dart
//call CloudFlareR2.init before using any call
CloudFlareR2.init(
  accountId: 'your account ID',
  accessKeyId: 'your access id',
  secretAccessKey: 'your secret access key',
);


//to get the Object
List<int> object = await CloudFlareR2.getObject(
    bucket: 'bucket name',
    objectName: 'name of the object',
    onReceiveProgress: (total, received) {
      //do the progress of the download here
    },
  );
//handle the writing of the object after
//File myFile = File(yourPath).writeAsBytesSync(object);

  //to get the Object Size
  //return the size in bytes
  await CloudFlareR2.getObjectSize(
    bucket: 'bucket name',
    objectName: 'name of the object',
  );

  //get the Object Info, [name, size, etag, last modified]
  ObjectInfo obj = await CloudFlareR2.getObjectInfo(
    bucket: 'bucket name',
    objectName: 'name of the object',
  );

  //to get the List of Objects on a bucket
  //return List<ObjectInfo>
  await CloudFlareR2.listObjectsV2(
    bucket: 'bucket name',
  );

//upload some object
//return Status
await CloudFlareR2.putObject(
  bucket: 'bucket name',
  objectName: 'name of the object',
  objectBytes: objectBytes,
  contentType: 'content type of the file here');


//Delete some object
//return Status
await CloudFlareR2.deleteObject(
    bucket: 'bucket name',
    objectName: 'name of the object');

//Delete list of objects
//return Status
await CloudFlareR2.deleteObjects(
    bucket: 'bucket name',
    objectNames: ['name of the object1', 'name of object 2']);

//Generate a pre-signed URL for downloading an object
await CloudFlareR2.getPresignedUrl({
    bucket: 'bucket name',
    objectName: 'name of the object',
    expiresIn: Duration(hours: 1),
    queryParameters: {}, //optional
    headers: {}, //optional
  })

// Generate a pre-signed URL for uploading an object
await CloudFlareR2.putPresignedUrl({
    bucket: 'bucket name',
    objectName: 'name of the object',
    expiresIn: Duration(hours: 1),
    contentType: 'content type of the file here',    
    headers: {}, //optional
  });  
```