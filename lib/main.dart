import 'package:flutter/material.dart';
import 'package:offline_first_poc/main_app.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.initialize();

  runApp(const MainApp());
}
