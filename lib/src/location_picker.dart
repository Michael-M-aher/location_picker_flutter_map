import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:latlong2/latlong.dart';

import 'Widgets/wide_button.dart';
import 'classes.dart';

/// Principal widget to show Flutter map using osm api with pick up location marker and search bar.
/// you can track you current location, search for a location and select it.
/// navigate easily in the map to selecte location.

class FlutterLocationPicker extends StatefulWidget {
  /// [onPicked] : (callback) is trigger when you clicked on select location,return current [PickedData] of the Marker
  ///
  final void Function(PickedData pickedData) onPicked;

  /// [onError] : (callback) is trigger when an error occurs while fetching location
  ///
  final void Function(Exception e)? onError;

  /// [initPosition] :(LatLong?) set the initial location of the pointer on the map
  ///
  final LatLong? initPosition;

  /// [urlTemplate] : (String) set the url template of the tile layer to get the data from the api (makes you apply your own style to the map) (default = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png')
  ///
  final String urlTemplate;

  /// [mapLanguage] : (String) set the language of the map and address text (default = 'en')
  ///
  final String mapLanguage;

  /// [selectLocationButtonText] : (String) set the text of the select location button (default = 'Set Current Location')
  ///
  final String selectLocationButtonText;

  /// [initZoom] : (double) set initialized zoom in specific location  (default = 17)
  ///
  final double initZoom;

  /// [stepZoom] : (double) set default step zoom value (default = 1)
  ///
  final double stepZoom;

  /// [minZoomLevel] : (double) set default zoom value (default = 2)
  ///
  final double minZoomLevel;

  /// [maxZoomLevel] : (double) set default zoom value (default = 18.4)
  ///
  final double maxZoomLevel;

  /// [loadingWidget] : (Widget) show custom  widget until the map finish initialization
  ///
  final Widget? loadingWidget;

  /// [trackMyPosition] : (bool) if is true, map will track your your location on the map initialization and makes inittial position of the pointer your current location (default = false)
  ///
  final bool trackMyPosition;

  /// [showZoomController] : (bool) enable/disable zoom in and zoom out buttons (default = true)
  ///

  final bool showZoomController;

  /// [showLocationController] : (bool) enable/disable locate me button (default = true)
  ///

  final bool showLocationController;

  /// [showSelectLocationButton] : (bool) enable/disable select location button (default = true)
  ///

  final bool showSelectLocationButton;

  /// [mapAnimationDuration] : (Duration) time duration of the move from point to point animation (default = Duration(milliseconds: 2000))
  ///

  final Duration mapAnimationDuration;

  /// [mapLoadingBackgroundColor] : (Color) change the background color of the loading screen before the map initialized
  ///
  final Color? mapLoadingBackgroundColor;

  /// [selectLocationButtonStyle] : (ButtonStyle) change the style of the select Location button
  ///
  final ButtonStyle? selectLocationButtonStyle;

  /// [selectLocationTextColor] : (Color) change the color of the select Location text
  ///
  final Color? selectLocationTextColor;

  /// [showSearchBar] : (bool) enable/disable search bar (default = true)
  ///

  final bool showSearchBar;

  /// [searchBarBackgroundColor] : (Color) change the background color of the search bar
  ///

  final Color? searchBarBackgroundColor;

  /// [searchBarTextColor] : (Color) change the color of the search bar text
  ///

  final Color? searchBarTextColor;

  /// [searchBarHintText] : (String) change the hint text of the search bar
  ///

  final String searchBarHintText;

  /// [searchBarHintColor] : (Color) change the color of the search bar hint text
  ///

  final Color? searchBarHintColor;

  /// [zoomButtonsColor] : (Color) change the color of the zoom buttons icons
  ///

  final Color? zoomButtonsColor;

  /// [zoomButtonsBackgroundColor] : (Color) change the background color of the zoom buttons
  ///

  final Color? zoomButtonsBackgroundColor;

