class MedicalHistoryModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String diagnosis;
  final String treatment;
  final String? notes;
  final DateTime lastUpdated;

  MedicalHistoryModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.diagnosis,
    required this.treatment,
    this.notes,
    required this.lastUpdated,
  });

  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    String? doctorName;
    if (json['doctorId'] is Map) {
      doctorName = json['doctorId']['name'] as String?;
    }

    return MedicalHistoryModel(
      id: json['_id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      doctorId: json['doctorId'] is Map ? json['doctorId']['_id'] as String : json['doctorId'] as String,
      doctorName: doctorName ?? json['doctorName'] as String? ?? 'Unknown Doctor',
      diagnosis: json['diagnosis'] as String,
      treatment: json['treatment'] as String,
      notes: json['notes'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
