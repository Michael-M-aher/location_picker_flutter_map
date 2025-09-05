import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Configuration class for map styling and behavior
///
/// This class centralizes all map-related settings including tiles,
/// zoom levels, animations, and visual appearance.
class MapConfiguration {
  /// URL template for map tiles
  ///
  /// **Default**: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
  final String urlTemplate;

  /// Initial zoom level when map loads
  ///
  /// **Default**: 17.0
  final double initZoom;

  /// Zoom step for zoom in/out buttons
  ///
  /// **Default**: 1.0
  final double stepZoom;

  /// Minimum allowed zoom level
  ///
  /// **Default**: 2.0
  final double minZoomLevel;

  /// Maximum allowed zoom level
  ///
  /// **Default**: 18.4
  final double maxZoomLevel;

  /// Duration for map animations
  ///
  /// **Default**: 2000 milliseconds
  final Duration mapAnimationDuration;

  /// Background color while map tiles load
  final Color? mapLoadingBackgroundColor;

  /// Geographic bounds to restrict map movement
  final LatLngBounds? maxBounds;

  /// Custom tile provider
  final TileProvider? customTileProvider;

  /// HTTP headers for tile requests
  final Map<String, String>? tileRequestHeaders;

  /// Language code for map labels
  ///
  /// **Default**: 'en'
  final String mapLanguage;

  const MapConfiguration({
    this.urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.initZoom = 17,
    this.stepZoom = 1,
    this.minZoomLevel = 2,
    this.maxZoomLevel = 18.4,
    this.mapAnimationDuration = const Duration(milliseconds: 2000),
    this.mapLoadingBackgroundColor,
    this.maxBounds,
    this.customTileProvider,
    this.tileRequestHeaders,
    this.mapLanguage = 'en',
  });

  MapConfiguration copyWith({
    String? urlTemplate,
    double? initZoom,
    double? stepZoom,
    double? minZoomLevel,
    double? maxZoomLevel,
    Duration? mapAnimationDuration,
    Color? mapLoadingBackgroundColor,
    LatLngBounds? maxBounds,
    TileProvider? customTileProvider,
    Map<String, String>? tileRequestHeaders,
    String? mapLanguage,
  }) {
    return MapConfiguration(
      urlTemplate: urlTemplate ?? this.urlTemplate,
      initZoom: initZoom ?? this.initZoom,
      stepZoom: stepZoom ?? this.stepZoom,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      mapAnimationDuration: mapAnimationDuration ?? this.mapAnimationDuration,
      mapLoadingBackgroundColor:
          mapLoadingBackgroundColor ?? this.mapLoadingBackgroundColor,
      maxBounds: maxBounds ?? this.maxBounds,
      customTileProvider: customTileProvider ?? this.customTileProvider,
      tileRequestHeaders: tileRequestHeaders ?? this.tileRequestHeaders,
      mapLanguage: mapLanguage ?? this.mapLanguage,
    );
  }
}

/// Configuration class for search functionality
///
/// This class manages all aspects of the location search feature
/// including appearance, behavior, and performance settings.
class SearchConfiguration {
  /// Whether to show the search bar
  ///
  /// **Default**: true
  final bool showSearchBar;

  /// Placeholder text in search field
  ///
  /// **Default**: 'Search location'
  final String searchBarHintText;

  /// Background color of search container
  final Color? searchBarBackgroundColor;

  /// Text color for search input
  final Color? searchBarTextColor;

  /// Color of search hint text
  final Color? searchBarHintColor;

  /// Border radius for search bar container
  final BorderRadiusGeometry? searchbarBorderRadius;

  /// Delay before triggering search
  ///
  /// **Default**: 500 milliseconds
  final Duration? searchbarDebounceDuration;

  /// Maximum number of search results to display
  ///
  /// **Default**: 5
  final int maxSearchResults;

  /// Border style for search input
  final OutlineInputBorder? searchbarInputBorder;

