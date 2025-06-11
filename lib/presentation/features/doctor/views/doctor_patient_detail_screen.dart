import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/core/providers.dart';
import 'package:medsync/presentation/navigation/routes.dart';
import 'package:medsync/presentation/features/doctor/viewmodels/doctor_viewmodel.dart';

class DoctorPatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;

  const DoctorPatientDetailScreen({super.key, required this.patientId});

  @override
  ConsumerState<DoctorPatientDetailScreen> createState() => _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends ConsumerState<DoctorPatientDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure we're not in the build phase
    Future.microtask(() {
      final notifier = ref.read(doctorViewModelProvider.notifier);
      notifier.fetchPatientDetails(widget.patientId);
      notifier.fetchPatientMedicalRecords(widget.patientId);
      notifier.fetchPatientPrescriptions(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorViewModelProvider);
    final notifier = ref.read(doctorViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              notifier.fetchPatientDetails(widget.patientId);
              notifier.fetchPatientMedicalRecords(widget.patientId);
              notifier.fetchPatientPrescriptions(widget.patientId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Section
            const Text('Patient Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            doctorState.selectedPatient?.when(
              data: (patientDetails) {
                if (patientDetails == null) {
                  return const Text('No details found.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${patientDetails['name'] ?? ''}'),
                    Text('Email: ${patientDetails['email'] ?? ''}'),
                    Text('Gender: ${patientDetails['gender'] ?? ''}'),
                    Text('Date of Birth: ${patientDetails['dateOfBirth'] ?? ''}'),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error loading patient details: ${e.toString()}'),
            ) ?? const Text('Loading...'),

            const SizedBox(height: 20),

            // Medical Records Section
            const Text('Medical Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            doctorState.patientMedicalRecords?.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Text('No medical records found.');
                }
                return Column(
                  children: records.map((record) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text('Diagnosis: ${record.diagnosis}'),
                      subtitle: Text('Treatment: ${record.treatment}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push('${AppRoutes.doctorEditMedicalRecord.replaceFirst(':id', record.id)}?patientId=${widget.patientId}');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              notifier.deleteMedicalRecord(record.id, patientId: widget.patientId);
                            },
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error loading medical records: ${e.toString()}'),
            ) ?? const Text('Loading...'),

            const SizedBox(height: 20),

            // Prescriptions Section
            const Text('Prescriptions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            doctorState.patientPrescriptions?.when(
              data: (prescriptions) {
                if (prescriptions.isEmpty) {
                  return const Text('No prescriptions found.');
                }
                return Column(
                  children: prescriptions.map((prescription) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text('Prescription ID: ${prescription.id}'),
                      subtitle: Text('Medications: ${prescription.medications.length}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push(AppRoutes.doctorEditPrescription.replaceFirst(':id', prescription.id));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              notifier.deletePrescription(prescription.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error loading prescriptions: ${e.toString()}'),
            ) ?? const Text('Loading...'),

            const SizedBox(height: 20),

            // Buttons to Add New Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.push('${AppRoutes.doctorCreateMedicalRecord}?patientId=${widget.patientId}');
                  },
                  child: const Text('Add Medical Record'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push('${AppRoutes.doctorCreatePrescription}?patientId=${widget.patientId}');
                  },
                  child: const Text('Add Prescription'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 