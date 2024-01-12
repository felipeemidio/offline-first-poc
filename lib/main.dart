import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:offline_first_poc/datasources/firestore_datasource.dart';
import 'package:offline_first_poc/firebase_options.dart';
import 'package:offline_first_poc/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirestoreDatasource.initialize();

  runApp(const MainApp());
}
