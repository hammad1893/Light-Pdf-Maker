import 'package:hive/hive.dart';
part 'pdf_model.g.dart'; 

@HiveType(typeId: 0)
class PdfModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String filepath;

  @HiveField(3)
  final int pageCount;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isFavorite;

  PdfModel({
    required this.id,
    required this.title,
    required this.filepath,
    required this.pageCount,
    required this.createdAt,
    this.isFavorite = false,
  });
}
