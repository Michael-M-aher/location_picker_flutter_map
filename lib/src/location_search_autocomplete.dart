import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:latlong2/latlong.dart';

import 'Widgets/wide_button.dart';
import 'classes.dart';

/// Principal widget to show Flutter map using osm api with search bar.
/// you can track you current location, search for a location and select it.
/// navigate easily in the map to selecte location.

class LocationSearchAutocomplete extends StatefulWidget {
  /// [onPicked] : (callback) is trigger when you clicked on select location,return current [PickedData] of the Marker
  ///
  final void Function(OSMdata data)? onPicked;

  /// [onError] : (callback) is trigger when an error occurs while fetching location
  ///
  final void Function(Exception e)? onError;

// // TODO : check if this is needed
//   /// [initPosition] :(LatLong?) set the initial location of the pointer on the map
//   ///
//   final LatLong? initPosition;

  /// [mapLanguage] : (String) set the language of the map and address text (default = 'en')
  ///
  final String mapLanguage;

  /// [countryCodes] : Limit search results to one or more countries
  ///
  final List<String>? countryCodes;

// TODO : check if this is needed
  /// [loadingWidget] : (Widget) show custom  widget until the map finish initialization
  ///
  final Widget? loadingWidget;

  // // TODO : check if this is needed
  // /// [trackMyPosition] : (bool) if is true, map will track your your location on the map initialization and makes inittial position of the pointer your current location (default = false)
  // ///
  // final bool trackMyPosition;

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

/// [lightAdress] : (bool) if true, displayed and returned adresses will be lighter
  ///
  final bool lightAdress;

  const LocationSearchAutocomplete({
    Key? key,
    this.onPicked,
    this.onError,
    // this.initPosition,
    this.mapLanguage = 'en',
    this.countryCodes,
    // this.trackMyPosition = false,
    this.searchBarBackgroundColor,
    this.searchBarTextColor,
    this.searchBarHintText = 'Search location',
    this.searchBarHintColor,
    this.lightAdress = false,
    Widget? loadingWidget,
  })  : loadingWidget = loadingWidget ?? const CircularProgressIndicator(),
        super(key: key);

  @override
  State<LocationSearchAutocomplete> createState() =>
      _LocationSearchAutocompleteState();
}

