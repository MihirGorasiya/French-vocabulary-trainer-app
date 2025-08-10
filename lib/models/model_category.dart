class Category {
  final int? id; // null when creating a new category before saving
  final String name;

  Category({this.id, required this.name});

  // Convert a Category into a Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  // Create a Category from a Map (DB fetch)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}
