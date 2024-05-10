import 'package:flutter/material.dart';

class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '发现',
          style: TextStyle(
            color: Colors.black, // 设置标题文字颜色为黑色
          ),
        ),
        centerTitle: true, // 标题居中
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5), // 深灰色
        iconTheme: IconThemeData(color: Colors.black), // 设置AppBar图标颜色为黑色
      ),
      body: Center(
        child: Text(
          'Discover Page Content',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DiscoverPage(),
  ));
}
