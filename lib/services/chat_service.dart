import "package:cloud_firestore/cloud_firestore.dart";

class ChatMessage {
  final String id;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromDoc(String id, Map<String, dynamic> data) => ChatMessage(
        id: id,
        senderName: data["senderName"] ?? "",
        senderRole: data["senderRole"] ?? "",
        text: data["text"] ?? "",
        sentAt: (data["sentAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        "senderName": senderName,
        "senderRole": senderRole,
        "text": text,
        "sentAt": FieldValue.serverTimestamp(),
      };
}

class ChatService {
  final _db = FirebaseFirestore.instance;

  /// A stable thread id shared by a specific doctor + patient pair,
  /// so both sides see the same conversation.
  String threadId(String doctorKey, String patientKey) {
    final a = doctorKey.trim().toLowerCase();
    final b = patientKey.trim().toLowerCase();
    final sorted = [a, b]..sort();
    return "${sorted[0]}__${sorted[1]}";
  }

  Stream<List<ChatMessage>> messages(String threadId) {
    return _db
        .collection("chats")
        .doc(threadId)
        .collection("messages")
        .orderBy("sentAt", descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromDoc(d.id, d.data())).toList());
  }

  Future<void> send({
    required String threadId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    await _db.collection("chats").doc(threadId).collection("messages").add(
          ChatMessage(id: "", senderName: senderName, senderRole: senderRole, text: text.trim(), sentAt: DateTime.now()).toMap(),
        );
  }
}
