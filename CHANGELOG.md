## 0.0.12
* Change package to dart sdk
* Add Status class to return the status of the request on putObject, deleteObject, deleteObjects

## 0.0.11
* set `intl` to `any` version

## 0.0.10
* Fix getObject, removed arg `pathToSave`, getObject return List<int>, the handle of the object is done outside
* Export class `object_info`

## 0.0.9
* Add deleteObjects
* Add exception for status code returned from api and fix wrong messages
* Add var `statusCode` to retrieve the last status Code from last call

## 0.0.8
* Add getObjectSize
* Refactory getObject to not use Dio
* Refactory listObjectsV2 to not use Dio, thanks to @jesussmile on #4
* Remove package Dio
* Add package intl to parse DateTime
* Fix example

## 0.0.7
* Add listObjectsV2

## 0.0.6
* Add getObjectSize [issue from #4]
    * thanks to @jesussmile

## 0.0.5
* Fix the example of onReceiveProgress

## 0.0.4
* Change the core to use aws_common and aws_signature_v4 instead of rust ffi (rust ffi have problems with android platform)

## 0.0.3
* upgrade Package flutter_rust_bridge 

## 0.0.2
* Fix bug when call CloudFlareR2.init multiple time, flutter_rust_bridge don't allow

## 0.0.1
* Add Get/Put/Delete Object to CloudFlare R2
