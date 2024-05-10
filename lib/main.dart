/*import 'package:chainchat/pages/login_page.dart';
import 'package:chainchat/pages/register_page.dart';
import 'package:chainchat/services/auth/login_or_register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:LoginOrRegister(),
    );
  }

}
*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_page.dart'; // 导入主页页面
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/auth/login_or_register.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_page.dart'; // 导入主页页面
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
        future: _checkSavedUserInfo(), // 检查是否保存了用户信息
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 显示加载指示器，直到检查完成
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == true) {
              // 如果保存了用户信息，则导航到 HomePage 页面，并传递助记词和地址参数
              return FutureBuilder(
                future: _getUserInfo(), // 获取用户信息
                builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // 显示加载指示器，直到获取用户信息完成
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    if (snapshot.hasData) {
                      return HomePage(phrase: snapshot.data!['mnemonic']!, ed25519Address: snapshot.data!['address']!);
                    } else {
                      // 如果无法获取用户信息，则导航到登录页面
                      return LoginOrRegister();
                    }
                  }
                },
              );
            } else {
              // 如果没有保存用户信息，则导航到 LoginOrRegister 页面
              return LoginOrRegister();
            }
          }
        },
      ),
    );
  }

  // 检查是否保存了用户信息
  Future<bool> _checkSavedUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mnemonic = prefs.getString('mnemonic');
    String? address = prefs.getString('address');
    // 如果助记词和地址都存在，则返回 true，否则返回 false
    return mnemonic != null && address != null;
  }

  // 获取用户信息
  Future<Map<String, String>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mnemonic = prefs.getString('mnemonic');
    String? address = prefs.getString('address');
    // 返回助记词和地址信息的映射
    return {'mnemonic': mnemonic!, 'address': address!};
  }
}
