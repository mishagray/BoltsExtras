#
# Be sure to run `pod lib lint BoltsExtras.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BoltsExtras"
  s.version          = "0.3.0"
  s.summary          = "A collection of stuff to make IOS Programming Easier with Bolts."
  s.description      = <<-DESC
                       A collection of stuff to make IOS Programming Easier with Bolts.
                       
                       UIAlertView and UIActionSheet block based implementations that let wrap them into BFTasks

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/mishagray/BoltsExtras"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Michael Gray" => "mishagray@gmail.com" }
  s.source           = { :git => "https://github.com/mishagray/BoltsExtras.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mishagray'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/*.{h,m}'
  # s.resources = 'Pod/Assets/*.png'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'Bolts', '~> 1.1.2'
end
