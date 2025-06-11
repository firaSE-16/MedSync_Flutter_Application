import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/core/providers.dart';
import 'package:medsync/data/models/prescription_model.dart';
import 'package:medsync/presentation/features/doctor/viewmodels/doctor_viewmodel.dart';

class DoctorEditPrescriptionScreen extends ConsumerStatefulWidget {
  final String prescriptionId;

  const DoctorEditPrescriptionScreen({super.key, required this.prescriptionId});

  @override
  ConsumerState<DoctorEditPrescriptionScreen> createState() => _DoctorEditPrescriptionScreenState();
}

class _DoctorEditPrescriptionScreenState extends ConsumerState<DoctorEditPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationsController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();
  late List<Medication> _medications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorViewModelProvider.notifier).fetchPrescriptionDetails(widget.prescriptionId);
    });
  }

  @override
  void dispose() {
    _medicationsController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addMedication() {
    if (_medicationsController.text.isNotEmpty &&
        _dosageController.text.isNotEmpty &&
        _frequencyController.text.isNotEmpty ) {
      ref.read(doctorViewModelProvider.notifier).addMedication(
        name: _medicationsController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
      );

      // Clear controllers
      _medicationsController.clear();
      _dosageController.clear();
      _frequencyController.clear();
      _durationController.clear();
    }
  }

  void _removeMedication(int index) {
    ref.read(doctorViewModelProvider.notifier).removeMedication(index);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final medications = _medications.map((m) => m.toJson()).toList();
      ref.read(doctorViewModelProvider.notifier).updatePrescription(
        widget.prescriptionId,
        medications: medications,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prescription'),
      ),
      body: doctorState.selectedPrescription?.when(
        data: (prescription) {
          if (prescription == null) {
            return const Center(child: Text('Prescription not found.'));
          }
          // Pre-fill form fields with existing prescription data
          _medications = prescription.medications;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'Add Medications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _medicationsController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _frequencyController,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addMedication,
                    child: const Text('Add Medication'),
                  ),
                  const SizedBox(height: 16),
                  if (doctorState.patientPrescriptions?.value?.isNotEmpty == true) ...[
                    const Text(
                      'Added Medications',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctorState.patientPrescriptions?.value?.first.medications.length ?? 0,
                      itemBuilder: (context, index) {
                        final medication = doctorState.patientPrescriptions?.value?.first.medications[index];
                        return Card(
                          child: ListTile(
                            title: Text(medication?.name ?? 'N/A'),
                            subtitle: Text(
                              '${medication?.dosage ?? 'N/A'} - ${medication?.frequency ?? 'N/A'}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeMedication(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Instructions',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: doctorState.patientPrescriptions?.isLoading == true ? null : _submitForm,
                    child: doctorState.patientPrescriptions?.isLoading == true
                        ? const CircularProgressIndicator()
                        : const Text('Update Prescription'),
                  ),
                  if (doctorState.patientPrescriptions?.hasError == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        doctorState.patientPrescriptions?.error.toString() ?? 'An error occurred',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading prescription: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(doctorViewModelProvider.notifier).fetchPrescriptionDetails(widget.prescriptionId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 