class ShippingInfo {
  String carrier;
  String trackingNumber;
  String shippingStatus;
  String shippingMethod;
  DateTime? estimatedDelivery;
  DateTime? deliveredAt;
  ShippingInfo({
    required this.carrier,
    required this.trackingNumber,
    required this.shippingStatus,
    required this.shippingMethod,
    this.estimatedDelivery,
    this.deliveredAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'shippingStatus': shippingStatus,
      'shippingMethod': shippingMethod,
      'estimatedDelivery': estimatedDelivery,
      'deliveredAt': deliveredAt,
    };
  }

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      carrier: json['carrier'],
      trackingNumber: json['trackingNumber'],
      shippingStatus: json['shippingStatus'],
      shippingMethod: json['shippingMethod'],
      estimatedDelivery: json['estimatedDelivery']?.toDate(),
      deliveredAt: json['deliveredAt']?.toDate(),
    );
  }
}
