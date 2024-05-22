import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentCodePage extends StatefulWidget {
  final String phrase;
  final String address;
  final String net;

  const PaymentCodePage({
    Key? key,
    required this.phrase,
    required this.address,
    required this.net,
  }) : super(key: key);

  @override
  _PaymentCodePageState createState() => _PaymentCodePageState();
}

class _PaymentCodePageState extends State<PaymentCodePage> {
  late String _qrData;

  @override
  void initState() {
    super.initState();
    // Combine the address and network into a single string with a delimiter.
    _qrData = "${widget.address};${widget.net}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/SUI.png', width: 20, height: 20),
            SizedBox(width: 8),
            Text('Receive'),
          ],
        ),
      ),
      body: Center( // 使用Center小部件将内容居中
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // 将子部件在横轴上居中对齐
            children: [
              QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 16),
              Text(
                "Scan to receive",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () => _copyToClipboard(_qrData),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatAddress(widget.address),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.copy, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatAddress(String address) {
    if (address.length <= 11) return address;
    return '${address.substring(0, 7)}...${address.substring(address.length - 4)}';
  }
}