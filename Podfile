# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FitApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FitApp
		pod 'SpreadsheetView'
    pod 'BulletinBoard'
    pod 'DateToolsSwift'
		pod 'CropViewController'
		pod 'JGProgressHUD'
		pod 'SDWebImage', '~> 5.0'
		pod 'MKRingProgressView'
		pod 'Charts', '~> 4.1.0'
		pod 'BetterSegmentedControl', '~> 1.3'
		
  target 'FitAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FitAppUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end

end
