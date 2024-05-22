import 'package:flutter/material.dart';
import '../pages/ReceiveDetailsPage.dart';
import '../pages/TransferDetailsPage.dart';
import '../pages/TransferDetailsPage.dart';
class CryptoTransferWidget extends StatelessWidget {
  final String myAddress;
  final String currency;
  final String amount;
  /*final String? digest;*/
  final String? from;
  final String? to;
  //final String? status;

  CryptoTransferWidget({required this.myAddress,required this.currency, required this.amount, /*required this.digest*/required this.from, required this.to/*, required this.status*/});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double thirdScreenWidth = screenWidth / 3;

    return Container(
      width: thirdScreenWidth,
      padding: EdgeInsets.all(16.0),  // 增加内边距
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.indigo[800],  // 使用深蓝色背景
        borderRadius: BorderRadius.circular(12.0),  // 轻微增加边框圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),  // 添加阴影
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if(myAddress==from) {
            // 在这里导航到新页面并传递值
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransferDetailPage(
                      currency: currency,
                      amount: amount,
                      //digest: digest,
                      from: from,
                      to: to,
                      //status: status,
                    ),
              ),
            );
          }else{
            // 在这里导航到新页面并传递值
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ReceiveDetailPage(
                      currency: currency,
                      amount: amount,
                      //digest: digest,
                      from: from,
                      to: to,
                      //status: status,
                    ),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amberAccent[400]),  // 调整图标颜色
                SizedBox(width: 10.0),
                Text(
                  '$currency  $amount',  // 调整文本
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,  // 增加字体大小
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              '转账成功',
              style: TextStyle(
                color: Colors.white70,  // 文本颜色更柔和
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'chainchat转账',
              style: TextStyle(
                color: Colors.white54,  // 更柔和的字体颜色
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}