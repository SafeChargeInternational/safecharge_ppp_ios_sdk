#
# Be sure to run `pod lib lint SafechargePP_ios_sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SafechargePP_ios_sdk'
  s.version          = '1.0.1'
  s.summary          = 'iOS native framework which is used to integrate Safecharge Payment page.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    SafeCharge PPP SDK provides easy use and integrate payments in any application targeted for IOS. 
                       DESC

  s.homepage         = 'https://github.com/miroslavch/safecharge_ppp_ios_sdk.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'miroslavch@safecharge.com' => 'miroslavch@safecharge.com' }
  s.source           = { :git => 'https://github.com/miroslavch/safecharge_ppp_ios_sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SafechargePP_ios_sdk/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SafechargePP_ios_sdk' => ['SafechargePP_ios_sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
