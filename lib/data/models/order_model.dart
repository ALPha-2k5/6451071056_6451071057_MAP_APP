import 'cart_item_model.dart';
import 'coupon_model.dart';
import 'shipping_model.dart';
enum PaymentMethods { cash, bank }
class OrderModel {
String docId;
String id;
String userId;
String userName;
String userEmail;
String userDeviceToken;
List<CartItemModel> products;
double subTotal;
int shippingAmount;
double taxRate;
double taxAmount;
CouponModel? coupon;
double couponDiscountAmount;
int pointsUsed;
double pointsDiscountAmount;
double totalDiscountAmount;
double totalAmount;
String paymentStatus;
String orderStatus;
DateTime orderDate;
DateTime? shippingDate;
Map<String, dynamic> shippingAddress;
Map<String, dynamic>? billingAddress;
ShippingInfo? shippingInfo;
List<dynamic> activities;
int itemCount;
DateTime createdAt;
DateTime updatedAt;
String adminNote;
bool billingAddressSameAsShipping;
String currency;
String? paymentIntentId;
String? paymentMethodId;
String paymentMethod;
PaymentMethods paymentMethodType;
double amountCaptured;
OrderModel({
required this.docId,
required this.id,
required this.userId,
this.userName = '',
this.userEmail = '',
required this.userDeviceToken,
required this.products,
required this.subTotal,
required this.shippingAmount,
required this.taxRate,
required this.taxAmount,
this.coupon,
required this.couponDiscountAmount,
required this.pointsUsed,
required this.pointsDiscountAmount,
required this.totalDiscountAmount,
required this.totalAmount,
required this.paymentStatus,
required this.orderStatus,
required this.orderDate,
this.shippingDate,
required this.shippingAddress,
this.billingAddress,
this.shippingInfo,
required this.activities,
required this.itemCount,
required this.createdAt,
required this.updatedAt,
this.adminNote = '',
this.billingAddressSameAsShipping = true,
this.currency = 'usd',
this.paymentIntentId,
this.paymentMethodId,
this.paymentMethod = '',
this.paymentMethodType = PaymentMethods.cash,
this.amountCaptured = 0.0,
});
Map<String, dynamic> toJson() {
return {
'id': id,
'userId': userId,
'products': products.map((e) => e.toJson()).toList(),
'subTotal': subTotal,
'shippingAmount': shippingAmount,
'taxRate': taxRate,
'taxAmount': taxAmount,
/// FIX COUPON
'coupon': coupon != null ? coupon!.toJson() : null,
'couponDiscountAmount': couponDiscountAmount,
'totalDiscountAmount': totalDiscountAmount,
'totalAmount': totalAmount,
'paymentStatus': paymentStatus,
'orderStatus': orderStatus,
'orderDate': orderDate,
'shippingDate': shippingDate,
'shippingAddress': shippingAddress,
'itemCount': itemCount,
'createdAt': createdAt,
'updatedAt': updatedAt,
///FIX PAYMENT
'paymentMethod': paymentMethod,
'paymentMethodType': paymentMethodType.name,
};
}
factory OrderModel.fromJson(Map<String, dynamic> json) {
return OrderModel(
docId: json['docId'] ?? '',
id: json['id'],
userId: json['userId'],
userDeviceToken: '',products: (json['products'] as List)
.map((e) => CartItemModel.fromJson(e))
.toList(),
subTotal: (json['subTotal'] ?? 0).toDouble(),
shippingAmount: json['shippingAmount'] ?? 0,
taxRate: (json['taxRate'] ?? 0).toDouble(),
taxAmount: (json['taxAmount'] ?? 0).toDouble(),
coupon: json['coupon'] != null
? CouponModel.fromJson(json['coupon'])
: null,
couponDiscountAmount: (json['couponDiscountAmount'] ?? 0).toDouble(),
pointsUsed: 0,
pointsDiscountAmount: 0,
totalDiscountAmount: (json['totalDiscountAmount'] ?? 0).toDouble(),
totalAmount: (json['totalAmount'] ?? 0).toDouble(),
paymentStatus: json['paymentStatus'],
orderStatus: json['orderStatus'],
orderDate: json['orderDate'].toDate(),
/// 🔥 FIX QUAN TRỌNG
shippingDate: json['shippingDate'] != null
? json['shippingDate'].toDate()
: null,
shippingAddress: json['shippingAddress'],
activities: [],
itemCount: json['itemCount'] ?? 0,
createdAt: json['createdAt'].toDate(),
updatedAt: json['updatedAt'].toDate(),
paymentMethod: json['paymentMethod'] ?? '',
paymentMethodType: json['paymentMethodType'] == 'bank'
? PaymentMethods.bank
: PaymentMethods.cash,
);
}
}