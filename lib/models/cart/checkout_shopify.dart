import 'package:inspireui/widgets/coupon_card.dart';

class CheckoutCart {
  dynamic id;
  String? webUrl;
  double? subtotalPrice;
  double? totalTax;
  double? totalPrice;
  double? paymentDue;
  Coupon? coupon;

  CheckoutCart.fromJsonShopify(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    webUrl = parsedJson['webUrl'];
    subtotalPrice = double.parse(parsedJson['subtotalPrice'] ?? '0');
    totalTax = double.parse(parsedJson['totalTax'] ?? '0');
    totalPrice = double.parse(parsedJson['totalPrice'] ?? '0');
    paymentDue = double.parse(parsedJson['paymentDue'] ?? '0');
    coupon = Coupon.fromShopify(parsedJson['discountApplications'] ?? {});
  }

  CheckoutCart.fromJsonShopifyV2(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    webUrl = parsedJson['webUrl'];
    subtotalPrice =
        double.parse(parsedJson['subtotalPriceV2']?['amount'] ?? '0');
    totalTax = double.parse(parsedJson['totalTaxV2']?['amount'] ?? '0');
    totalPrice = double.parse(parsedJson['totalPriceV2']?['amount'] ?? '0');
    paymentDue = double.parse(parsedJson['paymentDueV2']?['amount'] ?? '0');
    coupon = Coupon.fromShopify(parsedJson['discountApplications'] ?? {});
  }

  @override
  String toString() => 'Checkout { id: $id }';
}
