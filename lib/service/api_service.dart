import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/cart_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/models/user.dart';

import 'package:shop_app/service/shared_preferences.dart';


class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  static Future<List<UserModel>?> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return UserModel.fromList(jsonList);
    }
    return null;
  }

  static Future<UserModel?> login(String username, String password) async {
    final tokenResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (tokenResponse.statusCode == 200) {
      final data = jsonDecode(tokenResponse.body);
      final token = data['token'];

      // 1. Бүх хэрэглэгчдийг авна
      final users = await getUsers();

      // 2. Username болон password тохирох хэрэглэгчийг хайна
      final matchedUser = users?.firstWhereOrNull(
        (user) => user.username == username && user.password == password,
        
      );

      // 3. Хэрвээ олдвол буцаана
      if (matchedUser != null) {
        await AuthStorage.saveToken(token); // токеныг хадгална
        return matchedUser;
      }
    }

    return null;
  }


  static Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load products");
  }

  static Future<ProductModel> fetchProductById(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return ProductModel.fromJson(json);
    } else {
      throw Exception('Failed to load product with id $productId');
    }
  }


  static Future<List<CartModel>> fetchCartByUserId(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/carts/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> products = decoded['products'] ?? [];
        
        List<CartModel> cartItems = [];
        for (var item in products) {
          try {
            final productId = item['productId'];
            final quantity = item['quantity'];
            
            final product = await fetchProductById(productId);
            cartItems.add(CartModel(product: product, quantity: quantity));
          } catch (e) {
            debugPrint("Error processing cart item: $e");
            continue;
          }
        }
        return cartItems;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching cart: $e");
      return [];
    }
  }

  static Future<List<CartModel>> fetchCartByUserIdWithProducts(int userId) async {
    return fetchCartByUserId(userId);
  }

  static Future<void> addToCart(int userId, CartModel cartItem) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "date": DateTime.now().toIso8601String(),
          "products": [{
            "productId": cartItem.product.id,
            "quantity": cartItem.quantity
          }],
        }),
      );
      debugPrint("${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to add to cart");
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      rethrow;
    }
  }

  static Future<void> updateCartQuantity(int userId, int productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/carts/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "date": DateTime.now().toIso8601String(),
          "products": [{
            "productId": productId,
            "quantity": quantity
          }],
        }),
      );
      debugPrint("${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to update cart quantity");
      }
    } catch (e) {
      debugPrint("Error updating cart quantity: $e");
      rethrow;
    }
  }
}
