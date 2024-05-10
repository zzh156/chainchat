import 'package:flutter/material.dart';

class BusinessCardPage extends StatefulWidget {
  @override
  _BusinessCardPageState createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  String _selectedBackground = ''; // 选择的名片背景
  String _name = ''; // 名字

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('名片'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择名片背景:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedBackground.isNotEmpty ? _selectedBackground : null,
              onChanged: (value) {
                setState(() {
                  _selectedBackground = value!;
                });
              },
              items: <String>['', 'Background 1', 'Background 2', 'Background 3'] // 添加空字符串作为默认值
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Text(
              '输入名字:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 20.0),
            Text(
              '发送者信息:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            // 显示发送者的 SUI 地址和名字
            SizedBox(height: 10.0),
            Text(
              'SUI地址: 发送者的SUI地址', // 替换为实际的发送者 SUI 地址
            ),
            Text(
              '名字: 发送者的名字', // 替换为实际的发送者名字
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 实现发送名片的逻辑
                  // 将 _selectedBackground 和 _name 发送给聊天页面
                  Navigator.pop(context, {'background': _selectedBackground, 'name': _name});
                },
                child: Text('发送名片'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
