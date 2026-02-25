class LogModel {
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });

  // Konversi JSON ke Object
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Pribadi',
    );
  }

  // Konversi Object ke JSON
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };
  }
}