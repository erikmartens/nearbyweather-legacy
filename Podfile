platform :ios, '9.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

def nearbyweather_pods
    pod 'PKHUD', '~> 5.3.0'
    pod 'RainyRefreshControl', '~> 0.4.0'
    pod 'TextFieldCounter', '~> 1.0.2'
    pod 'Alamofire', '~> 4.8.2'
    pod 'APTimeZones', :git => 'https://github.com/Alterplay/APTimeZones.git', :branch => 'master', :commit => '9ffd147'
    pod 'FMDB', '~> 2.7.5'
    pod 'R.swift', '5.0.3'
end

target 'NearbyWeather' do
    nearbyweather_pods
end  

target 'NearbyWeatherTests' do
  nearbyweather_pods
end
