// screens/map/map_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/property.dart';
import '../../utils/translations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Property? _selectedProperty;
  final MapController _mapController = MapController();
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

  List<Marker> _buildMarkers(List<Property> properties) {
    // Lightweight sampling to keep performance acceptable at low zoom
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
      return Marker(
        point: latLng.LatLng(property.latitude, property.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedProperty = property);
            _mapController.move(
              latLng.LatLng(property.latitude, property.longitude),
              15,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: property.transactionType == 'sale'
                    ? Colors.red
                    : Colors.green,
                size: 50,
                shadows: const [
                  Shadow(color: Colors.black45, blurRadius: 4),
                ],
              ),
              Positioned(
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(property.price / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('map'.tr(context)),
        actions: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, _) {
              return IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: locationProvider.hasLocation
                    ? () {
                        _mapController.move(
                          latLng.LatLng(
                            locationProvider.latitude!,
                            locationProvider.longitude!,
                          ),
                          13,
                        );
                      }
                    : null,
                tooltip: 'Ma position',
              );
            },
          ),
        ],
      ),
      body: Consumer2<PropertyProvider, LocationProvider>(
        builder: (context, propertyProvider, locationProvider, _) {
          final properties = propertyProvider.properties;

          // Default center (Tunisia)
          latLng.LatLng center = const latLng.LatLng(36.8065, 10.1815);

          // Use user location if available
          if (locationProvider.hasLocation) {
            center = latLng.LatLng(
              locationProvider.latitude!,
              locationProvider.longitude!,
            );
          } else if (properties.isNotEmpty) {
            // Center on first property
            center = latLng.LatLng(
              properties.first.latitude,
              properties.first.longitude,
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
                    // Track zoom to adjust sampling density
                    final z = _mapController.camera.zoom;
                    if (z != _currentZoom) {
                      setState(() => _currentZoom = z);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.immobilier.app',
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

                  // Property markers (sampled by zoom for performance)
                  MarkerLayer(markers: _buildMarkers(properties)),
                ],
              ),

              // Loading indicator
              if (propertyProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Property card at bottom
              if (_selectedProperty != null) _buildPropertyCard(),

              // Legend
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 4),
                            const Text('Vente', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 4),
                            const Text('Location',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _selectedProperty!.images.isNotEmpty
                          ? _selectedProperty!.images.first
                          : '', // Empty triggers errorBuilder
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.home_work,
                              size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedProperty!.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _selectedProperty!.city,
                                style: TextStyle(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bed,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${_selectedProperty!.bedrooms}'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bathtub,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${_selectedProperty!.bathrooms}'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.square_foot,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${_selectedProperty!.surface}m²'),
                              ],
                            ),
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
              const SizedBox(height: 12),
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
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Voir détails'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _selectedProperty = null),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
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
}
