import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/rave_text_field.dart';
import '../../widgets/common/rave_button.dart';

class CreateEventScreen extends StatefulWidget {
  final Function(EventModel)? onEventCreated;

  const CreateEventScreen({super.key, this.onEventCreated});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ticketUrlController = TextEditingController();
  final _artistsController = TextEditingController();
  final _tagsController = TextEditingController();

  EventType _selectedType = EventType.clubNight;
  DateTime _startTime = DateTime.now().add(const Duration(days: 1));
  DateTime? _endTime;
  final List<String> _taggedUsers = [];
  final List<String> _genres = [];

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ticketUrlController.dispose();
    _artistsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _selectDateTime(bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : (_endTime ?? _startTime.add(const Duration(hours: 4))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : (_endTime ?? _startTime.add(const Duration(hours: 4)))
        ),
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartTime) {
            _startTime = selectedDateTime;
            if (_endTime != null && _endTime!.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 4));
            }
          } else {
            _endTime = selectedDateTime;
          }
        });
      }
    }
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

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      final artists = _artistsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final event = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        venue: _venueController.text.trim(),
        location: _locationController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        type: _selectedType,
        artists: artists,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        price: _priceController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_priceController.text.trim()),
        ticketUrl: _ticketUrlController.text.trim().isEmpty 
            ? null 
            : _ticketUrlController.text.trim(),
        source: EventSource.eventbrite,
        genres: _genres,
      );

      widget.onEventCreated?.call(event);
      Navigator.pop(context, event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
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
              labelText: 'Event Name',
              validator: (value) => value?.isEmpty ?? true ? 'Event name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            
            DropdownButtonFormField<EventType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Event Type',
                border: OutlineInputBorder(),
              ),
              items: EventType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              )).toList(),
              onChanged: (type) => setState(() => _selectedType = type!),
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _venueController,
              labelText: 'Venue',
              validator: (value) => value?.isEmpty ?? true ? 'Venue is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _locationController,
              labelText: 'Location',
              validator: (value) => value?.isEmpty ?? true ? 'Location is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _artistsController,
              labelText: 'Artists (comma separated)',
            ),
            const SizedBox(height: AppSpacing.md),
            
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text('${_startTime.toLocal()}'.split('.')[0]),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectDateTime(true),
            ),
            
            ListTile(
              title: const Text('End Time (Optional)'),
              subtitle: Text(_endTime != null 
                  ? '${_endTime!.toLocal()}'.split('.')[0]
                  : 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectDateTime(false),
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _descriptionController,
              labelText: 'Description (Optional)',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _priceController,
              labelText: 'Price (Optional)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            
            RaveTextField(
              controller: _ticketUrlController,
              labelText: 'Ticket URL (Optional)',
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
              text: 'Create Event',
              onPressed: _createEvent,
            ),
          ],
        ),
      ),
    );
  }
}