  /// Border style when search input is focused
  final OutlineInputBorder? searchbarInputFocusBorder;

  /// Margin around search bar container
  ///
  /// **Default**: EdgeInsets.all(15)
  final EdgeInsets searchBarMargin;

  /// Padding inside search bar container
  ///
  /// **Default**: EdgeInsets.all(0)
  final EdgeInsets searchBarPadding;

  /// Height of each search result item
  ///
  /// **Default**: 56.0
  final double searchResultItemHeight;

  /// Icon for search results
  final IconData searchResultIcon;

  /// Icon color for search results
  final Color? searchResultIconColor;

  const SearchConfiguration({
    this.showSearchBar = true,
    this.searchBarHintText = 'Search location',
    this.searchBarBackgroundColor,
    this.searchBarTextColor,
    this.searchBarHintColor,
    this.searchbarBorderRadius,
    this.searchbarDebounceDuration,
    this.maxSearchResults = 5,
    this.searchbarInputBorder,
    this.searchbarInputFocusBorder,
    this.searchBarMargin = const EdgeInsets.all(15),
    this.searchBarPadding = const EdgeInsets.all(0),
    this.searchResultItemHeight = 56.0,
    this.searchResultIcon = Icons.location_on,
    this.searchResultIconColor,
  });

  SearchConfiguration copyWith({
    bool? showSearchBar,
    String? searchBarHintText,
    Color? searchBarBackgroundColor,
    Color? searchBarTextColor,
    Color? searchBarHintColor,
    BorderRadiusGeometry? searchbarBorderRadius,
    Duration? searchbarDebounceDuration,
    int? maxSearchResults,
    OutlineInputBorder? searchbarInputBorder,
    OutlineInputBorder? searchbarInputFocusBorder,
    EdgeInsets? searchBarMargin,
    EdgeInsets? searchBarPadding,
    double? searchResultItemHeight,
    IconData? searchResultIcon,
    Color? searchResultIconColor,
  }) {
    return SearchConfiguration(
      showSearchBar: showSearchBar ?? this.showSearchBar,
      searchBarHintText: searchBarHintText ?? this.searchBarHintText,
      searchBarBackgroundColor:
          searchBarBackgroundColor ?? this.searchBarBackgroundColor,
      searchBarTextColor: searchBarTextColor ?? this.searchBarTextColor,
      searchBarHintColor: searchBarHintColor ?? this.searchBarHintColor,
      searchbarBorderRadius:
          searchbarBorderRadius ?? this.searchbarBorderRadius,
      searchbarDebounceDuration:
          searchbarDebounceDuration ?? this.searchbarDebounceDuration,
      maxSearchResults: maxSearchResults ?? this.maxSearchResults,
      searchbarInputBorder: searchbarInputBorder ?? this.searchbarInputBorder,
      searchbarInputFocusBorder:
          searchbarInputFocusBorder ?? this.searchbarInputFocusBorder,
      searchBarMargin: searchBarMargin ?? this.searchBarMargin,
      searchBarPadding: searchBarPadding ?? this.searchBarPadding,
      searchResultItemHeight:
          searchResultItemHeight ?? this.searchResultItemHeight,
      searchResultIcon: searchResultIcon ?? this.searchResultIcon,
      searchResultIconColor:
          searchResultIconColor ?? this.searchResultIconColor,
    );
  }
}

/// Configuration class for control buttons
///
/// This class provides comprehensive customization for all map control
/// buttons including zoom controls and location button.
class ControlsConfiguration {
  /// Whether to show zoom control buttons
  ///
  /// **Default**: true
  final bool showZoomController;

  /// Whether to show location/GPS button
  ///
  /// **Default**: true
  final bool showLocationController;

  /// Icon color for zoom control buttons
  final Color? zoomButtonsColor;

  /// Background color for zoom control buttons
  final Color? zoomButtonsBackgroundColor;

  /// Icon color for location/GPS button
  final Color? locationButtonsColor;

