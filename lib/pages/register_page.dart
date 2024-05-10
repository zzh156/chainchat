// register_page.dart

import 'package:chainchat/components/my_button.dart';
import 'package:chainchat/components/my_text_field.dart';
import 'package:chainchat/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sui/sui.dart'; // 导入 Dart SUI SDK

/*class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({Key? key, required this.onTap}) : super(key: key);


  @override
  State<RegisterPage> createState() => _RegisterPageState();

  // 添加一个公共的 getter 方法来获取 ed25519Address 的值
  String? get ed25519Address => _RegisterPageState.ed25519Address;
}

class _RegisterPageState extends State<RegisterPage> {
  final phraseController = TextEditingController();
  static String? ed25519Address; // Store Ed25519 address
  String? privateKey; // Store private key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                Icon(
                  Icons.message,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 50),
                // 欢迎消息
                const Text(
                  "让我们为您创建一个钱包！",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                // 助记词文本框
                MyTextField(
                  controller: phraseController,
                  hintText: '您的新助记词',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                // 创建钱包按钮
                MyButton(
                  onTap: () {
                    // 生成随机助记词
                    final mnemonics = SuiAccount.generateMnemonic();
                    final ed25519 = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Ed25519);
                    //获取ed25519地址和私钥，并且传入到personal_info.dart中的PersonalInfoPage页面
                    ed25519Address = ed25519.getAddress();
                    privateKey = ed25519.privateKeyHex();

                    // 将生成的随机助记词填充到文本字段中
                    setState(() {
                      phraseController.text = mnemonics;
                    });
                  },
                  text: "创建钱包",
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("已经拥有钱包？"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "立即登录",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final onTap;

  const RegisterPage({Key? key, required this.onTap, required this.title}) : super(key: key);
  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _controller = TextEditingController(); // 创建 TextEditingController
  late String _email = ''; // 添加初始化_email变量
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String  _password='';
  bool _isObscure = true;
  Color _eyeColor = Colors.grey;
  final List _loginMethod = [
    {
      "title": "facebook",
      "icon": Icons.facebook,
    },
    {
      "title": "google",
      "icon": Icons.fiber_dvr,
    },
    {
      "title": "twitter",
      "icon": Icons.account_balance,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey, // 设置globalKey，用于后面获取FormStat
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: kToolbarHeight), // 距离顶部一个工具栏的高度
            buildTitle(), // Login
            buildTitleLine(), // Login下面的下划线
            const SizedBox(height: 30),
            buildMnemonicTextField(context), // 输入密码
            const SizedBox(height: 30),
            buildAddressField(), // 输入邮箱
            buildForgetPasswordText(context), // 忘记密码
            const SizedBox(height: 60),
            buildNewWalletButton(context), // 登录按钮
            const SizedBox(height: 40),
            buildOtherLoginText(), // 其他账号登录
            buildOtherMethod(context), // 其他登录方式
            buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }

  Widget buildRegisterText(context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('已有钱包?'),
            GestureDetector(
              child: const Text('点击登录', style: TextStyle(color: Colors.green)),
              onTap: () {
                // 跳转到登录页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(onTap: () {}, title: 'Login'),
                )
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildOtherMethod(context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: _loginMethod
          .map((item) => Builder(builder: (context) {
        return IconButton(
            icon: Icon(item['icon'],
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              //TODO: 第三方登录方法
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${item['title']}登录'),
                    action: SnackBarAction(
                      label: '取消',
                      onPressed: () {},
                    )),
              );
            });
      }))
          .toList(),
    );
  }

  Widget buildOtherLoginText() {
    return const Center(
      child: Text(
        '其他账号登录',
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

  Widget buildNewWalletButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
            // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('New wallet',
              style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () {
            // 生成随机助记词
            final mnemonics = SuiAccount.generateMnemonic();
            //通过助记词创建钱包
            final ed25519 = SuiAccount.fromMnemonics(mnemonics, SignatureScheme.Ed25519);
            //获取ed25519地址
            final ed25519Address = ed25519.getAddress();
            // 将生成的随机助记词填充到文本字段中
            setState(() {
              _controller.text = mnemonics;
              _email = ed25519Address;
            });


          },
        ),
      ),
    );
  }

  Widget buildForgetPasswordText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {

          },
          child: const Text("点击按钮，生成Sui钱包",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget buildMnemonicTextField(BuildContext context) {

    return TextFormField(
      readOnly: true,
      controller: _controller, // 将 TextEditingController 分配给 TextFormField
      obscureText: _isObscure, // 是否显示文字
      onSaved: (v) => _password = v!,
      validator: (v) {
        if (v!.isEmpty) {
          return 'press the button to get new Sui wallet'; // 提示生成助记词
        }
      },
      decoration: InputDecoration(
        labelText: "mnemonic phrase",

        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color: _eyeColor,
          ),
          onPressed: () {
            // 修改 state 内部变量, 且需要界面内容更新, 需要使用 setState()
            setState(() {
              _isObscure = !_isObscure;
              _eyeColor = (_isObscure
                  ? Colors.grey
                  : Theme.of(context).iconTheme.color)!;
            });
          },
        ),
      ),
    );
  }

  Widget buildAddressField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'address'),
              controller: TextEditingController(text: _email), // 将_email作为文本框的初始值
              readOnly: true,
              //onSaved: (v) => _password = v!, // 将助记词保存到 _password 中
            ),
          ),
          /*IconButton(
            onPressed: () {
              final phrase = _controller.text.trim(); // 使用 _password 作为助记词，您可以根据实际情况修改
              final ed25519 = SuiAccount.fromMnemonics(phrase, SignatureScheme.Ed25519);
              final ed25519Address = ed25519.getAddress();
              // 将 ed25519Address 输入到地址文本框中
              setState(() {
                _email = ed25519Address;
              });
            },
            icon: Icon(Icons.arrow_downward),
          ),*/
        ],
      ),
    );
  }


  Widget buildTitleLine() {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.black,
            width: 40,
            height: 2,
          ),
        ));
  }

  Widget buildTitle() {
    return const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Register',
          style: TextStyle(fontSize: 42),
        ));
  }
}

