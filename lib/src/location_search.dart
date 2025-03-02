import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';

import 'classes.dart';
import 'debounce.dart';

/// Principal widget to show Flutter map using osm api with search bar.
/// you can track you current location, search for a location and select it.
/// navigate easily in the map to selecte location.

class LocationSearchWidget extends StatefulWidget {
  /// [onPicked] : (callback) is triggered when you click on a location, returns current [PickedData] of the Marker
  ///
  final void Function(LocationData data)? onPicked;

  /// [onError] : (callback) is triggered when an error occurs while fetching location
  ///
  final void Function(Exception e)? onError;

  /// [language] : (String) set the language of the map and address text (default = 'en')
  ///
  final String? language;

  /// [countryCodes] : Limit search results to one or more countries
  ///
  final List<String>? countryCodes;

  /// [loadingWidget] : (Widget) show custom  widget until the map finish initialization
  ///
  final Widget? loadingWidget;

  /// [searchBarBackgroundColor] : (Color) change the background color of the search bar
  ///

  final Color? searchBarBackgroundColor;

  /// [searchBarTextColor] : (Color) change the color of the search bar text
  ///

  final Color searchBarTextColor;

  /// [searchBarHintText] : (String) change the hint text of the search bar
  ///

  final String searchBarHintText;

  /// [searchBarHintColor] : (Color) change the color of the search bar hint text
  ///

  final Color searchBarHintColor;

  /// [lightAddress] : (bool) if true, displayed and returned adresses will be lighter
  ///

  final bool lightAddress;

  /// [iconColor] : (Color) change the color of the search bar text
  ///

  final Color iconColor;

  /// [currentPositionButtonText] : (String) change the text of the button selecting current position
  ///

  final String currentPositionButtonText;

  /// [mode] : mode of display: fullscreen or overlay
  ///

  final Mode mode;

  /// [historyMaxLength] : (int) maximum length of history and suggested location
  ///

  final int historyMaxLength;

  /// [userAgent] : OpenStreetMap’s Nominatim service (used for geocoding) requires a user-agent to identify your application. If you don’t provide one, your requests might get blocked or throttled
  ///

  final UserAgent userAgent;

  const LocationSearchWidget({
    super.key,
    required this.onPicked,
    required this.userAgent,
    this.onError,
    this.language = 'en',
    this.countryCodes,
    this.searchBarBackgroundColor,
    this.searchBarTextColor = Colors.black87,
    this.searchBarHintText = 'Search location',
    this.currentPositionButtonText = 'Use current location',
    this.searchBarHintColor = Colors.black87,
    this.lightAddress = false,
    this.iconColor = Colors.grey,
    this.mode = Mode.fullscreen,
    this.historyMaxLength = 5,
    Widget? loadingWidget,
  }) : loadingWidget = loadingWidget ?? const CircularProgressIndicator();

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final logger = Logger();
  final _debounce = Debounce(milliseconds: 500);
  final _client = http.Client();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<LocationData> _options = <LocationData>[];
  bool isLoading = false;
  late void Function(Exception e) onError;
  final _defaultSearchBarColor = Colors.grey[300];

  final List<LocationData> _history = [];
  final _historyManager = HistoryManager();
  bool _isCurrentLocationLoading = false;

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
  /// have permissions, request them. If we have permissions, return the current position with data fetched
  /// from OpenStreetMap API
  ///
  /// Returns:
  ///   A Future<LocationData> object.
  Future<LocationData> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      const error = PermissionDeniedException('Location Permission is denied');
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
          PermissionDeniedException('Location Permission is denied forever');
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
    setState(() {
      _isCurrentLocationLoading = true;
    });
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final currentPos = await Geolocator.getCurrentPosition();

    // Query OpenStreetMap API to get
    // the address of the location
    final client = http.Client();

