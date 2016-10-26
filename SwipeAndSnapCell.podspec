#
# Be sure to run `pod lib lint SwipeAndSnapCell.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwipeAndSnapCell'
  s.version          = '0.3.0'
  s.summary          = 'Cell which immitates iOS10\'s Mail.app cell swiping behavior'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An example implementation of the swipe-able cell used in iOS10's Mail.app, where you can swipe to reveal a button, or swipe fully across to perform the action immediately.
                       DESC

  s.homepage         = 'https://github.com/iandundas/SwipeAndSnapCell'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ian Dundas' => 'contact@iandundas.co.uk' }
  s.source           = { :git => 'https://github.com/iandundas/SwipeAndSnapCell.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/id'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SwipeAndSnapCell/Classes/**/*'

  # s.resource_bundles = {
  #   'SwipeAndSnapCell' => ['SwipeAndSnapCell/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
