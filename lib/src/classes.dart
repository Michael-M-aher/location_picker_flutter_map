class OSMdata {
  final String displayName;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> addressData;
  OSMdata(
      {required this.displayName,
      required this.latitude,
      required this.longitude,
      required this.addressData});
  @override
  String toString() {
    return '$displayName, $latitude, $longitude';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayName == displayName;
  }

  @override
  int get hashCode => Object.hash(displayName, latitude, longitude);
}

class LatLong {
  final double latitude;
  final double longitude;
  LatLong(this.latitude, this.longitude);
}

enum Mode { overlay, fullscreen }