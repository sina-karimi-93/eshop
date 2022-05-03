import 'dart:convert';
import 'dart:typed_data';

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
    /*
    This method is responsible for getting data from the server.
    First it get data from server, and via json package, we decode
    it to readble data like List<Map<...>> or Map<...> then return
    it.

    args:
      path -> server url
    */
    try {
      final url = Uri.http('10.0.2.2:8000', path);

      var response = await http.get(url);
      var data = response.body;
      var decodedData = json.decode(data);
      return decodedData;
    } catch (error) {
      rethrow;
    }
  }

  void _prepareCategories(loadedCategories) {
    /*
    After getting categories from the server, we push them
    into a list as strings.
    */
    try {
      for (String element in loadedCategories["categories"]!) {
        _categories.add(element);
      }
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<Uint8List> _convertBinariesToImages(var binaryImages) {
    /* 
    This method converts images from binary base64 to Uint8List. In this
    way we can use these in Image.memory() widget to show
    these images in the app.

    args:
        binaryImages -> List of binary base64 
        [
          {
            "$binary": { "base64" : "..." }
          }
        ]
    */

    List<Uint8List> imagesUints = [];

    for (var imageData in binaryImages) {
      Uint8List imageUint = base64Decode(imageData['\$binary']['base64']);
      imagesUints.add(imageUint);
    }
    return imagesUints;
  }

  void _prepareProducts(var loadedProducts) {
    /*
    After getting products from server, it is time to
    reshape them as a usable objects in the app. So, we
    use Product class as a container. See ./Models/product.dart.
    */
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
          images: _convertBinariesToImages(product["images"]),
          comments: product["sizes"],
        ),
      );
    }
    notifyListeners();
  }

  Future<void> prepareProductsData() async {
    /*
    This method called from shop screen and get data from
    server. For that screen we need all products and categories.
    So, via _getDataFromServer() method we get the required data
    and pass them to related methods to reshape them for using
    in the app.
    */

    try {
      var loadedProducts = await _getDataFromServer('/products');
      var loadedCategories = await _getDataFromServer('/products/categories');
      _prepareProducts(loadedProducts);
      _prepareCategories(loadedCategories);
    } catch (error) {
      rethrow;
    }
  }
}
