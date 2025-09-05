import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:latlong2/latlong.dart';

import 'classes.dart';
import 'configuration.dart';
import 'services/location_service.dart';
import 'services/geocoding_service.dart';
import 'services/permission_service.dart';
import 'services/debouncer.dart';
import 'widgets/copyright_osm_widget.dart';
import 'widgets/wide_button.dart';

/// A comprehensive Flutter widget for interactive location picking using OpenStreetMap
///
/// FlutterLocationPicker provides a feature-rich map interface with location search,
/// current location tracking, and highly customizable UI elements. It integrates
/// seamlessly with OpenStreetMap and Nominatim for geocoding services.
///
/// ## Key Features:
/// * **Interactive Map**: Pan, zoom, and tap to select locations
/// * **Location Search**: Real-time search with autocomplete suggestions
/// * **Current Location**: GPS-based location tracking with permissions handling
/// * **Geocoding**: Reverse geocoding to get addresses from coordinates
/// * **Customizable UI**: Extensive styling options for all components
/// * **RTL Support**: Right-to-left language support
/// * **Responsive Design**: Adapts to different screen sizes
///
/// ## Basic Usage:
/// ```dart
/// FlutterLocationPicker(
///   userAgent: 'MyApp/1.0.0 (contact@example.com)',
///   onPicked: (PickedData pickedData) {
///     print('Selected location: ${pickedData.address}');
///     print('Coordinates: ${pickedData.latLong}');
///   },
/// )
/// ```
///
/// ## Advanced Usage with Configuration Classes:
/// ```dart
/// FlutterLocationPicker.withConfiguration(
///   userAgent: 'MyApp/1.0.0 (contact@example.com)',
///   onPicked: (pickedData) => handleLocationPicked(pickedData),
///   mapConfiguration: MapConfiguration(
///     initZoom: 15,
///     stepZoom: 2,
///     mapLanguage: 'es',
///   ),
///   searchConfiguration: SearchConfiguration(
///     maxSearchResults: 8,
///     searchBarHintText: 'Buscar ubicación...',
///   ),
///   controlsConfiguration: ControlsConfiguration(
///     zoomInIcon: Icons.add,
///     zoomOutIcon: Icons.remove,
///     zoomButtonsColor: Colors.white,
///     zoomButtonsBackgroundColor: Colors.green,
///     buttonElevation: 8.0,
///   ),
/// )
/// ```
class FlutterLocationPicker extends StatefulWidget {
  // Core Callbacks

  /// **REQUIRED** - Callback triggered when user confirms location selection
  ///
  /// This is called when the user taps the "Select Location" button.
  /// Use this to handle the final location choice.
  ///
  /// Example:
  /// ```dart
  /// onPicked: (PickedData pickedData) {
  ///   Navigator.pop(context, pickedData.latLong);
  ///   // Or save to database, send to API, etc.
  /// }
  /// ```
  final void Function(PickedData pickedData) onPicked;

  /// **OPTIONAL** - Callback triggered when marker location changes on map
  ///
  /// Called whenever the user moves the map and the center location changes.
  /// Useful for real-time location updates or preview functionality.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (PickedData pickedData) {
  ///   setState(() {
  ///     currentAddress = pickedData.address;
  ///   });
  /// }
  /// ```
  final void Function(PickedData pickedData)? onChanged;

  /// **OPTIONAL** - Callback triggered when an error occurs
  ///
  /// Handle various errors like network issues, permission denials,
  /// or geocoding failures. If not provided, errors are logged to console.
  ///
  /// Example:
  /// ```dart
  /// onError: (Exception e) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text('Error: ${e.toString()}')),
  ///   );
  /// }
  /// ```
  final void Function(Exception e)? onError;

  // Core Configuration

  /// **REQUIRED** - User agent string for API requests
  ///
  /// Required by Nominatim API to avoid rate limiting. Should include
  /// your app name and contact information.
  ///
  /// Format: 'AppName/Version (contact@example.com)'
  ///
  /// Example:
  /// ```dart
  /// userAgent: 'MyLocationApp/1.2.0 (developer@mycompany.com)',
  /// ```
  final String userAgent;

  /// **OPTIONAL** - Initial position of the map center and marker
  ///
  /// If not provided, defaults to a preset location (Cairo, Egypt).
  /// When [trackMyPosition] is true, this is overridden by user's location.
  ///
  /// Example:
  /// ```dart
  /// initPosition: LatLong(40.7128, -74.0060), // New York City
  /// ```
  final LatLong? initPosition;

  /// **OPTIONAL** - Automatically track user's current location on startup
  ///
  /// When true, requests location permission and moves map to user's position.
  /// Overrides [initPosition] if user grants permission.
  /// **Default**: false
  ///
  /// Example:
  /// ```dart
  /// trackMyPosition: true, // Auto-locate user
  /// ```
  final bool trackMyPosition;

  /// **OPTIONAL** - Show blue dot indicating user's current location
  ///
  /// Displays a location marker that tracks the user's position in real-time.
  /// **Default**: true
  final bool showCurrentLocationPointer;

  // Nominatim Configuration

  /// **OPTIONAL** - Custom Nominatim server hostname
  ///
  /// Use a custom Nominatim instance for geocoding services.
  /// Useful for private deployments or alternative providers.
  ///
  /// **Default**: 'nominatim.openstreetmap.org'
  ///
  /// Example:
  /// ```dart
  /// nominatimHost: 'my-nominatim-server.com',
  /// ```
  final String nominatimHost;

