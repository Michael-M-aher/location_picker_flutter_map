import 'package:latlong2/latlong.dart';

/// Represents OpenStreetMap data with location and display information
///
/// This class encapsulates the essential data returned from OSM Nominatim API
/// including the display name and geographical coordinates.
class OSMdata {
  /// The human-readable address or location name returned from Nominatim
  ///
  /// Example: "123 Main Street, New York, NY, United States"
  final String displayname;

  /// The latitude coordinate in decimal degrees
  ///
  /// Valid range: -90.0 to 90.0
  /// Positive values represent North, negative values represent South
  final double latitude;

  /// The longitude coordinate in decimal degrees
  ///
  /// Valid range: -180.0 to 180.0
  /// Positive values represent East, negative values represent West
  final double longitude;

  /// Creates an instance of OSMdata with required location information
  ///
  /// Parameters:
  /// * [displayname] - Human-readable location description
  /// * [latitude] - Latitude coordinate in decimal degrees (-90 to 90)
  /// * [longitude] - Longitude coordinate in decimal degrees (-180 to 180)
  const OSMdata({
    required this.displayname,
    required this.latitude,
    required this.longitude,
  });

  /// Validates if the coordinates are within valid geographical ranges
  ///
  /// Returns `true` if both latitude and longitude are within valid ranges:
  /// * Latitude: -90.0 to 90.0 degrees
  /// * Longitude: -180.0 to 180.0 degrees
  bool get isValidCoordinates =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Returns a string representation of the OSM data
  ///
  /// Format: "displayname, latitude, longitude"
  @override
  String toString() => '$displayname, $latitude, $longitude';

  /// Checks equality between two OSMdata instances
  ///
  /// Two instances are considered equal if they have the same
  /// displayname, latitude, and longitude values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OSMdata &&
        other.displayname == displayname &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  /// Generates a hash code for this instance
  ///
  /// Used for efficient storage in hash-based collections like Set and Map
  @override
  int get hashCode => Object.hash(displayname, latitude, longitude);

