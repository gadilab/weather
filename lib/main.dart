import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:developer';
import 'model_cuaca/Model_cuaca1.dart';
import 'package:remixicon/remixicon.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<MyApp> {
  final TextEditingController _searchController = TextEditingController();

  Result? cityData;
  bool isLoading = false;
  String errorMessage = '';
  List<Result> hasilpencarian = [];
  bool searching = false;

  Future<void> searchCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      setState(() {
        hasilpencarian = [];
      });
      return;
    }
    setState(() {
      searching = true;
    });

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName.trim())}&count=5&format=json',
    );

    try {
      final response = await http.get(url);
      log(response.body);
      if (response.statusCode == 200) {
        final parsedData = modelCuacaFromJson(response.body);
        setState(() {
          hasilpencarian = parsedData.results; // Simpan semua list kota
        });
        final results = parsedData.results;

        if (results.isNotEmpty) {
          setState(() {
            cityData = results[0];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = " ${cityName}tidak ditemukan!";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Gagal mengambil data dari server...';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi internet.';
        isLoading = false;
      });
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cari Kota'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama kota...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  searchCity(_searchController.text.trim());
                  _searchController.clear();
                }
                Navigator.pop(context);
              },
              child: const Text('search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.location_on, color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                if (isLoading)
                  const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else if (errorMessage.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // NAMA KOTA & WILAYAH
                  Text(
                    cityData != null ? cityData!.name : 'Jakarta',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    cityData != null
                        ? '${cityData!.admin1}, ${cityData!.country}'
                        : 'Updated just now',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // SUHU UTAMA
                  const Text(
                    '23°',
                    style: TextStyle(
                      fontSize: 84,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Partly Cloudy',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cityData != null
                        ? 'Lat: ${cityData!.latitude}  Long: ${cityData!.longitude}'
                        : 'H: 34°   L: 26°',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // BADGE UV INDEX (Glassmorphism)
                  GlassmorphicContainer(
                    width: 180,
                    height: 38,
                    borderRadius: 20,
                    blur: 15,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'High UV index today',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // KARTU HOURLY FORECAST (Glassmorphism + WeatherIcons)
                  GlassmorphicContainer(
                    width: double.infinity,
                    height: 140,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 1.5,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOURLY FORECAST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildHourlyItem('Now', Remix.sun_line, '23°'),
                              _buildHourlyItem(
                                '14:00',
                                Remix.sun_foggy_line,
                                '23°',
                              ),
                              _buildHourlyItem(
                                '13:00',
                                Remix.cloudy_line,
                                '23°',
                              ),
                              _buildHourlyItem(
                                '16:00',
                                Remix.sun_cloudy_line,
                                '21°',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyItem(String time, IconData icon, String temp) {
    return Column(
      children: [
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 13)),
        const SizedBox(height: 6),
        Icon(icon, color: Colors.amberAccent, size: 22),
        const SizedBox(height: 6),
        Text(
          temp,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
