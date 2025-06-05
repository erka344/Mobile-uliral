import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/globalProvider.dart';
import 'package:shop_app/screens/product_detail.dart';
import '../models/product_model.dart';

class ProductViewShop extends StatelessWidget {
  final ProductModel product;

  const ProductViewShop(this.product, {super.key});
  _onTap(BuildContext context ){ Navigator.push(context,MaterialPageRoute(builder: (_)=>Product_detail(product))); }

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => _onTap(context), child: Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Row(
            children: [
              // image
              Container(
                height: 150.0, // Adjust the height based on your design
                width: 150.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.image!),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title!,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.category!,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          double? rate = product.rating?.rate ?? 0;

                          if (index < rate.floor()) {
                            return const Icon(Icons.star, color: Colors.amber, size: 20);
                          } else if (index < rate) {
                            return const Icon(Icons.star_half, color: Colors.amber, size: 20);
                          } else {
                            return const Icon(Icons.star_border, color: Colors.amber, size: 20);
                          }
                        }),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '\$${product.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Consumer<Global_provider>(
              builder: (context, provider, child) =>
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
                              context.go('/sign-in');// LoginPage руу шилжих
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
          ),
          )
        ],
      ),
      
      
      
    ));
    
    
    // Row(
    //   children: [
    //     Box(
    //       height: width /3,
    //       width: width,
    //       margin: EdgeInsets.only(right: 10),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(8),
    //         image: DecorationImage(image: NetworkImage(product.image!), fit: BoxFit.fitHeight)
    //       ),
    //     ),
    //      Column(
    //       children: [
    //         Text(data.title==null?"": data.title!),
    //         Text(data.category==null?"": data.category!),
    //         Text('${data.price}'),
    //       ],
    //     )
      
    //   ],
    // );
  }
}