import 'dart:async';

import 'package:flutter/services.dart';

class FmPhoto {
  static const MethodChannel _channel = const MethodChannel('fm_photo');
  /*
  * type: 0:全部, 1:图片、2:视频.ofVideo()、3:音频
  * spanCount 每行显示个数
  * enableCrop 是否裁剪
  * enableCompress 是否压缩
  * enableGif 是否显示gif
  * compressSavePath 压缩图片保存地址
  * enableCircleDimmedLayer 是否圆形裁剪
  * recordVideoSecond 录制视频秒数 默认60s
  */
  static Future<List> pickPhoto({
    int type = 1,
    int max: 1,
    int spanCount: 4,
    bool enableCamera = true,
    bool enableCrop = false,
    bool enableCompress = false,
    bool enableGif = false,
    String compressSavePath = "",
    bool enableCircleDimmedLayer = true,
    int recordVideoSecond = 60,
  }) async {
    Map config = {
      "openGallery": type,
      "max": max,
      "spanCount": spanCount,
      "enableCamera": enableCamera,
      "enableCrop": enableCrop,
      "enableCompress": enableCompress,
      "enableGif": enableGif,
      "compressSavePath": compressSavePath,
      "enableCircleDimmedLayer": enableCircleDimmedLayer,
      "recordVideoSecond": recordVideoSecond,
    };
    return await _channel.invokeMethod("pickPhoto", config);
  }
  /*
  * type: 1:图片、2:视频.ofVideo()
  * spanCount 每行显示个数
  * enableCrop 是否裁剪
  * enableCompress 是否压缩
  * compressSavePath 压缩图片保存地址
  * enableCircleDimmedLayer 是否圆形裁剪
  * recordVideoSecond 录制视频秒数 默认60s
  * quality 录制视频质量，1为高，0为低
  * saveGallery 拍照或录制视频是否保存到相册
  * path 录制视频、拍照存储路径，可不传，传输相对路径，跟路径为应用内部存储
  */
  static Future<Map> cameraPhoto({
    int type = 1,
    bool enableCrop = false,
    bool enableCompress = false,
    bool enableGif = false,
    String compressSavePath = "",
    bool enableCircleDimmedLayer = true,
    int recordVideoSecond = 60,
    String path = "",
    bool saveGallery = false,
    int quality = 1
  }) async {
    Map config = {
      "openCamera": type,
      "max": 1,
      "spanCount": 1,
      "enableCamera": false,
      "enableCrop": enableCrop,
      "enableCompress": enableCompress,
      "enableGif": enableGif,
      "compressSavePath": compressSavePath,
      "enableCircleDimmedLayer": enableCircleDimmedLayer,
      "recordVideoSecond": recordVideoSecond,
      "path": path,
      "saveGallery": saveGallery,
      "quality": quality
    };
    return await _channel.invokeMethod("cameraPhoto", config);
  }

  /*
  * path 视频路径，绝对路径
  */
  static Future<Map> getThumbnail({
    String path = "",
  }) async {
    Map config = {
      "path": path,
    };
    return await _channel.invokeMethod("getThumbnail", config);
  }
}
