#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tuya_home_sdk_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tuya_home_sdk_flutter'
  s.version          = '0.0.2'
  s.summary          = 'Tuya Smart home SDK for flutter'
  s.description      = <<-DESC
Tuya Smart home SDK for flutter
                       DESC
  s.homepage         = 'https://premierank.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Premier Rank.com' => 'dev@premierank.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ThingSmartHomeKit' , '~> 5.17.0'
  
  s.static_framework = true
  s.platform = :ios, '11.0'
  
  s.vendored_frameworks = 'Assets/TuyaHomeSdkKit.xcframework'  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64',     
  }
  s.swift_version = '5.0'
  
  
end
