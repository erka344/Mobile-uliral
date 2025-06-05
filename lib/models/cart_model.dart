import 'product_model.dart';

class CartModel {
  final ProductModel product;
  int quantity;

  CartModel({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      product: ProductModel(
        id: json['productId'],
      ),
      quantity: json['quantity'] ?? 1,
    );
  }

  CartModel copyWith({ProductModel? product, int? quantity}) {
    return CartModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  static List<CartModel> fromList(List<dynamic>? list) {
    if (list == null) return [];
    return list.map((item) => CartModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
