import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart' as ord;
class OrdersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<ord.Orders>(context).orders;
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (_, index) => OrderItem(orders[index]),
    );
  }
}