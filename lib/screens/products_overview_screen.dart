import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/cart.dart';
import 'package:flutter_shop/providers/products.dart';
import 'package:flutter_shop/screens/cart_screem.dart';
import 'package:flutter_shop/widgets/app_drawer.dart';
import 'package:flutter_shop/widgets/badge.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';

enum FILTER_OPTIONS {
  FAVORITES,
  ALL,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context, listen: false).fetchAndSetProducts().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  var _showFavorites = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FILTER_OPTIONS selectedValue) => {
              setState(() {
                if (selectedValue == FILTER_OPTIONS.FAVORITES) {
                  _showFavorites = true;
                } else {
                  _showFavorites = false;
                }
              })
            },
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('Favorites'), value: FILTER_OPTIONS.FAVORITES),
              PopupMenuItem(child: Text('Show all'), value: FILTER_OPTIONS.ALL),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Opacity(
              opacity: 0.5,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : ProductsGrid(_showFavorites),
      drawer: AppDrawer(),
    );
  }
}
