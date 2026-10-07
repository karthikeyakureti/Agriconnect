import 'user_model.dart';

class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime? createdAt;
  final bool readStatus;
  final UserModel? sender;
  final UserModel? receiver;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.createdAt,
    required this.readStatus,
    this.sender,
    this.receiver,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      readStatus: json['read_status'] ?? false,
      sender: json['sender'] != null ? UserModel.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? UserModel.fromJson(json['receiver']) : null,
    );
  }
}

class ConversationSummaryModel {
  final int userId;
  final String userName;
  final String userRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationSummaryModel({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryModel(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      userRole: json['user_role'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
