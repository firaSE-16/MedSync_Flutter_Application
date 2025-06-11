import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/core/providers.dart';
import 'package:medsync/presentation/features/doctor/viewmodels/doctor_viewmodel.dart';

class DoctorEditMedicalRecordScreen extends ConsumerStatefulWidget {
  final String recordId;
  final String patientId;

  const DoctorEditMedicalRecordScreen({super.key, required this.recordId, required this.patientId});

  @override
  ConsumerState<DoctorEditMedicalRecordScreen> createState() => _DoctorEditMedicalRecordScreenState();
}

class _DoctorEditMedicalRecordScreenState extends ConsumerState<DoctorEditMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorViewModelProvider.notifier).fetchMedicalRecordDetails(widget.recordId);
    });
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ref.read(doctorViewModelProvider.notifier).updateMedicalRecord(
        patientId: widget.patientId,
        widget.recordId,
        diagnosis: _diagnosisController.text,
        treatment: _treatmentController.text,
        notes: _notesController.text,
        
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medical Record'),
      ),
      body: doctorState.selectedMedicalRecord?.when(
        data: (record) {
          if (record == null) {
            return const Center(child: Text('Record not found.'));
          }
          // Pre-fill form fields with existing record data
          _diagnosisController.text = record.diagnosis;
          _treatmentController.text = record.treatment;
          _notesController.text = record.notes ?? '';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter diagnosis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _treatmentController,
                    decoration: const InputDecoration(
                      labelText: 'Treatment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter treatment';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: doctorState.patientMedicalRecords?.isLoading ?? false ? null : _submitForm,
                    child: doctorState.patientMedicalRecords?.isLoading ?? false
                        ? const CircularProgressIndicator()
                        : const Text('Update Record'),
                  ),
                  if (doctorState.patientMedicalRecords?.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        doctorState.patientMedicalRecords!.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading record: ${e.toString()}')),
      ) ?? const Center(child: Text('Loading...')),
    );
  }
} 