  /// Background color for location/GPS button
  final Color? locationButtonBackgroundColor;

  /// Size of zoom control buttons
  final double? zoomButtonsSize;

  /// Size of location/GPS button
  final double? locationButtonSize;

  /// Spacing between control buttons
  ///
  /// **Default**: 16.0
  final double controlButtonsSpacing;

  /// Padding around control buttons from screen edges
  ///
  /// **Default**: EdgeInsets.all(16.0)
  final EdgeInsets controlButtonsPadding;

  /// Custom zoom in icon
  ///
  /// **Default**: Icons.zoom_in
  final IconData zoomInIcon;

  /// Custom zoom out icon
  ///
  /// **Default**: Icons.zoom_out
  final IconData zoomOutIcon;

  /// Custom location icon
  ///
  /// **Default**: Icons.my_location
  final IconData locationIcon;

  /// Elevation for control buttons
  ///
  /// **Default**: 6.0
  final double buttonElevation;

  /// Shape for control buttons
  final ShapeBorder? buttonShape;

  /// Position of control buttons from bottom
  ///
  /// **Default**: 72.0
  final double controlButtonsBottom;

  /// Position of control buttons from end (right in LTR)
  ///
  /// **Default**: 16.0
  final double controlButtonsEnd;

  /// Whether buttons should have a shadow
  ///
  /// **Default**: true
  final bool showButtonShadow;

  /// Animation duration for button press
  ///
  /// **Default**: 100 milliseconds
  final Duration buttonAnimationDuration;

  const ControlsConfiguration({
    this.showZoomController = true,
    this.showLocationController = true,
    this.zoomButtonsColor,
    this.zoomButtonsBackgroundColor,
    this.locationButtonsColor,
    this.locationButtonBackgroundColor,
    this.zoomButtonsSize,
    this.locationButtonSize,
    this.controlButtonsSpacing = 16.0,
    this.controlButtonsPadding = const EdgeInsets.all(16.0),
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutIcon = Icons.zoom_out,
    this.locationIcon = Icons.my_location,
    this.buttonElevation = 6.0,
    this.buttonShape,
    this.controlButtonsBottom = 72.0,
    this.controlButtonsEnd = 16.0,
    this.showButtonShadow = true,
    this.buttonAnimationDuration = const Duration(milliseconds: 100),
  });

  ControlsConfiguration copyWith({
    bool? showZoomController,
    bool? showLocationController,
    Color? zoomButtonsColor,
    Color? zoomButtonsBackgroundColor,
    Color? locationButtonsColor,
    Color? locationButtonBackgroundColor,
    double? zoomButtonsSize,
    double? locationButtonSize,
    double? controlButtonsSpacing,
    EdgeInsets? controlButtonsPadding,
    IconData? zoomInIcon,
    IconData? zoomOutIcon,
    IconData? locationIcon,
    double? buttonElevation,
    ShapeBorder? buttonShape,
    double? controlButtonsBottom,
    double? controlButtonsEnd,
    bool? showButtonShadow,
    Duration? buttonAnimationDuration,
  }) {
    return ControlsConfiguration(
      showZoomController: showZoomController ?? this.showZoomController,
      showLocationController:
          showLocationController ?? this.showLocationController,
      zoomButtonsColor: zoomButtonsColor ?? this.zoomButtonsColor,
      zoomButtonsBackgroundColor:
          zoomButtonsBackgroundColor ?? this.zoomButtonsBackgroundColor,
      locationButtonsColor: locationButtonsColor ?? this.locationButtonsColor,
      locationButtonBackgroundColor:
          locationButtonBackgroundColor ?? this.locationButtonBackgroundColor,
      zoomButtonsSize: zoomButtonsSize ?? this.zoomButtonsSize,
      locationButtonSize: locationButtonSize ?? this.locationButtonSize,
      controlButtonsSpacing:
          controlButtonsSpacing ?? this.controlButtonsSpacing,
      controlButtonsPadding:
          controlButtonsPadding ?? this.controlButtonsPadding,
      zoomInIcon: zoomInIcon ?? this.zoomInIcon,
      zoomOutIcon: zoomOutIcon ?? this.zoomOutIcon,
      locationIcon: locationIcon ?? this.locationIcon,
      buttonElevation: buttonElevation ?? this.buttonElevation,
      buttonShape: buttonShape ?? this.buttonShape,
      controlButtonsBottom: controlButtonsBottom ?? this.controlButtonsBottom,
      controlButtonsEnd: controlButtonsEnd ?? this.controlButtonsEnd,
      showButtonShadow: showButtonShadow ?? this.showButtonShadow,
      buttonAnimationDuration:
          buttonAnimationDuration ?? this.buttonAnimationDuration,
    );
  }
}

