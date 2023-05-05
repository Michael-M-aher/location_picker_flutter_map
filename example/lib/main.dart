import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:intl/date_symbol_data_local.dart';

// void main() => runApp(const MyApp());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if(kIsWeb) {
  //   // initialization for web
  //   await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //       apiKey: Keys.apiKey,
  //       appId: Keys.appId,
  //       messagingSenderId: Keys.messagingSenderId,
  //       projectId: Keys.projectId)
  //   );
  // } else {
  //   // initialization for android & ios
  //   await Firebase.initializeApp();
  // }

  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Location Picker',
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: LocationSearchWidget(

//             searchBarBackgroundColor: Colors.grey[300],
//             mapLanguage: 'fr',
//             onError: (e) => print(e),
//             onPicked: (data) {
//               print(data.latitude);
//               print(data.longitude);
//               print(data.displayName);
//               print(data.addressData['country']);
//               print(data.addressData['city']);
//               print(data.addressData);
//             }),
//       ),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _locationText = 'Tap here to search a place';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location Picker',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Builder(builder: (context) {
            return TextButton(
              child: Text(_locationText),
              onPressed: () async {
                LocationData? locationData = await LocationSearch.show(context: context, lightAdress: true);

                setState(() {
                  _locationText = locationData!.displayName;
                });
              },
            );
          }),
        ),
      ),
    );
  }
}
