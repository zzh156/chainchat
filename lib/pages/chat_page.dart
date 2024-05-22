import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart' show VoidCallback;
import 'dart:io';
import 'package:chainchat/pages/chat_bubble.dart';
import 'package:chainchat/pages/create_business_card.dart';
import 'package:chainchat/pages/transfer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ipfs/flutter_ipfs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sui/builder/transaction_block.dart';
import 'package:sui/cryptography/signature.dart';
import 'package:sui/sui_account.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';
import 'package:sui/types/objects.dart';
import 'package:sui/types/transactions.dart';
import '../model/crypto_transfer_widget.dart';

class ChatPage extends StatefulWidget {
  final String recipientAddress;
  final String? ed25519Address;
  final String phrase;

  const ChatPage({
    Key? key,
    required this.phrase,
    required this.recipientAddress,
    required this.ed25519Address,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class Message {
  final String from;
  final String to;
  final String text;
  final String timestamp;

  Message({
    required this.from,
    required this.to,
    required this.text,
    required this.timestamp,
  });
}

class Cryptotransfer {
  final String from;
  final String to;
  final String text;
  final String timestamp;
  final String crypto;
  final String amount;


  Cryptotransfer({
    required this.from,
    required this.to,
    required this.text,
    required this.timestamp,
    required this.crypto,
    required this.amount,
  });
}

class BusinessCard {
  final String from;
  final String to;
  final String name;
  final String email;

  BusinessCard({
    required this.name,
    required this.email,
    required this.from,
    required this.to,
  });
}
class _ChatPageState extends State<ChatPage> {
  String? transferDigest;
  String? transferFrom;
  String? transferTo;
  String? transferStatus;
  final TextEditingController _messageController = TextEditingController();
  final List<dynamic> _messages = [];
  late Timer _timer;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _fetchNewMessages();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchNewMessages() async {
    final client = SuiClient(SuiUrls.devnet);

    final objectReceive = await client.getOwnedObjects(
      widget.ed25519Address!,
      options: SuiObjectDataOptions(showContent: true),
    );
    final objectSend = await client.getOwnedObjects(
      widget.recipientAddress,
      options: SuiObjectDataOptions(showContent: true),
    );

    List<dynamic> newMessages = [];

    objectReceive.data.forEach((object) {
      final fields = object.data?.content?.fields;
      if (fields != null &&
          fields.length == 5 &&
          fields.containsKey('from') &&
          fields.containsKey('to') &&
          fields.containsKey('id') &&
          fields.containsKey('text') &&
          fields.containsKey('timestamp_ms') &&
          fields['from'] == widget.recipientAddress) {
        newMessages.add(Message(
          from: fields['from'],
          to: fields['to'],
          text: fields['text'],
          timestamp: fields['timestamp_ms'],
        ));
      }

      if (fields != null &&
          fields.length == 7 &&
          fields.containsKey('from') &&
          fields.containsKey('to') &&
          fields.containsKey('id') &&
          fields.containsKey('text') &&
          fields.containsKey('timestamp_ms') &&
          fields.containsKey('crypto') &&
          fields.containsKey('amount') &&
          fields['from'] == widget.recipientAddress) {
        newMessages.add(Cryptotransfer(
          from: fields['from'],
          to: fields['to'],
          text: fields['text'],
          timestamp: fields['timestamp_ms'],
          crypto: fields['crypto'],
          amount: fields['amount'],
        ));
      }
    });

    objectSend.data.forEach((object) {
      final fields = object.data?.content?.fields;
      if (fields != null &&
          fields.length == 5 &&
          fields.containsKey('from') &&
          fields.containsKey('to') &&
          fields.containsKey('id') &&
          fields.containsKey('text') &&
          fields.containsKey('timestamp_ms') &&
          fields['from'] == widget.ed25519Address) {
        newMessages.add(Message(
          from: fields['from'],
          to: fields['to'],
          text: fields['text'],
          timestamp: fields['timestamp_ms'],
        ));
      }
      if (fields != null &&
          fields.length == 7 &&
          fields.containsKey('from') &&
          fields.containsKey('to') &&
          fields.containsKey('id') &&
          fields.containsKey('text') &&
          fields.containsKey('timestamp_ms') &&
          fields.containsKey('crypto') &&
          fields.containsKey('amount') &&
          fields['from'] == widget.ed25519Address) {
        newMessages.add(Cryptotransfer(
          from: fields['from'],
          to: fields['to'],
          text: fields['text'],
          timestamp: fields['timestamp_ms'],
          crypto: fields['crypto'],
          amount: fields['amount'],
        ));
      }
    });

    newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    setState(() {
      _messages.clear();
      _messages.addAll(newMessages);
      _messages.forEach((msg) => _saveMessage(msg));
    });
  }

  Future<void> _saveMessage(dynamic msg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedMessages = [..._messages.map((msg) => json.encode(msg)).toList()];
    await prefs.setStringList('chat_messages_${widget.recipientAddress}', updatedMessages);
  }

  void _transferAction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransferPage()),
    );
    if (result != null) {
      final String currency = result['currency'] ?? '';
      final String amount = result['amount'] ?? '';
      final String transferMessage = result['transferMessage'] ?? '';

      final double amountDouble = double.parse(amount);

      final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
      final client = SuiClient(SuiUrls.devnet);
      final tx = TransactionBlock();
      tx.setGasBudget(BigInt.from(1000000000)); // Set explicit gas budget

      final coin = tx.splitCoins(tx.gas, [tx.pureInt((amountDouble * 1000000000).toInt())]);
      tx.transferObjects(
        [coin],
        tx.pure(widget.recipientAddress),

      );

      try {
        final result1 = await client.signAndExecuteTransactionBlock(account, tx);
        final String transferDigest = result1.digest;
        final txn = await client.getTransactionBlock(
          result1.digest,
          options: SuiTransactionBlockResponseOptions(
            showEffects: true,
            showBalanceChanges: true,
          ),
        );

        String transferStatus = txn.effects?.status.status.toString() ?? '';

        if (txn.effects?.status.status == ExecutionStatusType.success) {
          // Show success message with digest
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transfer Successful: $transferDigest'),
              backgroundColor: Colors.green,
            ),
          );

          final cryptoTransfer = Cryptotransfer(
            from: widget.ed25519Address ?? '',
            to: widget.recipientAddress,
            text: transferMessage,
            timestamp: DateTime.now().toString(),
            crypto: currency,
            amount: amount,
          );

          setState(() {
            _messages.add(cryptoTransfer);
            _saveMessage(cryptoTransfer);
          });

          const packageObjectId = '0x258c94354b09262213fd8d8b1834b3ad7a7bca8021e22d548a79b2c27e5c9c5e';
          final tx = TransactionBlock();
          tx.setGasBudget(BigInt.from(100000000));
          final newRecipientAddress = widget.recipientAddress.trim();

          tx.moveCall(
            '$packageObjectId::chat_coin::crypto_transfer',
            arguments: [
              tx.pureString(transferMessage),
              tx.pure(newRecipientAddress),
              tx.pure(currency),
              tx.pure(amount),
              tx.pure('0x6'), // Example of a fixed argument
            ],
          );

          final result = await client.signAndExecuteTransactionBlock(account, tx);
          print(result.digest);
        } else {
          // Show failure message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transfer Failed: $transferStatus'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Show message if no data is returned from the transfer page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer Cancelled'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Future<void> _sendMessage() async {
    final String message1 = _messageController.text;
    if (message1.isNotEmpty) {
      setState(() {
        final newMessage = Message(
          from: widget.ed25519Address!,
          to: widget.recipientAddress,
          text: message1,
          timestamp: DateTime.now().toString(),
        );
        _messages.add(newMessage);
        _showOptions = false;
        _saveMessage(newMessage);
      });
      _messageController.clear();
      final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
      final client = SuiClient(SuiUrls.devnet);
      const packageObjectId = '0x258c94354b09262213fd8d8b1834b3ad7a7bca8021e22d548a79b2c27e5c9c5e';
      final tx = TransactionBlock();
      tx.setGasBudget(BigInt.from(100000000));

      final newRecipientAddress = widget.recipientAddress.trim();
      tx.moveCall(
        '$packageObjectId::chat_coin::send_message',
        arguments: [
          tx.pure('0x970e113cb4f02a4438c52541131ea4d1a8c97dfc552223dc5c5f13d3e89c7129'),
          tx.pure('0xe36d688bd66838bd6b9f171bb295deebc4cfe68fd6578fd1529b028c6bde50e7'),
          tx.pureString(message1),
          tx.pure(newRecipientAddress),
          tx.pure('0x6'),
        ],
      );

      try {
        final result = await client.signAndExecuteTransactionBlock(account, tx);
        print("Message sent: ${result.digest}");
      } catch (e) {
        print('Error executing transaction: $e');
      }
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter message',
              ),
              onTap: () {
                setState(() {
                  _showOptions = false;
                });
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showOptions = !_showOptions;
              });
            },
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(
              Icons.send,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid() {
    void _sendAsymmetricEncryption() {
      // Placeholder for asymmetric encryption functionality
    }

    void _sendBusinessCard() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessCardPage(phrase: widget.phrase,newRecipientAddress: widget.recipientAddress)),
      ).then((value) {
        if (value != null) {
          final background = value['background'];
          final name = value['name'];
        }
      });
    }

    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOptionItem(Icons.photo, 'Gallery', 36, () => _pickImageFromGallery(context)),
            _buildOptionItem(Icons.attach_money, 'Transfer', 36, _transferAction),
            _buildOptionItem(Icons.contact_mail, 'Business Card', 36, _sendBusinessCard),
            _buildOptionItem(Icons.lock, 'Encryption', 36, _sendAsymmetricEncryption),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String text, double size, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(8),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: size),
          ),
        ),
        SizedBox(height: 4.0),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipientAddress,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                  if (_messages[index] is Cryptotransfer) {
                    bool isCurrentUser = _messages[index].from ==
                        widget.ed25519Address;
                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.66, // Occupy 2/3 of the screen width
                        child: CryptoTransferWidget(
                          myAddress: widget.ed25519Address!,
                          currency: _messages[index].crypto,
                          amount: _messages[index].amount,
                          //digest: _messages[index].digest,
                          from: _messages[index].from,
                          to: _messages[index].to,
                          //status: _messages[index].status,
                        ),
                      ),
                    );
                  } else if (_messages[index] is Message) {
                    return ChatBubble(
                      message: _messages[index].text,
                      senderAddress: _messages[index].from != null
                          ? _messages[index].from.substring(0, 8) + '...'
                          : '...',
                      isCurrentUser: _messages[index].from ==
                          widget.ed25519Address,
                    );
                  }


                return SizedBox.shrink(); // Return an empty widget if message type is unknown
              },
            ),
          ),
          _buildMessageInput(),
          if (_showOptions) _buildOptionsGrid(),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Uploading to IPFS...'),
        ),
      );

      try {
        // Handle image upload
      } finally {
        Navigator.pop(context);
      }
    }
  }
}