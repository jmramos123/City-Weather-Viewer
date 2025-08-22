// lib/main.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Weather Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _weatherData;
  String? _errorMessage;

// read compile-time string set with --dart-define
  static final String _apiKey =
      const String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: '');

  Future<void> _fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a city name.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _weatherData = null;
    });

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'q': city.trim(),
        'appid': _apiKey,
        'units': 'metric', // use 'imperial' for °F
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResp = json.decode(response.body);
        setState(() {
          _weatherData = jsonResp;
        });
      } else if (response.statusCode == 404) {
        // city not found
        setState(() {
          _errorMessage = 'City not found. Please check the city name.';
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Invalid API key. Check your OpenWeatherMap API key.';
        });
      } else {
        setState(() {
          _errorMessage = 'Server error (${response.statusCode}). Try again later.';
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _errorMessage = 'Network error. Please check your internet connection.';
      });
    } on FormatException catch (_) {
      setState(() {
        _errorMessage = 'Bad response format.';
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildWeatherCard() {
    if (_weatherData == null) return const SizedBox.shrink();

    final main = _weatherData!['main'] as Map<String, dynamic>?;
    final weatherList = _weatherData!['weather'] as List<dynamic>?;
    final name = _weatherData!['name'] as String? ?? '';

    final temp = main != null && main['temp'] != null ? (main['temp']).toString() : '--';
    final description = (weatherList != null && weatherList.isNotEmpty)
        ? (weatherList[0]['description'] as String?) ?? ''
        : '';
    final iconCode = (weatherList != null && weatherList.isNotEmpty) ? weatherList[0]['icon'] as String? : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (iconCode != null)
              Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 64,
                height: 64,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud_outlined, size: 64),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('$temp °C', style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Weather Viewer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter a city name', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _fetchWeather(value),
              decoration: InputDecoration(
                hintText: 'e.g. London',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _cityController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loading ? null : () => _fetchWeather(_cityController.text),
              icon: const Icon(Icons.cloud),
              label: const Text('Get Weather'),
            ),

            if (_loading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],

            if (_errorMessage != null && !_loading) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ],

            if (_weatherData != null && !_loading) _buildWeatherCard(),

            const SizedBox(height: 24),

            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('- Uses OpenWeatherMap current weather API.'),
            const Text('- Handles city not found, network errors, and invalid API key.'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