  /// [locationButtonsColor] : (Color) change the color of the location button icon
  ///

  final Color? locationButtonsColor;

  /// [locationButtonBackgroundColor] : (Color) change the background color of the location button
  ///
  final Color? locationButtonBackgroundColor;

  /// [markerIconColor] : (Color) change the marker color of the map (default = Colors.red)
  ///
  final Color markerIconColor;

  /// [markerIcon] : (IconData) change the marker icon of the map (default = Icons.location_on)
  ///
  final IconData markerIcon;

  const FlutterLocationPicker({
    Key? key,
    required this.onPicked,
    this.onError,
    this.initPosition,
    this.stepZoom = 1,
    this.initZoom = 17,
    this.minZoomLevel = 2,
    this.maxZoomLevel = 18.4,
    this.urlTemplate = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.mapLanguage = 'en',
    this.selectLocationButtonText = 'Set Current Location',
    this.mapAnimationDuration = const Duration(milliseconds: 2000),
    this.trackMyPosition = false,
    this.showZoomController = true,
    this.showLocationController = true,
    this.showSelectLocationButton = true,
    this.selectLocationButtonStyle,
    this.selectLocationTextColor,
    this.showSearchBar = true,
    this.searchBarBackgroundColor,
    this.searchBarTextColor,
    this.searchBarHintText = 'Search location',
    this.searchBarHintColor,
    this.mapLoadingBackgroundColor,
    this.locationButtonBackgroundColor,
    this.zoomButtonsBackgroundColor,
    this.zoomButtonsColor,
    this.locationButtonsColor,
    this.markerIconColor = Colors.red,
    this.markerIcon = Icons.location_pin,
    Widget? loadingWidget,
  })  : loadingWidget = loadingWidget ?? const CircularProgressIndicator(),
        super(key: key);

  @override
  State<FlutterLocationPicker> createState() => _FlutterLocationPickerState();
}

