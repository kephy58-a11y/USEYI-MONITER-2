class Student {
  final String id;
  final String name;
  final String program;
  final String cohort;
  final String phone;
  final bool active;

  const Student({
    required this.id,
    required this.name,
    required this.program,
    required this.cohort,
    this.phone = '',
    this.active = true,
  });

  Student copyWith({
    String? id,
    String? name,
    String? program,
    String? cohort,
    String? phone,
    bool? active,
  }) =>
      Student(
        id: id ?? this.id,
        name: name ?? this.name,
        program: program ?? this.program,
        cohort: cohort ?? this.cohort,
        phone: phone ?? this.phone,
        active: active ?? this.active,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'program': program,
        'cohort': cohort,
        'phone': phone,
        'active': active,
      };

  factory Student.fromMap(Map map) => Student(
        id: '${map['id'] ?? ''}'.trim(),
        name: '${map['name'] ?? ''}'.trim(),
        program: '${map['program'] ?? ''}'.trim(),
        cohort: '${map['cohort'] ?? ''}'.trim(),
        phone: '${map['phone'] ?? ''}'.trim(),
        active: map['active'] != false,
      );
}
