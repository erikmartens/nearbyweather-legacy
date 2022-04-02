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
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift"/></a>
<a href="https://github.com/erikmartens/NearbyWeather/commits/develop" title="Latest Commit"><img src="https://img.shields.io/github/last-commit/erikmartens/NearbyWeather?style=flat"></a>
<a href="https://github.com/erikmartens/NearbyWeather/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/erikmartens/NearbyWeather?style=flat"></a>
<a href="https://github.com/erikmartens/NearbyWeather/graphs/contributors"><img src="https://img.shields.io/github/contributors/erikmartens/NearbyWeather.svg?style=flat" alt="Contributors"></a>
<img src="https://img.shields.io/github/license/erikmartens/NearbyWeather.svg?style=flat" alt="License: MIT">
</p>
<p align="center">
<a href="https://itunes.apple.com/app/nearbyweather/id1227313069"><img src="Resources/app_store_badge.svg" alt="Download on the App Store"/></a>
</p>

<p align="center">
<img src="Resources/screenshots.PNG" alt="NearbyWeather Screenshots">
</p>

## About the App

> ❗️ By using the app you automatically agree to the [privacy policy](PRIVACYPOLICY.md) and the [terms of use](TERMSOFUSE.md).

> ❗️Please note that you need to supply your own OpenWeatherMap API key, in order to use the app.

NearbyWeather is a simple weather app, that provides current weather information for nearby weather stations, as well for bookmarked weather stations. NearbyWeather uses the OpenWeatherMap API to download weather data. Additionally the OpenWeatherMap's station-database is directly bootstrapped into the app for quick access.

### Supported Languages

| Development Language | App Localizations |
|:--|:--|
| 🇺🇸 | 🇺🇸 🇩🇪 🇫🇷 🇨🇳 (Traditional) |

## Mission of this Project

NearbyWeather was created to help you as a reference for advanced app-building-concepts. The app is kept up to date with the latest best practices in native development for Apple Platforms. Below is a list of the concepts used for different areas of the construction of NearbyWeather:

| Area | Concepts | Status |
|:--|:--|:-:|
| Language | Swift | ✅ |
| Framework | ReactiveX (RxCocoa, RxSwift) | ✅ |
| Architecture | MVVM+C | ✅ |
| Routing | Coordinator Pattern via RxFlow | ✅ |
| UI-Construction | Layout via Code + Factory Pattern | ✅ |
| Dependency Management| Swinject | ✅ |
| Data Persistence | Realm | ✅ |
| Networking | Alamofire | ✅ |
| Asset Management | R.Swift | ✅ |
| Code Quality | SwiftLint | ✅ |
| Package Management | CocoaPods | ✅ |
| Bootsrapping | Node.js Scripts | ✅ |
| Deployment | Fastlane | ✅ |
| Crash Data Analytics | Reports to Google Firebase | ✅ |
| Usage Behavior Analytics | Events to Google Firebase | 🅾️ |
| UI Design Verification | SwiftUI Scene Previews | 🅾️ |
| Continuous Integration | Bitrise | 🅾️ |
| Quality Assurance | Unit Tests & UI Tests for Regression Tests via CI | 🅾️ |

> __LEGEND:__ ✅ = Done, 🔄 = In Progress, 🅾️ = Coming Soon

## App Releases

Past releases are documented in the [release section](https://github.com/erikmartens/NearbyWeather/releases) of this repository. Future releases are planned via the [project board](https://github.com/erikmartens/NearbyWeather/projects). There you can get an overview of planned features. If you want to suggest a feature, you can submit a new issue for triage.

| Type | Project | Release |
|:--|:--|:--|
| Current Release | [Project 3.0.0](https://github.com/erikmartens/NearbyWeather/releases/tag/v2.3.0) | _N/A_ |
| Next Release | [Project 3.1.0](https://github.com/erikmartens/NearbyWeather/projects/8) | _N/A_ |
| Future Releases | [Future Backlog Project](https://github.com/erikmartens/NearbyWeather/projects) | _N/A_ |

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

## How to Contribute

### Development

We looking forward to receiving your contributions. You can find out how to take part in the development of this application. Please find out how to submit code to this repository via the [contribution guidelines](CONTRIBUTING.md).

### Translations

Localizing the app for additional languages is another great way to contribute. If you are an experienced iOS developer, you know what to do. Please create an issue for your chosen language and follow the [contribution guidelines](CONTRIBUTING.md). Otherwise get into contact in order to be introduced to the procedure.

### Beta Testing

You may also assist as a beta tester. Periodically test-builds will become available via Testflight. In order to take part in testing those submit an email address used as an Apple-ID to [erikmartens.dev@icloud.com](mailto:erikmartens.dev@icloud.com) to be added to the list of testers.

## Support & Feedback

If you are having technical issues or want to raise a bug/issue with the app, the preferred way is through [GitHub issues](https://github.com/erikmartens/NearbyWeather/issues). In order to contact Erik Maximilian Martens for any other request please reach out via one of the channels detailed in table below:

| Platform | Link |
|:--|:--|
| Discord | <a href="https://discord.gg/fxPgKzC"><img src="https://img.shields.io/discord/717413902689894411.svg?style=shield" alt="Discord: NearbyWeather by Erik Martens"/></a> |
| Twitter | <a href="https://twitter.com/erik_m_martens"><img src="https://img.shields.io/badge/Twitter-@erik_m_martens-blue.svg" alt="Twitter: @erik_m_martens"/></a> |
| Email | <a href="mailto:erikmartens.dev@gicloud.com" title="erikmartens.dev@icloud.com"><img src="https://img.shields.io/badge/email-erikmartens.dev@icloud.com-green?logo=mail&style=flat&logoColor=white"></a> |

## Licensing

Copyright © 2016 - 2022 Erik Maximilian Martens.

Licensed under the **MIT License** (the "License"); you may not use this project except in compliance with the License.

You may obtain a copy of the License at [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
