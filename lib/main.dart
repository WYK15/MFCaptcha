import 'package:flutter/material.dart';
import 'package:sm_captcha_flutter/sm_captcha_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SmCaptchaWebview v = SmCaptchaWebview({
      SmCaptchaWebview.OPTION_ORG: "z8T9p6PjPS40Gq0F8w3q",
      SmCaptchaWebview.OPTION_APPID: "default",
      SmCaptchaWebview.OPTION_MODE: SmCaptchaWebview.SM_MODE_SLIDE,
      // SmCaptchaWebview.OPTION_EXT: {"lang": "en"},
    });

    v.setCallback(smCaptchaCallback(
      onInitWithContent: (Map content) {
        // web 参数初始化完成时，回调此方法
        print("smCallback, onInitWithContent, captchaUuid: " +
            content["captchaUuid"]); // 获取 uuid，用于业务统计
      },
      onReadyWithContent: (Map content) {
        // 验证码图片加载成功时回调此方法
        print("smCallback, onReadyWithContent, captchaUuid: " +
            content["captchaUuid"]); // 获取 uuid，用于业务统计
      },
      onCloseWithContent: (Map content) {
        // 带关闭按钮样式的验证码点击关闭按钮时回调此方法
        print("smCallback, onCloseWithContent, captchaUuid: " +
            content["captchaUuid"]); // 获取 uuid，用于业务统计
      },
      onSuccessWithContent: (Map content) {
        // 验证结束时回调此方法
        print("smCallback, onSuccessWithContent, captchaUuid: " +
            content["captchaUuid"]); // 获取 uuid，用于业务统计
        print("smCallback, onSuccessWithContent, pass: " +
            (content["pass"]
                ? "true"
                : "false")); // 获取验证结果：true 为验证通过，false 为未通过
        print("smCallback, onSuccessWithContent, rid: " +
            content["rid"]); // 获取rid

        if (content["pass"]) {
          // 验证通过，取消弹窗
          v.dismiss();
        }
      },
      onErrorWithContent: (Map content) {
        // 加载或验证过程中出现错误时，回调此方法，code 码见下文
        print("smCallback, onErrorWithContent, captchaUuid: " +
            content["captchaUuid"]); // 获取 uuid，用于业务统计
        print("smCallback, onErrorWithContent, errcode: " +
            content["code"]); // 获取错误码，code 码含义见下文
      },

      // 以下回调方法用于版本升级过渡，后续会被移除
      onReady: () {
        // 请使用 onReadyWithContent 方法
        print("smCallback : onReady");
      },
      onSuccess: (String rid, bool pass) {
        // 请使用 onSuccessWithContent 方法
        print("smCallback : onSuccess,rid : " +
            rid +
            " pass : " +
            (pass ? 'true' : 'false'));
      },
      onError: (int code) {
        // 请使用 onErrorWithContent 方法
        print("smCallback : onError, errorCode : " + code.toString());
      },
      onClose: () {
        // 请使用 onCloseWithContent 方法
        print("smCallback : onClose");
      },
    ));

    print("smCaptchaSDKVersion : " + v.getSDKVersion());

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Captch example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                  child: Text("loadCaptcha"),
                  onPressed: () {
                    v.load();
                  }),
              MaterialButton(
                  child: Text("showCaptcha"),
                  onPressed: () {
                    v.show(true);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
