import 'package:flutter/material.dart';
import 'package:flutter_location_search_autocomplete/flutter_location_search_autocomplete.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Picker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LocationSearchAutocomplete(
            
            searchBarBackgroundColor: Colors.white,
            mapLanguage: 'fr',
            onError: (e) => print(e),
            onPicked: (data) {
              print(data.latitude);
              print(data.longitude);
              print(data.displayName);
              print(data.addressData['country']);
              print(data.addressData['city']);
              print(data.addressData);
            }),
      ),
    );
  }
}
