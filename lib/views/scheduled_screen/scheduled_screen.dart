import 'dart:async';

import 'package:driverapp/views/scheduled_screen/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ScheduledScreen extends StatefulWidget {
  const ScheduledScreen({super.key});

  @override
  State<ScheduledScreen> createState() => _ScheduledScreenState();
}

class _ScheduledScreenState extends State<ScheduledScreen> {
  static const CameraPosition _kGooglePlex =
  CameraPosition(target: LatLng(33.981140, 72.908560), zoom: 15);

  static const LatLng sourceLocation = LatLng(33.981140, 72.908560);
  static const LatLng destination = LatLng(34.024049, 72.919203);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  Location location = Location();
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getPolylinePoints();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    currentLocation = await location.getLocation();
    locationSubscription = location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      // _updateCurrentLocationMarker();
    });
  }

  Future<void> getPolylinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
    );
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
      googleApiKey: googleAPIkeys,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    }
  }
  // void _updateCurrentLocationMarker() {
  //   if (currentLocation != null) {
  //     setState(() {
  //       markers.removeWhere((m) => m.markerId.value == 'currentLocation');
  //       markers.add(Marker(
  //         markerId: MarkerId('currentLocation'),
  //         position:
  //         LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //       ));
  //     });
  //   }
  // }
  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('source'),
      position: sourceLocation,
    ),
    Marker(
      markerId: MarkerId('destination'),
      position: destination,
    ),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Rides'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: markers,
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                color: primaryColor,
                width: 6,
                points: polylineCoordinates,
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ],
      ),
    );
  }
}
