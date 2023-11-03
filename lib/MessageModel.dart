class MessageModel {
  String senderId;
  String receiverId;
  String textMessage;
  DateTime timeSent;
  String messageId;

  MessageModel({required this.senderId, required this.receiverId,
    required this.textMessage, required this.timeSent,
    required this.messageId});

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map["senderId"],
      textMessage: map["textMessage"],
      timeSent: map["timeSent"],
      messageId: map["messageId"],
      receiverId: map["receieverId"],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "textMessage": textMessage,
      "timeSent": timeSent,
      "messageId": messageId,
    };
  }
}

class LastMessage {
  String receiverNames;
  String senderId;
  String receiverId;
  String textMessage;
  DateTime timeSent;
  String messageId;

  LastMessage({required this.senderId, required this.receiverId,
    required this.textMessage, required this.timeSent,
    required this.messageId, required this.receiverNames});

  Map<String, dynamic> toMap(){
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "textMessage": textMessage,
      "timeSent": timeSent,
      "messageId": messageId,
      "receiverNames": receiverNames,
    };
  }

  factory LastMessage.fromMap(Map<String, dynamic> map) {
    return LastMessage(senderId: map["senderId"], receiverId: map["recieverId"], textMessage: map['textMessage'],
        timeSent: map['timeSent'], messageId: map['messageId'], receiverNames: map['receiverNames']);
  }
}