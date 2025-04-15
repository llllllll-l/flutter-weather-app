import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_modal.dart';
import 'package:weather_app/service/weather_service.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunwithclouds.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/clouds.json';
      case 'snow':
        return 'assets/snow.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/storm.json';
      case 'clear':
        return 'assets/sun.json';
      default:
        return 'assets/sunwithclouds.json';
    }
  }

  @override
  void initState() {
    super.initState();

    // fetch weather
    _fetchWeather(); // testing for animations, I do not want to reach the limit by accident
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
                    // location marker
                    const Icon(Icons.location_on, size: 32, color: Colors.red),
                    // city
                    Text(
                      _weather?.cityName ?? "Loading city...",
                      style: GoogleFonts.openSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 140),

                    // animation
                    Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

                    const SizedBox(height: 70),

                    // temp
                    Text(
                      '${_weather?.temperature.round().toString()} \u00B0C',
                      style: GoogleFonts.openSans(fontSize: 22),
                    ),
                  ],
                ),
      ),
    );
  }
}
