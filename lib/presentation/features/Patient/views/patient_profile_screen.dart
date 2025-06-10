import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// You might need a patient profile viewmodel if you fetch profile data separately
// For now, it's a simple placeholder.

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, you'd fetch patient's own profile data here
    // using a ViewModel, e.g., ref.watch(patientProfileViewModelProvider)

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'Patient Name Here', // Replace with actual data from a ViewModel
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'patient.email@example.com', // Replace with actual data
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Card(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.cake),
                        title: Text('Date of Birth: January 1, 1990'), // Replace
                      ),
                      ListTile(
                        leading: Icon(Icons.wc),
                        title: Text('Gender: Male'), // Replace
                      ),
                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('Phone: +123 456 7890'), // Replace
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Example: Logout button
              ElevatedButton.icon(
                onPressed: () {
                  // Implement logout logic: clear token, navigate to login
                  // ref.read(authViewModelProvider.notifier).logout();
                  // context.go(AppRoutes.login);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout functionality to be implemented')),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}