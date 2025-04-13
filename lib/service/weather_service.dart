import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/models/weather_modal.dart';
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

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      throw Exception('No placemarks found.');
    }

    if (position.latitude == 56.1672813 && position.longitude == 15.5648974) {
      return 'Karlskrona';
    }

    final Placemark place = placemarks.first;

    // Karlskrona is a city, but might not show up in locality
    String? city = place.locality;
    if (city == null || city.isEmpty) {
      city = place.subAdministrativeArea;
    }
    if (city == null || city.isEmpty) {
      city = place.administrativeArea;
    }
    if (city == null || city.isEmpty) {
      throw Exception('City name could not be determined.');
    }

    return city;
  }
}
