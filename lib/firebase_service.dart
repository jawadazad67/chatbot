import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class FirebaseService {
  static CollectionReference chatSessions =
      FirebaseFirestore.instance.collection('chatSessions');

  static Future<void> storeChatSession(List<ChatMessage> messages) async {
    if (messages.isEmpty) return;

    List<Map<String, dynamic>> sessionData = messages.map((message) {
      return {
        'text': message.text,
        'senderId': message.user.id,
        'timestamp': message.createdAt,
        'mediaUrl': message.medias?.isNotEmpty ?? false
            ? message.medias!.first.url
            : null,
      };
    }).toList();

    await chatSessions.add({
      'sessionData': sessionData,
      'createdAt': DateTime.now(),
      'title': messages.first.text.isNotEmpty
          ? messages.first.text
          : 'Image Message',
    });
  }

  static Future<List<Map<String, dynamic>>> getChatSessions() async {
    QuerySnapshot querySnapshot =
        await chatSessions.orderBy('createdAt', descending: true).get();
    List<Map<String, dynamic>> allSessions = [];

    for (var doc in querySnapshot.docs) {
      allSessions.add({
        'id': doc.id,
        'title': doc['title'],
        'sessionData': doc['sessionData'],
      });
    }

    return allSessions;
  }

  static Future<List<ChatMessage>> loadChatSession(String sessionId) async {
    DocumentSnapshot docSnapshot = await chatSessions.doc(sessionId).get();
    List<dynamic> sessionData = docSnapshot['sessionData'];
    List<ChatMessage> sessionMessages = sessionData.map((data) {
      ChatUser user = ChatUser(id: data['senderId']);
      return ChatMessage(
        user: user,
        text: data['text'],
        createdAt: (data['timestamp'] as Timestamp).toDate(),
        medias: data['mediaUrl'] != null
            ? [
                ChatMedia(
                    url: data['mediaUrl'], fileName: '', type: MediaType.image)
              ]
            : [],
      );
    }).toList();

    return sessionMessages;
  }
}
