// screens/property/add_property_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/services/api_service.dart';
import '../../models/property.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? property; // Property to edit (null for adding new)

  const AddPropertyScreen({super.key, this.property});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedType = 'apartment';
  String _selectedTransactionType = 'sale';
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  bool get isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();

    // If editing, populate fields with existing data
    if (isEditing) {
      _titleController.text = widget.property!.title;
      _descriptionController.text = widget.property!.description;
      _priceController.text = widget.property!.price.toString();
      _surfaceController.text = widget.property!.surface.toString();
      _roomsController.text = widget.property!.rooms?.toString() ?? '';
      _bedroomsController.text = widget.property!.bedrooms?.toString() ?? '';
      _bathroomsController.text = widget.property!.bathrooms?.toString() ?? '';
      _addressController.text = widget.property!.address ?? '';
      _cityController.text = widget.property!.city ?? '';
      _selectedType = widget.property!.type;
      _selectedTransactionType = widget.property!.transactionType;
      _latitude = widget.property!.latitude;
      _longitude = widget.property!.longitude;
    }

    _getCurrentLocation();

    // Sync token from auth provider to api service
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        _apiService.setToken(authProvider.token!);
        print('✅ Token synced to API service in add_property_screen');
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (!locationProvider.hasLocation) {
      await locationProvider.getCurrentLocation();
    }
    if (locationProvider.hasLocation) {
      setState(() {
        _latitude = locationProvider.latitude;
        _longitude = locationProvider.longitude;
      });
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 50,
    );

    setState(() {
      _selectedImages = images;
    });
  }

  Future<void> _submitProperty() async {
    if (_formKey.currentState!.validate()) {
      // Check if location is available
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez activer la géolocalisation'),
            backgroundColor: Colors.orange,
          ),
        );
        await _getCurrentLocation();
        if (_latitude == null || _longitude == null) {
          return;
        }
      }

      setState(() => _isLoading = true);

      try {
        // Get current user
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.user == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Upload images if any selected
        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          print('📸 Uploading ${_selectedImages.length} images...');

          for (var i = 0; i < _selectedImages.length; i++) {
            try {
              final image = _selectedImages[i];
              print('📸 Processing image ${i + 1}: ${image.path}');
              String imageUrl;

              if (kIsWeb) {
                // For web, convert to base64
                final bytes = await image.readAsBytes();
                final base64Image =
                    'data:image/jpeg;base64,${base64Encode(bytes)}';
                imageUrl = await _apiService.uploadImage(base64Image);
              } else {
                // For mobile, use the file path directly
                print('📸 Using image path: ${image.path}');
                imageUrl = await _apiService.uploadImage(image.path);
                print('📸 Upload returned URL: $imageUrl');
              }

              if (imageUrl.isNotEmpty) {
                imageUrls.add(imageUrl);
                print(
                    '✅ Image ${i + 1}/${_selectedImages.length} uploaded successfully: $imageUrl');
              } else {
                print('⚠️ Image ${i + 1} upload returned empty URL');
              }
            } catch (e) {
              print('❌ Failed to upload image ${i + 1}: $e');
              // Continue with other images
            }
          }
        }

        print('📋 Total images uploaded: ${imageUrls.length}');
        print('📋 Image URLs: $imageUrls');

        // Use empty array if no images uploaded (will show fallback in UI)
        if (imageUrls.isEmpty && !isEditing) {
          imageUrls.add(''); // Empty string triggers errorWidget
        }

        final property = Property(
          id: isEditing
              ? widget.property!.id
              : DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          type: _selectedType,
          transactionType: _selectedTransactionType,
          price: double.parse(_priceController.text),
          surface: double.parse(_surfaceController.text),
          rooms: int.parse(_roomsController.text),
          bedrooms: int.parse(_bedroomsController.text),
          bathrooms: int.parse(_bathroomsController.text),
          address: _addressController.text,
          city: _cityController.text,
          latitude: _latitude!,
          longitude: _longitude!,
          images: imageUrls.isNotEmpty
              ? imageUrls
              : (isEditing ? widget.property!.images : ['']),
          ownerId: authProvider.user!.id.toString(),
          ownerName: authProvider.user!.name,
          ownerPhone: authProvider.user!.phone ?? '',
          createdAt: isEditing ? widget.property!.createdAt : DateTime.now(),
        );

        final propertyProvider =
            Provider.of<PropertyProvider>(context, listen: false);
        final success = isEditing
            ? await propertyProvider.updateProperty(property.id, property)
            : await propertyProvider.addProperty(property);

        if (mounted) {
          setState(() => _isLoading = false);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing
                    ? 'Annonce modifiée avec succès!'
                    : 'Annonce publiée avec succès!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing
                    ? 'Erreur lors de la modification'
                    : 'Erreur lors de la publication'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Submit property error: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'annonce' : 'Publier une annonce'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de l\'annonce',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type de bien',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'apartment', child: Text('Appartement')),
                DropdownMenuItem(value: 'house', child: Text('Maison')),
                DropdownMenuItem(value: 'villa', child: Text('Villa')),
                DropdownMenuItem(value: 'studio', child: Text('Studio')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTransactionType,
              decoration: const InputDecoration(
                labelText: 'Type de transaction',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sale', child: Text('Vente')),
                DropdownMenuItem(value: 'rent', child: Text('Location')),
              ],
              onChanged: (value) =>
                  setState(() => _selectedTransactionType = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prix (TND)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _surfaceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Surface (m²)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _roomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pièces',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Chambres',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SDB',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Champ requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: Text(_selectedImages.isEmpty
                  ? 'Ajouter des photos'
                  : '${_selectedImages.length} photo(s) sélectionnée(s)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitProperty,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEditing
                      ? 'Enregistrer les modifications'
                      : 'Publier l\'annonce'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _roomsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
