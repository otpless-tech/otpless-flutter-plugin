#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint otpless_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'otpless_flutter'
  s.version          = '0.0.4'
  s.summary          = 'Sign-up/ Sign-in via Whatsapp engineered by Otpless.'
  s.description      = <<-DESC
  'Sign-up/ Sign-in via Whatsapp engineered by Otpless. Get your user authentication sorted in just five minutes by integrating of Otpless sdk.'
  DESC
  s.homepage         = 'https://github.com/otpless-tech/Otpless-iOS-SDK'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Otpless' => 'developer@otpless.com' }
  s.source           = { :git => 'https://github.com/otpless-tech/Otpless-iOS-SDK.git', :tag => s.version.to_s }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'OtplessSDK', '2.0.1'
  s.ios.deployment_target = '11.0'
  s.resources = ["OtplessSDK/Assets/*.png"]

  s.swift_versions = ['4.0', '4.1', '4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5']
end
