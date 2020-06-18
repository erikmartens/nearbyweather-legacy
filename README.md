<p align="center">
<img src="Resources/app_icon.png" alt="NearbyWeather for iOS" height="128" width="128">
</p>

<h1 align="center">NearbyWeather - OpenWeatherMap Client</h1>

<p align="center">
  <a href="#about-the-app">About the App</a> •
  <a href="#mission-of-this-project">Mission of this Project</a> •
  <a href="#future-releases">Future Releases</a> •
  <a href="#how-to-get-started">How to Get Started</a> •
  <a href="#how-to-contribute">How to Contribute</a> •
  <a href="#support--feedback">Support & Feedback</a> •
  <a href="#licensing">Licensing</a>
</p>

---

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5-orange.svg?style=flat" alt="Swift"/></a>
<img src="https://img.shields.io/badge/Platform-iOS%2011.0+-lightgrey.svg" alt="Platform: iOS">
<img src="https://img.shields.io/github/license/erikmartens/NearbyWeather.svg?style=flat" alt="License: MIT">
<a href="https://github.com/erikmartens/NearbyWeather/commits/develop" title="Latest Commit"><img src="https://img.shields.io/github/last-commit/erikmartens/NearbyWeather?style=flat"></a>
<a href="https://github.com/erikmartens/NearbyWeather/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/erikmartens/NearbyWeather?style=flat"></a>
<a href="https://github.com/erikmartens/NearbyWeather/graphs/contributors"><img src="https://img.shields.io/github/contributors/erikmartens/NearbyWeather.svg?style=flat" alt="Contributors"></a>
</p>
<p align="center">
<a href="https://itunes.apple.com/app/nearbyweather/id1227313069"><img src="Resources/app_store_badge.svg" alt="Download on the App Store"/></a>
</p>

<p align="center">
<img src="Resources/screenshots.PNG" alt="NearbyWeather Screenshots">
</p>

## About the App

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
| Additional Frameworks | RxSwift | 🔄 In Progress |
| Architecture | MVVM+C | 🔄 In Progress |
| Navigation | Coordinator Pattern with RxFlow | ✅ |
| UI-Construction | Autolayout in Code + Factory Pattern | 🔄 In Progress |
| Dependencies | Dependency Injection & Singletons | ✅ |
| Data Persistence | Realm & Files on Disk | 🔄 In Progress |
| Networking | Alamofire | ✅ |
| Asset Management | R.Swift | ✅ |
| Code Quality | SwiftLint | ✅ |
| Analytics and Reporting | Google Firebase | ✅ |
| Library Management | CocoaPods | ✅ |
| Bootsrapped Bundle Data | Node.js Scripts | ✅ |
| Deployment | Fastlane | ✅ |
| Testing and Quality Assurance | Unit Tests and UI Tests, SwiftUI Scene Previews | 🅾️ Coming Soon |

## Future Releases

Past releases are documented in the [release section](https://github.com/erikmartens/NearbyWeather/releases) of this repository. Future releases are planned via the [project board](https://github.com/erikmartens/NearbyWeather/projects).

| Version | Tag |
|:--|:--|
| Current Release | [v2.2.0](https://github.com/erikmartens/NearbyWeather/releases/tag/v2.2.0)
| Next Release | [v2.3.0](https://github.com/erikmartens/NearbyWeather/projects/5) |
| Future Releases | [vX.X.X](https://github.com/erikmartens/NearbyWeather/projects/1) |

## How to Get Started

In order to get started, fork the project and clone it to your local machine. 

In order to open the project and in oder to run it, you will need to have the latest Apple developer tools installed, namely Xcode. 

For libraries this app uses the dependency manager [Cocoa Pods](https://cocoapods.org). Pods are not checked into the repository, so you will have run `pod install` in the project base directory after cloning. Additionally it might be helpful to set up signing through [fastlane match](https://docs.fastlane.tools/actions/match/). Create your own repo to store your personal sigining certificates and provisioning profiles and adapt the `./fastlane/Matchfile` accordingly. _Make sure to never commit these changes or your pull requests will be rejected._

## How to Contribute

### Development

We looking forward to receiving your contributions. You can find out how to take part in the development of this application via the [contribution guidelines](https://github.com/erikmartens/NearbyWeather/blob/master/CONTRIBUTING.md).

### Beta Testing

You may also assist as a beta tester. Periodically test-builds will become available via Testflight. In order to take part in testing those submit an email address used as an Apple-ID to [erikmartens.developer@gmail.com](mailto:erikmartens.developer@gmail.com) to be added to the list of testers.

## Support & Feedback

If you are having technical issues or want to raise a bug/issue with the app, the preferred way is through [GitHub issues](https://github.com/erikmartens/NearbyWeather/issues). In order to contact Erik Maximilian Martens for any other request please reach out via one of the channels detailed in table below:

| Platform | Address |
|:--|:--|
| Discord | <a href="https://discord.gg/fxPgKzC"><img src="https://img.shields.io/discord/717413902689894411.svg?style=shield" alt="Discord: NearbyWeather by Erik Martens"/></a> |
| Twitter | <a href="https://twitter.com/erik_m_martens"><img src="https://img.shields.io/badge/Twitter-@erik_m_martens-blue.svg" alt="Twitter: @erik_m_martens"/></a> |
| Email | <a href="mailto:erikmartens.developer@gmail.com" title="erikmartens.developer@gmail.com"><img src="https://img.shields.io/badge/email-erikmartens.developer@gmail.com-green?logo=mail&style=flat&logoColor=white"></a> |

## Licensing

Copyright (c) 2020 Erik Maximilian Martens.

Licensed under the **MIT License** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://opensource.org/licenses/MIT.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
