// add_friend_page.dart

import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  final Function(String) onFriendAdded;

  const AddFriendPage({Key? key, required this.onFriendAdded}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加朋友'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '输入Sui地址',
                hintText: '请输入有效的Sui地址',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String suiAddress = _controller.text;
                if (suiAddress.isNotEmpty) { // Check if the entered address is not empty
                  widget.onFriendAdded(suiAddress);
                  Navigator.pop(context);
                } else {
                  // Show a snackbar or any other feedback indicating that the address is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('请输入有效的Sui地址'),
                    ),
                  );
                }
              },
              child: Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
