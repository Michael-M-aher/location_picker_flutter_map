## 4.0.0

* **MAJOR REFACTORING**: Complete code architecture overhaul with clean code practices
* **NEW**: Service layer architecture with dedicated service classes:
  - `LocationService`: Handles all GPS and location operations with modern `LocationSettings` API
  - `GeocodingService`: Manages Nominatim API interactions with proper HTTP headers
  - `PermissionService`: User-friendly permission handling with informative dialogs
  - `Debouncer`: Optimized search input handling with configurable delays
* **NEW**: Enhanced error handling with custom exception classes (`LocationException`, `GeocodingException`)
* **NEW**: Configuration classes for better code organization:
  - `MapConfiguration`: Centralized map settings (tiles, zoom, language, bounds)
  - `SearchConfiguration`: Search functionality options (results, styling, behavior)
  - `ControlsConfiguration`: Comprehensive UI control styling (zoom buttons, location button)
  - `MarkerConfiguration`: Location marker appearance and behavior
  - `SelectButtonConfiguration`: Select location button customization
  - `AttributionConfiguration`: OSM attribution badge settings
* **NEW**: `FlutterLocationPicker.withConfiguration()` constructor for cleaner configuration
* **NEW**: Extensive zoom button customization:
  - Custom icons (`zoomInIcon`, `zoomOutIcon`, `locationIcon`)
  - Button shapes and elevation (`buttonShape`, `buttonElevation`)
  - Individual button sizes (`zoomButtonsSize`, `locationButtonSize`)
  - Shadow effects (`showButtonShadow`)
  - Positioning and spacing controls
* **NEW**: Enhanced HTTP headers for Nominatim API compliance:
  - Proper User-Agent validation and error handling
  - Support for custom headers and authentication
  - Rate limiting detection and informative error messages
* **NEW**: Timeout handling for all network requests
* **IMPROVED**: Better separation of concerns with cleaner method structure
* **IMPROVED**: Enhanced data classes with validation, equality operators, and helper methods
* **IMPROVED**: Comprehensive documentation with dartdoc comments and usage examples
* **IMPROVED**: Better resource management and disposal patterns
* **IMPROVED**: User experience with better permission dialogs and error messages
* **IMPROVED**: Performance optimizations and HTTP client management
* **IMPROVED**: RTL language support and internationalization
* **IMPROVED**: Formatted address components with smart parsing
* **IMPROVED**: Search functionality with configurable debouncing and result limits
* **FIXED**: All deprecation warnings and modernized API usage
* **FIXED**: Memory leaks with proper controller disposal
* **FIXED**: Nominatim API compliance with proper HTTP headers and User-Agent
* **BREAKING CHANGES**:
  - Service classes are now exported and can be used independently
  - Enhanced data classes with new methods and properties
  - Improved error handling may require updates to error callback handling
  - User-Agent parameter is now strictly validated for Nominatim compliance

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