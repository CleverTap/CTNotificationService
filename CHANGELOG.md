Change Log
==========

Version 1.0.0 (19 November, 2026)
-----------------------------------------------
- The SDK builds with Xcode 27 and runs on iOS 27.
- Raises the minimum supported deployment target to iOS 15.0.
- Updates the example apps to the UIScene lifecycle.
- Registers its name and version with the CleverTap iOS SDK when both are in the Notification Service Extension.
- Adds a CocoaPods sunset notice to the podspec and README. CocoaPods trunk becomes read-only on December 2, 2026. Add `source 'https://github.com/CleverTap/podspecs.git'` and `source 'https://cdn.cocoapods.org/'` to the top of your Podfile to keep receiving updates.

Version 0.1.7 (17 April, 2024)
-----------------------------------------------
- Fixes a build error related to privacy manifests when statically linking the SDK using Cocoapods.
- Fixes the error "Missing an expected key: 'NSPrivacyCollectedDataTypes'" when generating a privacy report.

Version 0.1.6 (20 March, 2024)
-----------------------------------------------
- Adds privacy manifests.

Version 0.1.5 *(22 June, 2022)*
-------------------------------------------
- Added support for media url having no extension.

Version 0.1.4 *(2 December, 2021)*
-------------------------------------------
- Adds support for installation via Swift Package Manager
- Update Starter Applications

Version 0.1.3 *(28 September, 2020)*
-------------------------------------------
- Adds support for [Carthage](https://github.com/Carthage/Carthage)
- Update Starter Applications

Version 0.1.2 *(22 January, 2020)*
-------------------------------------------
- Replace `FOUNDATION_EXPORT` with extern


Version 0.1.1 *(19 September, 2017)*
-------------------------------------------

- Update podspec to weak link `UserNotifications` framework to allow safe linking to < iOS 10 targets

Version 0.1.0 *(28 February, 2017)*
-------------------------------------------

- Initial release.
