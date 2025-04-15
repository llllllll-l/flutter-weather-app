import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/models/weather_modal.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = "http://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data...');
    }
  }

  Future<String> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    // use Google Geocoding API to get the city (a lot more accurate)
    return await getCityFromCoordinates(position.latitude, position.longitude);
  }

  Future<String> getCityFromCoordinates(double lat, double lng) async {
    try {
      final String? api_key = dotenv.env['GOOGLE_GEOCODING_API_KEY'] ?? "";
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$api_key';

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['status'] == 'OK') {
          for (var result in data['results']) {
            for (var component in result['address_components']) {
              if (component['types'].contains('locality')) {
                return component['long_name'];
              }
            }
          }
        }
        throw Exception('City not found in Google response.');
      } else {
        throw Exception('Google API error: ${res.statusCode}');
      }
    } catch (e) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          return place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              "Unknown location...";
        } else {
          throw Exception("No placemarks found.");
        }
      } catch (fellbackError) {
        throw Exception('Both geocoding methods failed: $fellbackError');
      }
    }
  }
}
