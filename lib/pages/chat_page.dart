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
import 'package:sui/http/http.dart';
import 'package:sui/sui_account.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';
import 'package:sui/types/objects.dart';
import 'package:dio/dio.dart';
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

class message{
  final String from;
  final String to;
  final String text;
  final String timestamp;
  message({required this.from,required this.to,required this.text,required this.timestamp});
}

class _ChatPageState extends State<ChatPage> {
  String? transferDigest;
  String? transferFrom;
  String? transferTo;
  String? transferStatus;
  final TextEditingController _messageController = TextEditingController();
  final List<message> _messages = [];
  late Timer _timer;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchNewMessages();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchNewMessages() async {
    final client = SuiClient(SuiUrls.testnet);

    final objectReceive = await client.getOwnedObjects(
      widget.ed25519Address!,
      options: SuiObjectDataOptions(showContent: true),
    );
    final objectSend = await client.getOwnedObjects(
      widget.recipientAddress,
      options: SuiObjectDataOptions(showContent: true),
    );

    List<message> newMessages = [];

    objectReceive.data.forEach((object) {
      final fields = object.data?.content?.fields;
      if (fields != null &&
          fields.length == 5 &&
          fields.containsKey('from') &&
          fields.containsKey('to') &&
          fields.containsKey('id') &&
          fields.containsKey('text') &&
          fields.containsKey('timestamp_ms')&&fields['from']==widget.recipientAddress) {
        newMessages.add(message(
          from: fields['from'],
          to: fields['to'],
          text: fields['text'],
          timestamp: fields['timestamp_ms'],
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
          fields.containsKey('timestamp_ms')&&fields['from']==widget.ed25519Address) {
        newMessages.add(message(
          from: fields['from'],
          to: fields['to'],
          text: fields['text'],
          timestamp: fields['timestamp_ms'],
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

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _messages.clear();
      _messages.addAll((prefs.getStringList('chat_messages_${widget.recipientAddress}') ?? []).map((msg) {
        Map<String, dynamic> jsonMsg = json.decode(msg);
        return message(
          from: jsonMsg['from'],
          to: jsonMsg['to'],
          text: jsonMsg['text'],
          timestamp: jsonMsg['timestamp'],
        );
      }));
    });
  }

  Future<void> _saveMessage(dynamic msg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> updatedMessages = [..._messages.map((msg) => json.encode(msg)).toList()];
    await prefs.setStringList('chat_messages_${widget.recipientAddress}', updatedMessages);
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
          status: 'Uploading to IPFS...',
        ),
      );

      try {
        // Handle image upload
      } finally {
        Navigator.pop(context);
      }
    }
  }


  Future<void> _sendMessage() async {
    final String message1 = _messageController.text;
    if (message1.isNotEmpty) {
      setState(() {
        message messagestruct = message(from: widget.ed25519Address!,to: widget.recipientAddress,text: message1,timestamp: DateTime.now().toString());
        _messages.add(messagestruct);
        _showOptions = false;
        _saveMessage(messagestruct);
      });
      _messageController.clear();
      final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
      final client = SuiClient(SuiUrls.testnet);
      const packageObjectId = '0xb249cf2bf20797893465581768ec6e5b0dd7ce3a9475b157bce69f20960117a1';
      final tx = TransactionBlock();
      tx.setGasBudget(BigInt.from(100000000));
      final newRecipientaddress = widget.recipientAddress.trim();

      tx.moveCall('$packageObjectId::send_message::send_message', arguments: [tx.pureString(message1),tx.pure(newRecipientaddress),tx.pure('0x6')]);

      try {
        final result = await client.signAndExecuteTransactionBlock(account, tx);
        print("发送消息成功------------------------------------------------------");
        print(result.digest);
        print("发送消息成功------------------------------------------------------");
      } catch (e) {
        print('执行交易时出错: $e');
      }
    }
  }

  void _transferAction() async {
/*    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransferPage()),
    );
    if (result != null) {
      setState(() {
        final currency = result['currency'];
        print(currency);
        final amount = result['amount'];
        print(amount);
        final transferMessage = 'Transfer Successful';
        final transferWidget = CryptoTransferWidget(currency: currency, amount: amount);
        _messages.add(transferWidget);
        _saveMessage(transferWidget); // Save the transfer message
      });
    }*/
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TransferPage()),
    );
    if (result != null) {
      setState(() async {
        final String currency = result['currency'];
        final String amount = result['amount'];
        final String transferMessage = result['transferMessage'];
        final double amount_double = double.parse(amount);
        //尝试用dart sui sdk发送一笔交易
        final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
        final client = SuiClient(SuiUrls.testnet);
        final tx = TransactionBlock();
        //将amount_double*1000000000转为int
        final coin = tx.splitCoins(tx.gas, [tx.pureInt((amount_double*1000000000).toInt())]);
        tx.transferObjects(
            [coin],
            tx.pureAddress(widget.recipientAddress),
        );

        final result1 = await client.signAndExecuteTransactionBlock(account, tx);
        setState(() {
          transferDigest = result1.digest;
          print("转账digest:----------------------------");
          print(transferDigest);
          transferFrom = widget.ed25519Address;
          print("transfer from address:----------------------------");
          print(transferFrom);
          transferTo = widget.recipientAddress;
          print("transfer to address:----------------------------");
          print(transferTo);
        });

        print(result1.digest);

        print(result1.toJson());
        final txn = await client.getTransactionBlock(result1.digest,
            options: SuiTransactionBlockResponseOptions(showEffects: true,showBalanceChanges: true,)
        );
        setState(() {
          transferStatus = txn.effects?.status.status.toString();
          print("transfer status:----------------------------");
          print(transferStatus);
        });
        //print(txn.effects?.status.status.toString());  //txn.effects?.status.status.toString()== ExecutionStatusType.success 或者 ExecutionStatusType.failure
        if (txn.effects?.status.status==ExecutionStatusType.success){
          //弹出转账成功提示框
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('转账成功'),
                content: Text('转账成功'),
                actions: [
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
          //调用消息发送合约，将text换为currency+amount
          final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
          final client = SuiClient(SuiUrls.testnet);
          const packageObjectId = '0xb249cf2bf20797893465581768ec6e5b0dd7ce3a9475b157bce69f20960117a1';
          final tx = TransactionBlock();
          tx.setGasBudget(BigInt.from(100000000));
          final newRecipientaddress = widget.recipientAddress.trim();
          /*
          final String prefix = "transfer";
          tx.moveCall('$packageObjectId::send_message::send_message', arguments: [tx.pureString(prefix+currency+amount),tx.pure(newRecipientaddress),tx.pure('0x6')]);
           */

          tx.moveCall('$packageObjectId::send_message::crypto_transfer', arguments: [tx.pureString(transferMessage),tx.pure(newRecipientaddress),tx.pureString(currency),tx.pureString(amount),tx.pure('0x6')]);
          try {
            final result = await client.signAndExecuteTransactionBlock(account, tx);
            print("发送消息成功----------------------------------------------------------------------------");
            print(result.digest);
            print("发送消息成功----------------------------------------------------------------------------");
            print("发送消息成功----------------------------------------------------------------------------");
            print("发送消息成功----------------------------------------------------------------------------");
          } catch (e) {
            print('执行交易时出错: $e');
          }

        }else{
          print("转账失败");
        }

        //转账digest:9sPiJ37cCDNQZiyaHJPDKYuRtgjqKetkyJS9C1tAnPMj
        //发送消息成功:8yY7ofSruR6yhMQjUWpYW92qgEZdX9iSC1hfwGzXvBrE

        //检查交易是否成功执行

        //如果成功执行，调用消息发送合约，将text换为currency+amount

        //解析账户下的object是，发现转账格式的object，分类调用另一种样式

      });
    }else{
      print("转账失败");
    }

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
                if (_messages[index].text.startsWith('transfer')) {
                  // Render transfer messages using CryptoTransferWidget
                  String currency;
                  String amount;

                  if (_messages[index].text.substring(7, 10) == "USD") {
                    currency = _messages[index].text.substring(7, 11);
                    amount = _messages[index].text.substring(11);
                  } else {
                    currency = _messages[index].text.substring(8, 11);
                    amount = _messages[index].text.substring(11);
                  } 

                  return Expanded(
                    child: CryptoTransferWidget(
                      currency: currency,
                      amount: amount,
                      //补充所有交易完整信息, //获得result1交易的digest from to amount currency status

                      //transferDigest等获取有问题

                      digest: ,
                      from: _messages[index].from,
                      to: _messages[index].to,
                      status: ,

                    ),
                  );




                }  if (_messages[index] is message) {
                  // Render chat messages using ChatBubble
                  return ChatBubble(
                    message: _messages[index].text,
                    senderAddress: _messages[index].from != null ? _messages[index].from.substring(0, 8) + '...' : '...',
                    isCurrentUser: _messages[index].from == widget.ed25519Address,
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

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入消息',
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
    // Options functions
    void _sendNFT() {
      // Not implemented yet
    }

    void _sendBusinessCard() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessCardPage()),
      ).then((value) {
        if (value != null) {
          final background = value['background'];
          final name = value['name'];
        }
      });
    }

    /*void _transferAction() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TransferPage()),
      ).then((value) {
        if (value != null) {
          setState(() {
            final currency = value['currency'];
            final amount = value['amount'];
            final transferMessage = 'Transfer Successful';
            final transferWidget = CryptoTransferWidget(currency: currency, amount: amount);
            _messages.add(transferWidget);
          });
        }
      });
    }*/



    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOptionItem(Icons.photo, '相册', 36, () => _pickImageFromGallery(context)),
            _buildOptionItem(Icons.attach_money, '转账', 36, _transferAction),
            _buildOptionItem(Icons.contact_mail, '名片', 36, _sendBusinessCard),
            _buildOptionItem(Icons.account_balance_wallet, '发送NFT', 36, _sendNFT),
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
}
