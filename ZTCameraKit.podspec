#
# Be sure to run `pod lib lint ZTCameraKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZTCameraKit'
  s.version          = '0.1.1'
  s.summary          = '自定义相机相册'

  s.description      = <<-DESC
加一个长的描述~自定义相机相册.
                       DESC

  s.homepage         = 'https://github.com/zttina/ZTCameraKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zttina' => '351199191@qq.com' }
  s.source           = { :git => 'https://github.com/zttina/ZTCameraKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'ZTCameraKit/Classes/**/*'
  
  s.dependency 'ReactiveCocoa','~> 2.5'
  
  s.resource_bundle = {
      'ZTCameraKit' => ['ZTCameraKit/Assets/*.png']
  }

end
