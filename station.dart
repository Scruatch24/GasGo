// lib/models/station.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double currentPrice;
  final double rating;
  final int reviewCount;
  final String? phoneNumber;
  final List<String> photos;
  final Map<String, String> workingHours;
  final List<String> services;
  final String ownerId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;
  final double? distance;

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.currentPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.phoneNumber,
    this.photos = const [],
    this.workingHours = const {},
    this.services = const [],
    required this.ownerId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.distance,
  });

  factory Station.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Station(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      currentPrice: (data['currentPrice'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      phoneNumber: data['phoneNumber'],
      photos: List<String>.from(data['photos'] ?? []),
      workingHours: Map<String, String>.from(data['workingHours'] ?? {}),
      services: List<String>.from(data['services'] ?? []),
      ownerId: data['ownerId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'currentPrice': currentPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'phoneNumber': phoneNumber,
      'photos': photos,
      'workingHours': workingHours,
      'services': services,
      'ownerId': ownerId,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Station copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? currentPrice,
    double? rating,
    int? reviewCount,
    String? phoneNumber,
    List<String>? photos,
    Map<String, String>? workingHours,
    List<String>? services,
    bool? isActive,
    bool? isFavorite,
    double? distance,
  }) {
    return Station(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentPrice: currentPrice ?? this.currentPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photos: photos ?? this.photos,
      workingHours: workingHours ?? this.workingHours,
      services: services ?? this.services,
      ownerId: ownerId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
    );
  }
}