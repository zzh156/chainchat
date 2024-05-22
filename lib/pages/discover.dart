import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '发现',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(227, 224, 224, 0.5),
          iconTheme: IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '输入Dapp名称或者网址',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.blue,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Bridge'),
                    Tab(text: 'Defi'),
                    Tab(text: 'Dex'),
                    Tab(text: 'NFT'),
                    Tab(text: 'Tools'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            BridgeTabContent(),
            DefiTabContent(),
            DexTabContent(),
            NFTTabContent(),
            ToolsTabContent(),
          ],
        ),
      ),
    );
  }
}

class BridgeTabContent extends StatelessWidget {
  final String _urlOmniBTC = 'https://www.omnibtc.finance/';
  final String _urlAnotherDapp = 'https://example.com/another-dapp';

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildDappCard(String imagePath, String title, String description, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDappCard(
            'assets/images/OmniBTC.png',
            'OmniBTC',
            'OmniBTC is an omnichain financial platform for web3, '
                'including omnichain swap and BTC omnichain lending.',
            _urlOmniBTC,
          ),


        ],
      ),
    );
  }
}

class DefiTabContent extends StatelessWidget {
  final String _urlCetus = 'https://www.cetus.zone/';
  final String _urlOmniBTC = 'https://www.omnibtc.finance/';
  final String _urlDeepBook = 'https://deepbook.tech/';
  final String _urlTurbos = 'https://turbos.finance/';
  final String _urlFlowXFinance = 'https://flowx.finance/';
  final String _urlKriyaDEX = 'https://www.kriya.finance/';
  final String _urlNavi = 'https://naviprotocol.io/';
  final String _urlScallop = 'https://scallop.io/';
  final String _urlAftermath = 'https://aftermath.finance/';
  final String _urlBucket = 'https://bucketprotocol.io/';
  final String _urlTypus = 'https://typus.finance/';

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildDappCard(String imagePath, String title, String description, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
    child: ListView(
    children: [
    _buildDappCard(
    'assets/images/Cetus.png',
    'Cetus',
    'Cetus builds a highly-customizable liquidity protocol based on CLMM. Through flexible composition of swap, range order and limit order, users can conduct almost all kinds of complex trading strategies that could be achieved on a CEX.',
    _urlCetus,
    ),
    _buildDappCard(
    'assets/images/OmniBTC.png',
    'OmniBTC',
    'OmniBTC is an omnichain financial platform for web3, '
    'including omnichain swap and BTC omnichain lending.',
    _urlOmniBTC,
    ),
    _buildDappCard(
    'assets/images/DeepBook.png',
    'DeepBook',
    'Deepbook is a high-throughput and low latency DEX with a fully on-chain order book capable of delivering a trading experience similar to that of a CEX.',
    _urlDeepBook,
    ),
    _buildDappCard(
    'assets/images/Turbos.png',
    'Turbos',
    'Turbos Finance is a hyper-efficient decentralized crypto marketplace built atop Sui.',
    _urlTurbos,
    ),
    _buildDappCard(
    'assets/images/FlowX.png',
    'FlowX Finance',
    'FlowX Finance is the one stop DEX for trading needs, designed to provide a seamless, user-friendly experience for all.',
    _urlFlowXFinance,
    ),
    _buildDappCard(
    'assets/images/KriyaDEX.png',
    'KriyaDEX',
    'KriyaDEX is a decentralized exchange that allows users to trade tokens in a permissionless and secure manner.',
    _urlKriyaDEX,
    ),
    _buildDappCard(
    'assets/images/Navi Protocol.png',
    'Navi',
    'NAVI is the One-stop Liquidity Protocol built on Move. NAVI Products offers easy to use lending/borrowing.',
    _urlNavi,
    ),
    _buildDappCard(
    'assets/images/Scallop.png',
    'Scallop',
    'a DeFi lending protocol built on Sui, is leveraging the network strengths to offer a user-friendly platform for borrowing and lending digital assets',
      _urlScallop,
    ),
      _buildDappCard(
        'assets/images/Aftermath.png',
        'Aftermath Finance',
        'Join Aftermath Finance for the future of decentralized trading. Experience the security of self-custody and the ease of a centralized exchange.',
        _urlAftermath,
      ),
      _buildDappCard(
        'assets/images/Bucket.png',
        'Bucket Protocol',
        'Bucket Protocol is the leading stablecoin protocol powered by Sui Network. While optimizing DeFi yields, BUCK stablecoin also bridges the gap between GameFi ...',
        _urlBucket,
      ),
      _buildDappCard(
        'assets/images/Typus.png',
        'Typus Finance',
        'Real Yield in One Click. Built on Sui Blockchain.',
        _urlTypus,
      ),
    ],
    ),
    );

  }
}


