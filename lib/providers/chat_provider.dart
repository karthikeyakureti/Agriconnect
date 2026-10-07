import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ConversationSummaryModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConversationSummaryModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await ApiService.getConversations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int userId, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final newMessages = await ApiService.getMessages(userId);
      _messages = newMessages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> sendMessage(int receiverId, String text) async {
    if (text.trim().isEmpty) return false;

    try {
      final newMsg = await ApiService.sendMessage(receiverId: receiverId, message: text.trim());
      _messages.add(newMsg);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
