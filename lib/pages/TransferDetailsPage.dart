import 'package:flutter/material.dart';

class TransferDetailPage extends StatelessWidget {
  final String currency;
  final String amount;
  final String? digest;
  final String? from;
  final String? to;
  final String? status;

  TransferDetailPage({
    required this.currency,
    required this.amount,
    this.digest,
    this.from,
    this.to,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('转账详情'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                '你已转账，代币已成功发送',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                '$amount $currency',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              //if (digest != null) _buildDetailRow('Digest', digest!),
              if (from != null) _buildDetailRow('From', from!),
              if (to != null) _buildDetailRow('To', to!),
              //if (status != null) _buildDetailRow('Status', status!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80, // 设定一个固定宽度以保持对齐
            child: Text(
              '$label: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}