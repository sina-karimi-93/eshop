import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mobile_version/Models/product.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<String> _categories = [];

  List<Product> get products {
    return [..._products];
  }

  List<String> get categories {
    return [..._categories];
  }

  Future<dynamic> _getDataFromServer(String path) async {
    try {
      final url = Uri.http('10.0.2.2:8000', path);

      var response = await http.get(url);
      var data = response.body;
      var decodedData = json.decode(data);
      return decodedData;
    } catch (error) {}
  }

  void _prepareCategories(loadedCategories) {
    try {
      for (String element in loadedCategories["categories"]!) {
        _categories.add(element);
      }
    } catch (error) {
      rethrow;
    }
  }

  void _prepareProducts(var loadedProducts) {
    for (var product in loadedProducts) {
      _products.add(
        Product(
          id: product["_id"]["\$oid"],
          title: product["title"],
          description: product["description"],
          price: product["price"],
          createDate:
              DateFormat("dd-MM-yyyy").parse(product["create_date"]["\$date"]),
          categories: product["categories"],
          colors: product["colors"],
          sizes: product["sizes"],
          comments: product["sizes"],
        ),
      );
    }
  }

  Future<void> prepareProductsData() async {
    try {
      var loadedProducts = await _getDataFromServer('/products');
      var loadedCategories = await _getDataFromServer('/products/categories');
      _prepareProducts(loadedProducts);
      _prepareCategories(loadedCategories);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