/// Configuration class for the location marker
///
/// This class manages the appearance and behavior of the location
/// marker that indicates the selected position on the map.
class MarkerConfiguration {
  /// Custom widget to use as location marker
  final Widget? markerIcon;

  /// Vertical offset for marker from map center
  ///
  /// **Default**: 50.0
  final double markerIconOffset;

  /// Whether marker should animate when map moves
  ///
  /// **Default**: true
  final bool animateMarker;

  /// Duration for marker animations
  ///
  /// **Default**: 200 milliseconds
  final Duration markerAnimationDuration;

  /// Default marker color when no custom icon is provided
  ///
  /// **Default**: Colors.blue
  final Color defaultMarkerColor;

  /// Default marker size when no custom icon is provided
  ///
  /// **Default**: 50.0
  final double defaultMarkerSize;

  /// Default marker icon when no custom icon is provided
  ///
  /// **Default**: Icons.location_pin
  final IconData defaultMarkerIcon;

  /// Shadow for the marker
  ///
  /// **Default**: false
  final bool showMarkerShadow;

  /// Shadow color for the marker
  final Color? markerShadowColor;

  /// Shadow blur radius for the marker
  ///
  /// **Default**: 4.0
  final double markerShadowBlurRadius;

  const MarkerConfiguration({
    this.markerIcon,
    this.markerIconOffset = 50.0,
    this.animateMarker = true,
    this.markerAnimationDuration = const Duration(milliseconds: 200),
    this.defaultMarkerColor = Colors.blue,
    this.defaultMarkerSize = 50.0,
    this.defaultMarkerIcon = Icons.location_pin,
    this.showMarkerShadow = false,
    this.markerShadowColor,
    this.markerShadowBlurRadius = 4.0,
  });

  MarkerConfiguration copyWith({
    Widget? markerIcon,
    double? markerIconOffset,
    bool? animateMarker,
    Duration? markerAnimationDuration,
    Color? defaultMarkerColor,
    double? defaultMarkerSize,
    IconData? defaultMarkerIcon,
    bool? showMarkerShadow,
    Color? markerShadowColor,
    double? markerShadowBlurRadius,
  }) {
    return MarkerConfiguration(
      markerIcon: markerIcon ?? this.markerIcon,
      markerIconOffset: markerIconOffset ?? this.markerIconOffset,
      animateMarker: animateMarker ?? this.animateMarker,
      markerAnimationDuration:
          markerAnimationDuration ?? this.markerAnimationDuration,
      defaultMarkerColor: defaultMarkerColor ?? this.defaultMarkerColor,
      defaultMarkerSize: defaultMarkerSize ?? this.defaultMarkerSize,
      defaultMarkerIcon: defaultMarkerIcon ?? this.defaultMarkerIcon,
      showMarkerShadow: showMarkerShadow ?? this.showMarkerShadow,
      markerShadowColor: markerShadowColor ?? this.markerShadowColor,
      markerShadowBlurRadius:
          markerShadowBlurRadius ?? this.markerShadowBlurRadius,
    );
  }
}