  /// Creates OSMdata from a JSON map returned by Nominatim API
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "display_name": "Location Name",
  ///   "lat": "40.7128",
  ///   "lon": "-74.0060"
  /// }
  /// ```
  ///
  /// Returns OSMdata with default values if parsing fails
  factory OSMdata.fromJson(Map<String, dynamic> json) {
    return OSMdata(
      displayname: json['display_name'] ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// Converts this OSMdata instance to a JSON map
  ///
  /// Returns a Map suitable for JSON serialization with keys:
  /// * 'display_name': The location description
  /// * 'lat': Latitude as string
  /// * 'lon': Longitude as string
  Map<String, dynamic> toJson() => {
        'display_name': displayname,
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      };
}

/// Represents a latitude-longitude coordinate pair with utility methods
///
/// This class provides a lightweight representation of geographical coordinates
/// with validation and conversion capabilities for use with flutter_map.
class LatLong {
  /// The latitude coordinate in decimal degrees
  ///
  /// Valid range: -90.0 to 90.0
  /// * Positive values: North of equator
  /// * Negative values: South of equator
  /// * 0.0: On the equator
  final double latitude;

  /// The longitude coordinate in decimal degrees
  ///
  /// Valid range: -180.0 to 180.0
  /// * Positive values: East of Prime Meridian
  /// * Negative values: West of Prime Meridian
  /// * 0.0: On the Prime Meridian
  final double longitude;

  /// Creates a LatLong coordinate pair
  ///
  /// Parameters:
  /// * [latitude] - Latitude in decimal degrees (-90 to 90)
  /// * [longitude] - Longitude in decimal degrees (-180 to 180)
  ///
  /// Example:
  /// ```dart
  /// final newYork = LatLong(40.7128, -74.0060);
  /// final london = LatLong(51.5074, -0.1278);
  /// ```
  const LatLong(this.latitude, this.longitude);

  /// Validates if the coordinates are within valid geographical ranges
  ///
  /// Returns `true` if both coordinates are valid:
  /// * Latitude: -90.0 to 90.0 degrees
  /// * Longitude: -180.0 to 180.0 degrees
  ///
  /// Example:
  /// ```dart
  /// final validCoord = LatLong(40.7128, -74.0060);
  /// print(validCoord.isValid); // true
  ///
  /// final invalidCoord = LatLong(91.0, 200.0);
  /// print(invalidCoord.isValid); // false
  /// ```
  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  /// Converts this LatLong to a LatLng object for flutter_map compatibility
  ///
  /// Returns a LatLng instance that can be used directly with flutter_map widgets
  ///
  /// Example:
  /// ```dart
  /// final coord = LatLong(40.7128, -74.0060);
  /// final mapCoord = coord.toLatLng(); // Use with FlutterMap
  /// ```
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Creates LatLong from a flutter_map LatLng instance
  ///
  /// Useful for converting coordinates received from map interactions
  /// back to the plugin's coordinate format.
  ///
  /// Example:
  /// ```dart
  /// final mapCoord = LatLng(40.7128, -74.0060);
  /// final coord = LatLong.fromLatLng(mapCoord);
  /// ```
  factory LatLong.fromLatLng(LatLng latLng) =>
      LatLong(latLng.latitude, latLng.longitude);

  /// Returns a string representation of the coordinates
  ///
  /// Format: "LatLong(latitude, longitude)"
  @override
  String toString() => 'LatLong($latitude, $longitude)';

  /// Checks equality between two LatLong instances
  ///
  /// Two instances are equal if they have the same latitude and longitude values
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LatLong &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  /// Generates a hash code for this coordinate pair
  ///
  /// Used for efficient storage in hash-based collections
  @override
  int get hashCode => Object.hash(latitude, longitude);

  /// Creates a copy of this LatLong with optional parameter overrides
  ///
  /// Allows creating a new instance with modified coordinates while
  /// keeping unchanged values from the original instance.
  ///
  /// Parameters:
  /// * [latitude] - New latitude value (optional)
  /// * [longitude] - New longitude value (optional)
  ///
  /// Example:
  /// ```dart
  /// final original = LatLong(40.7128, -74.0060);
  /// final moved = original.copyWith(latitude: 41.0); // Only change latitude
  /// ```
  LatLong copyWith({double? latitude, double? longitude}) {
    return LatLong(
      latitude ?? this.latitude,
      longitude ?? this.longitude,
    );
  }
}

/// Contains comprehensive data about a picked location
///
/// This class encapsulates all information related to a selected location,
/// including coordinates, address details, and the raw API response for
/// advanced use cases.
class PickedData {
  /// The geographical coordinates of the picked location
  final LatLong latLong;

  /// The primary address string for the location
  ///
  /// This is typically the display_name from Nominatim API,
  /// providing a human-readable address description.
  final String address;

  /// Detailed address components from the geocoding service
  ///
  /// Contains structured address data such as:
  /// * 'house_number': Street number
  /// * 'road': Street name
  /// * 'city', 'town', 'village': Settlement name
  /// * 'state': State or province
  /// * 'country': Country name
  /// * 'postcode': Postal code
  ///
  /// Example:
  /// ```dart
  /// final houseNumber = pickedData.addressData['house_number'];
  /// final street = pickedData.addressData['road'];
  /// final city = pickedData.addressData['city'];
  /// ```
  final Map<String, dynamic> addressData;

  /// The complete raw response from the geocoding API
  ///
  /// Contains the full JSON response for advanced processing
  /// or debugging purposes. The structure depends on the API used.
  final dynamic fullResponse;

  /// Creates a PickedData instance with location and address information
  ///
  /// Parameters:
  /// * [latLong] - The geographical coordinates
  /// * [address] - Primary address string
  /// * [addressData] - Structured address components
  /// * [fullResponse] - Complete API response
  const PickedData(
    this.latLong,
    this.address,
    this.addressData,
    this.fullResponse,
  );

  /// Validates if the picked data contains valid information
  ///
  /// Returns `true` if:
  /// * The coordinates are within valid geographical ranges
  /// * The address string is not empty
  ///
  /// This is useful for ensuring data quality before using the location.
  bool get isValid => latLong.isValid && address.isNotEmpty;

  /// Returns a formatted address string with structured components
  ///
  /// Creates a human-readable address by intelligently combining
  /// address components in a logical order:
  /// 1. House number + street name
  /// 2. City/town/village
  /// 3. Country
  ///
  /// Falls back to the primary address string if no structured data is available.
  ///
  /// Example output: "123 Main Street, New York, United States"
  String get formattedAddress {
    if (addressData.isEmpty) return address;

    final components = <String>[];

    // Add street address (house number + road)
    final houseNumber = addressData['house_number'];
    final road = addressData['road'];
    if (houseNumber != null && road != null) {
      components.add('$houseNumber $road');
    } else if (road != null) {
      components.add(road);
    }

    // Add settlement (city, town, or village)
    final city =
        addressData['city'] ?? addressData['town'] ?? addressData['village'];
    if (city != null) components.add(city);

    // Add country
    final country = addressData['country'];
    if (country != null) components.add(country);

    return components.isNotEmpty ? components.join(', ') : address;
  }

  /// Returns a string representation of the picked data
  ///
  /// Format: "PickedData(coordinates, address)"
  @override
  String toString() => 'PickedData(${latLong.toString()}, $address)';

  /// Checks equality between two PickedData instances
  ///
  /// Two instances are equal if they have the same coordinates and address
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PickedData &&
        other.latLong == latLong &&
        other.address == address;
  }

  /// Generates a hash code for this instance
  @override
  int get hashCode => Object.hash(latLong, address);

  /// Creates a copy of this PickedData with optional parameter overrides
  ///
  /// Useful for creating modified versions while preserving unchanged data.
  ///
  /// Parameters:
  /// * [latLong] - New coordinates (optional)
  /// * [address] - New address string (optional)
  /// * [addressData] - New address components (optional)
  /// * [fullResponse] - New full response (optional)
  ///
  /// Example:
  /// ```dart
  /// final original = PickedData(coord, "Old Address", {}, response);
  /// final updated = original.copyWith(address: "New Address");
  /// ```
  PickedData copyWith({
    LatLong? latLong,
    String? address,
    Map<String, dynamic>? addressData,
    dynamic fullResponse,
  }) {
    return PickedData(
      latLong ?? this.latLong,
      address ?? this.address,
      addressData ?? this.addressData,
      fullResponse ?? this.fullResponse,
    );
  }
}
