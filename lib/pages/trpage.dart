import 'package:flutter/material.dart';
import 'package:sui/sui.dart';

class TransferPage extends StatefulWidget {
  final Map<String, dynamic> token;
  final String network;
  final String from;
  final String phrase;

  TransferPage({Key? key, required this.token, required this.network, required this.from,required this.phrase}) : super(key: key);

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late SuiClient _suiClient;
  String? _transactionResult;

  @override
  void initState() {
    super.initState();
    _initializeSuiClient();
  }

  void _initializeSuiClient() {
    switch (widget.network) {
      case 'mainnet':
        _suiClient = SuiClient(SuiUrls.mainnet);
        break;
      case 'testnet':
        _suiClient = SuiClient(SuiUrls.testnet);
        break;
      default:
        _suiClient = SuiClient(SuiUrls.devnet);  // Default to devnet for safety
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Image.asset(widget.token["image"], width: 40, height: 40),
              title: Text(widget.token["name"]),
            ),
            TextField(
              controller: _toController,
              decoration: InputDecoration(labelText: "To Address"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Amount",
                suffixText: widget.token["name"],
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _performTransfer,
              child: Text('Continue'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),  // make button width 100%
              ),
            ),
            if (_transactionResult != null)
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Transaction successful: $_transactionResult', style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }

  void _performTransfer() async {
    final address = _toController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    final balance = double.tryParse(widget.token["balance"]); // Ensure this is correctly parsed from your token map

    if (address.isEmpty || amount == null || balance == null) {
      _showSnackBar('Invalid input', Colors.red);
      return;
    }

    if (amount > balance) {
      _showSnackBar('Amount exceeds balance', Colors.red);
      return; // Exit the method here to prevent further execution
    }

    if (widget.token["name"] != "SUI"&&widget.token["name"]!="CHAT") {
      _showSnackBar('Currently, only SUI AND CHAT transfer are supported', Colors.red);
      return;
    }

    try {
      final mnemonics = widget.phrase;
      final account = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Ed25519);
      final tx = TransactionBlock();

      final coin = tx.splitCoins(tx.gas, [tx.pureInt((amount * 1e9).toInt())]);

      tx.transferObjects(
        [coin],
        tx.pureAddress(address),
      );

      final result = await _suiClient.signAndExecuteTransactionBlock(account, tx);
      setState(() {
        _transactionResult = result.digest;
      });
      _showSnackBar('Transfer successful', Colors.green);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }



  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}