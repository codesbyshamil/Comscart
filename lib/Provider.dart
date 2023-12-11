import 'package:flutter/foundation.dart';

class CartCountNotifier extends ChangeNotifier {
  int _productCountInCart = 0;

  int get productCountInCart => _productCountInCart;

  void updateProductCount(int count) {
    _productCountInCart = count;
    notifyListeners();
  }
  void adduserdetails(){
    
  }
}
