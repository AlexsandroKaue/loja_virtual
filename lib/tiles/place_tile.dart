import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceTile extends StatelessWidget {
  final DocumentSnapshot snapshot;
  PlaceTile(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal:8.0,vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 100.0,
            child: FutureBuilder<String>(
              future: _getImageName(snapshot.data["image"]),
              builder: (context, s){
                if(!s.hasData)
                  return Container();
                else
                  return Image.network(
                    s.data,
                    fit: BoxFit.cover,
                  );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data["title"],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
                Text(
                  snapshot.data["address"],
                  textAlign: TextAlign.start,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      padding: EdgeInsets.zero,
                      textColor: Colors.blue,
                      child: Text("Ver no mapa"),
                      onPressed: (){
                        launch("https://www.google.com/maps/search/?api=1&query=${snapshot.data["lat"]},"
                            "${snapshot.data["lon"]}");
                      },
                    ),
                    FlatButton(
                      padding: EdgeInsets.zero,
                      textColor: Colors.blue,
                      child: Text("Ligar"),
                      onPressed: (){
                        launch("tel:${snapshot.data["phone"]}");
                      },
                    )
                  ],
                ),

              ],
            ),
          )
        ],
      ),
    );
  }

  Future<String> _getImageName(String local) async {
    String url =
    await FirebaseStorage.instance.ref().child(local).getDownloadURL();
    return url;
  }
}