  /// **OPTIONAL** - Additional query parameters for Nominatim requests
  ///
  /// Add custom parameters or override defaults for geocoding requests.
  /// Useful for fine-tuning search behavior.
  ///
  /// Example:
  /// ```dart
  /// nominatimAdditionalQueryParameters: {
  ///   'extratags': '1',        // Include additional tags
  ///   'namedetails': '1',      // Include name variants
  ///   'polygon_geojson': '1',  // Include polygon data
  /// }
  /// ```
  final Map<String, dynamic>? nominatimAdditionalQueryParameters;

  /// **OPTIONAL** - Zoom level for geocoding precision
  ///
  /// Higher values provide more precise address details.
  /// If null, uses the current map zoom level.
  ///
  /// Range: 1-18 (1 = country level, 18 = building level)
  /// **Default**: null (auto-adjust to map zoom)
  ///
  /// Example:
  /// ```dart
  /// nominatimZoomLevel: 18, // Building-level precision
  /// ```
  final int? nominatimZoomLevel;

  /// **OPTIONAL** - Country codes to limit search results
  ///
  /// Restrict location search to specific countries using ISO 3166-1 alpha-2 codes.
  /// Use comma-separated values for multiple countries.
  ///
  /// Example:
  /// ```dart
  /// countryFilter: 'us,ca,mx', // North America only
  /// ```
  final String? countryFilter;

  // Configuration Classes

  /// **OPTIONAL** - Map configuration settings
  final MapConfiguration? mapConfiguration;

  /// **OPTIONAL** - Search functionality configuration
  final SearchConfiguration? searchConfiguration;

  /// **OPTIONAL** - Control buttons configuration
  final ControlsConfiguration? controlsConfiguration;

  /// **OPTIONAL** - Location marker configuration
  final MarkerConfiguration? markerConfiguration;

  /// **OPTIONAL** - Select button configuration
  final SelectButtonConfiguration? selectButtonConfiguration;

  /// **OPTIONAL** - Attribution configuration
  final AttributionConfiguration? attributionConfiguration;

  // Advanced Customization

  /// **OPTIONAL** - Custom widget displayed while loading
  ///
  /// **Default**: CircularProgressIndicator()
  ///
  /// Example:
  /// ```dart
  /// loadingWidget: Column(
  ///   mainAxisAlignment: MainAxisAlignment.center,
  ///   children: [
  ///     CircularProgressIndicator(color: Colors.blue),
  ///     SizedBox(height: 16),
  ///     Text('Loading map...', style: TextStyle(fontSize: 16)),
  ///   ],
  /// ),
  /// ```
  final Widget? loadingWidget;

  /// **OPTIONAL** - Additional map layers to display
  ///
  /// Add custom overlays, polygons, polylines, etc.
  /// **Default**: Empty list
  ///
  /// Example:
  /// ```dart
  /// mapLayers: [
  ///   PolylineLayer(
  ///     polylines: [
  ///       Polyline(
  ///         points: routePoints,
  ///         color: Colors.red,
  ///         strokeWidth: 4.0,
  ///       ),
  ///     ],
  ///   ),
  ///   CircleLayer(
  ///     circles: [
  ///       CircleMarker(
  ///         point: centerPoint,
  ///         radius: 100,
  ///         color: Colors.blue.withOpacity(0.3),
  ///       ),
  ///     ],
  ///   ),
  /// ],
  /// ```
  final List<Widget> mapLayers;

  /// **OPTIONAL** - Callback for custom map interaction handling
  ///
  /// Called when user taps on the map
  ///
  /// Example:
  /// ```dart
  /// onMapTap: (LatLng position) {
  ///   print('Map tapped at: ${position.latitude}, ${position.longitude}');
  /// },
  /// ```
  final void Function(LatLng position)? onMapTap;

  /// **OPTIONAL** - Callback for map ready event
  ///
  /// Called when map finishes initial loading
  ///
  /// Example:
  /// ```dart
  /// onMapReady: () {
  ///   print('Map is ready for interaction');
  /// },
  /// ```
  final VoidCallback? onMapReady;

  // Legacy Parameters (for backward compatibility)
  // These will be deprecated in future versions

  /// **DEPRECATED** - Use mapConfiguration.urlTemplate instead
  final String? urlTemplate;

  /// **DEPRECATED** - Use mapConfiguration.mapLanguage instead
  final String? mapLanguage;

  /// **DEPRECATED** - Use mapConfiguration.initZoom instead
  final double? initZoom;

  /// **DEPRECATED** - Use mapConfiguration.stepZoom instead
  final double? stepZoom;

  /// **DEPRECATED** - Use mapConfiguration.minZoomLevel instead
  final double? minZoomLevel;

  /// **DEPRECATED** - Use mapConfiguration.maxZoomLevel instead
  final double? maxZoomLevel;

  /// **DEPRECATED** - Use mapConfiguration.maxBounds instead
  final LatLngBounds? maxBounds;

  /// **DEPRECATED** - Use mapConfiguration.mapAnimationDuration instead
  final Duration? mapAnimationDuration;

  /// **DEPRECATED** - Use mapConfiguration.mapLoadingBackgroundColor instead
  final Color? mapLoadingBackgroundColor;

  /// **DEPRECATED** - Use controlsConfiguration.showZoomController instead
  final bool? showZoomController;

  /// **DEPRECATED** - Use controlsConfiguration.showLocationController instead
  final bool? showLocationController;

  /// **DEPRECATED** - Use selectButtonConfiguration.showSelectLocationButton instead
  final bool? showSelectLocationButton;

  /// **DEPRECATED** - Use searchConfiguration.showSearchBar instead
  final bool? showSearchBar;