/// Configuration class for the select location button
///
/// This class manages all aspects of the button used to confirm
/// the selected location.
class SelectButtonConfiguration {
  /// Whether to show the select location button
  ///
  /// **Default**: true
  final bool showSelectLocationButton;

  /// Text displayed on the button
  ///
  /// **Default**: 'Set Current Location'
  final String selectLocationButtonText;

  /// Icon displayed before the button text
  final Widget? selectLocationButtonLeadingIcon;

  /// Custom styling for the button
  final ButtonStyle? selectLocationButtonStyle;

  /// Fixed width for the button
  final double? selectLocationButtonWidth;

  /// Fixed height for the button
  ///
  /// **Default**: 45.0
  final double? selectLocationButtonHeight;

  /// Text style for the button
  ///
  /// **Default**: TextStyle(fontSize: 20)
  final TextStyle selectedLocationButtonTextStyle;

  /// Distance from top of screen
  final double? selectLocationButtonPositionTop;

  /// Distance from right edge of screen
  ///
  /// **Default**: 0
  final double? selectLocationButtonPositionRight;

  /// Distance from left edge of screen
  ///
  /// **Default**: 0
  final double? selectLocationButtonPositionLeft;

  /// Distance from bottom of screen
  ///
  /// **Default**: 3
  final double? selectLocationButtonPositionBottom;

  /// Padding around the button
  ///
  /// **Default**: EdgeInsets.all(8.0)
  final EdgeInsets selectLocationButtonPadding;

  /// Animation duration for button press
  ///
  /// **Default**: 150 milliseconds
  final Duration buttonAnimationDuration;

  const SelectButtonConfiguration({
    this.showSelectLocationButton = true,
    this.selectLocationButtonText = 'Set Current Location',
    this.selectLocationButtonLeadingIcon,
    this.selectLocationButtonStyle,
    this.selectLocationButtonWidth,
    this.selectLocationButtonHeight,
    this.selectedLocationButtonTextStyle = const TextStyle(fontSize: 20),
    this.selectLocationButtonPositionTop,
    this.selectLocationButtonPositionRight = 0,
    this.selectLocationButtonPositionLeft = 0,
    this.selectLocationButtonPositionBottom = 3,
    this.selectLocationButtonPadding = const EdgeInsets.all(8.0),
    this.buttonAnimationDuration = const Duration(milliseconds: 150),
  });

  SelectButtonConfiguration copyWith({
    bool? showSelectLocationButton,
    String? selectLocationButtonText,
    Widget? selectLocationButtonLeadingIcon,
    ButtonStyle? selectLocationButtonStyle,
    double? selectLocationButtonWidth,
    double? selectLocationButtonHeight,
    TextStyle? selectedLocationButtonTextStyle,
    double? selectLocationButtonPositionTop,
    double? selectLocationButtonPositionRight,
    double? selectLocationButtonPositionLeft,
    double? selectLocationButtonPositionBottom,
    EdgeInsets? selectLocationButtonPadding,
    Duration? buttonAnimationDuration,
  }) {
    return SelectButtonConfiguration(
      showSelectLocationButton:
          showSelectLocationButton ?? this.showSelectLocationButton,
      selectLocationButtonText:
          selectLocationButtonText ?? this.selectLocationButtonText,
      selectLocationButtonLeadingIcon: selectLocationButtonLeadingIcon ??
          this.selectLocationButtonLeadingIcon,
      selectLocationButtonStyle:
          selectLocationButtonStyle ?? this.selectLocationButtonStyle,
      selectLocationButtonWidth:
          selectLocationButtonWidth ?? this.selectLocationButtonWidth,
      selectLocationButtonHeight:
          selectLocationButtonHeight ?? this.selectLocationButtonHeight,
      selectedLocationButtonTextStyle: selectedLocationButtonTextStyle ??
          this.selectedLocationButtonTextStyle,
      selectLocationButtonPositionTop: selectLocationButtonPositionTop ??
          this.selectLocationButtonPositionTop,
      selectLocationButtonPositionRight: selectLocationButtonPositionRight ??
          this.selectLocationButtonPositionRight,
      selectLocationButtonPositionLeft: selectLocationButtonPositionLeft ??
          this.selectLocationButtonPositionLeft,
      selectLocationButtonPositionBottom: selectLocationButtonPositionBottom ??
          this.selectLocationButtonPositionBottom,
      selectLocationButtonPadding:
          selectLocationButtonPadding ?? this.selectLocationButtonPadding,
      buttonAnimationDuration:
          buttonAnimationDuration ?? this.buttonAnimationDuration,
    );
  }
}

