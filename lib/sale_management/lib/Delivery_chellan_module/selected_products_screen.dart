import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import 'product_model.dart';
import 'invoice_view_screen.dart';

class DeliveryChallanSelectedProductsScreen extends StatefulWidget {
  final List<DeliveryChallanProduct> selectedProducts;
  final double totalAmount;
  final DeliveryChallanSummary? summary;

  const DeliveryChallanSelectedProductsScreen({
    super.key,
    required this.selectedProducts,
    required this.totalAmount,
    this.summary,
  });

  @override
  State<DeliveryChallanSelectedProductsScreen> createState() => _DeliveryChallanSelectedProductsScreenState();
}

class _DeliveryChallanSelectedProductsScreenState extends State<DeliveryChallanSelectedProductsScreen> {
  int? _expandedProductIndex;

  void _showDiscountBottomSheet(DeliveryChallanProduct product) {
    bool localIsPercentage = product.isPercentageDiscount;
    final TextEditingController discountCtrl = TextEditingController(
        text: localIsPercentage
            ? (product.discountPercentage > 0 ? product.discountPercentage.toString() : '')
            : (product.discountAmount > 0 ? product.discountAmount.toString() : ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name.replaceAll('\n', ' '),
                        style: const TextStyle(
                          color: Color(0xFF1A2332),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Choose Discount Type",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => localIsPercentage = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: localIsPercentage ? const Color(0xFF0045BC) : const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: localIsPercentage ? const Color(0xFF0045BC) : Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              "Percentage (%)",
                              style: TextStyle(
                                color: localIsPercentage ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => localIsPercentage = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !localIsPercentage ? const Color(0xFF0045BC) : const Color(0xFFF2F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: !localIsPercentage ? const Color(0xFF0045BC) : Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              "Amount (₹)",
                              style: TextStyle(
                                color: !localIsPercentage ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  localIsPercentage ? "Discount Percentage" : "Discount Amount",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: discountCtrl,
                  decoration: InputDecoration(
                    hintText: localIsPercentage ? "Enter %" : "Enter ₹",
                    prefixText: localIsPercentage ? null : "₹",
                    suffixText: localIsPercentage ? "%" : null,
                    filled: true,
                    fillColor: const Color(0xFFF2F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        product.isPercentageDiscount = localIsPercentage;
                        if (localIsPercentage) {
                          product.discountPercentage = double.tryParse(discountCtrl.text) ?? 0;
                          product.discountAmount = 0;
                        } else {
                          product.discountAmount = double.tryParse(discountCtrl.text) ?? 0;
                          product.discountPercentage = 0;
                        }
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0045BC),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Apply Discount",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Screen sizing
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final sp = (sw / 390).clamp(0.8, 1.2);
    final hp = sw / 390;
    final vp = sh / 844;

    double currentSubtotal = 0;
    double currentTotal = 0;
    for (var p in widget.selectedProducts) {
      double lineSubtotal = p.price * p.selectedQty;
      double disc = p.isPercentageDiscount ? (lineSubtotal * p.discountPercentage / 100) : p.discountAmount;
      currentSubtotal += lineSubtotal;
      currentTotal += (lineSubtotal - disc);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delivery Challan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * hp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6 * hp),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.inventory_2, color: Colors.white, size: 18 * sp),
                      ),
                      SizedBox(width: 8 * hp),
                      Text(
                        'View Product Items',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16 * sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: 8 * hp),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // back to payment
                          Navigator.pop(context); // back to catalog
                        },
                        child: Icon(Icons.add_circle_outline,
                            color: AppColors.blue, size: 22 * sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * vp),

                  // ── PRODUCT LIST (INDIVIDUAL CARDS) ──────────────────────
                  Column(
                    children: widget.selectedProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final isExpanded = _expandedProductIndex == index;

                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16 * vp),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 12 * vp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 15 * sp,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() =>
                                            _expandedProductIndex = isExpanded ? null : index),
                                        child: Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textLight,
                                          size: 24 * sp,
                                          ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1 * vp),
                                  Text(
                                    'SKU: SLI-${product.id.padLeft(3, '0')}-X',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12 * sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 3 * vp),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Total: ₹${((product.price * product.selectedQty) - (product.isPercentageDiscount ? (product.price * product.selectedQty * product.discountPercentage / 100) : product.discountAmount)).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.green,
                                            fontSize: 14 * sp,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.edit_note_rounded,
                                        color: AppColors.blue,
                                        size: 24 * sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: EdgeInsets.fromLTRB(16 * hp, 0, 16 * hp, 16 * vp),
                                child: Column(
                                  children: [
                                    const Divider(height: 1, color: AppColors.divider),
                                    SizedBox(height: 14 * vp),
                                    _detailRow(Icons.sell_outlined, AppColors.blue, 'PRICE', '₹${product.price.toStringAsFixed(2)}', sp, hp),
                                    SizedBox(height: 10 * vp),
                                    _detailRow(Icons.inventory_2_outlined, AppColors.blue, 'QTY', '${product.selectedQty}', sp, hp),
                                    SizedBox(height: 10 * vp),
                                    GestureDetector(
                                      onTap: () => _showDiscountBottomSheet(product),
                                      child: _detailRow(
                                        Icons.percent, 
                                        AppColors.blue, 
                                        product.isPercentageDiscount ? 'DISC%' : 'DISC(₹)', 
                                        product.isPercentageDiscount ? '${product.discountPercentage.toInt()}%' : '₹${product.discountAmount.toInt()}', 
                                        sp, 
                                        hp
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 16 * vp),

                  // ── PAYMENT SECTION ──────────────────────────────────
                  Text(
                    'Payment',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18 * sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 12 * vp),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16 * hp),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _inputField('Amount Received', '₹0.0', sp, hp, vp),
                            ),
                            SizedBox(width: 12 * hp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment Mode',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12 * sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 6 * vp),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10 * hp, vertical: 8 * vp),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Cash', style: TextStyle(fontSize: 13 * sp, fontFamily: 'Poppins', color: AppColors.textDark)),
                                        Icon(Icons.keyboard_arrow_down, size: 18 * sp, color: AppColors.textLight),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * vp),
                        _inputField('Notes', 'Add Notes', sp, hp, vp),
                        SizedBox(height: 16 * vp),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFC8E6C9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: const Color(0xFF2E7D32), size: 14 * sp),
                            ),
                            SizedBox(width: 8 * hp),
                            Text(
                              'Mark as fully paid',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13 * sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: false,
                                onChanged: (v) {},
                                activeThumbColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ── BOTTOM SUMMARY ──────────────────────────────────
          Container(
            padding: EdgeInsets.all(16 * hp),
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sub Total : ₹${currentSubtotal.toInt()}',
                      style: TextStyle(color: Colors.white, fontSize: 14 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                    Text(
                      'Total Amount : ₹${currentTotal.toInt()}',
                      style: TextStyle(color: Colors.white, fontSize: 14 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Accurate Calculation Logic
                    double totalSubtotal = 0;
                    double totalDiscount = 0;
                    for (var p in widget.selectedProducts) {
                      totalSubtotal += p.price * p.selectedQty;
                      totalDiscount += p.isPercentageDiscount
                          ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
                          : (p.discountAmount * p.selectedQty);
                    }
                    
                    double taxableAmount = totalSubtotal - totalDiscount;
                    double tax = taxableAmount * 0.18; // Default 18% GST
                    double tcs = taxableAmount * 0.001; 
                    double tds = 0.0;
                    double shipping = 0.0;
                    
                    double rawTotal = taxableAmount + tax + shipping + tcs - tds;
                    double finalPayable = rawTotal.roundToDouble();
                    double roundOff = finalPayable - rawTotal;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryChallanViewScreen(
                          selectedProducts: widget.selectedProducts,
                          summary: widget.summary ?? DeliveryChallanSummary(
                            subtotal: totalSubtotal,
                            discount: totalDiscount,
                            taxableAmount: taxableAmount,
                            igst: tax, // Simplified for now
                            cgst: 0,
                            sgst: 0,
                            tcs: tcs,
                            tds: tds,
                            shippingCharges: shipping,
                            finalPayable: finalPayable,
                            taxType: 'IGST',
                            priceType: 'Exclude tax',
                            roundOff: roundOff,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 10 * vp),
                  ),
                  child: Row(
                    children: [
                      Text('Create', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * sp, fontFamily: 'Poppins')),
                      SizedBox(width: 4 * hp),
                      Icon(Icons.chevron_right, size: 18 * sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, Color color, String label, String value, double sp, double hp) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18 * sp),
        SizedBox(width: 8 * hp),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13 * sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1E2432),
            fontSize: 13 * sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, String hint, double sp, double hp, double vp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 12 * sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 6 * vp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10 * hp, vertical: 8 * vp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(hint, style: TextStyle(color: Colors.grey, fontSize: 13 * sp, fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}
