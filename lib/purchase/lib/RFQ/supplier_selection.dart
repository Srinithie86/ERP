import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/core/api_config.dart';

class SupplierSelectionScreen extends StatefulWidget {
  final String rfqNo;
  final String itemCode;
  final String itemDesc;
  final String itemQty;

  const SupplierSelectionScreen({
    super.key,
    required this.rfqNo,
    required this.itemCode,
    required this.itemDesc,
    required this.itemQty,
  });

  @override
  State<SupplierSelectionScreen> createState() => _SupplierSelectionScreenState();
}

class _SupplierSelectionScreenState extends State<SupplierSelectionScreen> {
  bool selectAll = false;
  List<dynamic> supplierList = [];
  List<bool> selectedSuppliers = [];
  bool isLoading = false;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      final Map<String, dynamic> body = {
        "type": "4014",
        "cid": cid,
        "device_id": deviceId,
        "ln": ln,
        "lt": lt,
      };

      debugPrint("API 4014 REQUEST BODY: $body");

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: body,
      );

      debugPrint("API 4014 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              supplierList = data['data'] ?? [];
              selectedSuppliers = List.generate(supplierList.length, (index) => false);
              isFetching = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Suppliers Error: $e");
      if (mounted) setState(() => isFetching = false);
    }
  }

  Future<void> _submitQuotation() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      // Gather selected supplier IDs dynamically
      List<String> selectedIds = [];
      for (int i = 0; i < selectedSuppliers.length; i++) {
        if (selectedSuppliers[i]) {
          selectedIds.add(supplierList[i]['id'].toString());
        }
      }
      
      if (selectedIds.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one supplier")),
        );
        return;
      }
      
      String chosenSuppliers = selectedIds.join(",");
      
      final Map<String, dynamic> requestBody = {
        "type": "4017",
        "cid": cid,
        "device_id": deviceId,
        "uid": uid,
        "ln": ln,
        "lt": lt,
        "rfq_no": widget.rfqNo, 
        "supplier_id": chosenSuppliers,
        "item_code": widget.itemCode,
        "item_desc": widget.itemDesc,
        "item_qty": widget.itemQty,
      };

      debugPrint("API 4017 REQUEST BODY: $requestBody");

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: requestBody,
      );

      debugPrint("API 4017 RESPONSE BODY: ${response.body}");

      setState(() => isLoading = false);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
           if (mounted) {
             _showSuccessDialog(data['message'] ?? "Quotation Saved Successfully");
           }
           return;
        } else {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? "Failed to save quotation"), backgroundColor: Colors.red),
             );
           }
        }
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to save quotation"), backgroundColor: Colors.red),
           );
         }
      }
    } catch (e) {
      debugPrint("Save Quotation Error: $e");
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xff188E24).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xff188E24),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Success !",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    // Pop exactly 2 times to return to RFQ Screen
                    int count = 0;
                    Navigator.of(this.context).popUntil((_) => count++ >= 2);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xff26A69A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
            padding: EdgeInsets.all(width * 0.04),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Supplier...",
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

          /// SELECT ALL SUPPLIERS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
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
                        for (int i = 0; i < selectedSuppliers.length; i++) {
                          selectedSuppliers[i] = selectAll;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Select All Suppliers",
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

          /// SUPPLIER LIST
          Expanded(
            child: isFetching
                ? const Center(child: CircularProgressIndicator(color: Color(0xff26A69A)))
                : supplierList.isEmpty
                    ? const Center(child: Text("No Suppliers Found"))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                        itemCount: supplierList.length,
                        itemBuilder: (context, index) {
                          final supplier = supplierList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: selectedSuppliers[index],
                                    activeColor: const Color(0xff26A69A),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedSuppliers[index] = val ?? false;
                                        if (selectedSuppliers.contains(false)) {
                                          selectAll = false;
                                        } else {
                                          selectAll = true;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    supplier['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          /// CONFIRM & SAVE BUTTON
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(width * 0.04, width * 0.04, width * 0.04, 0),
              child: InkWell(
                onTap: () {
                  if (!isLoading) {
                    _submitQuotation();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : const Color(0xff26A69A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Confirm & Save",
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}