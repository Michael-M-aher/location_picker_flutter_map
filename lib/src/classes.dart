class OSMdata {
  final String displayname;
  final double latitude;
  final double longitude;
  OSMdata(
      {required this.displayname,
      required this.latitude,
      required this.longitude});
  @override
  String toString() {
    return '$displayname, $latitude, $longitude';
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OSMdata && other.displayname == displayname;
  }

  @override
  int get hashCode => Object.hash(displayname, latitude, longitude);
}

class LatLong {
  final double latitude;
  final double longitude;
  LatLong(this.latitude, this.longitude);
}

class PickedData {
  final LatLong latLong;
  final String address;
  final Address addressData;

  PickedData(this.latLong, this.address, this.addressData);
}

class Address {
  String? houseNumber;
  String? neighbourhood;
  String? city;
  String? state;
  String? iSO31662Lvl4;
  String? postcode;
  String? country;
  String? countryCode;

  Address(
      {this.houseNumber,
      this.neighbourhood,
      this.city,
      this.state,
      this.iSO31662Lvl4,
      this.postcode,
      this.country,
      this.countryCode});

  Address.fromJson(Map<String, dynamic> json) {
    houseNumber = json['house_number'];
    neighbourhood = json['neighbourhood'];
    city = json['city'];
    state = json['state'];
    iSO31662Lvl4 = json['ISO3166-2-lvl4'];
    postcode = json['postcode'];
    country = json['country'];
    countryCode = json['country_code'];
  }
}
