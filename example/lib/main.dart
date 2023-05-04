import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Picker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LocationSearchWidget(
            
            searchBarBackgroundColor: Colors.grey[300],
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
