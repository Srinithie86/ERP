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
  List<dynamic> pendingItems = [];
  List<dynamic> assignedItems = [];

  @override
  void initState() {
    super.initState();
    _processItems();
  }

  void _processItems() {
    pendingItems = widget.items.where((item) => item['is_assigned'] == false).toList();
    assignedItems = widget.items.where((item) => item['is_assigned'] == true).toList();
    selectedItems = List.generate(pendingItems.length, (index) => false);
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
                const Spacer(),
                if (pendingItems.isNotEmpty)
                  Text(
                    "${pendingItems.length} pending",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// PRODUCT LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Assigned Items first (with checkmark)
                ...assignedItems.map((item) {
                  return productSelectionCard(
                    title: item['product_name'] ?? 'Unknown Item',
                    subtitle: item['item_code']?.toString() ?? 'No Code',
                    qty: item['qty']?.toString() ?? '0',
                    isSelected: true,
                    isAlreadyAssigned: true,
                    onChanged: (_) {},
                  );
                }),

                // Pending Items
                ...List.generate(pendingItems.length, (index) {
                  final item = pendingItems[index];
                  return productSelectionCard(
                    title: item['product_name'] ?? 'Unknown Item',
                    subtitle: item['item_code']?.toString() ?? 'No Code',
                    qty: item['qty']?.toString() ?? '0',
                    isSelected: selectedItems[index],
                    isAlreadyAssigned: false,
                    onChanged: (val) {
                      setState(() {
                        selectedItems[index] = val ?? false;
                        selectAll = !selectedItems.contains(false);
                      });
                    },
                  );
                }),

                if (widget.items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text("No items found"),
                    ),
                  ),
              ],
            ),
          ),

          /// NEXT BUTTON / CONFIRM CHECKBOX
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (assignedItems.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFF14B8A6)),
                          const SizedBox(width: 8),
                          Text(
                            "Already Assigned Items (${assignedItems.length})",
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: assignedItems.length,
                        itemBuilder: (context, index) {
                          final item = assignedItems[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.2)),
                            ),
                            child: Center(
                              child: Text(
                                "${item['product_name']} [${item['item_code']}]",
                                style: const TextStyle(
                                  color: Color(0xFF14B8A6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  InkWell(
                    onTap: () {
                      // Get selected items
                      List<String> codes = [];
                      List<String> descs = [];
                      List<String> qtys = [];

                      for (int i = 0; i < pendingItems.length; i++) {
                        if (selectedItems[i]) {
                          final item = pendingItems[i];
                          codes.add(item['item_code']?.toString() ?? '');
                          descs.add(item['product_name']?.toString() ?? '');
                          qtys.add(item['qty']?.toString() ?? '0');
                        }
                      }

                      if (codes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select at least one pending product")),
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
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Confirm & Save Selection",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    required bool isAlreadyAssigned,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isAlreadyAssigned ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlreadyAssigned ? const Color(0xFF14B8A6).withOpacity(0.3) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          if (!isAlreadyAssigned)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAlreadyAssigned)
              const Icon(Icons.check_circle, color: Color(0xFF14B8A6), size: 28)
            else
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF14B8A6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: onChanged,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isAlreadyAssigned ? Colors.blueGrey.shade700 : Colors.blueGrey.shade900,
                          ),
                        ),
                      ),
                      if (isAlreadyAssigned)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14B8A6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Already Assigned",
                            style: TextStyle(
                              color: Color(0xFF14B8A6),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "QTY : $qty",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isAlreadyAssigned ? Colors.grey.shade600 : Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      if (isAlreadyAssigned)
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              "Assigned",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                    ],
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

