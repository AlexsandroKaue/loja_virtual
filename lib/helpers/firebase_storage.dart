
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageHelper {
  static final FirebaseStorageHelper _instance = FirebaseStorageHelper.internal();

  factory FirebaseStorageHelper() => _instance;

  FirebaseStorageHelper.internal();

  final FirebaseStorage storage = FirebaseStorage(
      app: Firestore.instance.app,
      storageBucket: 'gs://loja-flutter-91708.appspot.com/');
}