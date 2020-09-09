import 'package:flutter/material.dart';
import 'package:flutter_shop/providers/products.dart';
import 'package:flutter_shop/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  static final routeName = '/user-products';
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(icon: Icon(Icons.edit), onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: id);
            }),
            IconButton(icon: Icon(Icons.delete), onPressed: () {
              Provider.of<Products>(context, listen: false).deleteProduct(id);
            }, color: Theme.of(context).errorColor,),
          ],
        ),
      ),
    );
  }
}
