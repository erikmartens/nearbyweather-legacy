```
⚠️ LEGACY REPO: 

⚠️ Further development of NearbyWeather has turned private. 
⚠️ This repo is no longer accepting contributions and will not get updated. 
⚠️ You may use all code contained therein in compliance with the MIT license.

```
<br>

<p align="center">
<img src="Resources/app_icon.png" alt="NearbyWeather for iOS" height="128" width="128">
</p>

<h1 align="center">NearbyWeather - OpenWeatherMap Client</h1>

<p align="center">
  <a href="#about-the-app">About the App</a> •
  <a href="#mission-of-this-project">Mission of this Project</a> •
  <a href="#app-releases">App Releases</a> •
  <a href="#how-to-get-started">How to Get Started</a> •
  <a href="#how-to-contribute">How to Contribute</a> •
  <a href="#support--feedback">Support & Feedback</a> •
  <a href="#licensing">Licensing</a>
</p>

---

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2012.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat" alt="Swift"/></a>
<a href="https://github.com/erikmartens/nearbyweather-legacy/commits/develop" title="Latest Commit"><img src="https://img.shields.io/github/last-commit/erikmartens/nearbyweather-legacy?style=flat"></a>
<a href="https://github.com/erikmartens/nearbyweather-legacy/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/erikmartens/nearbyweather-legacy?style=flat"></a>
<a href="https://github.com/erikmartens/nearbyweather-legacy/graphs/contributors"><img src="https://img.shields.io/github/contributors/erikmartens/nearbyweather-legacy.svg?style=flat" alt="Contributors"></a>
<img src="https://img.shields.io/github/license/erikmartens/nearbyweather-legacy.svg?style=flat" alt="License: MIT">
</p>
<p align="center">
<a href="https://itunes.apple.com/app/nearbyweather/id1227313069"><img src="Resources/app_store_badge.svg" alt="Download on the App Store"/></a>
</p>

<p align="center">
<img src="Resources/screenshots.PNG" alt="NearbyWeather Screenshots">
</p>

## About the App

> ℹ️ By using the app you automatically agree to the [privacy policy](PRIVACYPOLICY.md) and the [terms of use](TERMSOFUSE.md).

NearbyWeather is a simple weather app, that provides current weather information for nearby cities, as well for bookmarked locations. NearbyWeather uses the OpenWeatherMap API to download weather data. Additionally the OpenWeatherMaps location database is directly bootstrapped into the app for quick access.

With NearbyWeather you can:

- See current weather information for bookmarked and nearby places via a list and a map view
- See the current temperature on your app icon
- Detailed weather information is offered in addition to the overviews
- Add places as bookmarks via OpenWeatherMaps weather-station data base
- Choose your preferred units (celsius/fahrenheit/kelvin & kilometres/miles)
- Access previously loaded data offline

```
❗️Please note that you need to supply your own OpenWeatherMap API key, in order to use the app.
```

## Mission of this Project

NearbyWeather was created to help you as a reference for developing your skills. The app is kept up to date with the latest best practices in mobile app development. Find out how how modern iOS apps are engineered:

| Area | Concepts | Status |
|:--|:--|:--|
| Language | Swift (latest release) | ✅ |
| Additional Languages | Objective-C, JavaScript | ✅ |
| Architecture | MVC+Coordinator (RxFlow) | ✅ |
| Dependencies | Singletons | ✅ |
| Data Persistence | Files on Disk | ✅ |
| Networking | Alamofire | ✅ |
| Asset Management | R.Swift | ✅ |
| Code Quality | SwiftLint | ✅ |
| Analytics and Reporting | Google Firebase | ✅ |
| Library Management | CocoaPods | ✅ |
| Bootsrapped Bundle Data | Node.js Scripts | ✅ |
| Deployment | Fastlane | ✅ |
| Testing and Quality Assurance | Unit Tests and UI Tests | 🅾️ |

## App Releases

Past releases are documented in the [release section](https://github.com/erikmartens/NearbyWeather/releases) of this repository. Future releases are planned via the [project board](https://github.com/erikmartens/NearbyWeather/projects).

| Version | Tag |
|:--|:--|
| Current Release | [v2.2.1](https://github.com/erikmartens/NearbyWeather/releases/tag/v2.2.1)
| Next Release | [v2.3.0](https://github.com/erikmartens/NearbyWeather/projects/5) |
| Future Releases | [v?.?.?](https://github.com/erikmartens/NearbyWeather/projects/1) |

## How to Get Started

1. Install the latest version of Xcode from the Mac AppStore
2. Install the latest Xcode command line tools
    ```
    xcode-select --install
    ```
3. Install [CocoaPods](https://cocoapods.org) to your machine
4. Install [fastlane](https://docs.fastlane.tools/getting-started/ios/setup/) to your machine
5. Install [SwiftLint](https://github.com/realm/SwiftLint/#installation) to your machine
6. Fork the project and clone it to your local machine
7. Configure signing via [fastlane match](https://docs.fastlane.tools/actions/match/) to use your personal certificates
7. Run `pod install` to be able to build locally

## Licensing

Copyright © 2016 - 2022 Erik Maximilian Martens.

Licensed under the **MIT License** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://opensource.org/licenses/MIT.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
