import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'directions_model.dart';
import 'google_api_keys.dart';


class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  // +'origin=2R8X%2BR4%20Bahçelievler%20İstanbul&destination=2R8W%2BX7%20Bahçelievler%20İstanbul' +
  // '&waypoints=via:2RCW%2B26%20Bahçelievler%20İstanbul|via:2RGW%2BF4%20Bağcılar%20İstanbul|via:2RJQ%2B4C%20Bağcılar%20İstanbul' +
  // '&key=${googleAPIKey}';

  final Dio _dio;

  DirectionsRepository({ Dio? dio}) : _dio = dio ?? Dio();


  Future<Directions?> getDirections({
    required bool alternatives,
    required LatLng origin,
    required LatLng destination,
    required String mode,
  }) async {

    // Waypoints doesnt work correctly
    //  final waypoints =
    //      'XVW4%2BRC%20Bahçelievler%20İstanbul';


    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': '$mode',
      // 'waypoints':'${waypoints}',
      'alternatives': alternatives ? 'true' : 'false',
      'key': googleAPIkey,
    });

    if (response.statusCode == 200) {
      log(response.data.toString());
      return Directions.fromMap(response.data);
    }
    return null;
  }
}