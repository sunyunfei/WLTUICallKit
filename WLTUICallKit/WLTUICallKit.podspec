#
# Be sure to run `pod lib lint WLTUICallKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WLTUICallKit'
  s.version          = '0.9.1'
  s.platform     = :ios
  s.ios.deployment_target = '9.0'
  s.summary          = 'A short description of WLTUICallKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/sunyunfei/WLTUICallKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sunyunfei' => '1035044809@qq.com' }
  s.source           = { :git => 'https://github.com/sunyunfei/WLTUICallKit.git', :tag => s.version.to_s }
  
  s.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  
  s.dependency 'Masonry'
  s.dependency 'TUICore', '~>7.1.3925'
  
  s.requires_arc = true
  s.static_framework = true
  # s.source = { :git => 'https://github.com/tencentyun/TUICalling.git' }
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'
  s.default_subspec = 'TRTC'
  
  s.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.dependency 'TUICallEngine/TRTC', '~> 1.5.1.310'
    # trtc.source_files = 'WLTUICallKit/TUICallKit/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/localized/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/Base/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/Service/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/Config/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/UI/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/TUICallKit_TRTC/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/TUICallEngine_Framework/*.{h,m,mm}'
    trtc.ios.framework = ['AVFoundation', 'Accelerate']
    trtc.library = 'c++', 'resolv','sqlite3'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['TUICallKit/Resources/Localized/**/*.strings']
    }
  end
  
  # s.subspec 'Professional' do |professional|
  #   professional.dependency 'TXLiteAVSDK_Professional'
  #   professional.dependency 'TUICallEngine/Professional'
  #   professional.source_files = 'WLTUICallKit/TUICallKit/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/localized/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/Base/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/Service/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/Config/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/UI/**/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/TUICallKit_Professional/*.{h,m,mm}', 'WLTUICallKit/TUICallKit/TUICallEngine_Framework/*.{h,m,mm}'
  #   professional.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
  #   professional.library = 'c++', 'resolv', 'sqlite3'
  #   professional.resource_bundles = {
  #     'TUICallingKitBundle' => ['WLTUICallKit/Resources/Localized/**/*.gif','WLTUICallKit/Resources/Localized/**/*.strings', 'WLTUICallKit/Resources/AudioFile', 'WLTUICallKit/Resources/*.xcassets']
  #   }
  # end
end
