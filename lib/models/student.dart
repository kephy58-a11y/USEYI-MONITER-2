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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'program': program,
        'cohort': cohort,
        'phone': phone,
        'active': active,
      };

  factory Student.fromMap(Map map) => Student(
        id: '${map['id'] ?? ''}',
        name: '${map['name'] ?? ''}',
        program: '${map['program'] ?? ''}',
        cohort: '${map['cohort'] ?? ''}',
        phone: '${map['phone'] ?? ''}',
        active: map['active'] != false,
      );
}