/// Configuration class for OpenStreetMap attribution
///
/// This class manages the OSM contributor badge that can be
/// displayed to credit OpenStreetMap contributors.
class AttributionConfiguration {
  /// Whether to show OpenStreetMap attribution badge
  ///
  /// **Default**: false
  final bool showContributorBadgeForOSM;

  /// Background color for attribution badge
  final Color? contributorBadgeForOSMColor;

  /// Text color for attribution badge
  ///
  /// **Default**: Colors.blue
  final Color contributorBadgeForOSMTextColor;

  /// Text displayed in attribution badge
  ///
  /// **Default**: 'OpenStreetMap contributors'
  final String contributorBadgeForOSMText;

  /// Distance from top of screen
  final double? contributorBadgeForOSMPositionTop;

  /// Distance from left edge
  final double? contributorBadgeForOSMPositionLeft;

  /// Distance from right edge
  ///
  /// **Default**: 0
  final double? contributorBadgeForOSMPositionRight;

  /// Distance from bottom of screen
  ///
  /// **Default**: -6
  final double? contributorBadgeForOSMPositionBottom;

  const AttributionConfiguration({
    this.showContributorBadgeForOSM = false,
    this.contributorBadgeForOSMColor,
    this.contributorBadgeForOSMTextColor = Colors.blue,
    this.contributorBadgeForOSMText = 'OpenStreetMap contributors',
    this.contributorBadgeForOSMPositionTop,
    this.contributorBadgeForOSMPositionLeft,
    this.contributorBadgeForOSMPositionRight = 0,
    this.contributorBadgeForOSMPositionBottom = -6,
  });

  AttributionConfiguration copyWith({
    bool? showContributorBadgeForOSM,
    Color? contributorBadgeForOSMColor,
    Color? contributorBadgeForOSMTextColor,
    String? contributorBadgeForOSMText,
    double? contributorBadgeForOSMPositionTop,
    double? contributorBadgeForOSMPositionLeft,
    double? contributorBadgeForOSMPositionRight,
    double? contributorBadgeForOSMPositionBottom,
  }) {
    return AttributionConfiguration(
      showContributorBadgeForOSM:
          showContributorBadgeForOSM ?? this.showContributorBadgeForOSM,
      contributorBadgeForOSMColor:
          contributorBadgeForOSMColor ?? this.contributorBadgeForOSMColor,
      contributorBadgeForOSMTextColor: contributorBadgeForOSMTextColor ??
          this.contributorBadgeForOSMTextColor,
      contributorBadgeForOSMText:
          contributorBadgeForOSMText ?? this.contributorBadgeForOSMText,
      contributorBadgeForOSMPositionTop: contributorBadgeForOSMPositionTop ??
          this.contributorBadgeForOSMPositionTop,
      contributorBadgeForOSMPositionLeft: contributorBadgeForOSMPositionLeft ??
          this.contributorBadgeForOSMPositionLeft,
      contributorBadgeForOSMPositionRight:
          contributorBadgeForOSMPositionRight ??
              this.contributorBadgeForOSMPositionRight,
      contributorBadgeForOSMPositionBottom:
          contributorBadgeForOSMPositionBottom ??
              this.contributorBadgeForOSMPositionBottom,
    );
  }
}
