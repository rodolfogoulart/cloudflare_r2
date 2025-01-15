# cloudflare_r2

Flutter CloudFlare R2 plugin project. It's using a [aws_signature_v4](https://pub.dev/packages/aws_signature_v4) to access CloudFlare R2

For now only **get [object, size]/put/delete/list object** Object on R2 Bucket

## `Tested on`


| Function          | Windows       | Android       | Linux    | MacOS    | Ios    |
| ----------        | ----------- | ----------- | ----------- | ----------- | ----------- |
| Get Object        | 👍 | 👍       | need test | need test | need test |
| Get Object Size   | 👍 | 👍       |  need test | need test | need test |
| Get Object Info   | 👍 | 👍       |  need test | need test | need test |
| Put Object        | 👍 | 👍       | need test | need test | need test |
| Delete Object     | 👍 | 👍       | need test | need test | need test |
| List Objects      | 👍 | need test | need test | need test | need test |

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
await CloudFlareR2.putObject(
  bucket: 'bucket name',
  objectName: 'name of the object',
  objectBytes: objectBytes,
  contentType: 'content type of the file here');


//Delete some object
await CloudFlareR2.deleteObject(
    bucket: 'bucket name',
    objectName: 'name of the object');

//Delete list of objects
await CloudFlareR2.deleteObjects(
    bucket: 'bucket name',
    objectNames: ['name of the object1', 'name of object 2']);
```