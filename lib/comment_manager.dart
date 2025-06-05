import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_app/models/commment_model.dart';

class CommentManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Comment нэмэх
  Future<void> addComment(String productId, CommentModel comment) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .collection('comments')
        .add(comment.toMap());
  }

  /// Comment-уудыг real-time байдлаар авах
  Stream<List<CommentModel>> getComments(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Нэг удаагийн (future) байдлаар авах хүсэлт (хэрвээ хэрэгтэй бол)
  Future<List<CommentModel>> fetchCommentsOnce(String productId) async {
    final snapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
