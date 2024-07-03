import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;

  final String totalDistance;
  final String totalDuration;
  final String alternativeTotalDistance;
  final String alternativeTotalDuration;
  final List<PointLatLng> alternativePolylinePoints;

  const Directions({
    required this.alternativePolylinePoints,
    required this.alternativeTotalDistance,
    required this.alternativeTotalDuration,
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    //check route is not available
    if ((map['routes'] as List).isEmpty) throw Exception('routes are empty');

    final data = Map<String, dynamic>.from(map['routes'][0]);
    final routeList = map['routes'] as List;

    //bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );

    //distance & duration
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    // Map for allternative route
    List<PointLatLng> alternativeRoutePolyLinePoints;
    String alternativeDistance;
    String alternativeDuration;

    // If alternative is available
    if ((map['routes'] as List).length > 1) {
      final alternativeRoute = Map<String, dynamic>.from(map['routes'][1]);
      alternativeRoutePolyLinePoints = PolylinePoints()
          .decodePolyline(alternativeRoute['overview_polyline']['points']);

      alternativeDuration = alternativeRoute['legs'][0]['duration']['text'];
      alternativeDistance = alternativeRoute['legs'][0]['distance']['text'];
    } else {
      alternativeRoutePolyLinePoints = [];
      alternativeDistance = '';
      alternativeDuration = '';
    }

    return Directions(
        alternativePolylinePoints: alternativeRoutePolyLinePoints,
        alternativeTotalDistance: alternativeDistance,
        alternativeTotalDuration: alternativeDuration,
        bounds: bounds,
        polylinePoints: PolylinePoints()
            .decodePolyline(data['overview_polyline']['points']),
        totalDistance: distance,
        totalDuration: duration);
  }
}
