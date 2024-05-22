import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/auth/login_or_register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _checkSavedUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == true) {
              return FutureBuilder(
                future: _getUserInfo(),
                builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    if (snapshot.hasData && snapshot.data!['mnemonic'] != null && snapshot.data!['address'] != null && snapshot.data!['privateKey'] != null) {
                      return HomePage(
                        phrase: snapshot.data!['mnemonic']!,
                        ed25519Address: snapshot.data!['address']!,
                        privateKey: snapshot.data!['privateKey']!,
                      );
                    } else {
                      return LoginOrRegister();
                    }
                  }
                },
              );
            } else {
              return LoginOrRegister();
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkSavedUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mnemonic = prefs.getString('mnemonic');
    String? address = prefs.getString('address');
    String? privateKey = prefs.getString('privateKey');
    return mnemonic != null && address != null && privateKey != null;
  }

  Future<Map<String, String>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mnemonic = prefs.getString('mnemonic');
    String? address = prefs.getString('address');
    String? privateKey = prefs.getString('privateKey');
    return {'mnemonic': mnemonic!, 'address': address!, 'privateKey': privateKey!};
  }
}
