platform :ios, '14.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

def nearbyweather_pods
    pod 'PKHUD', '~> 5.3.0'
    pod 'Alamofire', '~> 5.5.0'
    pod 'APTimeZones', :git => 'https://github.com/Alterplay/APTimeZones.git', :branch => 'master', :commit => '9ffd147'
    pod 'FMDB', '~> 2.7.5'
    pod 'RealmSwift', '~> 10.24.1'
    pod 'Swinject', '~> 2.8.1'

    pod 'RxSwift', '~> 6.5.0'
    pod 'RxCocoa', '~> 6.5.0'
    pod 'RxOptional', '~> 5.0.2'
    pod 'RxFlow', '~> 2.12.4'
    pod 'RxRealm', '~> 5.0.4'
    pod 'RxAlamofire', '~> 6.1.1'
    pod 'RxCoreLocation', '~> 1.5.1'

    pod 'SwiftLint', '~> 0.46.2'
    pod 'R.swift', '5.3.0'

    pod 'Firebase/Analytics', '~> 8.12.0'
    pod 'Firebase/Crashlytics', '~> 8.12.0'
end

target 'NearbyWeather' do
    nearbyweather_pods
end  

target 'NearbyWeatherTests' do
    nearbyweather_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      
      next if config.name.downcase.include? 'debug'
      config.build_settings['ENABLE_BITCODE'] = 'YES'
      cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
      cflags << '-fembed-bitcode'
      config.build_settings['OTHER_CFLAGS'] = cflags
      
    end
  end
end
