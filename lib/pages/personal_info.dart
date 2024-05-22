import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sui/sui.dart';
import 'package:chainchat/pages/PaymentCodePage.dart';
import 'package:chainchat/pages/Scan_code.dart';
import 'trpage.dart';

class WalletPage extends StatefulWidget {
  final String address;
  final String phrase;

  WalletPage({Key? key, required this.address, required this.phrase}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String _selectedNetwork = 'mainnet';
  late SuiClient mainnetClient;
  late SuiClient devnetClient;
  Timer? _timer;
  bool _isFaucetLoading = false;

  final List<Map<String, dynamic>> _mainnetTokens = [
    {"name": "SUI", "image": "assets/images/SUI.png", "balance": "0", "type": '0x2::sui::SUI'},
    {"name": "WBTC", "image": "assets/images/BTC.png", "balance": "0", "type": '0x94e7a8e71830d2b34b3edaa195dc24c45d142584f06fa257b73af753d766e690::celer_wbtc_coin::CELER_WBTC_COIN'},
    {"name": "WETH", "image": "assets/images/ETH.png", "balance": "0", "type": '0xaf8cd5edc19c4512f4259f0bee101a40d41ebed738ade5874359610ef8eeced5::coin::COIN'},
    {"name": "USDT", "image": "assets/images/USDT.png", "balance": "0", "type": '0xc060006111016b8a020ad5b33834984a437aaa7d3c74c18e09a95d48aceab08c::coin::COIN'},
    {"name": "BNB", "image": "assets/images/BNB.png", "balance": "0", "type": '0xb848cce11ef3a8f62eccea6eb5b35a12c4c2b1ee1af7755d02d7bd6218e8226f'},
    {"name": "USDC", "image": "assets/images/USDC.png", "balance": "0", "type": '0x5d4b302506645c37ff133b98c4b50a5ae14841659738d6d733d59d0d217a93bf::coin::COIN'},
    {"name": "APT", "image": "assets/images/APT.png", "balance": "0", "type": '0x3a5143bb1196e3bcdfab6203d1683ae29edd26294fc8bfeafe4aaa9d2704df37::coin::COIN'},
  ];

  final List<Map<String, dynamic>> _devnetTokens = [
    {"name": "SUI", "image": "assets/images/SUI.png", "balance": "0", "type": '0x2::sui::SUI'},
    {"name": "CHAT", "image": "assets/icon/app_icon.png", "balance": "0", "type": '0x258c94354b09262213fd8d8b1834b3ad7a7bca8021e22d548a79b2c27e5c9c5e::chat_coin::CHAT_COIN'},
  ];

  @override
  void initState() {
    super.initState();
    mainnetClient = SuiClient(SuiUrls.mainnet);
    devnetClient = SuiClient(SuiUrls.devnet);
    _startBalanceUpdate();
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '兑换功能稍后开放',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }


  void _navigateToTransferPage(Map<String, dynamic> token, String network) {
    Navigator.pop(context); // 关闭底部菜单
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => TransferPage(token: token, network: network, from: widget.address, phrase: widget.phrase),
    ));
  }

  void _startBalanceUpdate() {
    _updateBalances();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) => _updateBalances());
  }

  Future<void> _updateBalances() async {
    if (_selectedNetwork == 'mainnet') {
      await _updateTokenBalances(mainnetClient, _mainnetTokens);
    } else {
      await _updateTokenBalances(devnetClient, _devnetTokens);
    }
    if (_isFaucetLoading) {
      await _faucetDevnet();
    }
  }

  Future<void> _updateTokenBalances(SuiClient client, List<Map<String, dynamic>> tokens) async {
    try {
      final allCoins = await client.getAllCoins(widget.address);
      print('All coins data: ${allCoins.data}');
      Map<String, BigInt> balances = {}; // Use BigInt to store balances

      // First loop: Sum up balances for each coinType
      for (var coin in allCoins.data) {
        final coinType = coin.coinType;
        final balance = BigInt.parse(coin.balance);

        if (balances.containsKey(coinType)) {
          balances[coinType] = balances[coinType]! + balance; // Add to existing balance
        } else {
          balances[coinType] = balance; // Initialize balance for this coinType
        }
      }

      // Second loop: Update the UI with the calculated balances
      if (mounted) {
        setState(() {
          for (var token in tokens) {
            final balanceBigInt = balances[token['type']] ?? BigInt.zero;
            double realBalance = balanceBigInt / BigInt.from(10).pow(9); // Convert to main unit
            token['balance'] = realBalance.toStringAsFixed(3); // Format to 3 decimal places
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          print('Error fetching balances: $e');
        });
      }
    }
  }



  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _copyToClipboard(String? text) {
    if (text != null && text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatAddress(String? address) {
    if (address == null || address.length <= 11) return address ?? '';
    return '${address.substring(0, 7)}...${address.substring(address.length - 4)}';
  }

  void _sendMainnet() {
    _showTokenSelector(_mainnetTokens, 'mainnet');
  }

  void _sendDevnet() {
    _showTokenSelector(_devnetTokens, 'devnet');
  }

  void _receiveMainnet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentCodePage(address: widget.address, phrase: widget.phrase, net: "mainnet"),
      ),
    );
  }

  void _receiveDevnet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentCodePage(address: widget.address, phrase: widget.phrase, net: "devnet"),
      ),
    );
  }

  void _scanMainnet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(phrase: widget.phrase),
      ),
    );
  }

  void _scanDevnet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(phrase: widget.phrase),
      ),
    );
  }

  Future<void> _faucetDevnet() async {
    if (_selectedNetwork == 'mainnet') {
      _showComingSoonSnackBar(); // 如果是Mainnet，显示提示对话框
      return; // 直接返回，不进行后续操作
    }

    if (_isFaucetLoading) return;  // 如果正在加载中，则直接返回，防止重复请求

    setState(() {
      _isFaucetLoading = true;
    });

    try {
      final faucet = FaucetClient(SuiUrls.faucetDev);
      await faucet.requestSuiFromFaucetV1(widget.address);
      await Future.delayed(Duration(seconds: 5));  // 等待交易完成
      await _updateBalances();  // 获取水龙头资金后刷新余额
    } catch (e) {
      print('Error requesting from faucet: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFaucetLoading = false;
        });
      }
    }
  }


  void _showTokenSelector(List<Map<String, dynamic>> tokens, String network) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: Text('Choose Token', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tokens.length,
                  itemBuilder: (context, index) {
                    return _buildTokenTile(tokens[index], network); // 传递network参数
                  },
                ),
              ),
            ],
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedNetwork == 'mainnet' ? Colors.grey[200] : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedNetwork = 'mainnet';
                    });
                    _updateBalances();
                  },
                  child: Text('Mainnet'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedNetwork == 'devnet' ? Colors.grey[200] : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedNetwork = 'devnet';
                    });
                    _updateBalances();
                  },
                  child: Text('Devnet'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => _selectedNetwork == 'mainnet' ? _sendMainnet() : _sendDevnet(),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('发送'),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _selectedNetwork == 'mainnet' ? _receiveMainnet() : _receiveDevnet(),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.qr_code, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('接收'),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _selectedNetwork == 'mainnet' ? _scanMainnet() : _scanDevnet(),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.camera, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('扫一扫'),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _faucetDevnet(),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        padding: EdgeInsets.all(10),
                        child: _isFaucetLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                            : Icon(
                          _selectedNetwork == 'mainnet' ? Icons.currency_exchange : Icons.water_drop,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(_selectedNetwork == 'mainnet' ? '兑换' : '水龙头'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _selectedNetwork == 'mainnet'
                  ? _mainnetTokens.map((token) => _buildTokenTile(token, "mainnet")).toList()
                  : _devnetTokens.map((token) => _buildTokenTile(token, "devnet")).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenTile(Map<String, dynamic> token, String network) {
    return ListTile(
      leading: Container(
        width: 40, // 设置容器的固定大小
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).scaffoldBackgroundColor, // 使用当前主题的背景色
        ),
        child: ClipOval(
          child: Image.asset(
            token["image"],
            fit: BoxFit.cover, // 确保图像充满容器并保持纵横比
          ),
        ),
      ),
      title: Text(token["name"]),
      trailing: Text("${token["balance"]} ${token["name"]}", style: TextStyle(fontSize: 16)),
      onTap: () => _navigateToTransferPage(token, network), // 确保这里调用了_navigateToTransferPage
    );
  }
}
