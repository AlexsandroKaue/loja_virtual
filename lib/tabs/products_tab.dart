import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/tiles/category_tile.dart';

class ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance.collection("products").getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var dividedTiles = ListTile.divideTiles(
            context: context,
            color: Colors.grey[500],
            tiles: snapshot.data.documents.map((doc) {  //iterable
              return CategoryTile(doc);
            }).toList());

          return ListView(
            children: dividedTiles.toList(),
          );
        }
      },
    );
  }
}
