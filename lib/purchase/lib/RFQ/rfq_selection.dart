import 'package:flutter/material.dart';
import 'package:purchase_erp/RFQ/supplier_selection.dart';

class RFQSelectionScreen extends StatefulWidget {
  final List<dynamic> items;
  final String rfqNo;
  const RFQSelectionScreen({super.key, required this.items, required this.rfqNo});

  @override
  State<RFQSelectionScreen> createState() => _RFQSelectionScreenState();
}

class _RFQSelectionScreenState extends State<RFQSelectionScreen> {
  bool selectAll = false;
  late List<bool> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = List.generate(widget.items.length, (index) => false);
  }

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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Product...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.black, size: 22),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xff26A69A)),
                ),
              ),
            ),
          ),

          /// SELECT ALL PENDING
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: selectAll,
                    activeColor: const Color(0xff26A69A),
                    onChanged: (val) {
                      setState(() {
                        selectAll = val ?? false;
                        for (int i = 0; i < selectedItems.length; i++) {
                          selectedItems[i] = selectAll;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Select All Pending",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// PRODUCT LIST
          Expanded(
            child: widget.items.isEmpty
                ? const Center(child: Text("No items pending"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      // Map your API fields here
                      final String title = item['product_name'] ?? 'Unknown Item';
                      final String subtitle = item['item_code']?.toString() ?? 'No Code';
                      final String qty = item['qty']?.toString() ?? '0';

                      return productSelectionCard(
                        title: title,
                        subtitle: subtitle,
                        qty: qty,
                        isSelected: selectedItems[index],
                        onChanged: (val) {
                          setState(() {
                            selectedItems[index] = val ?? false;
                          });
                        },
                      );
                    },
                  ),
          ),

          /// NEXT BUTTON
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  // Get selected items
                  List<String> codes = [];
                  List<String> descs = [];
                  List<String> qtys = [];
                  
                  for (int i = 0; i < widget.items.length; i++) {
                    if (selectedItems[i]) {
                      final item = widget.items[i];
                      codes.add(item['item_code']?.toString() ?? '');
                      descs.add(item['product_name']?.toString() ?? '');
                      qtys.add(item['qty']?.toString() ?? '0');
                    }
                  }

                  if (codes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select at least one product")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupplierSelectionScreen(
                        rfqNo: widget.rfqNo,
                        itemCode: codes.join(","),
                        itemDesc: descs.join(","),
                        itemQty: qtys.join(","),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xff26A69A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget productSelectionCard({
    required String title,
    required String subtitle,
    required String qty,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: isSelected,
                activeColor: const Color(0xff26A69A),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "QTY : $qty",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
