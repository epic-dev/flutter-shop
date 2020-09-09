import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://flutter-provider-8b77c.firebaseio.com/orders.json';
    var response = await http.get(url);
    if (response.statusCode == 401) {
      print('\n UNAUTHORIZED \n');
      return;
    }
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    List<OrderItem> loadedOrders = [];
    extracted.forEach((orderKey, orderData) {
      loadedOrders.add(OrderItem(
        id: orderKey,
        amount: orderData['amount'],
        products: (orderData['products'] as List<dynamic>).map(
          (item) => CartItem(
            id: item['id'],
            title: item['title'],
            quantity: item['quantity'],
            price: item['price'],
          ),
        ).toList(),
        dateTime: DateTime.parse(orderData['dateTime']),
      ));
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://flutter-provider-8b77c.firebaseio.com/orders.json';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((cart) => {
                    'id': cart.id,
                    'price': cart.price,
                    'quantity': cart.quantity,
                    'title': cart.title,
                  })
              .toList(),
          'dateTime': timestamp.toIso8601String(),
        }));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ));
    notifyListeners();
  }
}