class  DexTabContent extends StatelessWidget {
  final String _urlUniswapv3 = 'https://app.uniswap.org/';
  final String _urlDODO = 'https://www.omnibtc.finance/';
  final String _urlCurve = 'https://curve.fi/#/ethereum/swap';
  final String _urlClipper = 'https://clipper.exchange/';
  final String _urlTokenlon = 'https://tokenlon.im/instant';
  final String _urlBalancer = 'https://balancer.fi/';
  final String _url1inch = 'https://1inch.io/';
  final String _urlBancor = 'https://bancor.network/';
  final String _urldydx = 'https://dydx.exchange/';
  final String _urlKyber = 'https://https://kyber.network/';
  final String _urlSmoothy = 'https://https://smoothy.finance/#/swap';

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Widget _buildDappCard(String imagePath, String title, String description, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDappCard(
            'assets/images/uniswap.png',
            'Uniswapv3',
            'Uniswap is a decentralized finance protocol that is used to exchange cryptocurrencies. Uniswap is also the name of the company that initially built the Uniswap protocol.',
            _urlUniswapv3,
          ),
          _buildDappCard(
            'assets/images/DODO.png',
            'DODO',
            'DODO is an On-Chain Liquidity Provider for everyone.DODO Aims to be the Best Decentralize Exchange (DEX) Ranking based on trading volumes, market share of ...',
            _urlDODO,
          ),
          _buildDappCard(
            'assets/images/Curve.png',
            'Curve',
            'Curve-frontend is a user interface application designed to connect to Curve s deployment of smart contracts.',
            _urlCurve,
          ),
          _buildDappCard(
            'assets/images/Clipper.png',
            'Clipper',
            'Clipper is the decentralized exchange (DEX) built to have the best possible prices on small trades ',
            _urlClipper,
          ),
          _buildDappCard(
            'assets/images/Tokenlon.png',
            'Tokenlon',
            'Tokenlon protocol provides trustless token-to-token exchange, get the best price quotes and enjoy minimum slippage. 99% of your transactions will go ...',
            _urlTokenlon,
          ),
          _buildDappCard(
            'assets/images/Balancer.png',
            'Balancer',
            'Balancer is the epitome of technical excellence and innovation in the DeFi space. Balancer V2 is another testimony of continued effort to innovate through ...',
            _urlBalancer,
          ),
          _buildDappCard(
            'assets/images/1inch.png',
            '1inch Network',
            'The 1inch Network unites decentralized protocols whose synergy enables the most lucrative, fastest and protected operations in the DeFi space.',
            _url1inch,
          ),
          _buildDappCard(
            'assets/images/Bancor.png',
            'Bancor',
            'A permissionless framework to arbitrage decentralized exchanges. Searcher.',
            _urlBancor,
          ),
          _buildDappCard(
            'assets/images/dYdX.png',
            'dydx',
            'dYdX is the leading DeFi protocol developer for advanced trading. Trade 67 cryptocurrencies with low fees, deep liquidity, and up to 20× Buying Power.',
            _urldydx,
          ),
          _buildDappCard(
            'assets/images/Kyper.png',
            'Kyper',
            'Kyper Network is a multi-chain crypto trading and liquidity hub that connects liquidity from different sources to enable trades at the best rates .',
            _urlKyber,
          ),
          _buildDappCard(
            'assets/images/Smoothy.png',
            'Smoothy',
            'Smoothy is a decentralized exchange (DEX) aggregator that provides the best prices by splitting orders among multiple DEXs.',
            _urlSmoothy,
          ),
        ],
      ),
    );

  }

}


class NFTTabContent extends StatelessWidget{
  final String _urlClutchy = 'https://clutchy.io/';
  //https://clutchy.io/marketplace
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Widget _buildDappCard(String imagePath, String title, String description, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDappCard(
            'assets/images/Clutchy.png',
            'Clutchy',
            'Sui NFT Marketplace for Art & Gaming.',
            _urlClutchy,
          ),

        ],
      ),
    );

  }


}


class ToolsTabContent extends StatelessWidget{
  final String url_SuiNameService = 'https://suins.io/';
  final String url_FaTPay = 'https://www.fatpay.org/';
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Widget _buildDappCard(String imagePath, String title, String description, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDappCard(
            'assets/images/SuiNameService.png',
            'Sui Name Service',
            'Sculpting your identity. The SuiNS team is building the next generation of identity services.',
            url_SuiNameService,
          ),
          _buildDappCard(
            'assets/images/FaTPay.png',
            'FaTPay',
            'FaTPay is founded by a group of digital payment experts from Alipay, Weibo and Paytm. We see crypto and Web 3.0 as a highly potential future, meanwhile, we also ...',
            url_FaTPay,
          ),

        ],
      ),
    );

  }


}

void main() {
  runApp(MaterialApp(
    home: DiscoverPage(),
  ));
}