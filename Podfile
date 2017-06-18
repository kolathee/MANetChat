# Uncomment this line to define a global platform for your project
platform :ios, '10.2'

target 'MANetChat' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MANetChat

  target 'MANetChatTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MANetChatUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  pod 'RealmSwift'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'JSQMessagesViewController'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
