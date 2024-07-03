import 'package:driverapp/views/home_screen/map_style.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driverapp/views/home_screen/direction_repository.dart';
import 'package:driverapp/views/home_screen/directions_model.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String chosenValue = 'driving';

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(41.017901, 28.847953),
    zoom: 16.5,
  );

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  bool _checked = false;
  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions ? _info;
  Set<Polyline> _polylines = {};

  late BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker1.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        centerTitle: false,
        title: const Text("Waste Management"),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin!.position,
                    zoom: 16.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text("ORIGIN"),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 16.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text("DESTINATION"),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
              // Uncomment and define Utils.mapStyle if you have a custom map style
              controller.setMapStyle(Utils.mapStyle);
            },
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            polylines: _polylines,
            onLongPress: _addMarker,
          ),
          buildDropDownMenu(context),
          buildAlternativesCheckBox(),
          if (_info != null) buildDurationAndDistanceContainer(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        onPressed: () => _googleMapController.animateCamera(_info != null
            ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCameraPosition)),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  Positioned buildAlternativesCheckBox() {
    return Positioned(
      left: 10,
      bottom: 20,
      child: Column(
        children: [
          Text(
            'ALTERNATIVES',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              checkColor: Colors.green,
              activeColor: Colors.transparent,
              value: _checked,
              onChanged: (bool? value) {
                setState(() {
                  _checked = value ?? false;
                });
              }),
        ],
      ),
    );
  }

  Positioned buildDropDownMenu(BuildContext context) {
    return Positioned(
      bottom: 20,
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            )
          ],
        ),
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: DropdownButton<String>(
            dropdownColor: Colors.grey,
            value: chosenValue,
            style: TextStyle(color: Colors.white, fontSize: 20),
            items: <String>[
              'driving',
              'walking',
              'bicycling',
              'transit',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            hint: Text(
              "Mod",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
            onChanged: (String? value) {
              setState(() {
                chosenValue = value!;
              });
            },
          ),
        ),
      ),
    );
  }

  Positioned buildDurationAndDistanceContainer(BuildContext context) {
    return Positioned(
      top: 20,
      child: Column(
        children: [
          Container(
            height: 45.0,
            width: MediaQuery.of(context).size.width / 1.5,
            padding: const EdgeInsets.symmetric(
              vertical: 6.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(204, 147, 70, 140),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                )
              ],
            ),
            child: Center(
              child: Text(
                '${_info!.totalDistance}, ${_info!.totalDuration}',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          if (_info!.alternativePolylinePoints != null)
            Container(
              height: 45.0,
              width: MediaQuery.of(context).size.width / 1.5,
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.5),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  'Alternative: ${_info!.alternativeTotalDistance}, ${_info!.alternativeTotalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _destination = null;
        _info = null;
        _polylines.clear();
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      final directions = await DirectionsRepository().getDirections(
        mode: chosenValue,
        origin: _origin!.position,
        destination: pos,
        alternatives: _checked,
      );

      // Directions is not empty make these
      if (directions != null) {
        Polyline polyline;
        // Refresh screen
        setState(() {
          _info = directions;
          polyline = Polyline(
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(204, 147, 70, 140),
              width: 6,
              points: _info!.polylinePoints
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList());

          _polylines.add(polyline);
          if (_info!.alternativePolylinePoints != null) {
            polyline = Polyline(
                polylineId: PolylineId("poly1"),
                color: Color.fromRGBO(255, 255, 255, 0.5),
                width: 7,
                points: _info!.alternativePolylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList());
            _polylines.add(polyline);
          }
        });
      }
    }
  }


}
