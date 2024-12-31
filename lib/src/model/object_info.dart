/// ObjectInfo model class
///
/// from the AWS S3 API response
///
/// ```xml
/// <?xml version="1.0" encoding="UTF-8"?>
///<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
///  <Name>teste</Name>
///  <Contents>
///    <Key>teste bucket list</Key>
///    <Size>54</Size>
///    <LastModified>2024-12-30T22:25:35.351Z</LastModified>
///    <ETag>"b9ae2987987977b960fa5d4eb7ab5df2"</ETag>
///    <StorageClass>STANDARD</StorageClass>
///  </Contents>
///  <IsTruncated>false</IsTruncated>
///  <MaxKeys>1000</MaxKeys>
///  <KeyCount>1</KeyCount>
///</ListBucketResult>
class ObjectInfo {
  String key;
  int size;
  DateTime lastModified;
  String eTag;
  String storageClass;
  ObjectInfo({
    required this.key,
    required this.size,
    required this.lastModified,
    required this.eTag,
    required this.storageClass,
  });

  @override
  bool operator ==(covariant ObjectInfo other) {
    if (identical(this, other)) return true;

    return other.key == key &&
        other.size == size &&
        other.lastModified == lastModified &&
        other.eTag == eTag &&
        other.storageClass == storageClass;
  }

  @override
  int get hashCode {
    return key.hashCode ^ size.hashCode ^ lastModified.hashCode ^ eTag.hashCode ^ storageClass.hashCode;
  }

  @override
  String toString() {
    return 'ObjectInfo(key: $key, size: $size, lastModified: $lastModified, eTag: $eTag, storageClass: $storageClass)';
  }
}
