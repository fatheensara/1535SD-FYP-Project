class Student {
  final String name;
  final String studentId;
  final String course;
  final String physicalCardUid;
  final DateTime registeredAt;
  final bool isActive; 
  final String status;

  Student({
    required this.name,
    required this.studentId,
    required this.course,
    required this.physicalCardUid,
    required this.registeredAt,
    this.isActive = false, 
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentId': studentId,
      'course': course,
      'physicalCardUid': physicalCardUid,
      'registeredAt': registeredAt.toIso8601String(),
      'isActive': isActive,
      'status': status,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
     return Student(
      name: json['name'] ?? 'Unknown',
      studentId: json['studentId'] ?? 'Unknown',
      course: json['course'] ?? 'Unknown',
      physicalCardUid: json['physicalCardUid'] ?? '',
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? false,
      status: json['status'] ?? 'pending',
    );
  }
   Student copyWith({
    String? name,
    String? studentId,
    String? course,
    String? physicalCardUid,
    DateTime? registeredAt,
    bool? isActive,
    String? status,
  }) {
    return Student(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      course: course ?? this.course,
      physicalCardUid: physicalCardUid ?? this.physicalCardUid,
      registeredAt: registeredAt ?? this.registeredAt,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
    );
  }
}