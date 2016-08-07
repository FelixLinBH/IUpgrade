#
# Be sure to run `pod lib lint IUpgrade.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IUpgrade'
  s.version          = '1.0.1'
  s.summary          = 'Notify new version of enterprise app is available.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Notify a new version of your enterprise release iOS app is available.
                       DESC

  s.homepage         = 'https://github.com/FelixLinBH/IUpgrade'
  s.screenshots     = 'https://raw.githubusercontent.com/FelixLinBH/IUpgrade/master/ScreenShot.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'felix.lin' => 'fly_81211@hotmail.com' }
  s.source           = { :git => 'https://github.com/FelixLinBH/IUpgrade.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'IUpgrade/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IUpgrade' => ['IUpgrade/Assets/*.png']
  # }

s.public_header_files = 'IUpgrade/Classes/**/*.h'
   s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
