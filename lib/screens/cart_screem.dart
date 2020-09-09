import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/cart.dart' show Cart;
import 'package:flutter_shop/providers/orders.dart';
import 'package:flutter_shop/providers/products.dart';
import 'package:flutter_shop/widgets/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/shopping-cart';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your cart')),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Consumer<Cart>(
                    builder: (ctx, cart, _) => Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      label: Text(
                        '\$${cart.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline3
                                .color),
                      ),
                    ),
                  ),
                  Consumer<Cart>(
                    builder: (ctx, cart, _) => OrderButton(cart),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Consumer<Cart>(
              builder: (ctx, cart, _) => ListView.builder(
                  itemBuilder: (ctx, index) {
                    return CartItem(
                      cart.items.values.toList()[index].id,
                      cart.items.keys.toList()[index],
                      cart.items.values.toList()[index].title,
                      cart.items.values.toList()[index].price,
                      cart.items.values.toList()[index].quantity,
                    );
                  },
                  itemCount: cart.items.length),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton(this.cart);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: widget.cart.items.length <= 0 ? null : () async {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
          widget.cart.items.values.toList(),
          widget.cart.totalPrice,
        );
        setState(() {
          _isLoading = false;
        });
        widget.cart.clearCart();
      },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
