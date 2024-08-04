## 3.1.0

* Migrate from `Geolocator` to `Location` package.
* Fix initial location not being set when `initialLocation` is provided.
* Fix infinite loading screen when user location is turned off.
* Add `mapLayers` property to allow users to add custom layers to the map.
* Add `nominatimHost` property to allow users to change the default Nominatim host.
* Improve performance.
* Update dependencies

## 3.0.1

* Fix error of Geolocator.getServiceStatusStream() on web
* Update dependencies

## 3.0.0

* Fix `Buffer parameter must not be null` issue.
* Fix `onChanged` null value issue.
* Add `countryFilter` that allows filtering search results to specific countries

## 2.1.0

* Improve performance.
* Reduce tile loading durations (particularly on the web).
* Reduce users' (cellular) data and cache space consumption.

## 2.0.0

* Add `onchanged` function that returns `pickedData` when the user change marker location on map.
* Add `searchbarDebounceDuration` property.
* Upgrade flutter_map to 6.0.1.
* Remove subdomains from the default OSM URLs.
* Update other dependencies.

## 1.2.2

* SetLocationError handling
* Support more customizations for Select Location button Text
* Remove loading when the current location is changed.
* Remove SafeArea from map
* Added maxBounds
* Update dependencies

## 1.2.1

* Added OSM copyrights Badge
* Support more customizations for Select Location button and Search bar
* Update dependencies

## 1.2.0

* Add Current Location Pointer
* Update dependencies

## 1.1.5

* Improve Animations

## 1.1.4

* Fix error zoom buttons and locate me button not working

## 1.1.3

* Fix Ticker error
* Remove Address class
* Add Map `addressData` to `pickedData` response

## 1.1.2

* Add `road` property to `Address` class
* Add `suburb` property to `Address` class

## 1.1.1

* Fix issues with new flutter_map update
* Add `mapLoadingBackgroundColor` property

## 1.1.0

* Improve performance
* Support multiple languages using `mapLanguage`
* Make controls position directional
* Use default app styles and theming instead of explicit values
* Make all controls optional by adding `showSelectLocationButton` and `showSearchBar`
* Add a new class for Address with all address details
* Add `searchBarHintText` property
* Add `addressData` to `pickedData` response
* Add `onError` property and improve error handling
* **BREAKING CHANGES**
    * Replaced `mapIsLoading` with `loadingWidget`
    * Replaced `selectLocationButtonColor` with `selectLocationButtonStyle`

## 1.0.3

* Improve performance

## 1.0.2

* Fixed infinite loading screen when user location is turned off

## 1.0.1

* Fixed formatting issue of loading_widget

## 1.0.0

* Implemented and tested the whole plugin and make sure everything works correctly