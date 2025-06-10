import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medsync/core/network/api_service.dart';
import 'package:medsync/data/models/booking_model.dart';
import 'package:medsync/data/models/user_model.dart';
import 'package:medsync/presentation/features/auth/viewmodels/auth_viewmodel.dart';

// Admin Imports
import 'package:medsync/data/repositories/admin_repository_impl.dart';
import 'package:medsync/domain/repositories/admin_repository.dart';
import 'package:medsync/domain/usecases/get_appointments_by_status_usecase.dart';
import 'package:medsync/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:medsync/domain/usecases/get_patients_usecase.dart';
import 'package:medsync/domain/usecases/get_staff_by_category_usecase.dart';
import 'package:medsync/domain/usecases/register_staff_usecase.dart';

// Patient Imports
import 'package:medsync/data/repositories/patient_repository_impl.dart';
import 'package:medsync/domain/repositories/patient_repository.dart';
import 'package:medsync/domain/usecases/patient/cancel_booking_usecase.dart';
import 'package:medsync/domain/usecases/patient/create_booking_usecase.dart';
import 'package:medsync/domain/usecases/patient/get_patient_appointments_usecase.dart';
import 'package:medsync/domain/usecases/patient/get_patient_dashboard_usecase.dart';
import 'package:medsync/domain/usecases/patient/get_patient_doctors_usecase.dart';
import 'package:medsync/domain/usecases/patient/get_patient_prescriptions_usecase.dart';

// --- Triage Module Providers ---
import 'package:medsync/data/repositories/triage_repository_impl.dart';
import 'package:medsync/domain/repositories/triage_repository.dart';
import 'package:medsync/domain/usecases/triage/get_unassigned_bookings_usecase.dart';
import 'package:medsync/domain/usecases/triage/get_available_doctors_usecase.dart';
import 'package:medsync/domain/usecases/triage/process_triage_usecase.dart';
import 'package:medsync/domain/usecases/triage/update_medical_history_usecase.dart';
import 'package:medsync/domain/usecases/triage/get_triage_patients_usecase.dart';

// --- Core Providers ---
// API Service Provider - Now ensures it's a singleton without creating a new instance
final apiServiceProvider = Provider((ref) => ApiService());

// Auth Provider
final authProvider = StateNotifierProvider<AuthViewModel, AsyncValue<UserModel?>>((ref) {
  final registerUseCase = ref.watch(registerPatientUseCaseProvider);
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return AuthViewModel(registerUseCase, loginUseCase);
});

// --- Admin Module Providers ---

// Admin Repository Provider
final adminRepositoryProvider = Provider<AdminRepository>(
    (ref) => AdminRepositoryImpl(ref.read(apiServiceProvider)));

// Admin Use Case Providers
final registerStaffUseCaseProvider = Provider(
    (ref) => RegisterStaffUseCase(ref.read(adminRepositoryProvider)));

final getStaffByCategoryUseCaseProvider = Provider(
    (ref) => GetStaffByCategoryUseCase(ref.read(adminRepositoryProvider)));

final getDashboardStatsUseCaseProvider = Provider(
    (ref) => GetDashboardStatsUseCase(ref.read(adminRepositoryProvider)));

final getAppointmentsByStatusUseCaseProvider = Provider(
    (ref) => GetAppointmentsByStatusUseCase(ref.read(adminRepositoryProvider)));

final getPatientsUseCaseProvider = Provider(
    (ref) => GetPatientsUseCase(ref.read(adminRepositoryProvider)));


// --- Patient Module Providers ---

// Patient Repository Provider
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PatientRepositoryImpl(apiService);
});

// Patient Use Case Providers
final getPatientDashboardUseCaseProvider = Provider<GetPatientDashboardUseCase>((ref) {
  final repository = ref.read(patientRepositoryProvider);
  return GetPatientDashboardUseCase(repository);
});

final getPatientAppointmentsUseCaseProvider = Provider<GetPatientAppointmentsUseCase>((ref) {
  final repository = ref.read(patientRepositoryProvider);
  return GetPatientAppointmentsUseCase(repository);
});

final getPatientPrescriptionsUseCaseProvider = Provider<GetPatientPrescriptionsUseCase>((ref) {
  final repository = ref.read(patientRepositoryProvider);
  return GetPatientPrescriptionsUseCase(repository);
});

final getPatientDoctorsUseCaseProvider = Provider<GetPatientDoctorsUseCase>((ref) {
  final repository = ref.read(patientRepositoryProvider);
  return GetPatientDoctorsUseCase(repository);
});

final createBookingUseCaseProvider = Provider<CreateBookingUseCase>((ref) {
  final repository = ref.read(patientRepositoryProvider);
  return CreateBookingUseCase(repository);
});

final cancelBookingUseCaseProvider = Provider<CancelBookingUseCase>((ref) {
  final repository = ref.read(patientRepositoryProvider);
  return CancelBookingUseCase(repository);
});

// Patient Bookings Provider
final patientBookingsProvider = FutureProvider.family<List<BookingModel>, String?>((ref, status) async {
  final repository = ref.read(patientRepositoryProvider);
  return await repository.getPatientBookings(status: status);
});

// --- Triage Module Providers ---
final triageRepositoryProvider = Provider<TriageRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TriageRepositoryImpl(apiService);
});

final getUnassignedBookingsUseCaseProvider = Provider<GetUnassignedBookingsUseCase>((ref) {
  final repository = ref.read(triageRepositoryProvider);
  return GetUnassignedBookingsUseCase(repository);
});

final getAvailableDoctorsUseCaseProvider = Provider<GetAvailableDoctorsUseCase>((ref) {
  final repository = ref.read(triageRepositoryProvider);
  return GetAvailableDoctorsUseCase(repository);
});

final processTriageUseCaseProvider = Provider<ProcessTriageUseCase>((ref) {
  final repository = ref.read(triageRepositoryProvider);
  return ProcessTriageUseCase(repository);
});

final updateMedicalHistoryUseCaseProvider = Provider<UpdateMedicalHistoryUseCase>((ref) {
  final repository = ref.read(triageRepositoryProvider);
  return UpdateMedicalHistoryUseCase(repository);
});

final getTriagePatientsUseCaseProvider = Provider<GetTriagePatientsUseCase>((ref) {
  final repository = ref.read(triageRepositoryProvider);
  return GetTriagePatientsUseCase(repository);
});