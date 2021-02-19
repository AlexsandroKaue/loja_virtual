import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/datas/cart_product.dart';
import 'package:lojavirtual/datas/product_data.dart';
import 'package:lojavirtual/models/cart_model.dart';

class CartTile extends StatelessWidget {
  final CartProduct cartProduct;

  CartTile(this.cartProduct);

  Widget _buildContent(BuildContext context) {
    //CartModel.of(context).updatePrices();
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          width: 120.0,
          child: FutureBuilder<String>(
            future: loadImage(cartProduct.productData.images[0]),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return Image.network(
                  snapshot.data,
                  fit: BoxFit.cover,
                );
              }
              return Container();

            },
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cartProduct.productData.title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
                ),
                Text(
                  "Tamanho: ${cartProduct.size}",
                  style: TextStyle(fontWeight: FontWeight.w300,),
                ),
                Text(
                  "R\$ ${cartProduct.productData.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove,),
                      color: Theme.of(context).primaryColor,
                      onPressed: cartProduct.quantity > 1 ?(){
                        CartModel.of(context).decProduct(cartProduct);
                      } : null,
                    ),
                    Text(cartProduct.quantity.toString()),
                    IconButton(
                        icon: Icon(Icons.add, color: Theme.of(context).primaryColor,),
                        onPressed: (){
                          CartModel.of(context).incProduct(cartProduct);
                        }
                    ),
                    FlatButton(
                        onPressed: (){
                          CartModel.of(context).removeCartItem(cartProduct);
                        },
                        child: Text("Remover"),
                      textColor: Colors.grey,

                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: cartProduct.productData == null
          ? FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance
                  .collection("products")
                  .document(cartProduct.category)
                  .collection("items")
                  .document(cartProduct.pid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  cartProduct.productData =
                      ProductData.fromDocument(snapshot.data);
                  return _buildContent(context);
                } else {
                  return Container(
                    height: 70.0,
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  );
                }
              })
          : _buildContent(context),
    );
  }

  Future<String> loadImage(String local) async {
    StorageReference reference = FirebaseStorage.instance.ref().child(local);
    String url = await reference.getDownloadURL();
    return url;
  }
}
