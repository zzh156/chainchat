import 'package:flutter/material.dart';
import '../model/crypto_transfer_widget.dart';
class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  String _selectedCryptoType = ''; // 选择的加密货币类型
  String _transferAmount = ''; // 转账数量
  String _transferMessage = ''; // 转账留言

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('转账'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择加密货币类型:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedCryptoType.isNotEmpty ? _selectedCryptoType : null,
              onChanged: (value) {
                setState(() {
                  _selectedCryptoType = value!;
                });
              },
              items: <String>['SUI', 'USDT', 'ETH', 'BTC']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Text(
              '输入转账数量:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _transferAmount = value;
                });
              },
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            Text(
              '输入转账留言:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _transferMessage = value;
                });
              },
              maxLines: 3,
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 实现转账功能
                  // 将转账信息传递给 ChatPage
                  Navigator.pop(context, {
                    'currency': _selectedCryptoType,
                    'amount': _transferAmount,
                  });
                },
                child: Text('转账'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
