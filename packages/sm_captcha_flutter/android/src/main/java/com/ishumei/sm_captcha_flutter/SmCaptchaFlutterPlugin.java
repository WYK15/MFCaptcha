package com.ishumei.sm_captcha_flutter;

import android.app.Activity;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Context;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.ishumei.sdk.captcha.SimpleResultListener;
import com.ishumei.sdk.captcha.SmCaptchaWebView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** SmCaptchaFlutterPlugin */
public class SmCaptchaFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity

  private static final String TAG = "Smcaptcha";

  private MethodChannel channel;
  private Dialog currentCaptchaDialog;
  private Activity activity;
  private float mRatio = 2 / 3f;
  private SmCaptchaWebView captchaView;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "captchachannel");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("load")) {
      Map paramsFromDart = (Map) call.arguments;
      Map creationParams = (Map) paramsFromDart.get("creationParams");

      SimpleResultListener listener = new SimpleResultListener() {
        @Override
        public void onReady() {
          channel.invokeMethod("onReady", null);
        }

        @Override
        public void onError(final int i) {
          channel.invokeMethod("onError", new HashMap<String, Integer>() {
            {
              put("errCode", new Integer(i));
            }
          });
        }

        @Override
        public void onSuccess(CharSequence charSequence, boolean b) {
          HashMap<String, Object> map = new HashMap<>();
          map.put("rid", charSequence);
          map.put("pass", new Boolean(b));
          channel.invokeMethod("onSuccess", map);
        }

        @Override
        public void onClose() {
          channel.invokeMethod("onClose", null);
          if (currentCaptchaDialog != null) {
            currentCaptchaDialog.dismiss();
          }
        }

        @Override
        public void onInitWithContent(JSONObject jsonObject) {
          super.onInitWithContent(jsonObject);
          channel.invokeMethod("onInitWithContent", jsonToMap(jsonObject));
        }

        @Override
        public void onReadyWithContent(JSONObject jsonObject) {
          super.onReadyWithContent(jsonObject);
          channel.invokeMethod("onReadyWithContent", jsonToMap(jsonObject));
        }

        @Override
        public void onSuccessWithContent(JSONObject jsonObject) {
          super.onSuccessWithContent(jsonObject);
          channel.invokeMethod("onSuccessWithContent", jsonToMap(jsonObject));
        }

        @Override
        public void onCloseWithContent(JSONObject jsonObject) {
          super.onCloseWithContent(jsonObject);
          channel.invokeMethod("onCloseWithContent", jsonToMap(jsonObject));
        }

        @Override
        public void onErrorWithContent(JSONObject jsonObject) {
          super.onErrorWithContent(jsonObject);
          channel.invokeMethod("onErrorWithContent", jsonToMap(jsonObject));
        }
      };

      SmCaptchaWebView.SmOption option = optionWithArg(creationParams);
      captchaView = new SmCaptchaWebView(activity);
      captchaView.initWithOption(option, listener);
      if(currentCaptchaDialog != null){
        currentCaptchaDialog.dismiss();
        currentCaptchaDialog = null;
      }
    } else if (call.method.equals("showFlutterDialog")) {
      Map paramsFromDart = (Map) call.arguments;
      boolean autoCancel = (boolean) paramsFromDart.get("canceledOnTouchOutside");
      showFlutterDialog(autoCancel);
    } else if (call.method.equals("dismissDialog")) {
      if (currentCaptchaDialog != null) {
        currentCaptchaDialog.dismiss();
        currentCaptchaDialog = null;
      }
      if (captchaView != null) {
        captchaView.destroy();
        captchaView = null;
      }
    } else {
      result.notImplemented();
    }
  }

  private void showFlutterDialog(boolean autoCancel) {
    if (activity == null) {
      Log.e(TAG, "show captcha dialog error, activity is empty.");
      return;
    }
    if (captchaView == null) {
      Log.e(TAG, "smcaptcha view not init");
      return;
    }
    if (currentCaptchaDialog != null) {
      currentCaptchaDialog.show();
      return;
    }

    DisplayMetrics dm = activity.getResources().getDisplayMetrics();
    int shortSize = (int) (Math.min(dm.widthPixels, dm.heightPixels) * 0.80f);

    FrameLayout webContainer = new FrameLayout(activity);
    FrameLayout.LayoutParams wCLP = new FrameLayout.LayoutParams(shortSize, (int) (shortSize * mRatio));
    wCLP.gravity = Gravity.CENTER;
    webContainer.setBackgroundColor(0xffffff);
    webContainer.addView(captchaView, wCLP);

    FrameLayout dialogRoot = new FrameLayout(activity);
    FrameLayout.LayoutParams dRLP = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
        ViewGroup.LayoutParams.WRAP_CONTENT);
    dRLP.gravity = Gravity.CENTER;
    dialogRoot.setBackgroundColor(0);
    dialogRoot.addView(webContainer, dRLP);

    Dialog mDialog = new Dialog(activity);
    mDialog.setContentView(dialogRoot);
    mDialog.setCanceledOnTouchOutside(autoCancel);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
      mDialog.getWindow().getDecorView().setBackgroundColor(0x00ffffff);
    }
    mDialog.getWindow().setDimAmount(0.1f);
    mDialog.getWindow().getDecorView().setPadding(0, 0, 0, 0);
    mDialog.getWindow().setGravity(Gravity.CENTER);
    mDialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
      @Override
      public void onDismiss(DialogInterface dialog) {
      }
    });
    mDialog.show();

    currentCaptchaDialog = mDialog;
  }

  private SmCaptchaWebView.SmOption optionWithArg(Map creationParams) {
    SmCaptchaWebView.SmOption option = new SmCaptchaWebView.SmOption();

    if (creationParams == null) {
      Log.e(TAG, "param is null");
    }
    if (creationParams.containsKey("organization")) {
      option.setOrganization((String) creationParams.get("organization"));
    }
    if (creationParams.containsKey("appId")) {
      option.setAppId((String) creationParams.get("appId"));
    }
    if (creationParams.containsKey("deviceId")) {
      option.setDeviceId((String) creationParams.get("deviceId"));
    }
    if (creationParams.containsKey("channel")) {
      option.setChannel((String) creationParams.get("channel"));
    }
    if (creationParams.containsKey("tipMessage")) {
      option.setTipMessage((String) creationParams.get("tipMessage"));
    }
    if (creationParams.containsKey("extOption")) {
      Map ext = (Map) creationParams.get("extOption");
      if (ext != null && ext.get("style") instanceof Map) {
        Object withTitle = ((Map) ext.get("style")).get("withTitle");
        if (withTitle instanceof Boolean && (Boolean) withTitle) {
          mRatio = 5 / 6f;
        }
      }
      option.setExtOption(ext);
    }
    if (creationParams.containsKey("https")) {
      option.setHttps((Boolean) creationParams.get("https"));
    }
    if (creationParams.containsKey("mode")) {
      String mode = (String) creationParams.get("mode");
      option.setMode(mode);
      if ("auto_slide".equals(mode)) {
        mRatio = 40 / 300f;
      }
    }
    if (creationParams.containsKey("host")) {
      option.setHost((String) creationParams.get("host"));
    }
    if (creationParams.containsKey("cdnHost")) {
      option.setCdnHost((String) creationParams.get("cdnHost"));
    }
    if (creationParams.containsKey("captchaHtml")) {
      option.setCaptchaHtml((String) creationParams.get("captchaHtml"));
    }
    if (creationParams.containsKey("captchaUuid")) {
      option.setCaptchaUuid((String) creationParams.get("captchaUuid"));
    }
    return option;
  }

  public static Map jsonToMap(JSONObject jsonObject) {
    Map<String, Object> map = new HashMap<>();

    Iterator<String> iter = jsonObject.keys();

    while (iter.hasNext()) {
      String key = iter.next();
      try {
        map.put(key, jsonObject.get(key));
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }

    return map;
  }
}