import 'package:hive/hive.dart';
part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) double amount;
  @HiveField(3) String categoryId;
  @HiveField(4) DateTime date;
  @HiveField(5) String? note;
  @HiveField(6) String status; // 'paid' | 'pending'// 'paid' | 'pending'

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.status = 'paid',
  });
}

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(6) int order;
  @HiveField(1) String name;
  @HiveField(2) int colorValue;
  @HiveField(3) int iconCodePoint;
  @HiveField(4) double budgetLimit;
  @HiveField(5) bool isCustom;
  @HiveField(6) List<String> subItems;// sub-items like Rent->Rent, Service charge...

  CategoryModel({
    required this.id,
    required this.order,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.budgetLimit = 0,
    this.isCustom = false,
    List<String>? subItems,
  }) : subItems = subItems ?? [];
}
