class Message {
  final String sender_address;
  final String recipient_address;
  final String message;
  final String timestamp;

  Message({
    required this.sender_address,
    required this.recipient_address,
    required this.message,
    required this.timestamp,
  });

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      'sender_address': sender_address,
      'recipient_address': recipient_address,
      'message': message,
      'timestamp': timestamp,
    };
  }
}