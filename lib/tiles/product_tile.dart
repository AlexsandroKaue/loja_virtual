import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/datas/product_data.dart';
import 'package:lojavirtual/screens/product_screen.dart';

class ProductTile extends StatelessWidget {
  final String type;
  final ProductData data;

  ProductTile(this.type, this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Container(
          padding: EdgeInsets.all(4.0),
          child: type == "grid"
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 0.8,
                child: FutureBuilder<String>(
                  future: _getImageName(data.images[0]),
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
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
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "R\$ ${data.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
              : Row(
            children: [
              Flexible(
                flex: 1,
                child: FutureBuilder<String>(
                  future: _getImageName(data.images[0]),
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Image.network(
                        snapshot.data,
                        fit: BoxFit.cover,
                        height: 200.0,
                      );
                    }
                    return Container();
                  },
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "R\$ ${data.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ProductScreen(data)));
        },
      ),
    );
  }

  Future<String> _getImageName(String local) async {
    String url =
        await FirebaseStorage.instance.ref().child(local).getDownloadURL();
    return url;
  }
}

/*InkWell(
child: Card(
child: Container(
padding: EdgeInsets.all(4.0),
child: type == "grid"
? Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
AspectRatio(
aspectRatio: 0.8,
child: _loadProductImage(""),
),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
data.title,
style: TextStyle(fontWeight: FontWeight.bold),
),
Text(
data.price.toStringAsFixed(2),
style: TextStyle(
color: Theme.of(context).primaryColor),
),
],
),
),
],
)
: Row(),
),
),
),*/
