import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather_modal.dart';
import 'package:weather_app/service/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  final _weatherService = WeatherService(dotenv.env['API_KEY'] ?? "");
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    // get current city
    String cityName = await _weatherService.getCurrentLocation();
    print('Current city: $cityName'); // Add this to check the city name

    // get the weather
    try {
      final weather = await _weatherService.getWeather(cityName);
      print(
        'Weather fetched: ${weather.cityName}',
      ); // Add this to check the fetched data

      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Error fetching weather: $e'); // Error handling
    }
  }

  @override
  void initState() {
    super.initState();

    // fetch weather
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _weather == null
                ? const CircularProgressIndicator() // Loading indicator if weather is not available yet
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_weather?.cityName ?? "Loading city..."),
                    Text('${_weather?.temperature.round().toString()} \u00B0C'),
                    Text(_weather?.mainCondition ?? ""),
                  ],
                ),
      ),
    );
  }
}
