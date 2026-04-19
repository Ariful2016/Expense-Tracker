// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'expense_model.dart';

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override final int typeId = 0;
  @override
  ExpenseModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return ExpenseModel(
      id: f[0] as String, title: f[1] as String, amount: f[2] as double,
      categoryId: f[3] as String, date: f[4] as DateTime,
      note: f[5] as String?, status: f[6] as String? ?? 'paid',
    );
  }
  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer..writeByte(7)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.amount)..writeByte(3)..write(obj.categoryId)
      ..writeByte(4)..write(obj.date)..writeByte(5)..write(obj.note)
      ..writeByte(6)..write(obj.status);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is ExpenseModelAdapter && runtimeType == o.runtimeType && typeId == o.typeId;
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override final int typeId = 1;
  @override
  CategoryModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return CategoryModel(
      id: f[0] as String, name: f[1] as String, colorValue: f[2] as int,
      iconCodePoint: f[3] as int, budgetLimit: f[4] as double? ?? 0,
      isCustom: f[5] as bool? ?? false, subItems: (f[6] as List?)?.cast<String>(), order: 0,
    );
  }
  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer..writeByte(7)
      ..writeByte(0)..write(obj.id)..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.colorValue)..writeByte(3)..write(obj.iconCodePoint)
      ..writeByte(4)..write(obj.budgetLimit)..writeByte(5)..write(obj.isCustom)
      ..writeByte(6)..write(obj.subItems);
  }
  @override int get hashCode => typeId.hashCode;
  @override bool operator ==(Object o) => identical(this, o) || o is CategoryModelAdapter && runtimeType == o.runtimeType && typeId == o.typeId;
}
