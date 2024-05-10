import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message; // 消息内容
  final String? senderAddress; // 发送者地址，可以为空
  final bool isCurrentUser; // 是否当前用户发送的消息，true 表示当前用户发送的消息，false 表示对方发送的消息

  const ChatBubble({
    Key? key,
    required this.message,
    required this.senderAddress,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start, // 根据 isCurrentUser 来设置主轴对齐方式
      children: [
        SizedBox(width: 8), // 添加一些水平间距
        Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, // 根据 isCurrentUser 来设置交叉轴对齐方式
          children: [
            Text(
              senderAddress ?? '', // 如果发送者地址为空，显示空字符串，避免出现空指针异常
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7, // 将 ChatBubble 的宽度限制在屏幕宽度的 70% 内
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue,
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
