import 'dart:async';
import 'package:chainchat/pages/Scan_code.dart';
import 'package:flutter/material.dart';
import 'package:chainchat/pages/add_friend_page.dart';
import 'package:chainchat/pages/contacts_page.dart';
import 'package:chainchat/pages/discover.dart';
import 'package:chainchat/pages/personal_info.dart';
import 'package:chainchat/pages/chat_page.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';
import 'package:sui/types/objects.dart';

import 'PaymentCodePage.dart';

class HomePage extends StatefulWidget {
  final String phrase;
  final String ed25519Address;
  final String privateKey;

  const HomePage({
    Key? key,
    required this.phrase,
    required this.ed25519Address,
    required this.privateKey,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> messages = []; // Modified to store address, unread status, latest message, and timestamp

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initialize timer to fetch transaction block every 500 ms
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
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
        final senderAddress = fields['from'];
        final latestMessage = fields['text'];
        final timestamp = fields['timestamp_ms'] is int
            ? fields['timestamp_ms']
            : int.tryParse(fields['timestamp_ms'].toString()) ?? 0; // Ensure timestamp is an integer
        final messageIndex = messages.indexWhere((message) => message['from'] == senderAddress);

        setState(() {
          if (messageIndex == -1) {
            // New message from a new sender
            messages.insert(0, {
              'from': senderAddress,
              'unread': true, // Initialize with unread status
              'latestMessage': latestMessage,
              'timestamp': timestamp,
            });
          } else {
            // Update the latest message from an existing sender
            messages[messageIndex]['latestMessage'] = latestMessage;
            messages[messageIndex]['timestamp'] = timestamp;
            messages[messageIndex]['unread'] = true; // Mark as unread
          }
          messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp'])); // Sort messages
        });
      }
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // Mark all messages as read when viewing messages page
        messages.forEach((message) => message['unread'] = false);
      }
    });
  }

  void _handleFriendAdded(String suiAddress) {
    // 检查输入的地址是否与当前用户相同
    if (suiAddress == widget.ed25519Address) {
      // 如果是当前用户，则显示错误消息
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cannot Add Yourself'),
            content: Text('You cannot add yourself as a friend.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (messages.any((message) => message['from'] == suiAddress)) {
      // 如果已经添加了该朋友，则显示错误消息
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Already Added'),
            content: Text('This friend is already added.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // 如果地址不是当前用户且也未添加过，则执行添加朋友操作
      setState(() {
        messages.insert(0, {'from': suiAddress, 'unread': false, 'latestMessage': '', 'timestamp': null});
      });
    }
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
    ).then((_) {
      // Mark the message as read when returning from chat page
      final messageIndex = messages.indexWhere((message) => message['from'] == suiAddress);
      if (messageIndex != -1) {
        setState(() {
          messages[messageIndex]['unread'] = false;
        });
      }
    });
  }

  void _markAsUnread(int index) {
    setState(() {
      messages[index]['unread'] = true;
    });
  }

  void _removeUnread(int index) {
    setState(() {
      messages[index]['unread'] = false;
    });
  }

  void _deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
  }

  void _topMessage(int index) {
    setState(() {
      final message = messages.removeAt(index);
      messages.insert(0, message);
    });
  }

  void _showContextMenu(BuildContext context, Offset position, int index) {
    final overlay = Overlay.of(context)?.context.findRenderObject();
    final overlaySize = overlay?.semanticBounds.size ?? Size.zero;
    final positionAdjusted = Offset(
      position.dx,
      position.dy - 60, // Adjust this value to move the menu up
    );

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        positionAdjusted.dx,
        positionAdjusted.dy,
        overlaySize.width - positionAdjusted.dx,
        overlaySize.height - positionAdjusted.dy,
      ),
      items: [
        PopupMenuItem(
          height: 40, // Adjust this value to make the menu smaller
          child: GestureDetector(
            onTap: () => _deleteMessage(index),
            child: Container(
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem(
          height: 40, // Adjust this value to make the menu smaller
          child: GestureDetector(
            onTap: () => _topMessage(index),
            child: Container(
              child: Center(
                child: Text(
                  'Top',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem(
          height: 40, // Adjust this value to make the menu smaller
          child: GestureDetector(
            onTap: () => _markAsUnread(index),
            child: Container(
              child: Center(
                child: Text(
                  'Unread',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedIndex == 0
        ? AppBar(
          //set height
          toolbarHeight: 43,
        title: const Text(
        'Chainchat',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
    ),
    centerTitle: true,
    backgroundColor: Color.fromRGBO(227, 224, 224, 0.5),
    actionsIconTheme: IconThemeData(color: Colors.black),
    iconTheme: IconThemeData(color: Colors.black),
    actions: [
      PopupMenuButton(
        iconSize: 20, // 调整图标大小
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
          if (value == 'payment') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PaymentCodePage(
                  phrase: widget.phrase,
                  address: widget.ed25519Address,
                  net: "mainnet",
                ),
              ),
            );
          }
          if (value == 'scan') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QRScannerPage(
                  phrase: widget.phrase,
                ),
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'add_friend',
            child: ListTile(
              leading: Icon(Icons.person_add, size: 20), // 调整图标大小
              title: Text(
                'Add Friend',
                style: TextStyle(fontSize: 14), // 调整文本大小
              ),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'start_group_chat',
            child: ListTile(
              leading: Icon(Icons.group, size: 20), // 调整图标大小
              title: Text(
                'Start Group Chat',
                style: TextStyle(fontSize: 14), // 调整文本大小
              ),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'scan',
            child: ListTile(
              leading: Icon(Icons.qr_code_scanner, size: 20), // 调整图标大小
              title: Text(
                'Scan QR Code',
                style: TextStyle(fontSize: 14), // 调整文本大小
              ),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'payment',
            child: ListTile(
              leading: Icon(Icons.attach_money, size: 20), // 调整图标大小
              title: Text(
                'Payment',
                style: TextStyle(fontSize: 14), // 调整文本大小
              ),
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
    GestureDetector(
    onLongPressStart: (details) {
    _showContextMenu(context, details.globalPosition, index);
    },
    child: ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300], // Light grey background
      ),
      child: Center(
        child: Text(
          messages[index]['from'].substring(0, 1), // Display the first character of the address
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  messages[index]['from'].length > 5
                      ? '${messages[index]['from'].substring(0, 5)}...'
                      : messages[index]['from'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                _formatTimestamp(messages[index]['timestamp']),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 5), // Add spacing between address and message
          Text(
            messages[index]['latestMessage'] ?? '',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 10), // Add spacing at the top
          if (messages[index]['unread']) // Check if the message is marked as unread
            Icon(
              Icons.circle,
              color: Colors.red,
              size: 10,
            ),
        ],
      ),
      onTap: () {
        _navigateToChatPage(messages[index]['from']);
      },
    ),
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
      ContactsPage(
        contacts: messages.map<String>((e) => e['from'] as String).toList(),
        phrase: widget.phrase,
        ed25519Address: widget.ed25519Address,
        privateKey: widget.privateKey,
      ),
      DiscoverPage(),
      WalletPage(
        address: widget.ed25519Address,
        phrase: widget.phrase,
      ),
    ],
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.message),
                if (messages.any((message) => message['unread']))
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(date).inDays == 1) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.year}-${date.month}-${date.day}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}