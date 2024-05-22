import 'package:flutter/material.dart';
import 'package:sui/builder/transaction_block.dart';
import 'package:sui/cryptography/signature.dart';
import 'package:sui/sui_account.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';

class BusinessCardPage extends StatefulWidget {
  @override
  _BusinessCardPageState createState() => _BusinessCardPageState();
  String phrase;
  String newRecipientAddress;
  BusinessCardPage({required this.phrase, required this.newRecipientAddress});
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  String _name = ''; // Name
  String _email = ''; // Email



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Card'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Name:',
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
              'Enter Email:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final testnetClient = SuiClient(SuiUrls.testnet);
                  final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
                  const packageObjectId = '0x8519d85438bff5329b2ba670751801f485aba44a232392ab21e70df27e928890';
                  final tx = TransactionBlock();
                  tx.moveCall('$packageObjectId::send_message::send_message', arguments: [tx.pureString("zsdgwg161wa2w6d62ada62d615a1d1adc2ac62"+_email),
                    tx.pure(widget.newRecipientAddress),
                    tx.pure('0x6'),
                  ]);
                  try {
                    final result = await testnetClient.signAndExecuteTransactionBlock(account, tx);
                    print("Message sent: ${result.digest}");
                  } catch (e) {
                    print('Error executing transaction: $e');
                  }
                  Navigator.pop(context, {'name': _name, 'email': _email});
                },
                child: Text('Send Business Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}