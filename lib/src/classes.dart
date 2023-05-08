import 'package:shared_preferences/shared_preferences.dart';
import 'package:json_annotation/json_annotation.dart';

part 'classes.g.dart';

@JsonSerializable()
class LocationData {
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> addressData;
  LocationData(
      {required this.address,
      required this.latitude,
      required this.longitude,
      required this.addressData});
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
    List<String> history = await getHistory();
    history.add(itemJson);
    history = history.toSet().toList();
    if (history.length > limit) {
      history = history.sublist(1);
    }
    await prefs.setStringList(_historyKey, history);
  }
}
