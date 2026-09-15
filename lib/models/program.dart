class UseyiProgram {
  final String id;
  final String name;
  final String description;
  final bool active;

  const UseyiProgram({
    required this.id,
    required this.name,
    this.description = '',
    this.active = true,
  });

  UseyiProgram copyWith({String? id, String? name, String? description, bool? active}) =>
      UseyiProgram(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        active: active ?? this.active,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'active': active,
      };

  factory UseyiProgram.fromMap(Map map) => UseyiProgram(
        id: '${map['id'] ?? ''}'.trim(),
        name: '${map['name'] ?? ''}'.trim(),
        description: '${map['description'] ?? ''}'.trim(),
        active: map['active'] != false,
      );
}
