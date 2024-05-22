/*
//朋友的转账
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget toTransferWidget(){
  var widget;
  return GestureDetector(
    onTap: (){
      _processTransferDetails();
    },
    child: Opacity(
      opacity: widget.chatBean.isClick == 1 ? 0.6 :1,
      child: Container(
        child: Stack(
          children: [
            toRedpacketBackground(),

            Positioned(
              left: 42, top: 20,
              child:CommonUtils.getBaseIconPng("wc_chat_transfer_icon", width: 40, height: 40),
            ),

            Positioned(
              left: 98, top: 14,
              child: Text("￥${double.parse(widget.chatBean.content??'0').toStringAsFixed(2)}", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
            ),

            Positioned(
              left: 98, top: 40,
              child: Text("请收款", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),),
            ),

            Positioned(
              left: 98, top: 54,
              child: Container(
                margin: EdgeInsets.only(top:10),
                width: 120,
                height: 1,
                color: Colors.white,
              ),
            ),

            Positioned(
              left: 38, bottom: 14,
              child:Text("私人转账", style: TextStyle(fontSize: 12, color: Colors.white38),),
            ),

          ],
        ),
      ),
    ),
  );
}
*/

