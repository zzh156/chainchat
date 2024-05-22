import 'package:flutter/material.dart';
class TestnetPage extends StatelessWidget {
  const TestnetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testnet Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Testnet Page!'),
      ),
    );
  }
}