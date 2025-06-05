import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/cart_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/provider/globalProvider.dart';


class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>{
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoriteItems();
  }

  Future<List<ProductModel>> loadFavoriteItems() async {
    final provider = Provider.of<Global_provider>(context, listen: false);
    final userId = provider.currentUser?.uid;

    if (userId == null) {
      setState(() => _isLoading = false); // Loading false болгоно
      return [];
    }

    // Та хүсвэл энд серверээс татаж болох боловч одоогоор provider.products ашиглаж байна
    final favorites = provider.products.where((product) => product.isFavorite).toList();

    setState(() {
      _isLoading = false; // ❗ Loading indicator-ийг зогсоох хэсэг
    });

    return favorites;
  }




  @override
  Widget build(BuildContext context) {
    return _isLoading
      ? const Center(child: CircularProgressIndicator())
      :  Consumer<Global_provider>(
      builder: (context, provider, child) {
        final favoriteCartItems = provider.products.where((product) => product.isFavorite).toList();
        // final favoriteCartItems = provider.products
        //   .where((product) => product.isFavorite)
        //   .map((product) => CartModel(product: product, quantity: 1))
        //   .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: favoriteCartItems.isEmpty
                        ? Center(
                            child: Text(
                              'No favorite items yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: favoriteCartItems.length,
                            separatorBuilder: (context, idx) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final cartProduct = favoriteCartItems[index];
                              return Stack(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              cartProduct.image ?? '',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        cartProduct.title ?? '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.close, color: Colors.grey),
                                                      onPressed: () {
                                                        // Remove from favorites
                                                        provider.products.firstWhere((p) => p.id == cartProduct.id).isFavorite = false;
                                                        // provider.notifyListeners();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  cartProduct.category ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '\$${cartProduct.price?.toStringAsFixed(2) ?? ''}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ...List.generate(5, (i) {
                                                      double rate = cartProduct.rating?.rate ?? 0;
                                                      return Icon(
                                                        i < rate.round()
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 18,
                                                      );
                                                    }),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '(${cartProduct.rating?.count ?? 0})',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
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
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: FloatingActionButton(
                                      mini: true,
                                      backgroundColor: Colors.red,
                                      elevation: 2,
                                      onPressed: () {
                                        // Add to bag/cart
                                        provider.addToCart(CartModel(product: cartProduct));
                                      },
                                      child: const Icon(Icons.shopping_bag, color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}