import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:lojavirtual/datas/cart_product.dart';
import 'package:lojavirtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;

  List<CartProduct> products = [];
  bool isLoading = false;
  String couponCode;
  int percent = 0;

  CartModel(this.user) {
    if (user.isLoggedIn()) {
      _loadCart();
    }
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    Iterator<CartProduct> it = products.iterator;
    bool isNew = true;
    while (it.moveNext()) {
      CartProduct current = it.current;
      if (current.pid == cartProduct.pid && current.size == cartProduct.size) {
        current.quantity++;
        Firestore.instance
            .collection("users")
            .document(user.firebaseUser.uid)
            .collection("cart")
            .document(current.cid)
            .updateData(current.toMap());
        isNew = false;
        break;
      }
    }
    if (isNew) {
      products.add(cartProduct);
      Firestore.instance
          .collection("users")
          .document(user.firebaseUser.uid)
          .collection("cart")
          .add(cartProduct.toMap())
          .then((doc) {
        cartProduct.cid = doc.documentID;
      });
    }

    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  int quantityItem() {
    int total = 0;
    if (products != null) {
      for (CartProduct cp in products) {
        total += cp.quantity;
      }
    }
    return total;
  }

  void setCoupon(String couponCode, int percent) {
    this.couponCode = couponCode;
    this.percent = percent;
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  double getProductsPrice() {
    double total = 0.0;
    for (CartProduct c in products) {
      if (c.productData != null) {
        total += c.quantity * c.productData.price;
      }
    }
    return total;
  }

  double getDiscount() {
    return (percent / 100) * getProductsPrice();
  }

  double getShipPrice() {
    return 9.90;
  }

  void updatePrices() {
    notifyListeners();
  }

  Future<String> finishOrder() async {
    if(products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double shipPrice = getShipPrice();
    double discount = getDiscount();
    double productsPrice = getProductsPrice();

    DocumentReference refOrder = await Firestore.instance.collection("orders").add({
      "clientId": user.firebaseUser.uid,
      "products": products.map((cartProduct){return cartProduct.toMap();}).toList(),
      "shipPrice": shipPrice,
      "discount": discount,
      "productsPrice": productsPrice,
      "totalPrice": productsPrice - discount + shipPrice,
      "status": 1,
      "date": DateTime.now()
    });
    
    await Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("orders").document(refOrder.documentID).setData({
      "orderId": refOrder.documentID
    });

    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").getDocuments();

    for(DocumentSnapshot doc in query.documents){
      doc.reference.delete();
    }

    products.clear();
    couponCode = null;
    percent = 0;
    isLoading = false;
    notifyListeners();

    return refOrder.documentID;
  }

  void _loadCart() async {
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();

    products = query.documents.map((document) {
      return CartProduct.fromDocument(document);
    }).toList();
  }
}
