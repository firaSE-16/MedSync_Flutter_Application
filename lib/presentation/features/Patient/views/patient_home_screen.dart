import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medsync/core/providers.dart';
import 'package:medsync/presentation/features/Patient/viewmodels/patient_dashboard_viewmodel.dart';
import 'package:medsync/presentation/navigation/routes.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(patientDashboardViewModelProvider);
    final user = ref.watch(authProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile icon and name
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.patientProfile),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user?.name != null ? 'Hi, WelcomeBack\n${user!.name}' : 'Hi, WelcomeBack',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Banner placeholder
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Banner Placeholder',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 24),
              // Appointment card or error
              dashboardState.dashboardData.when(
                data: (data) {
                  if (data.upcomingAppointments.isEmpty) {
                    return const Text('No upcoming appointments.', style: TextStyle(fontSize: 16));
                  }
                  final appointment = data.upcomingAppointments.first;
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.deepPurple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upcoming Appointment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple[700]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: Colors.deepPurple[400]),
                              const SizedBox(width: 8),
                              Text(DateFormat.yMMMMd().format(DateTime.parse(appointment.date))),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time, size: 18, color: Colors.deepPurple[400]),
                              const SizedBox(width: 8),
                              Text(appointment.time),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Dr. ${appointment.doctorName ?? 'N/A'}', style: const TextStyle(fontSize: 15)),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                try {
                                  await ref.read(cancelBookingUseCaseProvider).call(appointment.id);
                                  ref.refresh(patientDashboardViewModelProvider);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}