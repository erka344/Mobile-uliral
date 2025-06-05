import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/provider/globalProvider.dart';
import 'package:shop_app/service/api_service.dart';
import '../widgets/ProductView.dart';


class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProductData();
  }

  Future<List<ProductModel>?> _getProductData() async {
  
    if(Provider.of<Global_provider>(context, listen: false).products.isEmpty){
      List<ProductModel> products = ProductModel.fromList(await ApiService.fetchProducts());
      Provider.of<Global_provider>(context, listen: false).setProducts(products);
    }
     
    setState(() {
      _isLoading = false;
    });
    return Provider.of<Global_provider>(context, listen: false).products;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Consumer<Global_provider>(
            builder: (context, provider, _) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                centerTitle: true,
                title: const Text('Products', style: TextStyle(color: Colors.red)),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                     Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Бараанууд'.tr(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 10,
                        children: List.generate(
                          provider.products.length,
                          (index) => ProductViewShop(provider.products[index]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
  }
}

