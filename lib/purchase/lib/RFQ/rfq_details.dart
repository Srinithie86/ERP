import 'package:flutter/material.dart';
import 'package:purchase_erp/Supplier%20Quotations/quotation_details.dart';

class RFQDetailsScreen extends StatefulWidget {
  const RFQDetailsScreen({super.key});

  @override
  State<RFQDetailsScreen> createState() => _RFQDetailsScreenState();
}

class _RFQDetailsScreenState extends State<RFQDetailsScreen> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Request for Quotation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. TOP INFO BOXES (DEADLINE & TERMS)
            Row(
              children: [
                Expanded(
                  child: infoBox("Deadline", "2025-12-10"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: infoBox("Terms", "Net 30 Days, Delivery Within 7 Days"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// 2. SUPPLIERS INVITED
            const Text(
              "Suppliers Invited",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bulletItem("Ravi Industries"),
                  bulletItem("Sharma Traders"),
                  bulletItem("Global Metals"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 3. PRODUCT REQUESTED
            const Text(
              "Product Requested",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffE6FFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  productRow("Stainless Steel Sheet 2mm", "50 Nos"),
                  const Divider(height: 1, color: Color(0xffB2EBF2)),
                  productRow("Welding Roads 3.5mm", "200 Kg", isUnderlined: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 4. QUOTATIONS RECEIVED
            const Text(
              "Quotations Received (3)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 12),
            quotationReceivedCard("Ravi Industries", "QUOT - 2401 - 7 Days Delivery"),
            const SizedBox(height: 12),
            quotationReceivedCard("Sharma Traders", "QUOT - 2401 - 7 Days Delivery"),
            const SizedBox(height: 12),
            quotationReceivedCard("Global Metals", "QUOT - 2401 - 7 Days Delivery"),

            const SizedBox(height: 32),

            /// 5. FOOTER ACTIONS
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xff22A79A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Export PDF",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff22A79A)),
                      ),
                      child: const Text(
                        "Compare All",
                        style: TextStyle(color: Color(0xff22A79A), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffE6FFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget productRow(String title, String qty, {bool isUnderlined = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xff1C1C1C),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
                decorationColor: Colors.blue,
                decorationThickness: 2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            qty,
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget quotationReceivedCard(String supplier, String detail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff1A9A8C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuotationDetailsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "View",
                style: TextStyle(color: Color(0xff1A9A8C), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

