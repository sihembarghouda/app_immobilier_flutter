class Property {
  final String id;
  final String title;
  final String description;
  final String type; // apartment, house, villa, etc.
  final String transactionType; // sale, rent
  final double price;
  final double surface; // m²
  final int rooms;
  final int bedrooms;
  final int bathrooms;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String ownerId;
  final String ownerName;
  final String? ownerPhone;
  final bool isFavorite;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.transactionType,
    required this.price,
    required this.surface,
    required this.rooms,
    required this.bedrooms,
    required this.bathrooms,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: provide sensible defaults when fields are missing/null
    String parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    double parseDouble(dynamic v) {
      try {
        if (v == null) return 0.0;
        return double.parse(v.toString());
      } catch (_) {
        return 0.0;
      }
    }

    int parseInt(dynamic v) {
      try {
        if (v == null) return 0;
        return int.parse(v.toString());
      } catch (_) {
        // fallback for non-int numeric values
        try {
          return (double.parse(v.toString())).toInt();
        } catch (_) {
          return 0;
        }
      }
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    final imgs = <String>[];
    try {
      if (json['images'] is List) {
        imgs.addAll(List<String>.from(
            json['images'].where((e) => e != null).map((e) => e.toString())));
      }
    } catch (_) {}

    return Property(
      id: parseString(json['id']),
      title: parseString(json['title']),
      description: parseString(json['description']),
      type: parseString(json['type']),
      transactionType: parseString(json['transaction_type']),
      price: parseDouble(json['price']),
      surface: parseDouble(json['surface']),
      rooms: parseInt(json['rooms']),
      bedrooms: parseInt(json['bedrooms']),
      bathrooms: parseInt(json['bathrooms']),
      address: parseString(json['address']),
      city: parseString(json['city']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      images: imgs,
      ownerId: parseString(json['owner_id']),
      ownerName: parseString(json['owner_name']),
      ownerPhone:
          json['owner_phone'] == null ? null : parseString(json['owner_phone']),
      isFavorite:
          json['is_favorite'] == null ? false : (json['is_favorite'] == true),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'transaction_type': transactionType,
      'price': price,
      'surface': surface,
      'rooms': rooms,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Property copyWith({bool? isFavorite}) {
    return Property(
      id: id,
      title: title,
      description: description,
      type: type,
      transactionType: transactionType,
      price: price,
      surface: surface,
      rooms: rooms,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      images: images,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