class _FlutterLocationPickerState extends State<FlutterLocationPicker>
    with TickerProviderStateMixin {
  /// Creating a new instance of the MapController class.
  MapController _mapController = MapController();
  // Create a animation controller that has a duration and a TickerProvider.
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  LatLng? initPosition;
  Timer? _debounce;
  bool isLoading = true;
  late void Function(Exception e) onError;

  /// It returns true if the text is RTL, false if it's LTR
  ///
  /// Args:
  ///   text (String): The text to be checked for RTL directionality.
  ///
  /// Returns:
  ///   A boolean value.
  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  /// If location services are enabled, check if we have permissions to access the location. If we don't
  /// have permissions, request them. If we have permissions, return the current position
  ///
  /// Returns:
  ///   A Future<Position> object.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      const error = PermissionDeniedException("Location Permission is denied");
      onError(error);
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(error);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      const error =
          PermissionDeniedException("Location Permission is denied forever");
      onError(error);
      // Permissions are denied forever, handle appropriately.
      return Future.error(error);
    }

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      while (!await Geolocator.isLocationServiceEnabled()) {}
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Create a animation controller, add a listener to the controller, and
  /// then forward the controller with the new location
  ///
  /// Args:
  ///   destLocation (LatLng): The LatLng of the destination location.
  ///   destZoom (double): The zoom level you want to animate to.
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);
    // Create a animation controller that has a duration and a TickerProvider.
    if (mounted) {
      _animationController = AnimationController(
          vsync: this, duration: widget.mapAnimationDuration);
    }
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation = CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn);

    _animationController.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    if (mounted) {
      _animationController.forward();
    }
  }

  /// It takes the latitude and longitude of the current location and uses the OpenStreetMap API to get
  /// the address of the location
  ///
  /// Args:
  ///   latitude (double): The latitude of the location.
  ///   longitude (double): The longitude of the location.
  void setNameCurrentPos(double latitude, double longitude) async {
    var client = http.Client();
    setState(() {
      isLoading = true;
    });
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1&accept-language=${widget.mapLanguage}';

    try {
      var response = await client.post(Uri.parse(url));
      var decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
      _searchController.text =
          decodedResponse['display_name'] ?? "Search Location";
      setState(() {
        isLoading = false;
      });
    } on Exception catch (e) {
      onError(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// It takes the poiner of the map and sends a request to the OpenStreetMap API to get the address of
  /// the poiner
  ///
  /// Returns:
  ///   A Future object that will eventually contain a PickedData object.
  Future<PickedData> pickData() async {
    LatLong center = LatLong(
        _mapController.center.latitude, _mapController.center.longitude);
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_mapController.center.latitude}&lon=${_mapController.center.longitude}&zoom=18&addressdetails=1&accept-language=${widget.mapLanguage}';

    var response = await client.post(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
    String displayName = decodedResponse['display_name'];
    return PickedData(center, displayName, decodedResponse['address']);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _mapController = MapController();
    _animationController =
        AnimationController(duration: widget.mapAnimationDuration, vsync: this);
    onError = widget.onError ?? (e) => debugPrint(e.toString());

    /// Checking if the trackMyPosition is true or false. If it is true, it will get the current
    /// position of the user and set the initLate and initLong to the current position. If it is false,
    /// it will set the initLate and initLong to the [initPosition].latitude and
    /// [initPosition].longitude.
    if (widget.trackMyPosition) {
      _determinePosition().then((currentPosition) {
        initPosition =
            LatLng(currentPosition.latitude, currentPosition.longitude);

        setNameCurrentPos(currentPosition.latitude, currentPosition.longitude);
        _animatedMapMove(
            LatLng(currentPosition.latitude, currentPosition.longitude), 18.0);
      }, onError: (e) => onError(e)).whenComplete(() => setState(() {
            isLoading = false;
          }));
    } else if (widget.initPosition != null) {
      initPosition =
          LatLng(widget.initPosition!.latitude, widget.initPosition!.longitude);
      setState(() {
        isLoading = false;
      });
      setNameCurrentPos(
          widget.initPosition!.latitude, widget.initPosition!.longitude);
    } else {
      setState(() {
        isLoading = false;
      });
    }

    /// The above code is listening to the mapEventStream and when the mapEventMoveEnd event is
    /// triggered, it calls the setNameCurrentPos function.
    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        setNameCurrentPos(event.center.latitude, event.center.longitude);
      }
    });

    super.initState();
  }

  /// The dispose() function is called when the widget is removed from the widget tree and is used to
  /// clean up resources
  @override
  void dispose() {
    _mapController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildListView() {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _options.length > 5 ? 5 : _options.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _options[index].displayname,
              style: TextStyle(color: widget.searchBarTextColor),
            ),
            onTap: () {
              _animatedMapMove(
                  LatLng(_options[index].latitude, _options[index].longitude),
                  18.0);
              setNameCurrentPos(
                  _options[index].latitude, _options[index].longitude);

              _focusNode.unfocus();
              _options.clear();
              setState(() {});
            },
          );
        });
  }

  Widget _buildSearchBar() {
    OutlineInputBorder inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor),
    );
    OutlineInputBorder inputFocusBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: widget.searchBarBackgroundColor ??
              Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            TextFormField(
                textDirection: isRTL(_searchController.text)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TextStyle(color: widget.searchBarTextColor),
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.searchBarHintText,
                  hintTextDirection: isRTL(widget.searchBarHintText)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  border: inputBorder,
                  focusedBorder: inputFocusBorder,
                  hintStyle: TextStyle(color: widget.searchBarHintColor),
                  suffixIcon: IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: Icon(
                      Icons.clear,
                      color: widget.searchBarTextColor,
                    ),
                  ),
                ),
                onChanged: (String value) {
                  if (_debounce?.isActive ?? false) {
                    _debounce?.cancel();
                  }
                  setState(() {});
                  _debounce = Timer(const Duration(milliseconds: 20), () async {
                    var client = http.Client();
                    try {
                      String url =
                          'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1&accept-language=${widget.mapLanguage}';
                      var response = await client.post(Uri.parse(url));
                      var decodedResponse =
                          jsonDecode(utf8.decode(response.bodyBytes))
                              as List<dynamic>;
                      _options = decodedResponse
                          .map((e) => OSMdata(
                              displayname: e['display_name'],
                              latitude: double.parse(e['lat']),
                              longitude: double.parse(e['lon'])))
                          .toList();
                      setState(() {});
                    } on Exception catch (e) {
                      onError(e);
                    } finally {
                      client.close();
                    }
                  });
                }),
            StatefulBuilder(builder: ((context, setState) {
              return _buildListView();
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildControllerButtons() {
    return PositionedDirectional(
      bottom: 72,
      end: 16,
      child: Column(
        children: [
          if (widget.showZoomController)
            FloatingActionButton(
              heroTag: "btn1",
              shape: const CircleBorder(),
              backgroundColor: widget.zoomButtonsBackgroundColor,
              onPressed: () {
                _animatedMapMove(_mapController.center,
                    _mapController.zoom + widget.stepZoom);
              },
              child: Icon(
                Icons.zoom_in,
                color: widget.zoomButtonsColor,
              ),
            ),
          const SizedBox(height: 16),
          if (widget.showZoomController)
            FloatingActionButton(
              heroTag: "btn2",
              shape: const CircleBorder(),
              backgroundColor: widget.zoomButtonsBackgroundColor,
              onPressed: () {
                _animatedMapMove(_mapController.center,
                    _mapController.zoom - widget.stepZoom);
              },
              child: Icon(
                Icons.zoom_out,
                color: widget.zoomButtonsColor,
              ),
            ),
          const SizedBox(height: 22),
          if (widget.showLocationController)
            FloatingActionButton(
              heroTag: "btn3",
              backgroundColor: widget.locationButtonBackgroundColor,
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                _determinePosition().then((currentPosition) {
                  _animatedMapMove(
                      LatLng(
                          currentPosition.latitude, currentPosition.longitude),
                      18);
                  setNameCurrentPos(
                      currentPosition.latitude, currentPosition.longitude);
                });
              },
              child:
                  Icon(Icons.my_location, color: widget.locationButtonsColor),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Positioned.fill(
        child: FlutterMap(
      options: MapOptions(
          center: initPosition,
          zoom: initPosition != null ? widget.initZoom : widget.minZoomLevel,
          maxZoom: widget.maxZoomLevel,
          minZoom: widget.minZoomLevel),
      mapController: _mapController,
      children: [
        TileLayer(
          urlTemplate: widget.urlTemplate,
          subdomains: const ['a', 'b', 'c'],
          backgroundColor:
              widget.mapLoadingBackgroundColor ?? const Color(0xFFE0E0E0),
        )
      ],
    ));
  }

  Widget _buildMarker() {
    return Positioned.fill(
        child: IgnorePointer(
      child: Center(
        child: Icon(
          widget.markerIcon,
          color: widget.markerIconColor,
          size: 50,
        ),
      ),
    ));
  }

  Widget _buildSelectButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WideButton(widget.selectLocationButtonText,
              onPressed: () async {
            setState(() {
              isLoading = true;
            });
            pickData().then((value) {
              widget.onPicked(value);
            }, onError: (e) => onError(e)).whenComplete(() => setState(() {
                  isLoading = false;
                }));
          },
              style: widget.selectLocationButtonStyle,
              textColor: widget.selectLocationTextColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _buildMap(),
          if (!isLoading) _buildMarker(),
          if (isLoading) Center(child: widget.loadingWidget!),
          _buildControllerButtons(),
          if (widget.showSearchBar) _buildSearchBar(),
          if (widget.showSelectLocationButton) _buildSelectButton()
        ],
      ),
    );
  }
}
