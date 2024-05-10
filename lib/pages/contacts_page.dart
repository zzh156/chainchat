import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: TextStyle(color: Colors.black), // 设置标题文字颜色为黑色
        ),
        centerTitle: true, // 标题居中
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5), // 深灰色
        iconTheme: IconThemeData(color: Colors.black), // 设置AppBar图标颜色为黑色
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.group),
            title: Text('群聊'),
            onTap: () {
              // 点击群聊选项跳转到群聊页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupChatPage()),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.name),
                  onTap: () {
                    // 点击联系人操作，这里可以做进一步的处理，比如跳转到聊天界面
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GroupChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '群聊',
          style: TextStyle(color: Colors.black), // 设置标题文字颜色为黑色
        ),
        centerTitle: true, // 标题居中
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5), // 深灰色
        iconTheme: IconThemeData(color: Colors.black), // 设置AppBar图标颜色为黑色
      ),
      body: Center(
        child: Text('这是群聊页面'),
      ),
    );
  }
}

class Contact {
  final String name;

  Contact({required this.name});
}

// 假设这是你的联系人列表
List<Contact> contacts = [
  Contact(name: 'Alice'),
  Contact(name: 'Bob'),
  Contact(name: 'Carol'),
  Contact(name: 'David'),
  // 其他联系人...
];

void main() {
  runApp(MaterialApp(
    home: ContactsPage(),
  ));
}