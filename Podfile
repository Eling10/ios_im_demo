# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'ElingIMDemo' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  
  pod 'ElingIM', '~> 1.0.1'
  
  pod 'Masonry', '~> 1.1.0'
  pod 'MJRefresh', '~> 3.4.1'
  pod 'XCCustomItemView', '~> 0.0.3'
  pod 'XCPresentation', '~> 2.0.1'
  pod 'IQKeyboardManager', '~> 6.5.5'
  pod 'XCCountdownButton', '~> 2.0.1'
  pod 'XCSettingView', '~> 1.0.3'
  pod 'XCPhotoBrowser', '~> 1.0.6'
  pod 'XCBaseModule/Tools'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['VALID_ARCHS'] = 'arm64 arm64e'
          end
     end
  end

  target 'ElingIMDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ElingIMDemoUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
