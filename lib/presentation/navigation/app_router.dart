import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medsync/core/constants/app_constants.dart';
import 'package:medsync/core/services/shared_preferences_service.dart';
import 'package:medsync/presentation/features/Admin/views/admin_dashboard_view.dart';
import 'package:medsync/presentation/features/Admin/views/admin_patient_appointments_view.dart';
import 'package:medsync/presentation/features/Admin/views/admin_patients_view.dart';
import 'package:medsync/presentation/features/Admin/views/admin_shell_view.dart';
import 'package:medsync/presentation/features/Admin/views/admin_staff_detail_view.dart';
import 'package:medsync/presentation/features/Admin/views/admin_staff_view.dart';
import 'package:medsync/presentation/features/Patient/views/chat_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_appointments_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_booking_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_home_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_medical_history_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_prescriptions_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_profile_screen.dart';
import 'package:medsync/presentation/features/Patient/views/patient_shell_view.dart';
import 'package:medsync/presentation/features/auth/views/login_view.dart';
import 'package:medsync/presentation/features/auth/views/register_view.dart';
import 'package:medsync/presentation/features/intro/views/intro_screen.dart';
import 'package:medsync/presentation/features/splash/views/splash_screen.dart';
import 'package:medsync/presentation/navigation/routes.dart';
import 'package:medsync/presentation/features/Triage/views/triage_home_screen.dart';
import 'package:medsync/presentation/features/Triage/views/triage_booking_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) async {
      final token = await SharedPreferencesService.getString(AppConstants.tokenKey);
      final role = await SharedPreferencesService.getString(AppConstants.roleKey);
      final isLoggedIn = token != null && role != null;
      final isSplash = state.uri.path == AppRoutes.splash;
      final isIntro = state.uri.path == AppRoutes.intro;
      final isAuthRoute = 
          state.uri.path == AppRoutes.login || 
          state.uri.path == AppRoutes.register || 
          state.uri.path == AppRoutes.resetPassword;

      // If we're on splash screen, don't redirect
      if (isSplash) return null;

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute && !isIntro) {
        return AppRoutes.login;
      }

      // If logged in but trying to access auth route
      if (isLoggedIn && isAuthRoute) {
        return _getRoleHome(role!);
      }

      // Special handling for admin routes
      if (isLoggedIn && role == 'admin') {
        final isAdminRoute = state.uri.path.startsWith('/admin/');
        if (!isAdminRoute) {
          return AppRoutes.adminHome;
        }
      }

      // For other protected routes, verify role access
      if (isLoggedIn) {
        final path = state.uri.path;
        if (path.startsWith('/doctor/') && role != 'doctor') {
          return _getRoleHome(role!);
        }
        if (path.startsWith('/patient/') && role != 'patient') {
          return _getRoleHome(role!);
        }
        if (path.startsWith('/triage/') && role != 'triage') {
          return _getRoleHome(role!);
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => Container(
          color: Colors.teal,
          child: const Center(child: Text("Reset Password Screen")),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(title: const Text("Doctor Panel")),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.doctorHome,
            builder: (context, state) => Container(
              color: Colors.purple.shade200,
              child: const Center(child: Text("Doctor Home Page")),
            ),
          ),
          // ... other doctor routes ...
        ],
      ),
      ShellRoute(
      builder: (context, state, child) {
        return PatientShellView(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.patientHome,
          builder: (context, state) => const PatientHomeScreen(),
        ),
        GoRoute(path: AppRoutes.patientBooking,
          builder: (context, state) => const PatientBookingScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientAppointment,
          builder: (context, state) => const PatientAppointmentsScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientPrescription,
          builder: (context, state) => const PatientPrescriptionsScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientMedicalHistory,
          builder: (context, state) => const PatientMedicalHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientChat,
          builder: (context, state) => const PatientDoctorsListScreen(),
        ),
        GoRoute(
          path: AppRoutes.patientProfile,
          builder: (context, state) => const PatientProfileScreen(),
        ),
        // Keep the specific chat screen for direct navigation if needed
        GoRoute(
          path: AppRoutes.patientChatScreen, // e.g., /patient/chat/60c728e7e1c8d7001c8a1b2c
          builder: (context, state) {
            final String doctorId = state.pathParameters['id']!;
            // Replace with your actual chat screen widget that takes doctorId
            return Scaffold(
              appBar: AppBar(title: Text('Chat with Doctor ID: $doctorId')),
              body: Center(
                child: Text('Implement actual chat UI for doctor: $doctorId'),
              ),
            );
            // return PatientChatScreen(doctorId: doctorId); // Uncomment if you create this screen
          },
        ),
        // Add more patient specific routes as needed, e.g., for creating a booking
        // GoRoute(
        //   path: AppRoutes.patientBooking, // Example for a dedicated booking screen if needed
        //   builder: (context, state) => const PatientBookingScreen(),
        // ),
      ],
    ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(title: const Text("Triage Panel")),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.triageHome,
            builder: (context, state) => const TriageHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.triageBookingDetail,
            builder: (context, state) {
              final bookingId = state.pathParameters['id']!;
              return TriageBookingDetailScreen(bookingId: bookingId);
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AdminShellView(child: child);
        },
        routes: [
          GoRoute(
          path: AppRoutes.adminHome, // This will now be the Admin Patients View
          builder: (context, state) => const AdminPatientsView(),
        ),
        GoRoute(
          path: AppRoutes.adminStaff,
          builder: (context, state) => const AdminStaffView(),
        ),
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (context, state) => const AdminDashboardView(),
        ),
        GoRoute(
          path: AppRoutes.adminPatientAppointments,
          builder: (context, state) => const AdminPatientAppointmentsView(),
        ),
        GoRoute(
          path: AppRoutes.adminStaffDetail,
          builder: (context, state) => AdminStaffDetailView(
            staffId: state.pathParameters['id']!,
          ),
        ),
        ],
      ),
    ],
  );
});

String _getRoleHome(String role) {
  switch (role) {
    case 'admin':
      return AppRoutes.adminHome;
    case 'doctor':
      return AppRoutes.doctorHome;
    case 'triage':
      return AppRoutes.triageHome;
    case 'patient':
    default:
      return AppRoutes.patientHome;
  }
}