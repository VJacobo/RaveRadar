import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/rave_text_field.dart';
import '../../widgets/common/rave_button.dart';

class CreateLocationScreen extends StatefulWidget {
  final Function(LocationModel)? onLocationCreated;

  const CreateLocationScreen({super.key, this.onLocationCreated});

  @override
  State<CreateLocationScreen> createState() => _CreateLocationScreenState();
}

class _CreateLocationScreenState extends State<CreateLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _tagsController = TextEditingController();

  LocationType _selectedType = LocationType.venue;
  final List<String> _taggedUsers = [];
  final List<String> _amenities = [];
  final List<String> _availableAmenities = [
    'Bar',
    'Dance Floor',
    'VIP Area',
    'Outdoor Space',
    'Sound System',
    'Lighting',
    'Coat Check',
    'Parking',
    'Food',
    'Smoking Area'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _showUserTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: 'Enter username (without @)',
                prefixText: '@',
              ),
            ),
            const SizedBox(height: 16),
            if (_taggedUsers.isNotEmpty) ...[
              const Text('Tagged Users:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _taggedUsers.map((user) => Chip(
                  label: Text('@$user'),
                  onDeleted: () => setState(() => _taggedUsers.remove(user)),
                )).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final username = _tagsController.text.trim();
              if (username.isNotEmpty && !_taggedUsers.contains(username)) {
                setState(() => _taggedUsers.add(username));
                _tagsController.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAmenitiesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Amenities'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _availableAmenities.map((amenity) => CheckboxListTile(
              title: Text(amenity),
              value: _amenities.contains(amenity),
              onChanged: (checked) {
                setState(() {
                  if (checked ?? false) {
                    _amenities.add(amenity);
                  } else {
                    _amenities.remove(amenity);
                  }
                });
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _createLocation() {
    if (_formKey.currentState!.validate()) {
      final location = LocationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim().isEmpty 
            ? 'USA' 
            : _countryController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        amenities: _amenities,
        createdAt: DateTime.now(),
        createdBy: 'current_user',
        taggedUsers: _taggedUsers,
      );

      widget.onLocationCreated?.call(location);
      Navigator.pop(context, location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location'),
        backgroundColor: AppColors.backgroundSecondary,
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            RaveTextField(
              controller: _nameController,
              labelText: 'Location Name',
              validator: (value) => value?.isEmpty ?? true ? 'Location name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            
            DropdownButtonFormField<LocationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Location Type',
                border: OutlineInputBorder(),
              ),
              items: LocationType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(LocationModel(
                      id: '',
                      name: '',
                      address: '',
                      city: '',
                      state: '',
                      country: '',
                      type: type,
                      createdAt: DateTime.now(),
                      createdBy: '',
                    ).typeIcon, size: 20),
                    const SizedBox(width: 8),
                    Text(type.name.toUpperCase()),
                  ],
                ),
              )).toList(),
              onChanged: (type) => setState(() => _selectedType = type!),
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _addressController,
              labelText: 'Address',
              validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RaveTextField(
                    controller: _cityController,
                    labelText: 'City',
                    validator: (value) => value?.isEmpty ?? true ? 'City is required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: RaveTextField(
                    controller: _stateController,
                    labelText: 'State',
                    validator: (value) => value?.isEmpty ?? true ? 'State is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _countryController,
              labelText: 'Country (default: USA)',
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _descriptionController,
              labelText: 'Description (Optional)',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _phoneController,
              labelText: 'Phone Number (Optional)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _websiteController,
              labelText: 'Website (Optional)',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.md),
            
            ListTile(
              title: const Text('Amenities'),
              subtitle: _amenities.isNotEmpty 
                  ? Text('${_amenities.length} selected: ${_amenities.take(3).join(", ")}${_amenities.length > 3 ? "..." : ""}')
                  : const Text('No amenities selected'),
              trailing: const Icon(Icons.add),
              onTap: _showAmenitiesDialog,
            ),
            const SizedBox(height: AppSpacing.md),
            
            ListTile(
              title: const Text('Tag Users'),
              subtitle: _taggedUsers.isNotEmpty 
                  ? Text('${_taggedUsers.length} users tagged')
                  : const Text('No users tagged'),
              trailing: const Icon(Icons.person_add),
              onTap: _showUserTagDialog,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            RaveButton(
              text: 'Add Location',
              onPressed: _createLocation,
            ),
          ],
        ),
      ),
    );
  }
}