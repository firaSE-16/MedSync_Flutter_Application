import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medsync/data/models/dashboard_stats_model.dart';
import 'package:medsync/domain/usecases/patient/get_patient_dashboard_usecase.dart';
import 'package:medsync/core/providers.dart'; // Import your providers

class PatientDashboardState {
  final AsyncValue<PatientDashboardData> dashboardData;

  PatientDashboardState({
    required this.dashboardData,
  });

  PatientDashboardState copyWith({
    AsyncValue<PatientDashboardData>? dashboardData,
  }) {
    return PatientDashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}

final patientDashboardViewModelProvider =
    StateNotifierProvider<PatientDashboardViewModel, PatientDashboardState>(
  (ref) {
    final getDashboardUseCase = ref.read(getPatientDashboardUseCaseProvider);
    return PatientDashboardViewModel(getDashboardUseCase);
  },
);

class PatientDashboardViewModel extends StateNotifier<PatientDashboardState> {
  final GetPatientDashboardUseCase _getDashboardUseCase;

  PatientDashboardViewModel(this._getDashboardUseCase)
      : super(PatientDashboardState(dashboardData: const AsyncValue.loading())) {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    state = state.copyWith(dashboardData: const AsyncValue.loading());
    try {
      final data = await _getDashboardUseCase.call();
      state = state.copyWith(dashboardData: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(dashboardData: AsyncValue.error(e, st));
    }
  }

  // You might add methods to refresh individual sections if needed,
  // but for a dashboard, fetching all at once is common.
}