    final url =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=${currentPos.latitude}&lon=${currentPos.longitude}&zoom=18&addressdetails=1&accept-language=${widget.language}${widget.countryCodes == null ? '' : '&countrycodes=${widget.countryCodes}'}";

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': widget.userAgent.toString(),
        },
      );
      final decodedResponse =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

      final posData = _getLocationData(decodedResponse);

      setState(() {
        _isCurrentLocationLoading = false;
      });

      // show the current position in search bar
      setAddressInSearchBar(posData.address);

      return posData;
    } on Exception catch (e) {
      onError(e);
      return Future.error(e);
    } finally {
      setState(() {
        _isCurrentLocationLoading = false;
      });
    }
  }

  /// Returns an LocationData object based on Map of data provided
  ///
  /// args:
  ///     data (Map): A map of data fetched from OpenStreetMap API
  LocationData _getLocationData(Map data) {
    final lat = double.parse(data['lat']);
    final long = double.parse(data['lon']);
    final addressData = data['address'] as Map<String, dynamic>;

    if (!widget.lightAddress) {
      return LocationData(
        address: data['display_name'],
        latitude: lat,
        longitude: long,
        addressData: addressData,
      );
    }

    final address = addressData.entries
        .where(
          (entry) => !RegExp(
            '^(neighbourhood|municipality|state|country_code|village|region|suburb|city_district|hamlet|county|ISO.*)',
          ).hasMatch(entry.key),
        )
        .fold<String>(
          '',
          (previousValue, element) => previousValue.isEmpty
              ? element.value
              : '$previousValue, ${element.value}',
        );

    return LocationData(
      address: address,
      latitude: lat,
      longitude: long,
      addressData: addressData,
    );
  }

  /// It takes the display name of a location and uses the OpenStreetMap API to get
  /// the address of the location
  ///
  /// Args:
  ///   address (String): The display name of the location.
  void setAddressInSearchBar(String address) {
    try {
      _searchController.text = address;
    } on Exception catch (e) {
      onError(e);
    }
  }

  Future<void> _loadHistory() async {
    final historyJson = await _historyManager.getHistory();
    if (historyJson.isNotEmpty) {
      final historyList = historyJson.map(jsonDecode).toList();
      setState(() {
        _history.addAll(
          historyList.map((loc) => LocationData.fromJson(loc)).toList(),
        );
      });
    }
  }

  Future<void> _addToHistory(LocationData loc) async {
    await _historyManager.addToHistory(
      jsonEncode(loc),
      widget.historyMaxLength,
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    onError = widget.onError ?? logger.e;
    _loadHistory();
  }

  @override
  void dispose() {
    _client.close();
    _debounce.cancel();
    super.dispose();
  }

  Widget _buildListView() {
    return SliverList.separated(
      itemCount: _options.isEmpty ? _history.length : _options.length,
      itemBuilder: (context, index) {
        final items = _options.isEmpty ? _history : _options;
        final isHistory = _options.isEmpty;
        final item = items[index];

        return ListTile(
          leading: isHistory
              ? Icon(
                  Icons.watch_later_outlined,
                  color: widget.iconColor,
                )
              : null,
          trailing: Icon(
            Icons.chevron_right,
            color: widget.iconColor,
            size: 30,
          ),
          title: Text(
            item.address,
            style: TextStyle(
              color: widget.searchBarTextColor,
            ),
          ),
          onTap: () => _onResultTap(item),
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: _defaultSearchBarColor,
      ),
    );
  }

  void _onResultTap(LocationData item) {
    if (_options.isNotEmpty) {
      _addToHistory(item);
    }
    setAddressInSearchBar(item.address);

    widget.onPicked!(item);
    _focusNode.unfocus();
    _options.clear();
    setState(() {});
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            textDirection: isRTL(_searchController.text)
                ? TextDirection.rtl
                : TextDirection.ltr,
            style: TextStyle(color: widget.searchBarTextColor),
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              fillColor:
                  widget.searchBarBackgroundColor ?? _defaultSearchBarColor,
              hintText: widget.searchBarHintText,
              hintTextDirection: isRTL(widget.searchBarHintText)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: widget.searchBarHintColor),
              suffixIcon: IconButton(
                onPressed: _searchController.clear,
                icon: Icon(
                  Icons.clear,
                  color: widget.iconColor,
                ),
              ),
            ),
            onChanged: (value) {
              _debounce.run(() async {
                try {
                  _options = await _onSearch(value);
                  setState(() {});
                } on Exception catch (e) {
                  onError(e);
                }
              });
            },
          ),
        ),
        Expanded(
          child: CustomScrollView(
            controller: ScrollController(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildSelectCurrentPositionButton(),
              ),
              _buildListView(),
            ],
          ),
        ),
          Container(
          margin: const EdgeInsets.all(5),
              
              child: const  Text(
                '© OpenStreetMap contributors.',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
        ),
      ],
    );
  }

  Future<List<LocationData>> _onSearch(String value) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1&accept-language=${widget.language}${widget.countryCodes == null ? '' : '&countrycodes=${widget.countryCodes}'}";
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': value,
        'format': 'json',
        'polygon_geojson': '1',
        'addressdetails': '1',
        'accept-language': widget.language,
        if (widget.countryCodes != null)
          'countrycodes': widget.countryCodes!.join(','),
      },
    );

    final response = await _client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': widget.userAgent.toString(),
        },
      );

    final decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decodedResponse.map((e) => _getLocationData(e)).toList();
  }

  /// Button to select current location
  ///
  Widget _buildSelectCurrentPositionButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _defaultSearchBarColor!)),
      ),
      child: ListTile(
        onTap: () async {
          final currentPos = await _determinePosition();
          unawaited(_addToHistory(currentPos));
          widget.onPicked!(currentPos);
        },
        leading: Icon(
          Icons.location_searching,
          color: widget.iconColor,
        ),
        title: Text(
          widget.currentPositionButtonText,
          style: TextStyle(
            color: widget.searchBarTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        trailing: _isCurrentLocationLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: widget.iconColor,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                Icons.chevron_right,
                color: widget.iconColor,
                size: 30,
              ),
      ),
    );
  }

  /// this is used if mode = Mode.overlay
  ///
  Widget _buildDialog() {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      // content: const Text("Save successfully"),
      child: SizedBox(
        // height: MediaQuery.of(context).size.height - 300,
        child:
            isLoading ? Center(child: widget.loadingWidget) : _buildSearchBar(),
      ),
    );
  }

  /// this is used if mode = Mode.fullscreen
  ///
  Widget _buildScaffold() {
    return Scaffold(
      body: SafeArea(
        child:
            isLoading ? Center(child: widget.loadingWidget) : _buildSearchBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.mode == Mode.overlay ? _buildDialog() : _buildScaffold();
  }
}

class LocationSearch {
  static Future<LocationData?> show({
    required BuildContext context,
    void Function(Exception e)? onError,
    String language = 'en',
    List<String>? countryCodes,
    Color? searchBarBackgroundColor,
    required UserAgent userAgent,
    Color searchBarTextColor = Colors.black87,
    String searchBarHintText = 'Search location',
    String currentPositionButtonText = 'Use current location',
    Color searchBarHintColor = Colors.black87,
    bool lightAddress = false,
    Color iconColor = Colors.grey,
    Widget? loadingWidget,
    Mode mode = Mode.fullscreen,
    int historyMaxLength = 5,
  }) {
    LocationSearchWidget builder(BuildContext ctx) => LocationSearchWidget(
          onPicked: (data) => Navigator.pop(context, data),
          onError: onError,
          language: language,
          countryCodes: countryCodes,
          searchBarBackgroundColor: searchBarBackgroundColor,
          searchBarTextColor: searchBarTextColor,
          searchBarHintText: searchBarHintText,
          currentPositionButtonText: currentPositionButtonText,
          searchBarHintColor: searchBarHintColor,
          lightAddress: lightAddress,
          iconColor: iconColor,
          loadingWidget: loadingWidget,
          mode: mode,
          historyMaxLength: historyMaxLength,
          userAgent: userAgent,
        );

    if (mode == Mode.overlay) {
      return showDialog(context: context, builder: builder);
    }
    return Navigator.push(context, MaterialPageRoute(builder: builder));
  }
}
