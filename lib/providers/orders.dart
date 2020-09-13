import 'package:flutter/material.dart';
import 'package:flutter_shop/constants/endpoints.dart';
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
  Orders(this.authToken, this._orders);
  List<OrderItem> _orders = [];
  final String authToken;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = '${EndpointUrlBuilder.readOrders()}?auth=$authToken';
    try {
      final response = await http.get(url);
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> loaded = [];
      extracted.forEach((orderKey, orderData) {
        loaded.add(OrderItem(
          id: orderKey,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ));
      });
      _orders = loaded;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = '${EndpointUrlBuilder.createOrder()}?auth=$authToken';
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
