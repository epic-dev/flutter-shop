import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/product.dart';
import 'package:flutter_shop/screens/edit_product_screen.dart';
import 'package:flutter_shop/widgets/app_drawer.dart';
import 'package:flutter_shop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              })
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<Products>(
            builder: (ctx, products, _) => ListView.builder(
              // itemCount: productsData.productItems.length,
              itemCount: products.productItems.length,
              itemBuilder: (_, index) {
                return Column(
                  children: <Widget>[
                    UserProductItem(
                      // productsData.productItems[index].id,
                      // productsData.productItems[index].title,
                      // productsData.productItems[index].imageUrl,
                      products.productItems[index].id,
                      products.productItems[index].title,
                      products.productItems[index].imageUrl,
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
