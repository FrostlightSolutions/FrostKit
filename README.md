FrostKit
========

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Overview & Roadmap

#### Platforms
- [x] iOS
- [x] watchOS
- [x] tvOS
- [x] OS X

#### General
- [x] `FrostKit` - Used to setup some default values used thoughout the framework.
- [ ] Unit Tests - **_continuous_**
- [ ] Wiki/Documentation - **_continuous_**

#### Service
- [x] `TaskStore` - A class to keep track of URL tasks and operations.

#### Storage
- [x] `LocalStorage` - A series of helper functions for storing data and files locally.
- [x] `ContentManager` - A class to keep track of content and cleanup unused data.

#### CoreData
- [x] `CoreDataProxy` - A class to standardise some of the setup of CoreData (should be used as a template not subclassed).
- [x] `CoreDataController` - A controller for CoreData to be used in table and collection view controllers.
- [x] `CoreDataTableViewController` - Deals with a lot of the standard CoreData and CoreData Controller aspects for a table view controller.
- [x] `CoreDataCollectionViewController` - Deals with a lot of the standard CoreData and CoreData Controller aspects for a collection view controller.

#### CloudKit
- [x] `CloudKitTableViewController` - Deals with a lot of the standard CloudKit aspects for a table view controller (not commonly used, as `CoreDataTableViewController` and CoreData should normally be used instead).

#### View Controllers
- [x] `WebViewController`   - Included for iOS 8, in iOS 9 SFSafariViewController shuold be used.
- [x] `UIWebViewController` - Included for iOS 8, in iOS 9 SFSafariViewController shuold be used.
- [x] `WKWebViewController` - Included for iOS 8, in iOS 9 SFSafariViewController shuold be used.
- [x] `CarouselViewController` - A carousel style view based on a `UICollectionViewController`.

#### InterfaceController
- [x] `TableInterfaceController` - Deals with a lot of the standard table view aspects in a watchOS app.

#### Views & Appearance
- [ ] `Appearance` - Will deal with a unified appearnce and updating views and `UIAppearance` when changes are made. Addisions to all view based classes will added, prefixing them with `FK` (`UIView`, `UIButton`, etc).
- [x] `View` - Adds some `IBInspectable` variables.
- [x] `Button` - Adds some `IBInspectable` variables.
- [x] `ImageView` - Adds some `IBInspectable` variables.
- [x] `VisualEffectView` - Adds some `IBInspectable` variables.
- [x] `InitialsImageView` - For use with profiles to show a users initials if no image is available.

#### Helpers
- [x] `SocialHelper` - Helpers to create, present and deal with social prompts for email, phone, message and social services.
- [x] `AppStoreHelper` - Helper for getting information about the current app from the App Store (requires the App ID set in `setup()`).

#### Maps
- [x] `MapController` - Deals with a lot of the standard map functionality, including permission requests, plotting data and clustering.
- [x] `Address` - A standard implementation of an address object.
- [x] `Annotation` - A standard implementation of an annotation.
- [x] `MapViewController` - Deals with a lot of the standard map view functionality in a view controller such as presenation and interaction with the map view.
- [x] `MapSearchViewController` - A basic implementation of allowing the user to search the `MapViewController` and `MapController`.

#### Extensions
- [x] `Error`
- [x] `Date`
- [x] `Calendar`
- [x] `TimeZone`
- [x] `Data`
- [x] `Bundle`
- [x] `Font`
- [x] `Color`
- [x] `Image`
- [x] `Device`
- [x] `View`
- [x] `BarButtonItem`
- [x] `ViewController`
- [x] `CollectionViewController`
- [x] `Screen`
- [x] `CKContainer`
- [x] `CKDatabase`
- [x] `CKReference`
- [x] `CKRecordID`

#### Fonts
- [x] `CustomFonts` - A class to help programically load fonts by name and load default custom fonts.
- [x] FontAwesome
- [x] IonIcons

## Requirements

- iOS 8.0+
- Xcode 7

* * *

### Creator

- [James Barrow](http://github.com/baza207)
