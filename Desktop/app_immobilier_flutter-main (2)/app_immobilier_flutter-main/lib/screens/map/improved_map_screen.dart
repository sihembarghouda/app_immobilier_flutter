// screens/map/improved_map_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:url_launcher/url_launcher.dart';

import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/property.dart';
import '../../utils/translations.dart';
import '../../utils/distance_calculator.dart';

class ImprovedMapScreen extends StatefulWidget {
  const ImprovedMapScreen({super.key});

  @override
  State<ImprovedMapScreen> createState() => _ImprovedMapScreenState();
}

class _ImprovedMapScreenState extends State<ImprovedMapScreen> {
  Property? _selectedProperty;
  final MapController _mapController = MapController();
  String? _selectedType;
  String? _selectedTransaction;
  double _currentZoom = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperties();
    });
  }

  void _loadProperties() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    if (propertyProvider.properties.isEmpty) {
      propertyProvider.fetchProperties();
    }
  }

  List<Property> _getFilteredProperties(List<Property> properties) {
    return properties.where((p) {
      if (_selectedType != null && p.type != _selectedType) return false;
      if (_selectedTransaction != null &&
          p.transactionType != _selectedTransaction) return false;
      return true;
    }).toList();
  }

  List<Marker> _buildMarkers(
      List<Property> properties, LocationProvider locationProvider) {
    int step = 1;
    if (_currentZoom < 8) {
      step = 8;
    } else if (_currentZoom < 10) {
      step = 5;
    } else if (_currentZoom < 12) {
      step = 3;
    }

    final Iterable<Property> toRender = properties
        .asMap()
        .entries
        .where((e) => e.key % step == 0)
        .map((e) => e.value);

    return toRender.map((property) {
      // Calculate distance if user location is available
      String? distanceText;
      if (locationProvider.hasLocation) {
        final distance = DistanceCalculator.calculateDistance(
          locationProvider.latitude!,
          locationProvider.longitude!,
          property.latitude,
          property.longitude,
        );
        distanceText = DistanceCalculator.formatDistance(distance);
      }

      final isSelected = _selectedProperty?.id == property.id;

      return Marker(
        point: latLng.LatLng(property.latitude, property.longitude),
        width: isSelected ? 70 : 60,
        height: isSelected ? 90 : 80,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedProperty = property);
            _mapController.move(
              latLng.LatLng(property.latitude, property.longitude),
              15,
            );
          },
          child: Column(
            children: [
              if (distanceText != null && isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    distanceText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: property.transactionType == 'sale'
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                    size: isSelected ? 60 : 50,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  Positioned(
                    top: isSelected ? 12 : 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(property.price / 1000).toStringAsFixed(0)}K',
                        style: TextStyle(
                          fontSize: isSelected ? 11 : 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showRoute(Property property, LocationProvider locationProvider) async {
    if (!locationProvider.hasLocation) {
      await locationProvider.getCurrentLocation();
    }

    if (locationProvider.hasLocation) {
      final origin =
          '${locationProvider.latitude},${locationProvider.longitude}';
      final destination = '${property.latitude},${property.longitude}';
      final url =
          'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';

      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'obtenir votre position')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('map'.tr(context)),
        elevation: 0,
        actions: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, _) {
              return IconButton(
                icon: Icon(
                  locationProvider.hasLocation
                      ? Icons.my_location
                      : Icons.location_disabled,
                ),
                onPressed: () async {
                  await locationProvider.getCurrentLocation();
                  if (locationProvider.hasLocation) {
                    _mapController.move(
                      latLng.LatLng(
                        locationProvider.latitude!,
                        locationProvider.longitude!,
                      ),
                      13,
                    );
                  }
                },
                tooltip: 'Ma position',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value.startsWith('type_')) {
                  final type = value.substring(5);
                  _selectedType = type == 'all' ? null : type;
                } else if (value.startsWith('trans_')) {
                  final trans = value.substring(6);
                  _selectedTransaction = trans == 'all' ? null : trans;
                }
                _selectedProperty = null;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'type_all',
                child: Text('Tous les types'),
              ),
              const PopupMenuItem(
                value: 'type_apartment',
                child: Text('Appartements'),
              ),
              const PopupMenuItem(
                value: 'type_house',
                child: Text('Maisons'),
              ),
              const PopupMenuItem(
                value: 'type_villa',
                child: Text('Villas'),
              ),
              const PopupMenuItem(
                value: 'type_studio',
                child: Text('Studios'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'trans_all',
                child: Text('Toutes transactions'),
              ),
              const PopupMenuItem(
                value: 'trans_sale',
                child: Text('À vendre'),
              ),
              const PopupMenuItem(
                value: 'trans_rent',
                child: Text('À louer'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<PropertyProvider, LocationProvider>(
        builder: (context, propertyProvider, locationProvider, _) {
          final allProperties = propertyProvider.properties;
          final filteredProperties = _getFilteredProperties(allProperties);

          // Default center (Tunisia)
          latLng.LatLng center = const latLng.LatLng(36.8065, 10.1815);

          // Use user location if available
          if (locationProvider.hasLocation) {
            center = latLng.LatLng(
              locationProvider.latitude!,
              locationProvider.longitude!,
            );
          } else if (filteredProperties.isNotEmpty) {
            // Center on first property
            center = latLng.LatLng(
              filteredProperties.first.latitude,
              filteredProperties.first.longitude,
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 12,
                  minZoom: 5,
                  maxZoom: 18,
                  onMapEvent: (evt) {
                    final z = _mapController.camera.zoom;
                    if (z != _currentZoom) {
                      setState(() => _currentZoom = z);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.immobilier_app',
                  ),
                  // User location marker
                  if (locationProvider.hasLocation)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latLng.LatLng(
                            locationProvider.latitude!,
                            locationProvider.longitude!,
                          ),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 3),
                            ),
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Property markers
                  MarkerLayer(
                    markers:
                        _buildMarkers(filteredProperties, locationProvider),
                  ),
                ],
              ),

              // Stats card at top
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.home,
                          '${filteredProperties.length}',
                          'Propriétés',
                          Colors.blue,
                        ),
                        _buildStatItem(
                          Icons.sell,
                          '${filteredProperties.where((p) => p.transactionType == 'sale').length}',
                          'À vendre',
                          Colors.red,
                        ),
                        _buildStatItem(
                          Icons.key,
                          '${filteredProperties.where((p) => p.transactionType == 'rent').length}',
                          'À louer',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selected property details card
              if (_selectedProperty != null)
                _buildPropertyDetailsCard(locationProvider),

              // Loading indicator
              if (propertyProvider.isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetailsCard(LocationProvider locationProvider) {
    if (_selectedProperty == null) return const SizedBox();

    // Calculate distance and time
    String? distanceText;
    String? timeText;
    if (locationProvider.hasLocation) {
      final distance = DistanceCalculator.calculateDistance(
        locationProvider.latitude!,
        locationProvider.longitude!,
        _selectedProperty!.latitude,
        _selectedProperty!.longitude,
      );
      distanceText = DistanceCalculator.formatDistance(distance);
      final time = DistanceCalculator.calculateEstimatedTime(distance);
      timeText = DistanceCalculator.formatTime(time);
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Property Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _selectedProperty!.images.isNotEmpty
                          ? _selectedProperty!.images.first
                          : '', // Empty triggers errorBuilder
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.home_work,
                              size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Property Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProperty!.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _selectedProperty!.city,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Distance and Time
                        if (distanceText != null && timeText != null)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.near_me,
                                        size: 14, color: Colors.blue.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      distanceText,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 14,
                                        color: Colors.orange.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeText,
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        // Property specs
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _buildSpec(
                                Icons.bed, '${_selectedProperty!.bedrooms}'),
                            _buildSpec(Icons.bathtub,
                                '${_selectedProperty!.bathrooms}'),
                            _buildSpec(Icons.square_foot,
                                '${_selectedProperty!.surface.toInt()}m²'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_selectedProperty!.price.toStringAsFixed(0)} TND',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/property-detail',
                          arguments: _selectedProperty!.id,
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 20),
                      label: const Text('Détails'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showRoute(_selectedProperty!, locationProvider),
                      icon: const Icon(Icons.directions, size: 20),
                      label: const Text('Itinéraire'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _selectedProperty = null),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildSpec(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
