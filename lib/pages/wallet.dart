import 'dart:async';
import 'package:chainchat/pages/PaymentCodePage.dart';
import 'package:chainchat/pages/Scan_code.dart';
import 'package:chainchat/pages/wallet_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sui/sui.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

TextStyle commonTextStyle = TextStyle(
  color: Colors.grey,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

Future<double> fetchSuiPriceFromHuobi() async {
  // 火币网提供的获取所有交易对行情的 API
  const url = 'https://api.huobi.pro/market/tickers';

  try {
    // 发送 HTTP GET 请求
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // 解析响应的 JSON 数据
      final jsonResponse = json.decode(response.body);
      final List<dynamic> tickers = jsonResponse['data'];

      // 遍历所有交易对，找到 SUI-USDT
      for (var ticker in tickers) {
        if (ticker['symbol'] == 'suiusdt') {
          // 获取 SUI 对 USDT 的最新成交价
          return double.parse(ticker['close'].toString());
        }
      }
      // 如果没有找到 SUI-USDT 交易对，抛出异常
      throw Exception('SUI-USDT pair not found');
    } else {
      // 如果 HTTP 请求未成功，抛出异常
      throw Exception('Failed to load market tickers from Huobi');
    }
  } catch (e) {
    // 打印异常信息
    print('Exception when fetching SUI price: $e');
    throw Exception('Failed to load SUI price');
  }
}



Future<double> fetchSuiPrice() async {
  const url = 'https://api.coingecko.com/api/v3/simple/price?ids=sui&vs_currencies=usd';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final double price = jsonResponse['sui']['usd'].toDouble();
      return price;
    } else {
      throw Exception('Failed to load SUI price');
    }
  } catch (e) {
    throw Exception('Failed to load SUI price');
  }
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.ed25519Address, required this.phrase}) : super(key: key);

  final String ed25519Address;
  final String phrase;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SuiClient testnetClient = SuiClient(SuiUrls.testnet);
  late Timer _timer;
  String suiBalance = '0.00';
  double suiPrice = 0.0; // 新增变量来存储 SUI 的价格
  String totalValue = '0.00'; // 存储总价

  @override
  void initState() {
    super.initState();
    _fetchSuiPriceAndUpdateTotalValue();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateBalance());
  }

  Future<void> _fetchSuiPriceAndUpdateTotalValue() async {
    try {
      suiPrice = await fetchSuiPrice();
      _updateBalance();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "获取 SUI 价格失败: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _updateBalance() async {
    try {
      PaginatedCoins paginatedCoins = await testnetClient.getAllCoins(widget.ed25519Address);
      List<CoinStruct> allCoins = paginatedCoins.data;

      double totalBalance = 0.0;
      for (CoinStruct coin in allCoins) {
        double balance = double.parse(coin.balance) / 1e9;  // 转换为 SUI
        totalBalance += balance;
      }

      print('Total SUI Balance: $totalBalance');  // Debug: Print the total balance

      setState(() {
        suiBalance = totalBalance.toStringAsFixed(3);  // 保留三位小数
        totalValue = (totalBalance * suiPrice).toStringAsFixed(2);  // 更新总价
        print('Total Value: $totalValue');  // Debug: Print the total value
      });
    } catch (e) {
      print('Error fetching balance: $e');
      Fluttertoast.showToast(
        msg: "获取余额失败: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "已复制地址!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  String _getShortAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _navigateToTestnetPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestnetPage()),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSuiContainer(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 修改这里使内容居中并填满
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 10, height: 10),
                Image.asset('assets/images/sui.png', width: 60, height: 60),
                const SizedBox(width: 35),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    const Text(
                      'SUI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      suiBalance,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '\$$totalValue',  // 显示总价
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> Faucet() async {
    final faucet = FaucetClient(SuiUrls.faucetTest);
    await faucet.requestSuiFromFaucetV1(widget.ed25519Address);
    //成功后弹出提示
    Fluttertoast.showToast(
      msg: "claimed 1 SUI",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  Receive(){
    //弹出正方形页面，周围背景虚化，上方标题Receive(靠左)，中间显示二维码，下方显示地址(点击可复制)
    //导航到PaymentCodePage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentCodePage(phrase: widget.phrase, address: widget.ed25519Address, net: 'testnet')),
    );

  }


  Send() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan QR Code'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerPage(phrase: widget.phrase)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Enter Address Manually'),
              onTap: () {
                // 弹出一个文本输入框，让用户输入地址
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Enter Address&&Amount'),
                      //输入框，地址和数量
                      content: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter SUI address',
                        ),
                        onChanged: (value) {
                          // 在这里处理用户输入的地址

                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 在这里处理用户输入的地址
                            Navigator.of(context).pop();
                          },
                          child: const Text('Send'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 17,
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 34,
                    bottom: 10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.3),
                    child: GestureDetector(
                      onTap: () => _copyToClipboard(widget.ed25519Address),
                      child: Text(
                        _getShortAddress(widget.ed25519Address),
                        style: commonTextStyle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 34,
                    child: GestureDetector(
                      onTap: () => _navigateToTestnetPage(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            )
                          ],
                        ),
                        child: Text(
                          'testnet',
                          style: commonTextStyle.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 0.5,
            ),
            Expanded(
              flex: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$$totalValue',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _copyToClipboard(widget.ed25519Address),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getShortAddress(widget.ed25519Address),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(widget.ed25519Address),
                          child: const Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton('Faucet', Faucet),
                      const SizedBox(width: 8),
                      _buildButton('Receive', Receive),
                      const SizedBox(width: 8),
                      _buildButton('Send', () =>Send()),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 0.5,
            ),
            Expanded(
              flex: 77,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuiContainer(() => _showToast('Sui container clicked')),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 0.5,
            ),
            Expanded(
              flex: 20,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp(ed25519Address: 'ed25519Address_example', phrase: 'example phrase'));
}