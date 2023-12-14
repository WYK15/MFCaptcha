import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:sm_captcha_flutter/sm_captcha_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('sm_captcha_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