  /// **DEPRECATED** - Use attributionConfiguration.showContributorBadgeForOSM instead
  final bool? showContributorBadgeForOSM;

  /// **DEPRECATED** - Use selectButtonConfiguration.selectLocationButtonText instead
  final String? selectLocationButtonText;

  /// **DEPRECATED** - Use selectButtonConfiguration.selectLocationButtonLeadingIcon instead
  final Widget? selectLocationButtonLeadingIcon;

  /// **DEPRECATED** - Use selectButtonConfiguration.selectLocationButtonStyle instead
  final ButtonStyle? selectLocationButtonStyle;

  /// **DEPRECATED** - Use selectButtonConfiguration.selectLocationButtonWidth instead
  final double? selectLocationButtonWidth;

  /// **DEPRECATED** - Use selectButtonConfiguration.selectLocationButtonHeight instead
  final double? selectLocationButtonHeight;

  /// **DEPRECATED** - Use selectButtonConfiguration.selectedLocationButtonTextStyle instead
  final TextStyle? selectedLocationButtonTextStyle;

  /// **DEPRECATED** - Use selectButtonConfiguration positioning instead
  final double? selectLocationButtonPositionTop;
  final double? selectLocationButtonPositionRight;
  final double? selectLocationButtonPositionLeft;
  final double? selectLocationButtonPositionBottom;

  /// **DEPRECATED** - Use searchConfiguration properties instead
  final Color? searchBarBackgroundColor;
  final Color? searchBarTextColor;
  final String? searchBarHintText;
  final Color? searchBarHintColor;
  final OutlineInputBorder? searchbarInputBorder;
  final OutlineInputBorder? searchbarInputFocusBorderp;
  final BorderRadiusGeometry? searchbarBorderRadius;
  final Duration? searchbarDebounceDuration;
  final int? maxSearchResults;

  /// **DEPRECATED** - Use controlsConfiguration properties instead
  final Color? zoomButtonsColor;
  final Color? zoomButtonsBackgroundColor;
  final Color? locationButtonsColor;
  final Color? locationButtonBackgroundColor;
  final double? zoomButtonsSize;
  final double? locationButtonSize;
  final double? controlButtonsSpacing;
  final EdgeInsets? controlButtonsPadding;

  /// **DEPRECATED** - Use markerConfiguration properties instead
  final Widget? markerIcon;
  final double? markerIconOffset;
  final bool? animateMarker;
  final Duration? markerAnimationDuration;

  /// **DEPRECATED** - Use attributionConfiguration properties instead
  final Color? contributorBadgeForOSMColor;
  final Color? contributorBadgeForOSMTextColor;
  final String? contributorBadgeForOSMText;
  final double? contributorBadgeForOSMPositionTop;
  final double? contributorBadgeForOSMPositionLeft;
  final double? contributorBadgeForOSMPositionRight;
  final double? contributorBadgeForOSMPositionBottom;

  /// **DEPRECATED** - Use mapConfiguration properties instead
  final TileProvider? customTileProvider;
  final Map<String, String>? tileRequestHeaders;

  /// Creates a FlutterLocationPicker with individual parameters (legacy constructor)
  ///
  /// **Note**: This constructor is maintained for backward compatibility.
  /// Consider using `FlutterLocationPicker.withConfiguration()` for new projects.
  const FlutterLocationPicker({
    super.key,
    // Required parameters
    required this.onPicked,
    required this.userAgent,

    // Core configuration
    this.onChanged,
    this.onError,
    this.initPosition,
    this.trackMyPosition = false,
    this.showCurrentLocationPointer = true,

    // Nominatim configuration
    this.nominatimHost = 'nominatim.openstreetmap.org',
    this.nominatimAdditionalQueryParameters,
    this.nominatimZoomLevel,
    this.countryFilter,

    // Configuration classes
    this.mapConfiguration,
    this.searchConfiguration,
    this.controlsConfiguration,
    this.markerConfiguration,
    this.selectButtonConfiguration,
    this.attributionConfiguration,

    // Advanced customization
    Widget? loadingWidget,
    this.mapLayers = const [],
    this.onMapTap,
    this.onMapReady,

    // Legacy parameters (deprecated)
    this.urlTemplate,
    this.mapLanguage,
    this.initZoom,
    this.stepZoom,
    this.minZoomLevel,
    this.maxZoomLevel,
    this.maxBounds,
    this.mapAnimationDuration,
    this.mapLoadingBackgroundColor,
    this.showZoomController,
    this.showLocationController,
    this.showSelectLocationButton,
    this.showSearchBar,
    this.showContributorBadgeForOSM,
    this.selectLocationButtonText,
    this.selectLocationButtonLeadingIcon,
    this.selectLocationButtonStyle,
    this.selectLocationButtonWidth,
    this.selectLocationButtonHeight,
    this.selectedLocationButtonTextStyle,
    this.selectLocationButtonPositionTop,
    this.selectLocationButtonPositionRight,
    this.selectLocationButtonPositionLeft,
    this.selectLocationButtonPositionBottom,
    this.searchBarBackgroundColor,
    this.searchBarTextColor,
    this.searchBarHintText,
    this.searchBarHintColor,
    this.searchbarInputBorder,
    this.searchbarInputFocusBorderp,
    this.searchbarBorderRadius,
    this.searchbarDebounceDuration,
    this.maxSearchResults,
    this.zoomButtonsColor,
    this.zoomButtonsBackgroundColor,
    this.locationButtonsColor,
    this.locationButtonBackgroundColor,
    this.zoomButtonsSize,
    this.locationButtonSize,
    this.controlButtonsSpacing,
    this.controlButtonsPadding,
    this.markerIcon,
    this.markerIconOffset,
    this.animateMarker,
    this.markerAnimationDuration,
    this.contributorBadgeForOSMColor,
    this.contributorBadgeForOSMTextColor,
    this.contributorBadgeForOSMText,
    this.contributorBadgeForOSMPositionTop,
    this.contributorBadgeForOSMPositionLeft,
    this.contributorBadgeForOSMPositionRight,
    this.contributorBadgeForOSMPositionBottom,
    this.customTileProvider,
    this.tileRequestHeaders,
  }) : loadingWidget = loadingWidget ?? const CircularProgressIndicator();

