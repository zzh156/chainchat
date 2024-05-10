import 'package:flutter/material.dart';
import 'package:sui/sui.dart'; // Import SuiClient
import 'register_page.dart';

class PersonalInfoPage extends StatelessWidget {
  final String? address;
  final String? privateKey;

  PersonalInfoPage({Key? key, this.address, this.privateKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Information',
          style: TextStyle(color: Colors.black), // Set the title color to white
        ),
        centerTitle: true, // Center the title
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5), // 深灰色
        iconTheme: IconThemeData(color: Colors.black), // Set the icon color to white
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Text(
                'Your Name',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Text(
                address ?? 'Your Ed25519 Address',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {
                final client = SuiClient(SuiUrls.devnet);
                final suiBalance = await client.getBalance(address!);
                BigInt suiBalance_value = await suiBalance.totalBalance;
                BigInt suiBalance_divided = suiBalance_value ~/ BigInt.from(10).pow(9);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Balance'),
                      content: Text('Your balance: $suiBalance_divided SUI'),
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
              },
              child: Text('Check Balance'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                // Operation after clicking settings button
              },
              child: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}