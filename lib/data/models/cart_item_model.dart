class CartItemModel {
  String productId;
  int quantity;
  String? image;
  double price;
  String title;
  String? brandName;
  Map<String, String>? selectedVariation;
  CartItemModel({
    required this.productId,
    required this.quantity,
    this.image,
    this.price = 0.0,
    this.title = '',
    this.brandName,
    this.selectedVariation,
  });
  double get finalPrice => price;
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'image': image,
      'price': price,
      'title': title,
      'brandName': brandName,
      'selectedVariation': selectedVariation,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'],
      quantity: json['quantity'],
      image: json['image'],
      price: (json['price'] ?? 0).toDouble(),
      title: json['title'] ?? '',
      brandName: json['brandName'],
      selectedVariation:
          (json['selectedVariation'] as Map?)?.cast<String, String>(),
    );
  }
}
