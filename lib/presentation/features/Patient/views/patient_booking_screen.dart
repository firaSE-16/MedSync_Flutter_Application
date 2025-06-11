import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medsync/core/providers.dart';
import 'package:intl/intl.dart';

class PatientBookingScreen extends ConsumerStatefulWidget {
  const PatientBookingScreen({super.key});

  @override
  _PatientBookingScreenState createState() => _PatientBookingScreenState();
}

class _PatientBookingScreenState extends ConsumerState<PatientBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _lookingFor;
  String? _priority;

  final List<String> _specializations = [
    'dermatologist',
    'pathologist',
    'cardiologist',
    'neurologist',
    'pediatrician',
    'psychiatrist',
    'general physician',
    'dentist',
    'ophthalmologist',
    'orthopedist',
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = '$hour:$minute';
      });
    }
  }

  // Method to clear all form fields and reset selections
  void _clearForm() {
    _formKey.currentState?.reset(); // Resets all form fields that have initial values
    _dateController.clear();
    _timeController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _lookingFor = null;
      _priority = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Specialization'),
                value: _lookingFor, // Set current value to display after clearing
                items: _specializations.map((specialization) {
                  return DropdownMenuItem(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _lookingFor = value),
                validator: (value) => value == null ? 'Please select a specialization' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Preferred Date'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value!.isEmpty ? 'Please select a date' : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Preferred Time'),
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: (value) => value!.isEmpty ? 'Please select a time' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Priority'),
                value: _priority, // Set current value to display after clearing
                items: ['low', 'medium', 'high', 'emergency'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _priority = value),
                validator: (value) => value == null ? 'Please select a priority' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedDate == null || _selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select both date and time')),
                      );
                      return;
                    }

                    try {
                      await ref.read(createBookingUseCaseProvider).call(
                            lookingFor: _lookingFor!,
                            preferredDate: _dateController.text,
                            preferredTime: _timeController.text,
                            priority: _priority,
                            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                            patientName: user?.name,
                          );

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking created successfully!')));

                      // Refresh bookings data
                      ref.refresh(patientBookingsProvider(null));

                      // Clear all form fields and reset selections
                      _clearForm();

                      // IMPORTANT: Removed context.pop(); to stay on the same screen

                    } catch (e) {
                      print('Booking Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create booking: $e')));
                    }
                  }
                },
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}