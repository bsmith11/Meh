source 'https://github.com/CocoaPods/Specs'

platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

pod 'Alamofire', '~> 3.2'
pod 'AlamofireImage', '~> 2.3'
pod 'pop', '~> 1.0'
pod 'Shimmer', '~> 1.0'
pod 'youtube-ios-player-helper', :git => 'https://github.com/youtube/youtube-ios-player-helper', :commit => 'head'
pod 'TSMarkdownParser', '~> 2.1'

target :unit_tests, :exclusive => true do
  link_with 'UnitTests'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end


# Copy acknowledgements to the Settings.bundle

post_install do | installer |
  require 'fileutils'

  pods_acknowledgements_path = 'Pods/Target Support Files/Pods/Pods-Acknowledgements.plist'
  settings_bundle_path = Dir.glob("**/*Settings.bundle*").first

  if File.file?(pods_acknowledgements_path)
    puts 'Copying acknowledgements to Settings.bundle'
    FileUtils.cp_r(pods_acknowledgements_path, "#{settings_bundle_path}/Acknowledgements.plist", :remove_destination => true)
  end
end

