import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0) //Dibuat beberapa array agar bisa disimpan di Hive, harus ada typeId unik untuk tiap model
class LogModel {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String category; 

  @HiveField(5)
  final String authorId; 

  @HiveField(6)
  final String teamId;

  @HiveField(7)
  final bool isPublic;
  
  // Bagian constructor
  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.authorId,
    required this.teamId,
    this.isPublic = false,
  });

  // Untuk konversi ke Map agar bisa disimpan di MongoDB Atlas
  Map<String, dynamic> toMap() {
    return {
      '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
      'title': title,
      'description': description,
      'date': date,
      'category': category,
      'authorId': authorId,
      'teamId': teamId,
      'isPublic': isPublic,
    };
  }

  // Untuk konversi dari Map yang diambil dari MongoDB Atlas
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid ?? map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? 'Pribadi',
      authorId: map['authorId'] ?? 'unknown_user',
      teamId: map['teamId'] ?? 'no_team',
      isPublic: map['isPublic'] ?? false,
    );
  }
}