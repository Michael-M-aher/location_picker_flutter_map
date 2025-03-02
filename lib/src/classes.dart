import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'classes.g.dart';

@JsonSerializable()
class LocationData {
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> addressData;

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.addressData,
  });

  @override
  String toString() {
    return '$address, $latitude, $longitude';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LocationData && other.address == address;
  }

  @override
  int get hashCode => Object.hash(address, latitude, longitude);

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

class LatLong {
  final double latitude;
  final double longitude;

  LatLong(this.latitude, this.longitude);
}

enum Mode { overlay, fullscreen }

class HistoryManager {
  static const _historyKey = 'HISTORY';

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey);
    return history ?? [];
  }

  Future<void> addToHistory(String itemJson, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    var history = await getHistory();
    history.add(itemJson);
    history = history.toSet().toList();
    if (history.length > limit) {
      history = history.sublist(1);
    }
    await prefs.setStringList(_historyKey, history);
  }
}

/// An User-Agent is an http request header that is sent with each request.
/// OpenStreetMap’s Nominatim service (used for geocoding) requires a user-agent to identify your application.
/// If you don’t provide one, your requests might get blocked or throttled.
class UserAgent{
  /// The name of your application (eg: geo-app)
  final String appName;

  /// The version of the application (eg: 1.0.0)
  final String? version;

  /// Email contact. OSM Nominatim asks that the user_agent also contains your email address (eg: support@myapp.com)
  final String email;

  UserAgent({
    required this.appName,
    required this.email,
    this.version="1.0"
  });

  @override
  String toString() {
    return '$appName/$version ($email)';
  }
}
