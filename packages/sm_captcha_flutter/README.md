# sm_captcha_flutter

Sm captcha flutter plugin with demo

## 目录介绍

.
├── README.md
├── android
├── build
├── captcha_plugin_demo.iml
├── ios
├── lib		（demo入口）	
├── packages/sm_captcha_flutter （数美验证码Flutter 插件）
├── pubspec.lock
├── pubspec.yaml
└── test


## 接入方式

见[数美验证码 Flutter Plugin 接入手册](./数美验证码 Flutter Plugin 接入手册)


## 实现原理

dart<-----methodChannel<-----flutterPlugin(native语言开发)

FlutterPlugin通过methodchannel与dart通信

FlutterPlugin中回调方法触发时，通过methodChannel调用dart中注册的方法