  /// Creates a FlutterLocationPicker using configuration classes (recommended)
  ///
  /// This constructor provides a cleaner, more organized way to configure
  /// the location picker using dedicated configuration classes for each
  /// component. This approach is recommended for new projects.
  ///
  /// ## Example:
  /// ```dart
  /// FlutterLocationPicker.withConfiguration(
  ///   userAgent: 'MyApp/1.0',
  ///   onPicked: (pickedData) => handleSelection(pickedData),
  ///   mapConfiguration: MapConfiguration(
  ///     initZoom: 15,
  ///     stepZoom: 2,
  ///     mapLanguage: 'es',
  ///   ),
  ///   controlsConfiguration: ControlsConfiguration(
  ///     zoomInIcon: Icons.add_circle,
  ///     zoomOutIcon: Icons.remove_circle,
  ///     zoomButtonsColor: Colors.white,
  ///     zoomButtonsBackgroundColor: Colors.indigo,
  ///     buttonElevation: 8.0,
  ///     buttonShape: RoundedRectangleBorder(
  ///       borderRadius: BorderRadius.circular(15),
  ///     ),
  ///   ),
  /// )
  /// ```
  const FlutterLocationPicker.withConfiguration({
    super.key,
    // Required parameters
    required this.onPicked,
    required this.userAgent,

    // Core configuration
    this.onChanged,
    this.onError,
    this.initPosition,
    this.trackMyPosition = false,
    this.showCurrentLocationPointer = true,

    // Nominatim configuration
    this.nominatimHost = 'nominatim.openstreetmap.org',
    this.nominatimAdditionalQueryParameters,
    this.nominatimZoomLevel,
    this.countryFilter,

    // Configuration classes
    this.mapConfiguration,
    this.searchConfiguration,
    this.controlsConfiguration,
    this.markerConfiguration,
    this.selectButtonConfiguration,
    this.attributionConfiguration,

    // Advanced customization
    Widget? loadingWidget,
    this.mapLayers = const [],
    this.onMapTap,
    this.onMapReady,
  }) :
    // Set all legacy parameters to null
    loadingWidget = loadingWidget ?? const CircularProgressIndicator(),
    urlTemplate = null,
    mapLanguage = null,
    initZoom = null,
    stepZoom = null,
    minZoomLevel = null,
    maxZoomLevel = null,
    maxBounds = null,
    mapAnimationDuration = null,
    mapLoadingBackgroundColor = null,
    showZoomController = null,
    showLocationController = null,
    showSelectLocationButton = null,
    showSearchBar = null,
    showContributorBadgeForOSM = null,
    selectLocationButtonText = null,
    selectLocationButtonLeadingIcon = null,
    selectLocationButtonStyle = null,
    selectLocationButtonWidth = null,
    selectLocationButtonHeight = null,
    selectedLocationButtonTextStyle = null,
    selectLocationButtonPositionTop = null,
    selectLocationButtonPositionRight = null,
    selectLocationButtonPositionLeft = null,
    selectLocationButtonPositionBottom = null,
    searchBarBackgroundColor = null,
    searchBarTextColor = null,
    searchBarHintText = null,
    searchBarHintColor = null,
    searchbarInputBorder = null,
    searchbarInputFocusBorderp = null,
    searchbarBorderRadius = null,
    searchbarDebounceDuration = null,
    maxSearchResults = null,
    zoomButtonsColor = null,
    zoomButtonsBackgroundColor = null,
    locationButtonsColor = null,
    locationButtonBackgroundColor = null,
    zoomButtonsSize = null,
    locationButtonSize = null,
    controlButtonsSpacing = null,
    controlButtonsPadding = null,
    markerIcon = null,
    markerIconOffset = null,
    animateMarker = null,
    markerAnimationDuration = null,
    contributorBadgeForOSMColor = null,
    contributorBadgeForOSMTextColor = null,
    contributorBadgeForOSMText = null,
    contributorBadgeForOSMPositionTop = null,
    contributorBadgeForOSMPositionLeft = null,
    contributorBadgeForOSMPositionRight = null,
    contributorBadgeForOSMPositionBottom = null,
    customTileProvider = null,
    tileRequestHeaders = null;

  @override
  State<FlutterLocationPicker> createState() => _FlutterLocationPickerState();
}

