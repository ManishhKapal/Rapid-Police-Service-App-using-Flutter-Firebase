import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  String? mtoken =
      "fyvJUPSLQkaX1faGx7HjVr:APA91bHhFHVog3gMYPCbzggb4_BOOsq4NVV5afG0w9h6bdoJnoMmS8D03Qpi6EaHvQNofGcLj7lJ1CzpkwuHBTwqwxcFLtd3N4MPI5_kC-ayC2hVfhnHB1K1o_T3UG6llPb_-cesvKfv";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
    // getToken();
    // initInfo();
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
        (token) {
          setState(() {
            mtoken = token;
          });
        }
    );
  }

  void sendPushMessage(String token, String body, String title) async {
      await http.post(
        Uri.parse('http://fcm.googleapis.com/fcm/send'),
        headers : <String, String> {
          'Content-type' : 'application/json',
          'Authorization' : 'key=AAAAg8crzFs:APA91bH9jojweYLv6ioOjeN1rFXRuH5S8Y2CVsaQ5c_VMSTlEO8jfTbTi_Mi4RzXVKDAgncT4RoaWFTjNUhp0qlVkinOVO3MoCoBqs62v1cNrpyCWERoq2hY43b1h-iD72cJCBK05C-s',
        },
        body : jsonEncode(
          <String, dynamic> {
            'priority' : 'high',
            'data' : <String, dynamic> {
              'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
              'status' : 'done',
              'body' : body,
              'title' : title,
            },
            "notification" : <String, dynamic> {
              "title" : title,
              "body" : body,
              "android_channel_id" : "dbfood"
            },
            "to" : token,
          },
        ),
      );
    }


  late GoogleMapController googleMapController;

  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(26.867115155882168, 75.81906668466156), zoom: 14);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        // leading: IconButton(
        //   onPressed: () {},
        //   icon: Icon(
        //     Icons.arrow_back_ios_rounded,
        //     color: Colors.black,
        //   ),
        // ),
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              Position position = await _determinePosition();

              googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14,
                ),
              ));

              markers.clear();

              markers.add(
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(position.latitude, position.longitude),
                ),
              );

              setState(() {});
            },
            label: const Text("Current Location"),
            icon: const Icon(Icons.location_history),
          ),
          SizedBox(height: 16), // Add some spacing between the two buttons
          FloatingActionButton.extended(
            onPressed: () async {
              // String name = username.text
            },
            label: const Text("Ask for Help"),
            icon: const Icon(Icons.help),
          ),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    // print(position);
    return position;
  }
}