

import 'package:brixel/service/DioClient.dart';
import '../data/modele/Category.dart';


class CategoryService {
  final _dio = DioClient().dio;

  Future<List<Category?>> getAllCategory() async {
    final response = await _dio.get('/category/allCategory');
    return (response.data as List).map((item) => Category.fromJson(item)).toList();
  }

  Future<void> addCategory(String name) async {
    await _dio.post('/category/addCategory', data: {"name": name});
  }


}