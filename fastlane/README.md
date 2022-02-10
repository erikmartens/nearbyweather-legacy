fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### set_version

```sh
[bundle exec] fastlane set_version
```

fastlane set_version version_number:1.0.0

### bump_build

```sh
[bundle exec] fastlane bump_build
```



### set_build

```sh
[bundle exec] fastlane set_build
```

fastlane set_build build_number:123

### testflight_beta

```sh
[bundle exec] fastlane testflight_beta
```

fastlane testflight_beta changelog: 'Notes to testers'

### prepare_release

```sh
[bundle exec] fastlane prepare_release
```



### release

```sh
[bundle exec] fastlane release
```



### upload_meta_data

```sh
[bundle exec] fastlane upload_meta_data
```



### read_code_signing

```sh
[bundle exec] fastlane read_code_signing
```



### update_bootstrap_weatherstations

```sh
[bundle exec] fastlane update_bootstrap_weatherstations
```



### refresh_dsyms

```sh
[bundle exec] fastlane refresh_dsyms
```

fastlane refresh_dsyms version_number:1.0.0 build_number:123 or just fastlane refresh_dsyms

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
