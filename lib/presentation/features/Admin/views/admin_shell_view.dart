import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/presentation/navigation/routes.dart';

class AdminShellView extends StatefulWidget {
  final Widget child;

  const AdminShellView({super.key, required this.child});

  @override
  State<AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<AdminShellView> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/admin/home');
        break;
      case 1:
        context.go('/admin/staff');
        break;
      case 2:
        context.go('/admin/dashboard');
        break;
      case 3:
        context.go('/admin/patient-appointments');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: widget.child,
      ),
      bottomNavigationBar: Container(
        height: 65,
        margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'Home',
              isActive: _currentIndex == 0,
              onPressed: () => _onItemTapped(0),
            ),
            _NavItem(
              icon: Icons.people,
              label: 'Staff',
              isActive: _currentIndex == 1,
              onPressed: () => _onItemTapped(1),
            ),
            _NavItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isActive: _currentIndex == 2,
              onPressed: () => _onItemTapped(2),
            ),
            _NavItem(
              icon: Icons.calendar_today,
              label: 'Appointments',
              isActive: _currentIndex == 3,
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}