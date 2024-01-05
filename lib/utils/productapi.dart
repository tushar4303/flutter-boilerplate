import 'dart:convert';
import 'package:boilerplate/models/productModel.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<ProductList> fetchProducts() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products'));

    if (response.statusCode == 200) {
      return ProductList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load products');
    }
  }
}
