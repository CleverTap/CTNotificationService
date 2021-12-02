# CTNotificationService

[![Version](https://img.shields.io/cocoapods/v/CTNotificationService.svg?style=flat)](http://cocoapods.org/pods/CTNotificationService)
[![codebeat badge](https://codebeat.co/badges/45087421-b644-44fc-9a92-f2ccf61e0b16)](https://codebeat.co/projects/github-com-clevertap-ctnotificationservice-master)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CTNotificationService.svg?style=flat)](http://cocoapods.org/pods/CTNotificationService)
[![Platform](https://img.shields.io/cocoapods/p/CTNotificationService.svg?style=flat)](http://cocoapods.org/pods/CTNotificationService)
![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)

## 👋 Introduction

A simple Notification Service Extension class to add media attachments to iOS 10 rich push notifications. Starting with iOS 10 you can add media attachments (image, gif, video, audio) to iOS push notifications. This library provides a simple drop-in class to accomplish that.

[Rich push notifications](https://developer.apple.com/videos/play/wwdc2016/708/) are enabled in iOS 10 via a [Notification Service Extension](https://developer.apple.com/reference/usernotifications/unnotificationserviceextension), a separate and distinct binary embedded in your app bundle.

## 📋 Requirements

1. Compatible with iOS version 10.0 or above

2. Configure your app for Push and add a Notification Service Extension target

   - Enable [push notifications](https://developer.apple.com/notifications/) in your main app.

   - Create a Notification Service Extension in your project. To do that in your Xcode project, select File -> New -> Target and choose the Notification Service Extension template.

![notification service extension](https://github.com/CleverTap/CTNotificationService/blob/master/images/service_extension.png)

## 🎉 Installation

### CocoaPods

Install `CTNotificationService` in your Notification Service Extension via [CocoaPods](http://cocoapods.org)

Your `Podfile` should look something like this:

    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '10.0'

    use_frameworks!

    target 'YOUR_NOTIFICATION_SERVICE_TARGET_NAME' do  
        pod 'CTNotificationService'  
    end     

Then run `pod install`.

[See example Podfile here](https://github.com/CleverTap/CTNotificationService/blob/master/Example/Podfile).

### Carthage

CTNotificationService supports [Carthage](https://github.com/Carthage/Carthage) to package your dependencies as a framework.

To integrate CTNotificationService into your Xcode project using Carthage, specify the following in your `Cartfile`:

```
github "CleverTap/CTNotificationService"
```

Run `carthage update` to build the framework and drag the built `CTNotificationService.framework` into your Xcode project.

### Swift Package Manager

Swift Package Manager is an Xcode tool that installs project dependencies. To use it to install CTNotificationService SDK, follow these steps:

- In Xcode, navigate to **File -> Swift Package Manager -> Add Package Dependency.**
- Enter **https://github.com/CleverTap/CTNotificationService.git** when choosing package repo and Click **Next.**
- On the next screen, Select an SDK version (by default, Xcode selects the latest stable version). Click **Next.**
- Click **Finish** and ensure that the **CTNotificationService** has been added to the appropriate target.

## 🚀 Integration

### Configure your Notification Service Extension to use the CTNotificationServiceExtension class

By default CTNotificatonServiceExtension will look for the push payload key `ct_mediaUrl` with a value representing the url to your media file and the key `ct_mediaType` with a value of the type of media (image, video, audio or gif).

If you are happy with the default key names, you can simply insert `CTNotificationServiceExtension` in place of your extension class name as the value for the NSExtension -> NSExtensionPrincipalClass entry in your Notfication Service Extension target Info.plist.  [See example here](https://github.com/CleverTap/CTNotificationService/blob/master/Example/NotificationService/Info.plist). 

Alternatively, you can leave the NSExtensionPrincipalClass entry unchanged and instead have your NotificationService class extend the CTNotificationServiceExtension class. You can then also override the defaults to your chosen key names if you wish. [See Swift example here](https://github.com/CleverTap/CTNotificationService/blob/master/ExampleSwift/NotificationService/NotificationService.swift) and [Objective-C example here](https://github.com/CleverTap/CTNotificationService/blob/master/Example/NotificationService). In that case, only override `didReceive request: contentHandler:` as shown in the example.

If you plan on downloading non-SSL urls please be sure to enable App Transport Security Settings -> Allow Arbitrary Loads -> true in your plist.  [See plist example here](https://github.com/CleverTap/CTNotificationService/blob/master/Example/NotificationService/Info.plist).  

### Configure your APNS payload

Then, when sending notifications via APNS:
- Include the mutable-content flag in your payload aps entry (this key must be present in the aps payload or the system will not call your app extension) 
- Add the `ct_mediaUrl` and `ct_mediaType` key-values (or your custom key-values) to the payload, outside of the aps entry.

```
{
    "aps": {
        "alert": {
      		"body": "test message",
      		"title": "test title",
   	  	},
        "mutable-content": 1,
   	},
    "ct_mediaType": "gif",
    "ct_mediaUrl": "https://www.wired.com/images_blogs/design/2013/09/davey1_1.gif",
	...
}
```

## 𝌡 Example Usage

- See [an example Swift project here](https://github.com/CleverTap/CTNotificationService/blob/master/ExampleSwift).

- See [an example Objective-C project here](https://github.com/CleverTap/CTNotificationService/blob/master/Example).

- See [an example SwiftPM project here](https://github.com/CleverTap/CTNotificationService/blob/master/ExampleSwiftPM).


## 🆕 Change Log

Refer to the [CTNotificationService Change Log here](https://github.com/CleverTap/CTNotificationService/blob/master/CHANGELOG.md).
