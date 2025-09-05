# location_picker_flutter_map

A comprehensive Flutter package that provides location picking, place search, and map interactions using OpenStreetMap with extensive customization options and clean architecture.

[![Get the library](https://img.shields.io/badge/Get%20library-pub-blue)](https://pub.dev/packages/location_picker_flutter_map) &nbsp; [![Example](https://img.shields.io/badge/Example-Ex-success)](https://pub.dev/packages/location_picker_flutter_map/example)

## ✨ Features

* **🗺️ Interactive Map**: Pan, zoom, and tap to select locations
* **🔍 Smart Search**: Real-time location search with autocomplete suggestions
* **📍 Current Location**: GPS-based location tracking with intelligent permission handling
* **🎨 Highly Customizable**: 50+ customization options organized in configuration classes
* **🔧 Clean Architecture**: Service layer pattern with dedicated classes for different concerns
* **🌍 Multi-language**: RTL support and internationalization
* **⚡ Performance Optimized**: Efficient API calls, debouncing, and resource management
* **🛡️ Error Handling**: Comprehensive error management with user-friendly messages
* **🔒 Permission Management**: Smart permission dialogs with clear explanations

## 🎯 What's New in v4.0.0

### 🏗️ **Clean Architecture & Service Layer**
- **LocationService**: Modern GPS operations with `LocationSettings` API
- **GeocodingService**: Nominatim API with proper HTTP headers and rate limiting
- **PermissionService**: User-friendly permission dialogs
- **Configuration Classes**: Organized settings for each component

### 🎛️ **Enhanced Control Customization**
```dart
ControlsConfiguration(
  zoomInIcon: Icons.add_circle,           // Custom zoom icons
  zoomOutIcon: Icons.remove_circle,
  buttonShape: RoundedRectangleBorder(    // Custom button shapes
    borderRadius: BorderRadius.circular(15),
  ),
  buttonElevation: 8.0,                   // Shadow effects
  zoomButtonsSize: 60.0,                  // Individual sizing
  showButtonShadow: true,                 // Enable/disable shadows
)
```

### 🔧 **Better Configuration Pattern**
```dart
FlutterLocationPicker.withConfiguration(
  userAgent: 'MyApp/1.0.0 (contact@mycompany.com)',
  mapConfiguration: MapConfiguration(/*...*/),
  searchConfiguration: SearchConfiguration(/*...*/),
  controlsConfiguration: ControlsConfiguration(/*...*/),
  // ... other configurations
)
```

## 📱 Platform Setup

To add the location_picker_flutter_map to your Flutter application read the instructions. Below are some Android and iOS specifics that are required for the package to work correctly.
  
<details>
<summary>Android</summary>
  
**Upgrade pre 1.12 Android projects**
  
Since version 5.0.0 this plugin is implemented using the Flutter 1.12 Android plugin APIs. Unfortunately this means App developers also need to migrate their Apps to support the new Android infrastructure. You can do so by following the [Upgrading pre 1.12 Android projects](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects) migration guide. Failing to do so might result in unexpected behaviour.

**AndroidX** 

The geolocator plugin requires the AndroidX version of the Android Support Libraries. This means you need to make sure your Android project supports AndroidX. Detailed instructions can be found [here](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility). 

The TL;DR version is:

1. Add the following to your "gradle.properties" file:

```
android.useAndroidX=true
android.enableJetifier=true
```
2. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file to 35:

```
android {
  compileSdkVersion 35

  ...
}
```
3. Make sure you replace all the `android.` dependencies to their AndroidX counterparts (a full list can be found here: [Migrating to AndroidX](https://developer.android.com/jetpack/androidx/migrate)).

**Permissions**

On Android you'll need to add either the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission to your Android Manifest. To do so open the AndroidManifest.xml file (located under android/app/src/main) and add one of the following two lines as direct children of the `<manifest>` tag (when you configure both permissions the `ACCESS_FINE_LOCATION` will be used by the geolocator plugin):

``` xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Starting from Android 10 you need to add the `ACCESS_BACKGROUND_LOCATION` permission (next to the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission) if you want to continue receiving updates even when your App is running in the background:

``` xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

Starting from Android 14 (SDK 34) you need to add the `FOREGROUND_SERVICE_LOCATION` permission (next to the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` or the `ACCESS_BACKGROUND_LOCATION` permission) if you want to continue receiving updates even when your App is running in the foreground:
 [FOREGROUND_SERVICE_LOCATION](https://developer.android.com/reference/android/Manifest.permission#FOREGROUND_SERVICE_LOCATION) 

 ``` xml
 <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"
 ```

> **NOTE:** Specifying the `ACCESS_COARSE_LOCATION` permission results in location updates with an accuracy approximately equivalent to a city block. It might take a long time (minutes) before you will get your first locations fix as `ACCESS_COARSE_LOCATION` will only use the network services to calculate the position of the device. More information can be found [here](https://developer.android.com/training/location/retrieve-current#permissions). 


</details>

<details>
<summary>iOS</summary>

On iOS you'll need to add the following entry to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningful in the context of your App):

``` xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

If you don't need to receive updates when your app is in the background, then add a compiler flag as follows: in XCode, click on Pods, choose the Target 'geolocator_apple', choose Build Settings, in the search box look for 'Preprocessor Macros' then add the `BYPASS_PERMISSION_LOCATION_ALWAYS=1` flag.
Setting this flag prevents your app from requiring the `NSLocationAlwaysAndWhenInUseUsageDescription` entry in Info.plist, and avoids questions from Apple when submitting your app. 

You can also have the flag set automatically by adding the following to the `ios/Podfile` of your application:
```agsl
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "geolocator_apple"
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'BYPASS_PERMISSION_LOCATION_ALWAYS=1']
      end
    end
  end
end
```

If you do want to receive updates when your App is in the background (or if you don't bypass the permission request as described above) then you'll need to:
* Add the Background Modes capability to your XCode project (Project > Signing and Capabilities > "+ Capability" button) and select Location Updates. Be careful with this, you will need to explain in detail to Apple why your App needs this when submitting your App to the AppStore. If Apple isn't satisfied with the explanation your App will be rejected.
* Add an `NSLocationAlwaysAndWhenInUseUsageDescription` entry to your Info.plist (use `NSLocationAlwaysUsageDescription` if you're targeting iOS <11.0) 

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

On iOS 16 and above you need to specify `UIBackgroundModes` `location` to receive location updates in the background.

``` xml
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>
```

<details>
<summary>macOS</summary>

On macOS you'll need to add the following entries to your Info.plist file (located under macOS/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningfull in the context of your App):

``` xml
<key>NSLocationUsageDescription</key>
<string>This app needs access to location.</string>
```

You will also have to add the following entry to the DebugProfile.entitlements and Release.entitlements files. This will declare that your App wants to make use of the device's location services and adds it to the list in the "System Preferences" -> "Security & Privace" -> "Privacy" settings.
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

<details>
<summary>Web</summary>

To use the Geolocator plugin on the web you need to be using Flutter 1.20 or higher. Flutter will automatically add the endorsed [geolocator_web]() package to your application when you add the `geolocator: ^6.2.0` dependency to your `pubspec.yaml`.

The following methods of the geolocator API are not supported on the web and will result in a `UnsupportedError`:

- `getLastKnownPosition({ bool forceAndroidLocationManager = true })`
- `openAppSettings()`
- `openLocationSettings()`
- `getServiceStatusStream()`

**NOTE**

Geolocator Web is available only in [secure_contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts) (HTTPS). More info about the Geolocator API can be found [here](https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API).

</details>

<details>
<summary>Windows</summary>

To use the Geolocator plugin on Windows you need to be using Flutter 2.10 or higher. Flutter will automatically add the endorsed [geolocator_windows]() package to your application when you add the `geolocator: ^8.1.0` dependency to your `pubspec.yaml`.

</details>


## Installing

Add the following to your `pubspec.yaml` file:

    dependencies:
      location_picker_flutter_map: ^4.0.0

## 🚀 Getting Started

<img src="https://user-images.githubusercontent.com/25803558/186015160-ac89e47e-374d-42fb-b0d7-35ce660726d0.png" width="300" height="600" />

### 📱 Basic Usage

```dart
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

// Simple usage
FlutterLocationPicker(
  userAgent: 'MyApp/1.0.0 (contact@example.com)', // Required!
  onPicked: (PickedData pickedData) {
    print('Location: ${pickedData.latLong}');
    print('Address: ${pickedData.address}');
  },
)
```

### 🎨 Advanced Customization

```dart
FlutterLocationPicker.withConfiguration(
  userAgent: 'MyApp/1.0.0 (contact@example.com)',
  onPicked: (pickedData) => handleLocationPicked(pickedData),
  
  // Map Configuration
  mapConfiguration: MapConfiguration(
    initZoom: 15.0,
    stepZoom: 2.0,
    mapLanguage: 'en',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ),
  
  // Search Configuration  
  searchConfiguration: SearchConfiguration(
    maxSearchResults: 8,
    searchBarHintText: 'Search for places...',
    searchbarDebounceDuration: Duration(milliseconds: 300),
  ),
  
  // Controls Configuration
  controlsConfiguration: ControlsConfiguration(
    zoomInIcon: Icons.add_circle_outline,
    zoomOutIcon: Icons.remove_circle_outline,
    locationIcon: Icons.my_location_rounded,
    zoomButtonsColor: Colors.white,
    zoomButtonsBackgroundColor: Colors.blue.shade700,
    buttonElevation: 8.0,
    buttonShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  
  // Marker Configuration
  markerConfiguration: MarkerConfiguration(
    markerIcon: Icon(Icons.location_pin, color: Colors.red, size: 60),
    showMarkerShadow: true,
    animateMarker: true,
  ),
  
  // Select Button Configuration
  selectButtonConfiguration: SelectButtonConfiguration(
    selectLocationButtonText: 'Choose This Location',
    selectLocationButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
  ),
)
```

## ⚠️ Important: User-Agent Requirement

**Nominatim API requires a valid User-Agent header.** Provide your app information:

```dart
// ✅ Correct format
userAgent: 'MyLocationApp/1.2.0 (developer@mycompany.com)'

// ❌ These will cause 403 errors
userAgent: 'Dart/2.17 (dart:io)'  // Generic HTTP library agent
userAgent: 'http'                 // Too generic
userAgent: ''                     // Empty string
```

## 📚 Configuration Classes

### 🗺️ MapConfiguration
```dart
MapConfiguration(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  initZoom: 17.0,
  stepZoom: 1.0,
  minZoomLevel: 2.0,
  maxZoomLevel: 18.4,
  mapLanguage: 'en',
  mapAnimationDuration: Duration(milliseconds: 2000),
)
```

### 🔍 SearchConfiguration
```dart
SearchConfiguration(
  showSearchBar: true,
  searchBarHintText: 'Search location',
  maxSearchResults: 5,
  searchbarDebounceDuration: Duration(milliseconds: 500),
  searchResultIcon: Icons.location_on,
)
```

### 🎛️ ControlsConfiguration
```dart
ControlsConfiguration(
  showZoomController: true,
  showLocationController: true,
  zoomInIcon: Icons.zoom_in,
  zoomOutIcon: Icons.zoom_out,
  locationIcon: Icons.my_location,
  buttonElevation: 6.0,
  controlButtonsSpacing: 16.0,
)
```

### 📍 MarkerConfiguration
```dart
MarkerConfiguration(
  markerIcon: Icon(Icons.location_pin, color: Colors.blue),
  markerIconOffset: 50.0,
  animateMarker: true,
  showMarkerShadow: true,
)
```

## 🔧 Service Classes (Available for Independent Use)

```dart
// Location operations
final locationService = LocationService();
final position = await locationService.getCurrentPosition();

// Geocoding operations
final geocodingService = GeocodingService(
  nominatimHost: 'nominatim.openstreetmap.org',
  userAgent: 'MyApp/1.0.0',
);
final results = await geocodingService.searchLocations('New York');

// Permission handling
final permissionService = PermissionService(context);
await permissionService.checkAndRequestLocationPermission();
```

## 🛠️ Migration from v3.x to v4.0

### Using Configuration Classes (Recommended)
```dart
// v3.x (old way)
FlutterLocationPicker(
  userAgent: 'MyApp/1.0',
  zoomButtonsColor: Colors.white,
  zoomButtonsBackgroundColor: Colors.blue,
  searchBarHintText: 'Search...',
  onPicked: (data) => handlePicked(data),
)

// v4.0 (new way - cleaner)
FlutterLocationPicker.withConfiguration(
  userAgent: 'MyApp/1.0',
  controlsConfiguration: ControlsConfiguration(
    zoomButtonsColor: Colors.white,
    zoomButtonsBackgroundColor: Colors.blue,
  ),
  searchConfiguration: SearchConfiguration(
    searchBarHintText: 'Search...',
  ),
  onPicked: (data) => handlePicked(data),
)
```

### Backward Compatibility
The old constructor still works! Your existing code will continue to function without changes.


# Custom Map Style

You can apply themes to your map using [Map Tiler](https://www.maptiler.com/)

Head to the website and sign up then choose the map tile you want

Get the Maptile Url like this 
```
  https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?{apikey}
```

use it in the urlTemplate parameter.


```dart
FlutterLocationPicker(
    urlTemplate:
        'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key={apikey}',
    )
```
Example:


<img src="https://user-images.githubusercontent.com/25803558/186025531-8e57f941-56d2-4413-8931-1841b437e740.png" width="300" height="600" />

&nbsp;

## Contributing
Pull requests are welcome. For major changes, please open an [issue](https://github.com/Michael-M-aher/location_picker_flutter_map/issues) first to discuss what you would like to change.

Please make sure to update tests as appropriate.


## Author

👤 **Michael Maher**

- Twitter: [@Michael___Maher](https://twitter.com/Michael___Maher)
- Github: [@Michael-M-aher](https://github.com/Michael-M-aher)

## Show your support

Please ⭐️ this repository if this project helped you!

<a href="https://www.buymeacoffee.com/michael.maher" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60px" width="200" ></a>

## 📝 License

Copyright © 2022 [Michael Maher](https://github.com/Michael-M-aher).<br />
This project is [MIT](https://github.com/Michael-M-aher/location_picker_flutter_map/blob/main/LICENSE) licensed.