import '/data/models/cart_model.dart';
import '/data/models/cart_item_model.dart';

class CartService {
  final CartModel _cart = CartModel.empty();
  CartModel get cart => _cart;

  /// Add to cart
  void addToCart(CartItemModel item) {
    final index = _cart.items.indexWhere(
      (e) =>
          e.productId == item.productId &&
          _isSameVariation(e.selectedVariation, item.selectedVariation),
    );
    if (index >= 0) {
      _cart.items[index].quantity += item.quantity;
    } else {
      _cart.items.add(item);
    }
  }

  /// Remove item
  void removeItem(CartItemModel item) {
    _cart.items.remove(item);
  }

  /// Increase
  void increaseQty(CartItemModel item) {
    item.quantity++;
  }

  /// Decrease
  void decreaseQty(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cart.items.remove(item);
    }
  }

  ///Compare variation
  bool _isSameVariation(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
