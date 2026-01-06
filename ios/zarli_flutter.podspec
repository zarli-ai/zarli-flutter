#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zarli_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zarli_flutter'
  s.version          = '0.0.1'
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
  s.dependency 'ZarliSDKSwift', '~> 1.3'
  s.platform = :ios, '13.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
