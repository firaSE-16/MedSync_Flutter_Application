import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/data/models/booking_model.dart';
import 'package:medsync/presentation/common/widgets/profile_icon.dart';
import 'package:medsync/presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:medsync/presentation/features/triage/viewmodels/triage_unassigned_bookings_viewmodel.dart';
import 'package:medsync/presentation/navigation/routes.dart';

class TriageHomeScreen extends ConsumerWidget {
  const TriageHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(triageUnassignedBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triage - Unassigned Bookings'),
        actions: [
          const ProfileIcon(),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) => bookings.isEmpty
            ? const Center(child: Text('No unassigned bookings.'))
            : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('Patient: ${booking.patientName}'),
                      subtitle: Text('Specialty: ${booking.lookingFor}\nDate: ${booking.preferredDate} Time: ${booking.preferredTime}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to detail screen with booking id
                        context.push('/triage/booking/${booking.id}');
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load bookings: $e')),
      ),
    );
  }
} 