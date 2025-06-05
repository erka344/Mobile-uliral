import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/cart_manager.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/service/api_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _manager = CartManager();
  bool _isLoading = true;
  List<ProductModel> _products = [];
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartItems = await _manager.getCartItemsOnce();
    final productIds = cartItems.map((e) => e.productId).toList();

    final products = await Future.wait(
      productIds.map((id) => ApiService.fetchProductById(id)),
    );

    setState(() {
      _cartItems = cartItems;
      _products = products;
      _isLoading = false;
    });
  }

  ProductModel? _getProductById(String id) {
    return _products.firstWhereOrNull((p) => p.id.toString() == id);
  }
  
  double _calculateTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      final product = _getProductById(item.productId);
      if (product != null && product.price != null) {
        total += (product.price! * item.quantity);
      }
    }
    return total;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final product = _getProductById(item.productId);

                          if (product == null || product.id == null) {
                            return const ListTile(title: Text("Loading product..."));
                          }

                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Image.network(
                                    product.image ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.title ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.more_vert),
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Size: M',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _qtyButton(
                                                  icon: Icons.remove,
                                                  item: item,
                                                  isAdd: false,
                                                  onUpdated: _loadCartItems, // энэ функц нь initState-д байгаа update refresher
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  child: Text(
                                                    '${item.quantity}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                _qtyButton(
                                                  icon: Icons.add,
                                                  item: item,
                                                  isAdd: true,
                                                  onUpdated: _loadCartItems, // энэ функц нь initState-д байгаа update refresher
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '\$${(product.price ?? 0).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Checkout"),
                              content: const Text("Proceeding to checkout..."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                )
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: Text(
                          "Check Out (\$${_calculateTotalPrice().toStringAsFixed(2)})",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('Your cart is empty', style: TextStyle(fontSize: 20, color: Colors.grey.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text('Add items to your cart to see them here', style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required CartItem item,
    required bool isAdd,
    required VoidCallback onUpdated,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          int newQty = isAdd ? item.quantity + 1 : item.quantity - 1;

          final docRef = FirebaseFirestore.instance
              .collection('carts')
              .doc(user.uid)
              .collection('items')
              .doc(item.productId);

          if (newQty < 1) {
            await docRef.delete();
          } else {
            await docRef.update({'quantity': newQty});
          }
            onUpdated();
          },

        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 22, color: Colors.black),
        ),
      ),
    );
  }
}
