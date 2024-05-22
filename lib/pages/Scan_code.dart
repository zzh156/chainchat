import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sui/builder/transaction_block.dart';
import 'package:sui/cryptography/signature.dart';
import 'package:sui/sui_account.dart';
import 'package:sui/sui_client.dart';
import 'package:sui/sui_urls.dart';
import 'package:sui/types/transactions.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
  final String phrase;
  const QRScannerPage({Key? key, required this.phrase}) : super(key: key);
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // 申请摄像头权限
  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请授予摄像头权限')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code;
      });
      controller.pauseCamera();
      _showTransferDialog(result);  // 显示转账对话框
    });
  }

  void showSuccessDialog(BuildContext context, String digest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Lottie.asset('assets/checkmark.json', width: 100, height: 100, repeat: false),
              SizedBox(height: 20),
              Text('转账成功', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              Text('交易Digest: $digest', style: TextStyle(color: Colors.black)),
            ],
          ),
        );
      },
    );
  }

  void showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Lottie.asset('assets/cross.json', width: 100, height: 100, repeat: false),
              SizedBox(height: 20),
              Text('转账失败', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 10),
              Text('错误信息: $message', style: TextStyle(color: Colors.black)),
            ],
          ),
        );
      },
    );
  }

  void _showTransferDialog(String? scannedData) {
    if (scannedData == null) return;

    final parts = scannedData.split(';');
    if (parts.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('二维码格式不正确')),
      );
      return;
    }

    final scannedAddress = parts[0];
    final scannedNet = parts[1];

    TextEditingController amountController = TextEditingController();
    String selectedCurrency = 'SUI';  // 只支持SUI

    showDialog(
      context: context,
      barrierDismissible: false,  // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('输入转账详情', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '选择币种',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_exchange),
                  ),
                  value: selectedCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCurrency = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'SUI',
                      child: Text('SUI'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '金额',
                    hintText: '请输入转账金额',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                controller?.resumeCamera();
              },
            ),
            TextButton(
              child: Text('确认', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                final double amountDouble = double.tryParse(amountController.text) ?? 0;
                if (scannedAddress.isNotEmpty && amountDouble > 0) {
                  // 调用发送转账的函数
                  await _sendTransfer(scannedAddress, amountDouble, scannedNet);
                } else {
                  print("地址或金额无效！");
                }
                Navigator.of(context).pop();
                controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTransfer(String address, double amount, String net) async {
    final account = SuiAccount.fromMnemonics(widget.phrase, SignatureScheme.Ed25519);
    final client = SuiClient(net == 'mainnet' ? SuiUrls.mainnet : SuiUrls.testnet); // 选择主网或测试网

    try {
      // Create a new transaction block
      final tx = TransactionBlock();

      // Assuming 'amount' needs to be converted to the smallest unit and split from existing coins
      final int amountInt = (amount * 1000000000).toInt(); // Convert amount to an integer suitable for transaction
      final coin = tx.splitCoins(tx.gas, [tx.pureInt(amountInt)]); // Split the coins

      // Transfer the specified amount to the given address
      tx.transferObjects(
        [coin],
        tx.pureAddress(address),
      );

      // Sign and execute the transaction block
      final result = await client.signAndExecuteTransactionBlock(account, tx);

      // Print the transaction digest and check the result status
      print("Transaction Digest: ${result.digest}");

      if (result.effects?.status.status == ExecutionStatusType.success) {
        // 显示成功对话框
        showSuccessDialog(context, result.digest);
      } else {
        print("转账失败: ${result.effects?.status.status}");
        showFailureDialog(context, result.effects!.status.status.toString());
      }
    } catch (e) {
      print("转账异常: $e");
      showFailureDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫描二维码'),
        backgroundColor: Colors.transparent, // 将 AppBar 设置为透明
        elevation: 0, // 移除 AppBar 阴影
      ),
      extendBodyBehindAppBar: true, // 扩展 body 到 AppBar 后面
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
          // 移除下方白色区域
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          controller?.resumeCamera();
        },
      ),
    );
  }
}