// lib/screens/driver/map_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/app_localizations.dart';
import '../../models/station.dart';
import 'station_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Station> stations = [];
  List<Station> filteredStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stations')
          .where('isActive', isEqualTo: true)
          .get();

      setState(() {
        stations = snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
        filteredStations = stations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stations: $e')),
      );
    }
  }

  void _filterStations(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStations = stations;
      } else {
        filteredStations = stations
            .where((station) =>
        station.name.toLowerCase().contains(query.toLowerCase()) ||
            station.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search and header section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.findStations ?? 'Find LPG Stations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterStations,
                    decoration: InputDecoration(
                      hintText: l10n.searchStations ?? 'Search for stations...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF757575)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Map placeholder and stations list
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
              )
                  : Column(
                children: [
                  // Map placeholder (for now showing a container)
                  Container(
                    height: 200,
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Color(0xFF757575),
                          ),
                          SizedBox(height: 8),
                          Text(
                            l10n.mapView ?? 'Map View',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '(${filteredStations.length} stations)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stations list
                  Expanded(
                    child: filteredStations.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Color(0xFF9E9E9E),
                          ),
                          SizedBox(height: 16),
                          Text(
                            l10n.noStationsFound ?? 'No stations found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredStations.length,
                      itemBuilder: (context, index) {
                        return _buildStationCard(filteredStations[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Center map to user location
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.centeringMap ?? 'Centering map to your location')),
          );
        },
        backgroundColor: Color(0xFF1E88E5),
        child: Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildStationCard(Station station) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StationDetailScreen(station: station),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Station icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.local_gas_station,
                  color: Color(0xFF1E88E5),
                  size: 24,
                ),
              ),

              SizedBox(width: 16),

              // Station info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      station.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${station.rating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '• ${station.distance?.toStringAsFixed(1) ?? "0.0"} km',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${station.currentPrice.toStringAsFixed(2)} ₾',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Add to favorites
                        },
                        icon: Icon(
                          station.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: station.isFavorite ? Colors.red : Color(0xFF757575),
                          size: 20,
                        ),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Get directions
                        },
                        icon: Icon(
                          Icons.directions,
                          color: Color(0xFF1E88E5),
                          size: 20,
                        ),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}