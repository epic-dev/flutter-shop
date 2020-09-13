import 'package:flutter/material.dart';
import 'package:flutter_shop/constants/endpoints.dart';
import 'package:flutter_shop/models/http_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  Products(this.authToken, this.userId, this._items);
  final String authToken;
  final String userId;

  List<Product> _items = [];

  List<Product> get productItems {
    return [..._items];
  }

  List<Product> get favoriteProductItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    try {
      var url = '${EndpointUrlBuilder.readProducts()}?auth=$authToken&orderBy="creatorId"&equalTo="$userId"';
      final response = await http.get(url);
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      url = 'https://flutter-provider-8b77c.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoritesResponse = await http.get(url);
      final fav = json.decode(favoritesResponse.body) as Map<String, dynamic>;
      List<Product> loaded = [];
      extracted.forEach((productId, productData) {
        loaded.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          price: productData['price'],
          isFavorite: fav == null ? false : fav[productId] ?? false,
        ));
      });
      _items = loaded;
      notifyListeners();
    } catch (error) {
      print('error $error');
    }
  }

  Future<void> addProduct(Product product) async {
    final url = '${EndpointUrlBuilder.createProduct()}?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (exception) {
      throw exception;
    }
  }

  Product getById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final url = '${EndpointUrlBuilder.updateProduct(id)}?auth=$authToken';
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _items[index] = product;
      await http.patch(url,
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
    final url = '${EndpointUrlBuilder.deleteProduct(id)}?auth=$authToken';
    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex]; // save reference to the product
    _items.removeAt(existingProductIndex); // remove from the list but not from the memory
    notifyListeners();
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
      existingProduct = null;
    }).catchError((error) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
  }
}
