project 'WhatsApp.xcodeproj'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'WhatsApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Flash Chat
    pod 'Firebase/Core'
    pod 'FirebaseAnalytics'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'ChameleonFramework/Swift'
    pod 'SVProgressHUD'
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
