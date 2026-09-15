class UseyiActivity {
  final String id;
  final String date;
  final String program;
  final String title;
  final String outcome;
  final String challenge;
  final String notes;

  const UseyiActivity({
    required this.id,
    required this.date,
    required this.program,
    required this.title,
    this.outcome = '',
    this.challenge = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'program': program,
        'title': title,
        'outcome': outcome,
        'challenge': challenge,
        'notes': notes,
      };

  factory UseyiActivity.fromMap(Map map) => UseyiActivity(
        id: '${map['id'] ?? ''}',
        date: '${map['date'] ?? ''}',
        program: '${map['program'] ?? ''}',
        title: '${map['title'] ?? ''}',
        outcome: '${map['outcome'] ?? ''}',
        challenge: '${map['challenge'] ?? ''}',
        notes: '${map['notes'] ?? ''}',
      );
}
