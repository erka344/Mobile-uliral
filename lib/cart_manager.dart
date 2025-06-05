import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartManager {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addToCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = _db
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(productId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await docRef.set({
        'productId': productId,
        'quantity': 1,
        'addedAt': Timestamp.now(),
      });
    }
  }

  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = _db
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .doc(productId);

    await docRef.delete();
  }

  Stream<List<CartItem>> getCartItems() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('carts')
        .doc(user.uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return CartItem(
                productId: doc['productId'],
                quantity: doc['quantity'],
              );
            }).toList());
  }
}

class CartItem {
  final String productId;
   int quantity;

  CartItem({required this.productId, required this.quantity});
}
