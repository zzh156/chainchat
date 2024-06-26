import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sui/cryptography/signature.dart';
import 'package:sui/sui_account.dart';
import 'package:chainchat/pages/home_page.dart';
import 'package:chainchat/pages/register_page.dart';
import 'package:chainchat/services/auth/login_or_register.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap; // 添加 onTap 属性
  const LoginPage({Key? key, required this.onTap, required this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controller = TextEditingController(); // 创建 TextEditingController
  late String _email = ''; // 添加初始化_email变量
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _password = '';
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
            buildLoginButton(context), // 登录按钮
            const SizedBox(height: 40),
            buildOtherLoginText(), // 其他账号登录
            buildOtherMethod(context), // 其他登录方式
            buildRegisterText(context), // 注册
          ],
        ),
      ),
    );
  }

  Widget buildRegisterText(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('没有钱包?'),
            GestureDetector(
              child: const Text(
                '点击创建',
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(
                      onTap: null,
                      title: "Register",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOtherMethod(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: _loginMethod
          .map((item) => Builder(builder: (context) {
        return IconButton(
            icon: Icon(item['icon'],
                color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // TODO: 第三方登录方法
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

  Widget buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45,
        width: 270,
        child: ElevatedButton(
          style: ButtonStyle(
            // 设置圆角
              shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(style: BorderStyle.none)))),
          child: Text('Login',
              style: Theme.of(context).primaryTextTheme.headline5),
          onPressed: () async {
            // 检查输入的助记词是否是12个单词
            List<String> words = _controller.text.trim().split(' ');
            if (words.length != 12) {
              // 助记词不是12个单词，弹出报错提示
              final snackBar = SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),
                    const Text('mnemonic phrase only 12 words'),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return; // 阻止进一步执行
            }
            // 检查地址是否为空
            if (_email.isEmpty) {
              // 地址为空，弹出报错提示
              final snackBar = SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),
                    const Text('Please enter an address'),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return; // 阻止进一步执行
            }
            // 检查助记词与地址是否匹配
            // 获得助记词
            final phrase = _controller.text.trim(); // 使用 _password 作为助记词，您可以根据实际情况修改
            // 通过助记词创建钱包
            final ed25519 = SuiAccount.fromMnemonics(phrase, SignatureScheme.Ed25519);
            // 获取ed25519地址
            final ed25519Address = ed25519.getAddress();
            // 检查地址是否匹配
            if (ed25519Address != _email) {
              // 地址不匹配，弹出报错提示
              final snackBar = SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),
                    const Text('The address does not match the mnemonic phrase'),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return; // 阻止进一步执行
            }

            // 保存用户数据到 SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('mnemonic', phrase);
            await prefs.setString('address', ed25519Address);
            await prefs.setString('privateKey', ed25519.privateKeyHex());

            // 导航到HomePage页面,并传递助记词和地址
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  privateKey: ed25519.privateKeyHex(),
                  phrase: phrase,
                  ed25519Address: _email,
                ),
              ),
            );
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
            // Navigator.pop(context);
            print("忘记密码");
          },
          child: const Text("点击箭头，生成地址",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
      ),
    );
  }

  Widget buildMnemonicTextField(BuildContext context) {
    return TextFormField(
      controller: _controller, // 将 TextEditingController 分配给 TextFormField
      obscureText: _isObscure, // 是否显示文字
      onSaved: (v) => _password = v!,
      validator: (v) {
        if (v!.isEmpty) {
          return 'Please enter your mnemonic phrase'; // 提示用户输入助记词
        } else {
          // 检查输入的助记词是否包含 12 个单词
          List<String> words = v.split(' ');
          if (words.length != 12) {
            return 'Please enter a mnemonic phrase with 12 words'; // 提示用户输入 12 个单词的助记词
          }
        }
        return null; // 返回 null 表示验证通过
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
              _eyeColor = (_isObscure ? Colors.grey : Theme.of(context).iconTheme.color)!;
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
          IconButton(
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
          ),
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
          'Login',
          style: TextStyle(fontSize: 42),
        ));
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? mnemonic = prefs.getString('mnemonic');
  String? address = prefs.getString('address');
  String? privateKey = prefs.getString('privateKey');

  if (mnemonic != null && address != null && privateKey != null) {
    runApp(MaterialApp(
      home: HomePage(
        privateKey: privateKey,
        phrase: mnemonic,
        ed25519Address: address,
      ),
    ));
  } else {
    runApp(MaterialApp(
      home: LoginPage(
        onTap: null,
        title: 'Login',
      ),
    ));
  }
}
