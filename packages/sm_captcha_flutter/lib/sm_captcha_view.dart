import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//类似于SmCaptchaViewState的代理类
class SmCaptchaWebview {

  final String flutterSDKVersion = '1.2.5';

  // 传递给native SDK的参数时，native层getString使用的key值
  static const OPTION_ORG = 'organization';
  static const OPTION_APPID = 'appId';
  static const OPTION_DEVICEID = 'deviceId';
  static const OPTION_CHANNEL = 'channel';
  static const OPTION_TIP = 'tipMessage';
  static const OPTION_EXT = 'extOption';
  static const OPTION_HTTPS = 'https';
  static const OPTION_MODE = 'mode';
  static const OPTION_HOST = 'host';
  static const OPTION_CDNHOST = 'cdnHost';
  static const OPTION_CAPTCHA_HTML = 'captchaHtml';
  static const OPTION_CAPTCHA_UUID = 'captchaUuid';


  static const SM_MODE_SLIDE = 'slide';
  static const SM_MODE_AUTO_SLIDE = 'auto_slide';
  static const SM_MODE_SELECT = 'select';
  static const SM_MODE_SEQ_SELECT = 'seq_select';
  static const SM_MODE_ICON_SELECT = 'icon_select';
  static const SM_MODE_SPATIAL_SELECT = 'spatial_select';

  Map<String, Object> creationParams = <String, Object>{};

  late smCaptchaCallback callback;
    // 平台通道,用于 此dart控件 和 对应的native控件 通信
  late MethodChannel captchaChannel;
  final String channelName = "captchachannel";

  // native平台通道的响应函数
  Future<void> _handleMethod(MethodCall call) async {
    // 视图没被装载的情况不响应操作
    switch (call.method) {
      case "onReady":
      {
        if (this.callback.onReady != null) {
          this.callback.onReady!();
        }
      }
      break;

      case "onSuccess":
      {
        // onSuccess不能为空，使用！
        this.callback.onSuccess!(call.arguments['rid'], call.arguments['pass']);
      }
      break;

      case "onError":
      {
        if (this.callback.onError != null) {
          this.callback.onError!(call.arguments['errCode']);
        }
      }
      break;

      case "onClose":
      {
        if (this.callback.onClose != null) {
          this.callback.onClose!();
        }
      }
      break;

      case "onInitWithContent":
      {
        if (this.callback.onInitWithContent != null) {
          this.callback.onInitWithContent!(call.arguments);
        }
      }
      break;

      case "onReadyWithContent":
      {
        if (this.callback.onReadyWithContent != null) {
          this.callback.onReadyWithContent!(call.arguments);
        }
      }
      break;

      case "onSuccessWithContent":
      {
        if (this.callback.onSuccessWithContent != null) {
          this.callback.onSuccessWithContent!(call.arguments);
        }
      }
      break;

      case "onCloseWithContent":
      {
        if (this.callback.onCloseWithContent != null) {
          this.callback.onCloseWithContent!(call.arguments);
        }
      }
      break;

      case "onErrorWithContent":
      {
        if (this.callback.onErrorWithContent != null) {
          this.callback.onErrorWithContent!(call.arguments);
        }
      }
      break;


      default:
        throw UnsupportedError("Unrecognized method");
    }
  }



  SmCaptchaWebview(Map<String, Object> this.creationParams) {

    captchaChannel = MethodChannel(channelName);
    captchaChannel.setMethodCallHandler(_handleMethod);
  }

  Future<void> setCallback(smCaptchaCallback callback) async {
    this.callback = callback;
  }

  Future<void> show(bool canceledOnTouchOutside) async {
    Map<String, dynamic> arguments = {
      'canceledOnTouchOutside': canceledOnTouchOutside,
    };
    captchaChannel.invokeMethod('showFlutterDialog', arguments);
  }

  Future<void> load() async {
    Map<String, dynamic> arguments = {
      'creationParams' : this.creationParams,
    };
    captchaChannel.invokeMethod('load', arguments);
  }

  Future<void> dismiss() async {
    captchaChannel.invokeMethod('dismissDialog');
  }

  String getSDKVersion() {
    return flutterSDKVersion;
  }
}


//"以下定义外部dart传入plugin dart中的回调，当native回调时，调用这些回调"
typedef onReadyFunc = void Function();
typedef onSuccessFunc = void Function(String rid, bool pass);
typedef onErrorFunc = void Function(int code);
typedef onCloseFunc = void Function();
typedef withContentFunc = void Function(Map content);

class smCaptchaCallback {
  final onReadyFunc? onReady;
  final onSuccessFunc? onSuccess;
  final onErrorFunc? onError;
  final onCloseFunc? onClose;
  final withContentFunc? onInitWithContent;
  final withContentFunc? onReadyWithContent;
  final withContentFunc? onSuccessWithContent;
  final withContentFunc? onCloseWithContent;
  final withContentFunc? onErrorWithContent;


  smCaptchaCallback(
      {
      this.onReady,
      this.onSuccess,
      this.onError,
      this.onClose,
      this.onInitWithContent,
      this.onReadyWithContent,
      this.onSuccessWithContent,
      this.onCloseWithContent,
      this.onErrorWithContent
      }
      );
}
