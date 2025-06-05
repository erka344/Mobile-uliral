import 'package:flutter/material.dart';
import 'package:shop_app/cart_manager.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/service/api_service.dart';

class CartPage extends StatefulWidget {
   CartPage({super.key});

  @override
  State<StatefulWidget> createState() => _CartPageState(); 
}

class _CartPageState extends State<StatefulWidget>{

  final _manager = CartManager();
  bool _isLoading = false;
  List<ProductModel> products = [];


  @override
  void initState() {
    super.initState();
    if (provider.currentUser == null) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: StreamBuilder<List<CartItem>>(
        stream: _manager.getCartItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }
          final productsId = snapshot.data!.map((e) => e.productId).toList();
          products = await Future.wait(productsId.map((e) => ApiService.fetchProductById(e)).toList();)

          return Column(
            children: [
              Expanded(
                child: Consumer<Global_provider>(
                  builder: (context, provider, _) {
                    if (provider.cartItems.isEmpty) {
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

                    return ListView.builder(
                      itemCount: provider.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.cartItems[index];
                        final product = item.product;

                        if (product == null) {
                          return const ListTile(title: Text("Loading product..."));
                        }

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Image.network(product.image ?? '', width: 60, height: 60, fit: BoxFit.cover),
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
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      const Text('Size: M', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _qtyButton(
                                                icon: Icons.remove,
                                                onTap: () async {
                                                  if (item.quantity > 1) {
                                                    await provider.updateCartItemQuantity(index, item.quantity - 1);
                                                  }
                                                },
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                              _qtyButton(
                                                icon: Icons.add,
                                                onTap: () async {
                                                  await provider.updateCartItemQuantity(index, item.quantity + 1);
                                                },
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '\$${product.price?.toStringAsFixed(2) ?? "0.00"}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    );
                  },
                ),
              ),


              // --- Checkout Button ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement checkout logic
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
                  label: const Text("Check Out"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.green,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 22, color: Colors.black),
        ),
      ),
    );
  }
}
