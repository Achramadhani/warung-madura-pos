import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'main_navigation.dart'; // Sesuaikan dengan file navigasi Anda

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const TokoRajawaliApp(),
    ),
  );
}

class TokoRajawaliApp extends StatelessWidget {
  const TokoRajawaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toko Rajawali',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MainNavigation(), // Pastikan ini mengarah ke navigasi utama Anda
    );
  }
}