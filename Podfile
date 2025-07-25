# Uncomment the next line to define a global platform for your project
# platform :ios, '12.0'

target 'Zombie Zone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Then'
  pod 'Localize-Swift', '~> 2.0'
  pod 'Google-Mobile-Ads-SDK'
  pod 'SnapKit', '~> 5.0.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end

end