// TODO : check if 'TickerProviderStateMixin' is needed
class _LocationSearchAutocompleteState extends State<LocationSearchAutocomplete>
    with TickerProviderStateMixin {
  // Create a animation controller that has a duration and a TickerProvider.
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<OSMdata> _options = <OSMdata>[];
  LatLng? initPosition;
  Timer? _debounce;
  bool isLoading = true;
  late void Function(Exception e) onError;

  final _defaultSearchBarColor = Colors.grey[300];

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
          decodedResponse['display_name'] ?? widget.searchBarHintText;
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
  // Future<PickedData> pickData() async {
  //   LatLong center = LatLong(
  //       _mapController.center.latitude, _mapController.center.longitude);
  //   var client = http.Client();
  //   String url =
  //       'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_mapController.center.latitude}&lon=${_mapController.center.longitude}&zoom=18&addressdetails=1&accept-language=${widget.mapLanguage}';

  //   var response = await client.post(Uri.parse(url));
  //   var decodedResponse =
  //       jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
  //   String displayName = decodedResponse['display_name'];
  //   return PickedData(center, displayName, decodedResponse['address']);
  // }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    /// Checking if the trackMyPosition is true or false. If it is true, it will get the current
    /// position of the user and set the initLate and initLong to the current position. If it is false,
    /// it will set the initLate and initLong to the [initPosition].latitude and
    /// [initPosition].longitude.
    // if (widget.trackMyPosition) {
    //   _determinePosition().then((currentPosition) {
    //     initPosition =
    //         LatLng(currentPosition.latitude, currentPosition.longitude);

    //     setNameCurrentPos(currentPosition.latitude, currentPosition.longitude);
    //     _animatedMapMove(
    //         LatLng(currentPosition.latitude, currentPosition.longitude), 18.0);
    //   }, onError: (e) => onError(e)).whenComplete(() => setState(() {
    //         isLoading = false;
    //       }));
    // } else if (widget.initPosition != null) {
    //   initPosition =
    //       LatLng(widget.initPosition!.latitude, widget.initPosition!.longitude);
    //   setState(() {
    //     isLoading = false;
    //   });
    //   setNameCurrentPos(
    //       widget.initPosition!.latitude, widget.initPosition!.longitude);
    // } else {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }

    /// The above code is listening to the mapEventStream and when the mapEventMoveEnd event is
    /// triggered, it calls the setNameCurrentPos function.
    // _mapController.mapEventStream.listen((event) async {
    //   if (event is MapEventMoveEnd) {
    //     setNameCurrentPos(event.center.latitude, event.center.longitude);
    //   }
    // });

    super.initState();
  }

  /// The dispose() function is called when the widget is removed from the widget tree and is used to
  /// clean up resources
  @override
  void dispose() {
    // _mapController.dispose();
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
            // leading: Icon(Icons.location_on, color: widget.searchBarTextColor),
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: _defaultSearchBarColor!))),
              child: Text(
                _options[index].displayName,
                style: TextStyle(color: widget.searchBarTextColor),
              ),
            ),

            onTap: () async {
              //TODO : complete
              setNameCurrentPos(
                  _options[index].latitude, _options[index].longitude);

              widget.onPicked!(_options[index]);
              // setState(() {
              //   isLoading = true;
              // });
              // pickData().then((value) {
              //   widget.onPicked!(value);
              // }, onError: (e) => onError(e)).whenComplete(() => setState(() {
              //       isLoading = false;
              //     }));

              _focusNode.unfocus();
              _options.clear();
              setState(() {});
            },
          );
        });
  }

  Widget _buildSearchBar() {
    // OutlineInputBorder inputBorder = OutlineInputBorder(
    //   borderSide: BorderSide(color: Theme.of(context).primaryColor),
    // );
    // OutlineInputBorder inputFocusBorder = OutlineInputBorder(
    //   borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
    // );

    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.searchBarBackgroundColor ??
            Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: _defaultSearchBarColor,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: TextFormField(
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
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: widget.searchBarHintColor),
                  suffixIcon: IconButton(
                    onPressed: () => _searchController.clear(),
                    icon: Icon(
                      Icons.clear,
                      color: widget.searchBarTextColor,
                    ),
                  ),
                ),
                onChanged: (String value) async {
                  var client = http.Client();
                  try {
                    String url =
                        "https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1&accept-language=${widget.mapLanguage}${widget.countryCodes == null ? '' : '&countrycodes=${widget.countryCodes}'}";
                    var response = await client.post(Uri.parse(url));
                    var decodedResponse =
                        jsonDecode(utf8.decode(response.bodyBytes))
                            as List<dynamic>;
                    _options = decodedResponse
                        .map((e) => OSMdata(
                            displayName:  widget.lightAdress ? e['display_name'] : (e['address'] as Map)
                                .entries
                                .where((entry) => !RegExp(
                                        r'^(neighbourhood|municipality|state|country_code|village|region|suburb|city_district|hamlet|county|ISO.*)')
                                    .hasMatch(entry.key))
                                    .fold<String>('', (previousValue, element) => previousValue.isEmpty? element.value : '$previousValue, ${element.value}')
                                    ,
                            latitude: double.parse(e['lat']),
                            longitude: double.parse(e['lon']),
                            addressData: e['address']
                                        ))
                        .toList();
                    print(decodedResponse[0]);
                    setState(() {});
                  } on Exception catch (e) {
                    onError(e);
                  } finally {
                    client.close();
                  }
                }),
          ),
          StatefulBuilder(builder: ((context, setState) {
            return _buildListView();
          })),
        ],
      ),
    );
  }

  // Widget _buildSelectButton() {
  //   return Positioned(
  //     bottom: 0,
  //     left: 0,
  //     right: 0,
  //     child: Center(
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: WideButton(widget.selectLocationButtonText,
  //             onPressed: () async {
  //           setState(() {
  //             isLoading = true;
  //           });
  //           pickData().then((value) {
  //             widget.onPicked(value);
  //           }, onError: (e) => onError(e)).whenComplete(() => setState(() {
  //                 isLoading = false;
  //               }));
  //         },
  //             style: widget.selectLocationButtonStyle,
  //             textColor: widget.selectLocationTextColor),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child:
            // isLoading
            //     ? Center(child: widget.loadingWidget!)
            //     :
            _buildSearchBar());
  }
}
