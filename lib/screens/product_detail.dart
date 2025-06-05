import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/cart_manager.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/provider/globalProvider.dart';

class Product_detail extends StatelessWidget {
  final ProductModel product;
  // final CartManager cartManager;

  const Product_detail(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Global_provider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                // Product Image with Back Button
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: Image.network(
                            product.image ?? '',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 30,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.arrow_back, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.title ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: product.isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  final provider = Provider.of<Global_provider>(context, listen: false);

                                  if (!provider.isLoggedIn) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Анхааруулга'),
                                          content: Text('Та эхлээд нэвтэрнэ үү?'),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // dialog хаах
                                              },
                                            ),
                                            ElevatedButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // dialog хаагаад
                                                context.go('/sign-in'); // LoginPage руу шилжих
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }
                                  // product.isFavorite = !product.isFavorite;  
                                  provider.toggleFavorite(product.id!);
                                
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.category ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '\$${product.price?.toStringAsFixed(2) ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ...List.generate(5, (i) {
                                double rate = product.rating?.rate ?? 0;
                                return Icon(
                                  i < rate.round() ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.rating?.count ?? 0})',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final cartManager = CartManager();
                        cartManager.addToCart(product.id.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}