#
# Be sure to run `pod lib lint ZTCameraKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZTCameraKit'
  s.version          = '0.1.0'
  s.summary          = '自定义相机相册'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
加一个长的描述~自定义相机相册.
                       DESC

  s.homepage         = 'https://github.com/zttina/ZTCameraKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zttina' => '351199191@qq.com' }
  s.source           = { :git => 'https://github.com/zttina/ZTCameraKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ZTCameraKit/Classes/**/*'
  
  s.dependency 'ReactiveCocoa','~> 2.5'

  # s.resource_bundles = {
  #   'ZTCameraKit' => ['ZTCameraKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
