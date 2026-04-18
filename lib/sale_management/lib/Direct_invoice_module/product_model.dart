
class DirectInvoiceProduct {
  final String id;
  final String name;
  final String imageUrl;
  final int stock;
  final double price;
  final String category;
  final String hsn; // Added
  final String uom; // Added
  int selectedQty;
  bool isAdded;
  double discountPercentage;
  double discountAmount;
  bool isPercentageDiscount;

  DirectInvoiceProduct({
    required this.id,
    required this.name,
    this.imageUrl = 'https://picsum.photos/200',
    required this.stock,
    required this.price,
    required this.category,
    this.hsn = '', // Added
    this.uom = '', // Added
    this.selectedQty = 1,
    this.isAdded = false,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.isPercentageDiscount = true,
  });
}

class DirectInvoiceSummary {
  final double subtotal;
  final double discount;
  final double taxableAmount;
  final double igst;
  final double cgst;
  final double sgst;
  final double tcs;
  final double tds;
  final double shippingCharges;
  final double finalPayable;
  final String taxType;
  final String priceType;
  final double roundOff;

  DirectInvoiceSummary({
    required this.subtotal,
    required this.discount,
    required this.taxableAmount,
    required this.igst,
    required this.cgst,
    required this.sgst,
    required this.tcs,
    required this.tds,
    required this.shippingCharges,
    required this.finalPayable,
    required this.taxType,
    required this.priceType,
    this.roundOff = 0.0,
  });
}
