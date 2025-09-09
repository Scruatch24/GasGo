// lib/screens/driver/station_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/station.dart';
import '../../l10n/app_localizations.dart';

class StationDetailScreen extends StatefulWidget {
  final Station station;

  const StationDetailScreen({super.key, required this.station});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.station.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with images
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Color(0xFF1E88E5),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.station.photos.isNotEmpty
                  ? PageView.builder(
                itemCount: widget.station.photos.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.station.photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  );
                },
              )
                  : _buildPlaceholderImage(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic info
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.station.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF757575),
                              size: 18),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.station.address,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.star,
                            label: '${widget.station.rating.toStringAsFixed(
                                1)}',
                            sublabel: '(${widget.station.reviewCount} reviews)',
                            color: Color(0xFFFFB300),
                          ),
                          SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.directions,
                            label: '${widget.station.distance?.toStringAsFixed(
                                1) ?? "0.0"} km',
                            sublabel: l10n.away ?? 'away',
                            color: Color(0xFF1E88E5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_gas_station,
                        color: Color(0xFF2E7D32),
                        size: 32,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentPrice ?? 'Current Price',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            '${widget.station.currentPrice.toStringAsFixed(
                                2)} ₾/L',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Text(
                        l10n.lastUpdated ?? 'Last updated: Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Action buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getDirections,
                          icon: Icon(Icons.directions, color: Colors.white),
                          label: Text(
                            l10n.getDirections ?? 'Get Directions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1E88E5),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      if (widget.station.phoneNumber != null)
                        ElevatedButton(
                          onPressed: _callStation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE8F5E8),
                            foregroundColor: Color(0xFF2E7D32),
                            padding: EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Icon(Icons.phone, size: 24),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Working hours
                if (widget.station.workingHours.isNotEmpty)
                  _buildSection(
                    title: l10n.workingHours ?? 'Working Hours',
                    child: Column(
                      children: widget.station.workingHours.entries
                          .map((entry) =>
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getDayName(entry.key),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ))
                          .toList(),
                    ),
                  ),

                // Services
                if (widget.station.services.isNotEmpty)
                  _buildSection(
                    title: l10n.services ?? 'Services',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.station.services
                          .map((service) =>
                          Chip(
                            label: Text(service),
                            backgroundColor: Color(0xFFF5F5F5),
                            labelStyle: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 14,
                            ),
                          ))
                          .toList(),
                    ),
                  ),

                SizedBox(height: 20),

                // Reviews section
                _buildSection(
                  title: l10n.reviews ?? 'Reviews',
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Color(0xFFFFB300),
                                  size: 20),
                              SizedBox(width: 8),
                              Text(
                                '${widget.station.rating.toStringAsFixed(
                                    1)} out of 5',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${widget.station.reviewCount} reviews',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addReview,
                          icon: Icon(Icons.rate_review_outlined),
                          label: Text(l10n.addReview ?? 'Add Review'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF1E88E5),
                            side: BorderSide(color: Color(0xFF1E88E5)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Color(0xFF1E88E5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 16),
            Text(
              'LPG Station',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _getDayName(String dayCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (dayCode.toLowerCase()) {
      case 'monday':
      case 'mon':
        return l10n.monday ?? 'Monday';
      case 'tuesday':
      case 'tue':
        return l10n.tuesday ?? 'Tuesday';
      case 'wednesday':
      case 'wed':
        return l10n.wednesday ?? 'Wednesday';
      case 'thursday':
      case 'thu':
        return l10n.thursday ?? 'Thursday';
      case 'friday':
      case 'fri':
        return l10n.friday ?? 'Friday';
      case 'saturday':
      case 'sat':
        return l10n.saturday ?? 'Saturday';
      case 'sunday':
      case 'sun':
        return l10n.sunday ?? 'Sunday';
      default:
        return dayCode;
    }
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    // TODO: Update favorites in Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _getDirections() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget
        .station.latitude},${widget.station.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  void _callStation() async {
    if (widget.station.phoneNumber != null) {
      final url = 'tel:${widget.station.phoneNumber}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  void _addReview() {
    // TODO: Implement add review functionality
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Add Review'),
            content: Text(
                'Review functionality will be implemented in Phase 2'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }
}