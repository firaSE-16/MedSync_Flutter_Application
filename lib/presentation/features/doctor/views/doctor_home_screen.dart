import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medsync/core/providers.dart';
import 'package:medsync/presentation/features/doctor/viewmodels/doctor_viewmodel.dart';
import 'package:medsync/presentation/navigation/routes.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final doctorState = ref.watch(doctorViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(doctorViewModelProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAsync.when(
              data: (user) => Text(
                user != null ? 'Welcome, Dr. ${user.name}' : 'Welcome, Doctor!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              loading: () => const Text('Loading...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              error: (e, s) => const Text('Error loading user', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle(context, 'Upcoming Appointments', () {
              context.go(AppRoutes.doctorAppointment);
            }),
            doctorState.appointments.when(
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const Text('No upcoming appointments.');
                }
                return Column(
                  children: appointments.take(3).map((appointment) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text('Patient: ${appointment.patientName ?? 'N/A'}'),
                      subtitle: Text(
                        'Date: ${DateFormat.yMMMd().format(DateTime.parse(appointment.date))} - ${appointment.time}',
                      ),
                      trailing: Chip(label: Text(appointment.status)),
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Text('Error loading appointments.'),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle(context, 'My Patients', () {
              context.go(AppRoutes.doctorPatients);
            }),
            doctorState.patients.when(
              data: (patients) {
                if (patients.isEmpty) {
                  return const Text('No patients assigned yet.');
                }
                return Column(
                  children: patients.take(3).map((patient) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text('${patient.name}'),
                      subtitle: Text('Email: ${patient.email}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.push(AppRoutes.patientDetail.replaceFirst(':id', patient.id));
                      },
                    ),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Text('Error loading patients.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }
} 