fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
### setup
```
fastlane setup
```
Run this after creating the Xcode project
### xcsbuild
```
fastlane xcsbuild
```
Run by an Xcode Server instance via a Bot

----

## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios alpha
```
fastlane ios alpha
```
Run on a normal build locally to create an alpha
### ios fabric
```
fastlane ios fabric
```
Submit a new Beta Build to Fabric Crashlytics Beta
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios appstore
```
fastlane ios appstore
```
Deploy a new version to the App Store

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools).
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).