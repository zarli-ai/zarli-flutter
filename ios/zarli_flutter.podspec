#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zarli_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zarli_flutter'
  s.version          = '0.0.6'
  s.summary          = 'A Flutter plugin for the Zarli iOS SDK.'
  s.description      = <<-DESC
A Flutter plugin for the Zarli iOS SDK.
                       DESC
  s.homepage         = 'http://zarli.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Zarli AI' => 'support@zarli.ai' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  
  # Zarli iOS SDK Dependency
  # 
  # RECOMMENDED for Flutter 3.24+: Use Swift Package Manager instead
  # - Run: flutter config --enable-swift-package-manager
  # - Add https://github.com/zarli-ai/zarli-ios-sdk.git via Xcode
  # - Select 'ZarliAdapterAdMob' library
  # - Benefits: Faster builds, future-proof (CocoaPods sunset Dec 2026)
  #
  # For Flutter < 3.24: This CocoaPods dependency will be used automatically
  s.dependency 'ZarliAdapterAdMob', '~> 2.0'
  s.platform = :ios, '13.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-ObjC'
  }
  s.swift_version = '5.0'
end
