import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chainchat/pages/add_friend_page.dart';
import 'package:chainchat/pages/contacts_page.dart';
import 'package:chainchat/pages/discover.dart';
import 'package:chainchat/pages/personal_info.dart';
import 'package:chainchat/pages/chat_page.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';
import 'package:sui/types/objects.dart';
import 'package:sui/types/transactions.dart';

class HomePage extends StatefulWidget {
  final String phrase;
  final String ed25519Address;
  final String? privateKey;

  const HomePage({
    Key? key,
    required this.phrase,
    required this.ed25519Address,
    this.privateKey,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<String> messages = [];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 初始化计时器，每 5 秒执行一次函数
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchTransactionBlock();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchTransactionBlock() async {
    final client = SuiClient(SuiUrls.testnet);

    final objects = await client.getOwnedObjects(
      widget.ed25519Address,
      options: SuiObjectDataOptions(showContent: true),
    );

    objects.data.forEach((object) {
      final fields = object.data?.content?.fields;
      if (fields != null &&
          fields.length == 5 &&
          fields.containsKey('from') &&
          fields.containsKey('to') &&
          fields.containsKey('id') &&
          fields.containsKey('text') &&
          fields.containsKey('timestamp_ms')) {
        if (!messages.contains(fields['from'])) {
          setState(() {
            messages.insert(0, fields['from']);
          });
        }
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleFriendAdded(String suiAddress) {
    setState(() {
      messages.insert(0, suiAddress);
    });
  }

  void _navigateToChatPage(String suiAddress) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          phrase: widget.phrase,
          recipientAddress: suiAddress,
          ed25519Address: widget.ed25519Address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: const Text(
          'Home Page',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5),
        actionsIconTheme: IconThemeData(color: Colors.black),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'add_friend') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddFriendPage(
                      onFriendAdded: _handleFriendAdded,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'add_friend',
                child: ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('添加朋友'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'start_group_chat',
                child: ListTile(
                  leading: Icon(Icons.group),
                  title: Text('发起群聊'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'scan',
                child: ListTile(
                  leading: Icon(Icons.qr_code_scanner),
                  title: Text('扫一扫'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'payment',
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('收付款'),
                ),
              ),
            ],
          )
        ],
      )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          messages[index].length > 5
                              ? '${messages[index].substring(0, 5)}...'
                              : messages[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _navigateToChatPage(messages[index]);
                    },
                  ),
                  Divider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 0.5,
                    height: 0.0,
                  ),
                ],
              );
            },
          ),
          ContactsPage(),
          DiscoverPage(),
          PersonalInfoPage(
            address: widget.ed25519Address,
            privateKey: widget.privateKey,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '信息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '通讯录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我',
          ),
        ],
      ),
    );
  }
}
