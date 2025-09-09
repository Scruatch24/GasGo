// lib/screens/owner/owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/station.dart';
import 'edit_station_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final AuthService _authService = AuthService();
  List<Station> myStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyStations();
  }

  Future<void> _loadMyStations() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stations')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      setState(() {
        myStations = snapshot.docs.map((doc) => Station.fromFirestore(doc)).toList();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMyStations,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E88E5),
                        Color(0xFF1976D2),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Icon(Icons.business, color: Color(0xFF1E88E5))
                                : null,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.welcomeBack ?? 'Welcome back',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  user?.displayName ?? user?.email?.split('@')[0] ?? 'Owner',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              l10n.owner ?? 'Owner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        l10n.manageStations ?? 'Manage Your Stations',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Statistics cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.business,
                          value: myStations.length.toString(),
                          label: l10n.totalStations ?? 'Total Stations',
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          value: _calculateAverageRating().toStringAsFixed(1),
                          label: l10n.avgRating ?? 'Avg Rating',
                          color: Color(0xFFFFB300),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Active/Inactive stations
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          value: myStations.where((s) => s.isActive).length.toString(),
                          label: l10n.activeStations ?? 'Active',
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.pending,
                          value: myStations.where((s) => !s.isActive).length.toString(),
                          label: l10n.pendingApproval ?? 'Pending',
                          color: Color(0xFFFF7043),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Stations list
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              l10n.myStations ?? 'My Stations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Spacer(),
                            if (myStations.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // TODO: View all stations
                                },
                                child: Text(l10n.viewAll ?? 'View All'),
                              ),
                          ],
                        ),
                      ),

                      if (isLoading)
                        Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
                          ),
                        )
                      else if (myStations.isEmpty)
                        _buildEmptyState(l10n)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: myStations.take(3).length, // Show first 3 stations
                          separatorBuilder: (context, index) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _buildStationItem(myStations[index]);
                          },
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFF1E88E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_business,
              size: 40,
              color: Color(0xFF1E88E5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            l10n.noStationsYet ?? 'No Stations Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 8),
          Text(
            l10n.addFirstStation ?? 'Add your first station to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add station tab
              DefaultTabController.of(context)?.animateTo(1);
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              l10n.addStation ?? 'Add Station',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E88E5),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationItem(Station station) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: station.isActive
              ? Color(0xFF4CAF50).withOpacity(0.1)
              : Color(0xFFFF7043).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.local_gas_station,
          color: station.isActive ? Color(0xFF4CAF50) : Color(0xFFFF7043),
          size: 20,
        ),
      ),
      title: Text(
        station.name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station.address,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: station.isActive
                      ? Color(0xFF4CAF50).withOpacity(0.1)
                      : Color(0xFFFF7043).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  station.isActive
                      ? (l10n.active ?? 'Active')
                      : (l10n.pending ?? 'Pending'),
                  style: TextStyle(
                    fontSize: 12,
                    color: station.isActive ? Color(0xFF4CAF50) : Color(0xFFFF7043),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${station.currentPrice.toStringAsFixed(2)} ₾/L',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStationScreen(station: station),
                ),
              );
              break;
            case 'updatePrice':
              _showUpdatePriceDialog(station);
              break;
            case 'toggle':
              _toggleStationStatus(station);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text(l10n.edit ?? 'Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'updatePrice',
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 16),
                SizedBox(width: 8),
                Text(l10n.updatePrice ?? 'Update Price'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'toggle',
            child: Row(
              children: [
                Icon(
                  station.isActive ? Icons.pause : Icons.play_arrow,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  station.isActive
                      ? (l10n.deactivate ?? 'Deactivate')
                      : (l10n.activate ?? 'Activate'),
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditStationScreen(station: station),
          ),
        );
      },
    );
  }

  double _calculateAverageRating() {
    if (myStations.isEmpty) return 0.0;
    double total = myStations.fold(0.0, (sum, station) => sum + station.rating);
    return total / myStations.length;
  }

  void _showUpdatePriceDialog(Station station) {
    final TextEditingController priceController = TextEditingController(
      text: station.currentPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Price'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Price per liter (₾)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                await _updateStationPrice(station, newPrice);
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStationPrice(Station station, double newPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(station.id)
          .update({
        'currentPrice': newPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _loadMyStations(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Price updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating price: $e')),
      );
    }
  }

  Future<void> _toggleStationStatus(Station station) async {
    try {
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(station.id)
          .update({
        'isActive': !station.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _loadMyStations(); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            station.isActive
                ? 'Station deactivated'
                : 'Station activated',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating station: $e')),
      );
    }
  }
}