import 'package:get_storage/get_storage.dart';

class StorageService {
  final box = GetStorage();

  save(String key, dynamic value) => box.write(key, value);
  read(String key) => box.read(key);
}