// lib/screens/driver/favorites_screen.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/station.dart';
import 'station_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Station> favoriteStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // TODO: Load favorites from Firestore
    // For now, we'll simulate loading
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoading = false;
      // Mock data - replace with actual Firestore query
      favoriteStations = [];
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
            // Header
            Container(
              padding: EdgeInsets.all(20),
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
              child: Row(
                children: [
                  Text(
                    l10n.favorites ?? 'Favorite Stations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 28,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
              )
                  : favoriteStations.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: favoriteStations.length,
                itemBuilder: (context, index) {
                  return _buildFavoriteCard(favoriteStations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: Colors.red.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24),
          Text(
            l10n.noFavorites ?? 'No Favorite Stations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 8),
          Text(
            l10n.noFavoritesMessage ??
                'Start adding stations to your favorites by tapping the heart icon',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate back to map
              DefaultTabController.of(context)?.animateTo(0);
            },
            icon: Icon(Icons.map, color: Colors.white),
            label: Text(
              l10n.exploreStations ?? 'Explore Stations',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E88E5),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(Station station) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
          child: Column(
            children: [
              Row(
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
                      ],
                    ),
                  ),

                  // Actions
                  Column(
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
                      IconButton(
                        onPressed: () {
                          _removeFavorite(station);
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Get directions
                      },
                      icon: Icon(Icons.directions, size: 18),
                      label: Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF1E88E5),
                        side: BorderSide(color: Color(0xFF1E88E5)),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Price alert
                      },
                      icon: Icon(Icons.notifications_outlined, size: 18),
                      label: Text('Price Alert'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFFF7043),
                        side: BorderSide(color: Color(0xFFFF7043)),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeFavorite(Station station) {
    setState(() {
      favoriteStations.remove(station);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${station.name} removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              favoriteStations.add(station);
            });
          },
        ),
      ),
    );
  }
}