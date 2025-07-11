import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUser(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  Future addMessage(
    String chatRoomId,
    String messageId,
    Map<String, dynamic> messageInfoMap,
  ) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
    String chatRoomId,
    Map<String, dynamic> lastMessageInfoMap,
  ) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<QuerySnapshot> search(String username) async {
  if (username.isEmpty) {
      return FirebaseFirestore.instance.collection('users').limit(0).get();
    }

    return await FirebaseFirestore.instance
        .collection('users')
        .where('SearchKey', isEqualTo: username[0].toUpperCase())
        .get();
  }

}
