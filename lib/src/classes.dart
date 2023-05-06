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
}

class LatLong {
  final double latitude;
  final double longitude;
  LatLong(this.latitude, this.longitude);
}

enum Mode { overlay, fullscreen }