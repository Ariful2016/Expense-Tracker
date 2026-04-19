class Category {
  String id;
  String name;
  int color;
  double budget;

  Category({required this.id, required this.name, required this.color, required this.budget});

  Map<String, dynamic> toJson() => {"id": id, "name": name, "color": color, "budget": budget};

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    color: json["color"],
    budget: json["budget"]?.toDouble() ?? 0.0,
  );
}

class Expense {
  String id;
  String title;
  double amount;
  String categoryId;
  DateTime date;

  Expense({required this.id, required this.title, required this.amount, required this.categoryId, required this.date});

  Map<String, dynamic> toJson() => {
    "id": id, "title": title, "amount": amount, "categoryId": categoryId, "date": date.toIso8601String(),
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json["id"],
    title: json["title"],
    amount: json["amount"],
    categoryId: json["categoryId"],
    date: DateTime.parse(json["date"]),
  );
}