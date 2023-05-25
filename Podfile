# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!
  
# ignore all warnings from all pods
# :inhibit_warnings => true

# fix for CDN issue
source 'https://github.com/CocoaPods/Specs.git'

def main_pods

  # Pods for More
  pod 'CountryPickerView', :inhibit_warnings => true
  pod 'Firebase', :inhibit_warnings => true
  pod 'Firebase/Auth', :inhibit_warnings => true
  pod 'Firebase/Core', :inhibit_warnings => true
  pod 'Firebase/Storage', :inhibit_warnings => true
  pod 'Firebase/Messaging', :inhibit_warnings => true
  pod 'Firebase/RemoteConfig', :inhibit_warnings => true
  pod 'Firebase/Firestore', :inhibit_warnings => true
  pod 'Firebase/InAppMessaging', :inhibit_warnings => true
  pod 'Firebase/DynamicLinks', :inhibit_warnings => true
  pod 'Firebase/Functions', :inhibit_warnings => true
  pod 'Firebase/Crashlytics', :inhibit_warnings => true 
  pod 'Firebase/Performance', :inhibit_warnings => true
  pod 'Branch', :inhibit_warnings => true
  pod 'Geofirestore', :git => 'https://github.com/imperiumlabs/GeoFirestore-iOS.git', :branch => 'master', :inhibit_warnings => true
  pod 'GooglePlaces', :inhibit_warnings => true
  pod 'libPhoneNumber-iOS', :inhibit_warnings => true
  pod 'lottie-ios', :inhibit_warnings => true
  pod 'Mapbox-iOS-SDK', :inhibit_warnings => true
  pod 'MapboxDirections', '~> 2.10', :inhibit_warnings => true
  pod 'MapboxCoreNavigation', :inhibit_warnings => true
  # pod 'MapboxNavigation', '~> 0.27.0', :inhibit_warnings => true
  pod 'MapboxNavigation', :inhibit_warnings => true
    pod 'MapboxGeocoder.swift', '~> 0.12', :inhibit_warnings => true
  pod 'MBProgressHUD', :inhibit_warnings => true
  pod 'PinCodeTextField', :git => 'https://github.com/tkach/PinCodeTextField.git', :branch => 'master',  :inhibit_warnings => true
  pod 'SkyFloatingLabelTextField', '~> 3.0', :inhibit_warnings => true
  pod 'SDWebImage', '~> 5.0', :inhibit_warnings => true
  pod 'SwiftMessages', :inhibit_warnings => true 
  pod 'Nuke', :inhibit_warnings => true 
  pod 'VisualEffectView', :inhibit_warnings => true
  pod 'IGListKit', :inhibit_warnings => true 
  pod 'DeepLinkKit', :inhibit_warnings => true
  pod 'SwipeCellKit', :inhibit_warnings => true
  pod 'Siren', :inhibit_warnings => true  
  pod 'ImageViewer', :inhibit_warnings => true


  # video calls
#  pod 'QuickBlox', '~> 2.17.4', :inhibit_warnings => true
#  pod 'Quickblox-WebRTC', '~> 2.7.4', :inhibit_warnings => true
 #  pod 'CometChatPro', '2.0.8', :inhibit_warnings => true
  pod 'TwilioVideo', '~> 3.2', :inhibit_warnings => true
 
  # DO NOT REMOVE - for debugging when updating the pods
  # pod 'PinCodeTextField', :path => '../PinCodeTextField'

end

target 'More' do
  main_pods
  
  target 'MoreTests' do
    inherit! :search_paths
  end

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                if target.name == 'CountryPickerView'
                    config.build_settings['ENABLE_BITCODE'] = 'NO'
                end
            end
        end
    end
end
