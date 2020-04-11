fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### set_version
```
fastlane set_version
```
fastlane set_version version_number:1.0.0
### bump_build
```
fastlane bump_build
```

### set_build
```
fastlane set_build
```
fastlane set_build build_number:123
### testflight_beta
```
fastlane testflight_beta
```
fastlane testflight_beta changelog: 'Notes to testers'
### prepare_release
```
fastlane prepare_release
```

### release
```
fastlane release
```

### upload_meta_data
```
fastlane upload_meta_data
```

### read_code_signing
```
fastlane read_code_signing
```

### update_bootstrap_weatherstations
```
fastlane update_bootstrap_weatherstations
```

### refresh_dsyms
```
fastlane refresh_dsyms
```
fastlane refresh_dsyms version_number:1.0.0 build_number:123 or just fastlane refresh_dsyms

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
