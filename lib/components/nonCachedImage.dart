//import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'dart:ui' show Size, Locale, TextDirection, hashValues;
import 'dart:ui' as ui show instantiateImageCodec, Codec;
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/painting/_network_image_io.dart'
    if (dart.library.html) 'package:flutter/src/painting/_network_image_web.dart'
    as network_image;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/painting/image_cache.dart';
import 'package:flutter/src/painting/image_stream.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

//Кастомное расширение класса AdvancedNetworkImage, которое расширяет NetworkImage
//Отключтл сохрание в файл, потому что оно идёт по урлу, но оставил по памяти, и изменил оператор сравнения, теперь он работает по uuid
//Забавный эффект был без всяких кэширований, картинки продолжали non-stop загружаться пока эмулятор не начинал тормозить

class NonCachedImage extends AdvancedNetworkImage
{
  String uid;
  NonCachedImage(String url,
      this.uid,
  {scale: 1.0,
  header,
  useDiskCache,
  retryLimit:5,
  retryDuration: const Duration(milliseconds: 500),
  retryDurationFactor: 1.5,
  timeoutDuration: const Duration(seconds: 5),
  loadedCallback,
  loadFailedCallback,
  loadedFromDiskCacheCallback,
  fallbackAssetImage,
  fallbackImage,
  cacheRule,
  loadingProgress,
  getRealUrl,
  preProcessing,
  postProcessing,
  disableMemoryCache: false,
  printError = false }) : super(url, scale: scale,
      header: header,
      useDiskCache: useDiskCache,
      retryLimit: retryLimit,
      retryDuration: retryDuration,
      retryDurationFactor: retryDurationFactor,
      timeoutDuration:timeoutDuration,
      loadedCallback:loadedCallback,
      loadFailedCallback:loadFailedCallback,
      loadedFromDiskCacheCallback:loadedFromDiskCacheCallback,
      fallbackAssetImage:fallbackAssetImage,
      fallbackImage:fallbackImage,
      cacheRule:cacheRule,
      loadingProgress:loadingProgress,
      getRealUrl:getRealUrl,
      preProcessing:preProcessing,
      postProcessing:postProcessing,
      disableMemoryCache:disableMemoryCache,
      printError:printError){}



  //Сравнение идёт по uid
  @override
  bool operator ==(other) {
    // TODO: implement ==
    if (other.runtimeType != runtimeType) return false;
    final NonCachedImage typedOther = other;
    return uid == typedOther.uid;
  }


}