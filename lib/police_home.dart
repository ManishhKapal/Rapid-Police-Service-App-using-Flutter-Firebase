import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rps/polyline_response.dart';

class PoliceHomePage extends StatefulWidget {
  const PoliceHomePage({super.key});

  @override
  State<PoliceHomePage> createState() => _PoliceHomePageState();
}

class _PoliceHomePageState extends State<PoliceHomePage> {
  static const CameraPosition initialPosition =
      CameraPosition(target: LatLng(26.867115155882168, 75.81906668466156), zoom: 14);

  final Completer<GoogleMapController> _controller = Completer();

  String totalDistance = "";
  String totalTime = "";

  String apiKey = "AIzaSyC0YFYJVB_NI6-jTwCEfAVIAnnW7laBlcc";

  LatLng origin = const LatLng(26.867115155882168, 75.81906668466156);
  LatLng destination = const LatLng(31.5525789, 74.2813495);

  PolylineResponse polylineResponse = PolylineResponse();

  Set<Polyline> polylinePoints = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyline"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            polylines: polylinePoints,
            zoomControlsEnabled: false,
            initialCameraPosition: initialPosition,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'From'),
                ),
                TextField(
                  decoration:
                      InputDecoration(border: InputBorder.none, hintText: 'To'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          drawPolyline();
        },
        child: const Icon(Icons.directions),
      ),
    );
  }

  void drawPolyline() async {
    var response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?key=" +
            apiKey +
            "&units=metric&origin=" +
            origin.latitude.toString() +
            "," +
            origin.longitude.toString() +
            "&destination=" +
            destination.latitude.toString() +
            "," +
            destination.longitude.toString() +
            "&mode=driving"));

    print(response.body);

    polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));

    totalDistance = polylineResponse.routes![0].legs![0].distance!.text!;
    totalTime = polylineResponse.routes![0].legs![0].duration!.text!;

    for (int i = 0;
        i < polylineResponse.routes![0].legs![0].steps!.length;
        i++) {
      polylinePoints.add(Polyline(
          polylineId: PolylineId(
              polylineResponse.routes![0].legs![0].steps![i].polyline!.points!),
          points: [
            LatLng(
                polylineResponse
                    .routes![0].legs![0].steps![i].startLocation!.lat!,
                polylineResponse
                    .routes![0].legs![0].steps![i].startLocation!.lng!),
            LatLng(
                polylineResponse
                    .routes![0].legs![0].steps![i].endLocation!.lat!,
                polylineResponse
                    .routes![0].legs![0].steps![i].endLocation!.lng!),
          ],
          width: 3,
          color: Colors.red));
    }

    setState(() {});
  }
}
