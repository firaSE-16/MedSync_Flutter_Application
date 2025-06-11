import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/presentation/common/widgets/profile_icon.dart';
import 'package:medsync/presentation/navigation/routes.dart';

class DoctorShellView extends StatefulWidget {
  final Widget child;

  const DoctorShellView({super.key, required this.child});

  @override
  State<DoctorShellView> createState() => _DoctorShellViewState();
}

class _DoctorShellViewState extends State<DoctorShellView> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go(AppRoutes.doctorHome);
        break;
      case 1:
        context.go(AppRoutes.doctorPatients);
        break;
      case 2:
        context.go(AppRoutes.doctorAppointment); // Assuming this is for all appointments
        break;
      case 3:
        context.go(AppRoutes.doctorProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedSync'),
        actions: const [
          ProfileIcon(),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 