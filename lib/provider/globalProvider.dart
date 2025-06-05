import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/service/shared_preferences.dart';



// ignore: camel_case_types
class Global_provider extends ChangeNotifier{
  List<ProductModel> products =[];
  List <CartModel> cartItems = [];
  List <ProductModel> favoriteItems = [];

  FirebaseAuth _auth = FirebaseAuth.instance;
  User? _CurrentUser;
  bool get loggedIn => _CurrentUser != null;

  int currentIdx=0;
  User? get currentUser => _CurrentUser;
  bool get isLoggedIn => _CurrentUser != null || _CurrentUser != null;// ene hoyriin lai negeer login bvl ok
  String get currentLanguage => _currentLanguage;

  String _currentLanguage = 'en';

  Global_provider() {
    _loadSavedLanguage();
    _auth.userChanges().listen((user) {
      _CurrentUser = user;
      notifyListeners();
    });
  }

  Future<void> _loadSavedLanguage() async {
    _currentLanguage = await AuthStorage.getLanguage();
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await AuthStorage.saveLanguage(languageCode);
    notifyListeners();
  }

  void signOut() {
    _auth.signOut();
  }

  void setProducts( List<ProductModel> data){
    products = data;
    notifyListeners();
  }

  Future<void> updateCartItemQuantity(int index, int newQuantity) async {
    if (index >= 0 && index < cartItems.length) {
      try {
        // final item = cartItems[index];
        // await ApiService.updateCartQuantity(
        //   currentUser!.uid,
        //   item.product.id!,
        //   newQuantity,
        // );
        
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
        notifyListeners();
      } catch (e) {
        debugPrint("Failed to update cart quantity: $e");
        // Optionally show an error message to the user
      }
    }
  }

  void addToCart(CartModel item) async {
    CartModel? existing = cartItems.firstWhereOrNull(
      (e) => e.product.id == item.product.id,
    );

    if(existing != null){
      cartItems.remove(item);
    }
    else{
      cartItems.add(item);
    }
    notifyListeners();

    // try {
    //   await ApiService.addToCart(currentUser!.uid!, item);
    // } catch (e) {
    //   debugPrint("Failed to add to server cart: $e");
    // }
  }

  void toggleFavorite(int id) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      products[index].isFavorite = !products[index].isFavorite;
      notifyListeners();
    }
  }

  void changeCurrentIdx(int idx){
    currentIdx=idx;
    notifyListeners();
  }

  void login(User matchedUser) {
    _CurrentUser = matchedUser;
    cartItems = []; // Clear cart items when logging in
    debugPrint('Logged in as: ${_CurrentUser?.displayName}, ID: ${_CurrentUser?.uid}');
    notifyListeners();
  }

  void logout() {
    _CurrentUser = null;
    cartItems = []; // Clear cart items when logging out
    notifyListeners();
  }


  void setCartItems(List<CartModel> items) {
    cartItems = items;
    notifyListeners();
  }

 
  // void addCartItems(ProductModel item){
  //   if(cartItems.contains(item)){
  //     cartItems.remove(item);
  //   }
  //   else{
  //     cartItems.add(item);
  //   }
  //   notifyListeners();
  // }

  // void addFavoriteItems(ProductModel item){
  //   if(favoriteItems.contains(item)){
  //     favoriteItems.remove(item);
  //   }
  //   else{
  //     favoriteItems.add(item);
  //   }
  //   notifyListeners();
  // }

}