class _FlutterLocationPickerState extends State<FlutterLocationPicker>
    with TickerProviderStateMixin {
  // Controllers and services
  late final MapController _mapController;
  late final AnimationController _animationController;
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final GeocodingService _geocodingService;
  late final Debouncer _searchDebouncer;
  late final void Function(Exception e) _onError;

  // Resolved configuration objects
  late final MapConfiguration _mapConfig;
  late final SearchConfiguration _searchConfig;
  late final ControlsConfiguration _controlsConfig;
  late final MarkerConfiguration _markerConfig;
  late final SelectButtonConfiguration _selectButtonConfig;
  late final AttributionConfiguration _attributionConfig;

  // State variables
  List<OSMdata> _searchOptions = <OSMdata>[];
  LatLong _currentPosition = const LatLong(30.0443879, 31.2357257);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveConfigurations();
    _initializeControllers();
    _initializeServices();
    _setupMapEventListeners();
    _initializeLocation();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// Resolves configuration objects by merging user-provided configs with legacy parameters
  void _resolveConfigurations() {
    // Resolve MapConfiguration
    _mapConfig = widget.mapConfiguration?.copyWith(
      urlTemplate: widget.urlTemplate,
      mapLanguage: widget.mapLanguage,
      initZoom: widget.initZoom,
      stepZoom: widget.stepZoom,
      minZoomLevel: widget.minZoomLevel,
      maxZoomLevel: widget.maxZoomLevel,
      maxBounds: widget.maxBounds,
      mapAnimationDuration: widget.mapAnimationDuration,
      mapLoadingBackgroundColor: widget.mapLoadingBackgroundColor,
      customTileProvider: widget.customTileProvider,
      tileRequestHeaders: widget.tileRequestHeaders,
    ) ?? MapConfiguration(
      urlTemplate: widget.urlTemplate ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      mapLanguage: widget.mapLanguage ?? 'en',
      initZoom: widget.initZoom ?? 17,
      stepZoom: widget.stepZoom ?? 1,
      minZoomLevel: widget.minZoomLevel ?? 2,
      maxZoomLevel: widget.maxZoomLevel ?? 18.4,
      maxBounds: widget.maxBounds,
      mapAnimationDuration: widget.mapAnimationDuration ?? const Duration(milliseconds: 2000),
      mapLoadingBackgroundColor: widget.mapLoadingBackgroundColor,
      customTileProvider: widget.customTileProvider,
      tileRequestHeaders: widget.tileRequestHeaders,
    );

    // Resolve SearchConfiguration
    _searchConfig = widget.searchConfiguration?.copyWith(
      showSearchBar: widget.showSearchBar,
      searchBarBackgroundColor: widget.searchBarBackgroundColor,
      searchBarTextColor: widget.searchBarTextColor,
      searchBarHintText: widget.searchBarHintText,
      searchBarHintColor: widget.searchBarHintColor,
      searchbarInputBorder: widget.searchbarInputBorder,
      searchbarInputFocusBorder: widget.searchbarInputFocusBorderp,
      searchbarBorderRadius: widget.searchbarBorderRadius,
      searchbarDebounceDuration: widget.searchbarDebounceDuration,
      maxSearchResults: widget.maxSearchResults,
    ) ?? SearchConfiguration(
      showSearchBar: widget.showSearchBar ?? true,
      searchBarBackgroundColor: widget.searchBarBackgroundColor,
      searchBarTextColor: widget.searchBarTextColor,
      searchBarHintText: widget.searchBarHintText ?? 'Search location',
      searchBarHintColor: widget.searchBarHintColor,
      searchbarInputBorder: widget.searchbarInputBorder,
      searchbarInputFocusBorder: widget.searchbarInputFocusBorderp,
      searchbarBorderRadius: widget.searchbarBorderRadius,
      searchbarDebounceDuration: widget.searchbarDebounceDuration,
      maxSearchResults: widget.maxSearchResults ?? 5,
    );

    // Resolve ControlsConfiguration
    _controlsConfig = widget.controlsConfiguration?.copyWith(
      showZoomController: widget.showZoomController,
      showLocationController: widget.showLocationController,
      zoomButtonsColor: widget.zoomButtonsColor,
      zoomButtonsBackgroundColor: widget.zoomButtonsBackgroundColor,
      locationButtonsColor: widget.locationButtonsColor,
      locationButtonBackgroundColor: widget.locationButtonBackgroundColor,
      zoomButtonsSize: widget.zoomButtonsSize,
      locationButtonSize: widget.locationButtonSize,
      controlButtonsSpacing: widget.controlButtonsSpacing,
      controlButtonsPadding: widget.controlButtonsPadding,
    ) ?? ControlsConfiguration(
      showZoomController: widget.showZoomController ?? true,
      showLocationController: widget.showLocationController ?? true,
      zoomButtonsColor: widget.zoomButtonsColor,
      zoomButtonsBackgroundColor: widget.zoomButtonsBackgroundColor,
      locationButtonsColor: widget.locationButtonsColor,
      locationButtonBackgroundColor: widget.locationButtonBackgroundColor,
      zoomButtonsSize: widget.zoomButtonsSize,
      locationButtonSize: widget.locationButtonSize,
      controlButtonsSpacing: widget.controlButtonsSpacing ?? 16.0,
      controlButtonsPadding: widget.controlButtonsPadding ?? const EdgeInsets.all(16.0),
    );

    // Resolve MarkerConfiguration
    _markerConfig = widget.markerConfiguration?.copyWith(
      markerIcon: widget.markerIcon,
      markerIconOffset: widget.markerIconOffset,
      animateMarker: widget.animateMarker,
      markerAnimationDuration: widget.markerAnimationDuration,
    ) ?? MarkerConfiguration(
      markerIcon: widget.markerIcon,
      markerIconOffset: widget.markerIconOffset ?? 50.0,
      animateMarker: widget.animateMarker ?? true,
      markerAnimationDuration: widget.markerAnimationDuration ?? const Duration(milliseconds: 200),
    );

    // Resolve SelectButtonConfiguration
    _selectButtonConfig = widget.selectButtonConfiguration?.copyWith(
      showSelectLocationButton: widget.showSelectLocationButton,
      selectLocationButtonText: widget.selectLocationButtonText,
      selectLocationButtonLeadingIcon: widget.selectLocationButtonLeadingIcon,
      selectLocationButtonStyle: widget.selectLocationButtonStyle,
      selectLocationButtonWidth: widget.selectLocationButtonWidth,
      selectLocationButtonHeight: widget.selectLocationButtonHeight,
      selectedLocationButtonTextStyle: widget.selectedLocationButtonTextStyle,
      selectLocationButtonPositionTop: widget.selectLocationButtonPositionTop,
      selectLocationButtonPositionRight: widget.selectLocationButtonPositionRight,
      selectLocationButtonPositionLeft: widget.selectLocationButtonPositionLeft,
      selectLocationButtonPositionBottom: widget.selectLocationButtonPositionBottom,
    ) ?? SelectButtonConfiguration(
      showSelectLocationButton: widget.showSelectLocationButton ?? true,
      selectLocationButtonText: widget.selectLocationButtonText ?? 'Set Current Location',
      selectLocationButtonLeadingIcon: widget.selectLocationButtonLeadingIcon,
      selectLocationButtonStyle: widget.selectLocationButtonStyle,
      selectLocationButtonWidth: widget.selectLocationButtonWidth,
      selectLocationButtonHeight: widget.selectLocationButtonHeight,
      selectedLocationButtonTextStyle: widget.selectedLocationButtonTextStyle ?? const TextStyle(fontSize: 20),
      selectLocationButtonPositionTop: widget.selectLocationButtonPositionTop,
      selectLocationButtonPositionRight: widget.selectLocationButtonPositionRight ?? 0,
      selectLocationButtonPositionLeft: widget.selectLocationButtonPositionLeft ?? 0,
      selectLocationButtonPositionBottom: widget.selectLocationButtonPositionBottom ?? 3,
    );

    // Resolve AttributionConfiguration
    _attributionConfig = widget.attributionConfiguration?.copyWith(
      showContributorBadgeForOSM: widget.showContributorBadgeForOSM,
      contributorBadgeForOSMColor: widget.contributorBadgeForOSMColor,
      contributorBadgeForOSMTextColor: widget.contributorBadgeForOSMTextColor,
      contributorBadgeForOSMText: widget.contributorBadgeForOSMText,
      contributorBadgeForOSMPositionTop: widget.contributorBadgeForOSMPositionTop,
      contributorBadgeForOSMPositionLeft: widget.contributorBadgeForOSMPositionLeft,
      contributorBadgeForOSMPositionRight: widget.contributorBadgeForOSMPositionRight,
      contributorBadgeForOSMPositionBottom: widget.contributorBadgeForOSMPositionBottom,
    ) ?? AttributionConfiguration(
      showContributorBadgeForOSM: widget.showContributorBadgeForOSM ?? false,
      contributorBadgeForOSMColor: widget.contributorBadgeForOSMColor,
      contributorBadgeForOSMTextColor: widget.contributorBadgeForOSMTextColor ?? Colors.blue,
      contributorBadgeForOSMText: widget.contributorBadgeForOSMText ?? 'OpenStreetMap contributors',
      contributorBadgeForOSMPositionTop: widget.contributorBadgeForOSMPositionTop,
      contributorBadgeForOSMPositionLeft: widget.contributorBadgeForOSMPositionLeft,
      contributorBadgeForOSMPositionRight: widget.contributorBadgeForOSMPositionRight ?? 0,
      contributorBadgeForOSMPositionBottom: widget.contributorBadgeForOSMPositionBottom ?? -6,
    );
  }

  /// Initializes controllers and focus nodes
  void _initializeControllers() {
    _mapController = MapController();
    _animationController = AnimationController(
      duration: _mapConfig.mapAnimationDuration,
      vsync: this,
    );
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  /// Initializes services
  void _initializeServices() {
    _geocodingService = GeocodingService(
      nominatimHost: widget.nominatimHost,
      userAgent: widget.userAgent,
      language: _mapConfig.mapLanguage,
      additionalQueryParameters: widget.nominatimAdditionalQueryParameters,
      countryFilter: widget.countryFilter,
    );

    _searchDebouncer = Debouncer(
      delay: _searchConfig.searchbarDebounceDuration ?? const Duration(milliseconds: 500),
    );

    _onError = widget.onError ?? (e) => debugPrint(e.toString());
  }

  /// Sets up map event listeners
  void _setupMapEventListeners() {
    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        final center = LatLong(
          event.camera.center.latitude,
          event.camera.center.longitude,
        );
        await _handleLocationChanged(center);
      }
    });
  }

  /// Initializes location based on settings
  void _initializeLocation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (widget.initPosition != null) {
          _currentPosition = widget.initPosition!;
          await _handleLocationChanged(_currentPosition);
          _setLoadingState(false);
        } else if (widget.trackMyPosition) {
          await _trackCurrentPosition();
        } else {
          await _handleLocationChanged(_currentPosition);
          _setLoadingState(false);
        }
      } catch (e) {
        _onError(e is Exception ? e : Exception(e.toString()));
        _setLoadingState(false);
      }
    });
  }

  /// Tracks current user position
  Future<void> _trackCurrentPosition() async {
    try {
      final permissionService = PermissionService(context);
      await permissionService.checkAndRequestLocationPermission();

      final position = await LocationService.getCurrentPosition();
      _currentPosition = position;

      await _handleLocationChanged(_currentPosition);
      _animateToLocation(_currentPosition.toLatLng(), 18.0);
    } catch (e) {
      _onError(e is Exception ? e : Exception(e.toString()));
    } finally {
      _setLoadingState(false);
    }
  }

  /// Handles location changes and updates address
  Future<void> _handleLocationChanged(LatLong latLng, {String? address}) async {
    try {
      final pickedData = await _geocodingService.reverseGeocode(
        latLng,
        zoomLevel: widget.nominatimZoomLevel,
      );

      if (widget.onChanged != null) {
        widget.onChanged!(pickedData);
      }

      _searchController.text = address ?? pickedData.address;
      if (mounted) setState(() {});
    } catch (e) {
      _onError(e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Animates map to specified location
  void _animateToLocation(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    if (mounted) {
      _animationController.reset();

      final animation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      );

      _animationController.addListener(() {
        _mapController.move(
          LatLng(
            latTween.evaluate(animation),
            lngTween.evaluate(animation),
          ),
          zoomTween.evaluate(animation),
        );
      });

      _animationController.forward();
    }
  }

  /// Sets loading state safely
  void _setLoadingState(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// Handles search input changes
  void _handleSearchInput(String value) {
    if (mounted) setState(() {});

    _searchDebouncer(() async {
      if (value.trim().isEmpty) {
        _searchOptions.clear();
        if (mounted) setState(() {});
        return;
      }

      try {
        final results = await _geocodingService.searchLocations(value);
        _searchOptions = results;
        if (mounted) setState(() {});
      } catch (e) {
        _onError(e is Exception ? e : Exception(e.toString()));
      }
    });
  }

  /// Handles search result selection
  void _handleSearchResultTap(OSMdata selectedLocation) {
    final center = LatLong(selectedLocation.latitude, selectedLocation.longitude);
    _animateToLocation(center.toLatLng(), 18.0);
    _handleLocationChanged(
      center,
      address: selectedLocation.displayname,
    );
    _focusNode.unfocus();
    _searchOptions.clear();
    setState(() {});
  }

  /// Handles location button press
  Future<void> _handleLocationButtonPress() async {
    try {
      final permissionService = PermissionService(context);
      await permissionService.checkAndRequestLocationPermission();

      final position = await LocationService.getCurrentPosition();
      _animateToLocation(position.toLatLng(), 18);
      await _handleLocationChanged(position);
    } catch (e) {
      _onError(e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Handles select location button press
  Future<void> _handleSelectLocationPress() async {
    _setLoadingState(true);

    try {
      final center = LatLong(
        _mapController.camera.center.latitude,
        _mapController.camera.center.longitude,
      );
      final pickedData = await _geocodingService.reverseGeocode(center);
      widget.onPicked(pickedData);
    } catch (e) {
      _onError(e is Exception ? e : Exception(e.toString()));
    } finally {
      _setLoadingState(false);
    }
  }

  /// Disposes controllers and services
  void _disposeControllers() {
    _mapController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _searchDebouncer.dispose();
  }

  /// Checks if text is RTL
  bool _isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchOptions.length > _searchConfig.maxSearchResults
          ? _searchConfig.maxSearchResults
          : _searchOptions.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: _searchConfig.searchResultItemHeight,
          child: ListTile(
            leading: Icon(
              _searchConfig.searchResultIcon,
              color: _searchConfig.searchResultIconColor ?? _searchConfig.searchBarTextColor,
            ),
            title: Text(
              _searchOptions[index].displayname,
              style: TextStyle(color: _searchConfig.searchBarTextColor),
            ),
            onTap: () {
              _handleSearchResultTap(_searchOptions[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    if (!_searchConfig.showSearchBar) return const SizedBox.shrink();

    final inputBorder = _searchConfig.searchbarInputBorder ??
        OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        );
    final inputFocusBorder = _searchConfig.searchbarInputFocusBorder ??
        OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
        );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: _searchConfig.searchBarMargin,
        padding: _searchConfig.searchBarPadding,
        decoration: BoxDecoration(
          color: _searchConfig.searchBarBackgroundColor ??
              Theme.of(context).colorScheme.surface,
          borderRadius: _searchConfig.searchbarBorderRadius ?? BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            TextFormField(
              textDirection: _isRTL(_searchController.text)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: TextStyle(color: _searchConfig.searchBarTextColor),
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _searchConfig.searchBarHintText,
                hintTextDirection: _isRTL(_searchConfig.searchBarHintText)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                border: inputBorder,
                focusedBorder: inputFocusBorder,
                hintStyle: TextStyle(color: _searchConfig.searchBarHintColor),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchOptions.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    color: _searchConfig.searchBarTextColor,
                  ),
                ),
              ),
              onChanged: _handleSearchInput,
            ),
            if (_searchOptions.isNotEmpty) _buildListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildControllerButtons() {
    return PositionedDirectional(
      bottom: _controlsConfig.controlButtonsBottom,
      end: _controlsConfig.controlButtonsEnd,
      child: Padding(
        padding: _controlsConfig.controlButtonsPadding,
        child: Column(
          children: [
            if (_controlsConfig.showZoomController) ...[
              _buildZoomButton(
                icon: _controlsConfig.zoomInIcon,
                onPressed: () {
                  _animateToLocation(
                    _mapController.camera.center,
                    _mapController.camera.zoom + _mapConfig.stepZoom,
                  );
                },
                heroTag: "zoom_in",
              ),
              SizedBox(height: _controlsConfig.controlButtonsSpacing),
              _buildZoomButton(
                icon: _controlsConfig.zoomOutIcon,
                onPressed: () {
                  _animateToLocation(
                    _mapController.camera.center,
                    _mapController.camera.zoom - _mapConfig.stepZoom,
                  );
                },
                heroTag: "zoom_out",
              ),
              SizedBox(height: _controlsConfig.controlButtonsSpacing + 6),
            ],
            if (_controlsConfig.showLocationController)
              _buildLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return SizedBox(
      width: _controlsConfig.zoomButtonsSize,
      height: _controlsConfig.zoomButtonsSize,
      child: FloatingActionButton(
        heroTag: heroTag,
        elevation: _controlsConfig.showButtonShadow ? _controlsConfig.buttonElevation : 0,
        shape: _controlsConfig.buttonShape ?? const CircleBorder(),
        backgroundColor: _controlsConfig.zoomButtonsBackgroundColor,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: _controlsConfig.zoomButtonsColor,
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return SizedBox(
      width: _controlsConfig.locationButtonSize,
      height: _controlsConfig.locationButtonSize,
      child: FloatingActionButton(
        heroTag: "location",
        elevation: _controlsConfig.showButtonShadow ? _controlsConfig.buttonElevation : 0,
        shape: _controlsConfig.buttonShape ?? const CircleBorder(),
        backgroundColor: _controlsConfig.locationButtonBackgroundColor,
        onPressed: _handleLocationButtonPress,
        child: Icon(
          _controlsConfig.locationIcon,
          color: _controlsConfig.locationButtonsColor,
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Positioned.fill(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: widget.initPosition?.toLatLng() ?? _currentPosition.toLatLng(),
          initialZoom: _mapConfig.initZoom,
          maxZoom: _mapConfig.maxZoomLevel,
          minZoom: _mapConfig.minZoomLevel,
          cameraConstraint: (_mapConfig.maxBounds != null
              ? CameraConstraint.contain(bounds: _mapConfig.maxBounds!)
              : const CameraConstraint.unconstrained()),
          backgroundColor: _mapConfig.mapLoadingBackgroundColor ?? const Color(0xFFE0E0E0),
          keepAlive: true,
          onTap: widget.onMapTap != null
              ? (tapPosition, point) => widget.onMapTap!(point)
              : null,
        ),
        mapController: _mapController,
        children: [
          TileLayer(
            urlTemplate: _mapConfig.urlTemplate,
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: widget.userAgent,
            tileProvider: _mapConfig.customTileProvider ?? CancellableNetworkTileProvider(),
            additionalOptions: _mapConfig.tileRequestHeaders ?? {},
          ),
          if (widget.showCurrentLocationPointer) _buildCurrentLocation(),
          ...widget.mapLayers,
        ],
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return CurrentLocationLayer(
      style: const LocationMarkerStyle(
        markerDirection: MarkerDirection.heading,
        headingSectorRadius: 60,
        markerSize: Size(18, 18),
      ),
    );
  }

  Widget _buildMarker() {
    final markerWidget = _markerConfig.markerIcon ?? Icon(
      _markerConfig.defaultMarkerIcon,
      color: _markerConfig.defaultMarkerColor,
      size: _markerConfig.defaultMarkerSize,
    );

    Widget marker = markerWidget;

    if (_markerConfig.showMarkerShadow) {
      marker = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: _markerConfig.markerShadowColor ?? Colors.black26,
              blurRadius: _markerConfig.markerShadowBlurRadius,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: markerWidget,
      );
    }

    return Positioned.fill(
      bottom: _markerConfig.markerIconOffset,
      child: IgnorePointer(
        child: Center(child: marker),
      ),
    );
  }

  Widget _buildSelectButton() {
    if (!_selectButtonConfig.showSelectLocationButton) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: _selectButtonConfig.selectLocationButtonPositionTop,
      bottom: _selectButtonConfig.selectLocationButtonPositionBottom,
      left: _selectButtonConfig.selectLocationButtonPositionLeft,
      right: _selectButtonConfig.selectLocationButtonPositionRight,
      child: Center(
        child: Padding(
          padding: _selectButtonConfig.selectLocationButtonPadding,
          child: WideButton(
            _selectButtonConfig.selectLocationButtonText,
            leadingIcon: _selectButtonConfig.selectLocationButtonLeadingIcon,
            onPressed: _handleSelectLocationPress,
            style: _selectButtonConfig.selectLocationButtonStyle,
            textStyle: _selectButtonConfig.selectedLocationButtonTextStyle,
            width: _selectButtonConfig.selectLocationButtonWidth,
            height: _selectButtonConfig.selectLocationButtonHeight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Call onMapReady callback if map is loaded and callback exists
    if (!_isLoading && widget.onMapReady != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMapReady!();
      });
    }

    return Stack(
      children: [
        _buildMap(),
        if (!_isLoading) _buildMarker(),
        if (_isLoading) Center(child: widget.loadingWidget!),
        SafeArea(
          child: Stack(
            children: [
              _buildControllerButtons(),
              _buildSearchBar(),
              if (_attributionConfig.showContributorBadgeForOSM) ...[
                Positioned(
                  top: _attributionConfig.contributorBadgeForOSMPositionTop,
                  bottom: _attributionConfig.contributorBadgeForOSMPositionBottom,
                  left: _attributionConfig.contributorBadgeForOSMPositionLeft,
                  right: _attributionConfig.contributorBadgeForOSMPositionRight,
                  child: CopyrightOSMWidget(
                    badgeText: _attributionConfig.contributorBadgeForOSMText,
                    badgeTextColor: _attributionConfig.contributorBadgeForOSMTextColor,
                    badgeColor: _attributionConfig.contributorBadgeForOSMColor,
                  ),
                ),
              ],
              _buildSelectButton(),
            ],
          ),
        )
      ],
    );
  }
}
