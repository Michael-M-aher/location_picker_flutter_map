# flutter_location_search

A Flutter package that provides Place search with history of latest location searched using Open Street Map.

[![Get the library](https://img.shields.io/badge/Get%20library-pub-blue)](https://pub.dev/packages/flutter_location_search) &nbsp; [![Example](https://img.shields.io/badge/Example-Ex-success)](https://pub.dev/packages/flutter_location_search/example)

## Features

- Search location by places
- Return selected location's data
- Can be displayed in fullscreen mode or overlay mode
- Easy to use and custom

## Preview

<img src="https://user-images.githubusercontent.com/62302576/236583981-6a7ca9e2-0f8f-439c-92f6-c64915d4569a.png" width="200" height="400" />
<img src="https://user-images.githubusercontent.com/62302576/236583983-bbdc8e0f-0a70-42b0-9053-dc26a4c29138.png" width="200" height="400" />
<img src="https://user-images.githubusercontent.com/62302576/236583986-c46deb7a-0a3c-40b8-880a-604a614a0b84.png" width="200" height="400" />

## Setup

To add the flutter_location_search to your Flutter application read the instructions. Below are some Android and iOS specifics that are required for the package to work correctly.

<details>
<summary>Android</summary>
  
**Upgrade pre 1.12 Android projects**
  
Since version 5.0.0 this plugin is implemented using the Flutter 1.12 Android plugin APIs. Unfortunately this means App developers also need to migrate their Apps to support the new Android infrastructure. You can do so by following the [Upgrading pre 1.12 Android projects](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects) migration guide. Failing to do so might result in unexpected behaviour.

**AndroidX**

The flutter_location_search plugin requires the AndroidX version of the Android Support Libraries. This means you need to make sure your Android project supports AndroidX. Detailed instructions can be found [here](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility).

The TL;DR version is:

1. Add the following to your "gradle.properties" file:

```
android.useAndroidX=true
android.enableJetifier=true
```

2. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file:

```
android {
  compileSdkVersion 33

  ...
}
```

3. Make sure you set the `minSdkVersion` in your "android/app/build.gradle" file:

```
android {
  minSdkVersion 23

  ...
}
```

4. Make sure you replace all the `android.` dependencies to their AndroidX counterparts (a full list can be found here: [Migrating to AndroidX](https://developer.android.com/jetpack/androidx/migrate)).

**Permissions**

On Android you'll need to add either the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission to your Android Manifest. To do so open the AndroidManifest.xml file (located under android/app/src/main) and add one of the following two lines as direct children of the `<manifest>` tag (when you configure both permissions the `ACCESS_FINE_LOCATION` will be used by the flutter_location_search plugin):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

> **NOTE:** Specifying the `ACCESS_COARSE_LOCATION` permission results in location updates with an accuracy approximately equivalent to a city block. It might take a long time (minutes) before you will get your first locations fix as `ACCESS_COARSE_LOCATION` will only use the network services to calculate the position of the device. More information can be found [here](https://developer.android.com/training/location/retrieve-current#permissions).

</details>

<details>
<summary>iOS</summary>

On iOS you'll need to add the following entries to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningful in the context of your App):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
```

If you would like to receive updates when your App is in the background, you'll also need to add the Background Modes capability to your XCode project (Project > Signing and Capabilities > "+ Capability" button) and select Location Updates. Be careful with this, you will need to explain in detail to Apple why your App needs this when submitting your App to the AppStore. If Apple isn't satisfied with the explanation your App will be rejected.

When using the `requestTemporaryFullAccuracy({purposeKey: "YourPurposeKey"})` method, a dictionary should be added to the Info.plist file.

```xml
<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>YourPurposeKey</key>
  <string>The example App requires temporary access to the device&apos;s precise location.</string>
</dict>
```

The second key (in this example called `YourPurposeKey`) should match the purposeKey that is passed in the `requestTemporaryFullAccuracy()` method. It is possible to define multiple keys for different features in your app. More information can be found in Apple's [documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationtemporaryusagedescriptiondictionary).

> NOTE: the first time requesting temporary full accuracy access it might take several seconds for the pop-up to show. This is due to the fact that iOS is determining the exact user location which may take several seconds. Unfortunately this is out of our hands.

</details>

<details>
<summary>macOS</summary>

On macOS you'll need to add the following entries to your Info.plist file (located under macOS/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningful in the context of your App):

```xml
<key>NSLocationUsageDescription</key>
<string>This app needs access to location.</string>
```

You will also have to add the following entry to the DebugProfile.entitlements and Release.entitlements files. This will declare that your App wants to make use of the device's location services and adds it to the list in the "System Preferences" -> "Security & Privacy" -> "Privacy" settings.

```xml
<key>com.apple.security.personal-information.location</key>
<true/>
```

When using the `requestTemporaryFullAccuracy({purposeKey: "YourPurposeKey"})` method, a dictionary should be added to the Info.plist file.

```xml
<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>YourPurposeKey</key>
  <string>The example App requires temporary access to the device&apos;s precise location.</string>
</dict>
```

The second key (in this example called `YourPurposeKey`) should match the purposeKey that is passed in the `requestTemporaryFullAccuracy()` method. It is possible to define multiple keys for different features in your app. More information can be found in Apple's [documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationtemporaryusagedescriptiondictionary).

> NOTE: the first time requesting temporary full accuracy access it might take several seconds for the pop-up to show. This is due to the fact that macOS is determining the exact user location which may take several seconds. Unfortunately this is out of our hands.

</details>

## Installing

Add the following to your `pubspec.yaml` file:

    dependencies:
      flutter_location_search: ^2.2.0

## Getting Started

Import the following package in your dart file

```dart
import 'package:flutter_location_search/flutter_location_search.dart';
```

To use, call the _*LocationSearch.show()*_ function

    ```
    LocationData? locationData = await LocationSearch.show(
                    context: context,
                    userAgent: UserAgent(appName: 'Location Search Example', email: 'support@myapp.com'),
                    mode: Mode.fullscreen,
                    );
    ```

_*LocationSearch*_ has the following parameters: 

- _*onError*_ : (callback) is triggered when an error occurs while fetching location

- _*language*_ : (String) set the language of the address text (default = 'en')

- _*countryCodes*_ : (List) of countries to Limit search results to

- _*loadingWidget*_ : (Widget) show custom  widget until the map finish initialization

- _*searchBarBackgroundColor*_ : (Color) change the background color of the search bar

- _*searchBarTextColor*_ : (Color) change the color of the search bar text

- _*searchBarHintText*_ : (String) change the hint text of the search bar

- _*searchBarHintColor*_ : (Color) change the color of the search bar hint text

- _*lightAdress*_ : (bool) if true, displayed and returned adresses will be lighter

- _*iconColor*_ : (Color) change the color of the search bar text

- _*currentPositionButtonText*_ : (String) change the text of the button selecting current position

- _*mode*_ : mode of display (fullscreen or overlay)

- _*historyMaxLength*_ : (int) set the capacity or maximum length of history
- _*userAgent*_ : (UserAgent)  http request header that is sent with each request.

$OpenStreetMap’s Nominatim* service (used for geocoding) requires a user-agent to identify your application.
If you don’t provide one, your requests might get blocked or throttled. Hence this parameters *is mandatory since version _2.0.0_*.


# Usage

Location proposals will be displayed when typing in the search bar.

When a location proposal is selected, a _*LocationData*_ object is returned.

_*LocationData*_ has three properties.

1. latitude
2. longitude
3. address `//String address`
4. addressData `//Map<String, dynamic> contains address details`

The package also comes with a history of latest searched places. The amount of places to historicize is set by _*historyMaxLength*_ parameter.

<img src="https://user-images.githubusercontent.com/62302576/236868469-e244613f-32be-46e4-9bcf-efea72f27ef5.png" width="200" height="400" />
<img src="https://user-images.githubusercontent.com/62302576/236868476-fff61a67-49c3-4300-a74f-c9518db38d33.png" width="200" height="400" />

# Example

Here is a snippet od code showing a Button that on tap, shows a widget to search a location;
once a location is selected, the location address is set as the button text.

```dart
TextButton(
  child: Text(_locationText),
  onPressed: () async {
    LocationData? locationData = await LocationSearch.show(
      context: context,
      lightAdress: true,
      mode: Mode.fullscreen,
      userAgent: UserAgent(appName: 'Location Search Example', email: 'support@myapp.com')
      );

    setState(() {
      _locationText = locationData!.address;
    });
  },
)
```

&nbsp;

## Dependencies version solving issues

You may encounter a dependency version failure because this package uses the _0.18.0_ version of *_intl_* and some frequently used packages such as *_firebase_auth_* use its _0.17.0_ version.
To solve this issue, you can add the following to your *_pubspec.yaml_* file :
```yaml
dependency_overrides:
  intl: ^0.18.0
```

## Contributing

Pull requests are welcome. For major changes, please open an [issue](https://github.com/KomInc/flutter_location_search/issues) first to discuss what you would like to change.


## 📝 License

Copyright © 2022 [Michael Maher](https://github.com/Michael-M-aher).<br />
This project is [MIT](https://github.com/KomInc/flutter_location_search/blob/main/LICENSE) licensed.
