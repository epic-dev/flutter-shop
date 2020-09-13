import 'package:flutter/material.dart';
import 'package:flutter_shop/mock/products_mock.dart';
import 'package:flutter_shop/models/http_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  Products(this.authToken, this._items);
  final String authToken;

  List<Product> _items = [];

  List<Product> get productItems {
    return [..._items];
  }

  List<Product> get favoriteProductItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    final URL = 'https://flutter-provider-8b77c.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.get(URL);
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      List<Product> loaded = [];
      extracted.forEach((productId, productData) {
        loaded.add(Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            isFavorite: productData['isFavorite']));
      });
      _items = loaded;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addProduct(Product product) async {
    final URL = 'https://flutter-provider-8b77c.firebaseio.com/products.json';
    try {
      final response = await http.post(URL,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  Product getById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final URL = 'https://flutter-provider-8b77c.firebaseio.com/products/$id.json';
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _items[index] = product;
      await http.patch(URL,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          }));
      notifyListeners();
    } else {
      print('not found');
    }
  }

  void deleteProduct(String id) {
    /*
     Optimistic update pattern:
     save the reference until in successfully removed from server
     and return back if it's failed
    */
    final URL = 'https://flutter-provider-8b77c.firebaseio.com/products/$id.json';
    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex]; // save reference to the product
    _items.removeAt(existingProductIndex); // remove from the list but not from the memory
    notifyListeners();
    http.delete(URL).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
      existingProduct = null;
    }).catchError((error) {
      print(error);
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
  }
}
