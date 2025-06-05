import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteManager {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addToFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _db
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .doc(productId)
        .set({'addedAt': Timestamp.now()});
  }

  Future<void> removeFromFavorites(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _db
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .doc(productId)
        .delete();
  }

  Stream<List<String>> getFavoriteProductIds() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
