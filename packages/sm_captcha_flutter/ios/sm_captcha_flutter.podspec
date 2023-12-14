#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sm_captcha_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sm_captcha_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Sm captcha flutter plugin'
  s.description      = <<-DESC
Sm captcha flutter plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  s.vendored_frameworks = 'Assets/SmCaptcha.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
