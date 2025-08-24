class Animal {
  final String id;
  final String name;
  final String species;
  final int? age;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    this.age,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      age: json['age'] as int?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'age': age,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}