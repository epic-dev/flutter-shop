import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/orders.dart' show Orders;
import 'package:flutter_shop/widgets/app_drawer.dart';
import 'package:flutter_shop/widgets/orders_list.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: OrdersList(),
      drawer: AppDrawer(),
    );
  }
}
