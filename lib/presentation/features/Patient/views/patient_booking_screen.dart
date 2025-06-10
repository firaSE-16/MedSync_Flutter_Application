import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/core/providers.dart';

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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
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
                    try {
                      await ref.read(createBookingUseCaseProvider).call(
                            lookingFor: _lookingFor!,
                            preferredDate: _dateController.text,
                            preferredTime: _timeController.text,
                            priority: _priority,
                            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                            patientName: user?.name,
                          );
                      ref.refresh(patientBookingsProvider(null));
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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