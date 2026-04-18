import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:purchase_erp/utils/device_services.dart';

class CreateRFQScreen extends StatefulWidget {
  const CreateRFQScreen({super.key});

  @override
  State<CreateRFQScreen> createState() => _CreateRFQScreenState();
}

class _CreateRFQScreenState extends State<CreateRFQScreen> {
  final List<Map<String, dynamic>> items = [
    {
      "code": TextEditingController(),
      "name": TextEditingController(),
      "uom": TextEditingController(),
      "qty": TextEditingController(),
      "remarks": TextEditingController(),
      "selectedSuppliers": <String>[],
    },
  ];

  List<String> allSuppliers = [];
  bool isLoadingSuppliers = true;
  String? supplierError;

  String? cid;
  String? deviceId;
  String? lt;
  String? ln;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        cid = prefs.getString('cid') ?? '';
        deviceId = prefs.getString('device_id') ?? '123';
        lt = prefs.getString('lt') ?? '123';
        ln = prefs.getString('ln') ?? '987';
      });

      // Get updated device info in background
      DeviceServices.getAndStoreDeviceInfo().then((deviceData) {
        if (mounted) {
          setState(() {
            deviceId = deviceData['device_id'] ?? deviceId;
            lt = deviceData['lt'] ?? lt;
            ln = deviceData['ln'] ?? ln;
          });
        }
      });

      _fetchSuppliers();
    } catch (e) {
      debugPrint("Error loading initial data: $e");
    }
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      isLoadingSuppliers = true;
      supplierError = null;
    });

    try {
      if (cid == null || cid!.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        cid = prefs.getString('cid');
      }

      if (cid == null || cid!.isEmpty) {
        throw Exception("CID not found in SharedPreferences");
      }

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: {
          'type': '4014',
          'cid': cid ?? '',
          'device_id': deviceId ?? '123',
          'lt': lt ?? '123',
          'ln': ln ?? '987',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['error'] == false && jsonData['data'] != null) {
          final List<dynamic> supplierList = jsonData['data'];

          setState(() {
            allSuppliers = supplierList
                .map<String>((item) => item['name'].toString())
                .toList();
            isLoadingSuppliers = false;
          });
        } else {
          throw Exception("API returned error or empty data");
        }
      } else {
        throw Exception("Failed to load suppliers: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        supplierError = "Failed to load suppliers: ${e.toString()}";
        isLoadingSuppliers = false;
        // Fallback to your previous hardcoded list in case of error
        allSuppliers = ["CMS Soft", "RK Traders", "SMM", "SMV"];
      });
      debugPrint("Supplier fetch error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _searchItems(String query) async {
    if (query.trim().isEmpty) return [];
    if (cid == null || cid!.isEmpty) {
      debugPrint("⚠️ Cannot search: cid is missing");
      return [];
    }

    try {
      debugPrint("🔍 Searching for: '$query' (cid: $cid)");
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4003",
          "cid": cid ?? '',
          "device_id": deviceId ?? '123',
          "lt": lt ?? '123',
          "ln": ln ?? '987',
          "search": query.trim(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          debugPrint("⚠️ Item Search API returned error or no data");
        }
      } else {
        debugPrint("❌ Item Search API Fail: Status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Search Exception: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

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
          "Create RFQ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PROJECT NAME & DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Project Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Date : 25-03-2026",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            buildTextField("Project Name"),

            const SizedBox(height: 16),

            /// DEPARTMENT
            const Text(
              "Department",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            buildTextField("Department"),

            const SizedBox(height: 16),

            /// DUE DATE
            const Text(
              "Due Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            buildTextField("25-03-2026"),

            const SizedBox(height: 16),

            /// APPROVED BY
            const Text(
              "Approved By",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            buildTextField("Approved By"),

            const SizedBox(height: 16),

            /// REASON FOR PURCHASE
            const Text(
              "Reason For Purchase",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            buildTextField("Reason For Purchase", maxLines: 3),

            const SizedBox(height: 24),

            /// ITEMS SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Items",
                    style: TextStyle(
                      color: Color(0xff512DA8),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(
                      items.length,
                      (index) => buildItemCard(index),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          items.add({
                            "code": TextEditingController(),
                            "name": TextEditingController(),
                            "uom": TextEditingController(),
                            "qty": TextEditingController(),
                            "remarks": TextEditingController(),
                            "selectedSuppliers": <String>[],
                          });
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff26A69A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// SUPPLIER QUOTATION BUTTON
            InkWell(
              onTap: () {
                _showSuccessDialog();
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
                  "Supplier Quotation",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff26A69A), size: 60),
            const SizedBox(height: 16),
            const Text(
              "Success!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Supplier Quotation created successfully",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff26A69A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Item ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (items.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          buildLabel("Item Code"),
          TypeAheadField<Map<String, dynamic>>(
            controller: items[index]["code"],
            suggestionsCallback: _searchItems,
            debounceDuration: const Duration(milliseconds: 300),
            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Search for Items...",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            builder: (context, controller, focusNode) {
              return buildSmallTextField("Enter Item Code", controller,
                  focusNode: focusNode);
            },
            itemBuilder: (context, suggestion) {
              String name = suggestion['Item name'] ?? 'Unknown';
              String code = suggestion['Item Code'] ?? 'N/A';
              return ListTile(
                title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(name, style: const TextStyle(fontSize: 12)),
              );
            },
            onSelected: (suggestion) {
              setState(() {
                items[index]["code"].text = suggestion['Item Code']?.toString() ?? '';
                items[index]["name"].text = suggestion['Item name']?.toString() ?? '';
                items[index]["uom"].text = suggestion['UOM']?.toString() ?? '';
              });
            },
          ),
          const SizedBox(height: 12),
          buildLabel("Product Name"),
          TypeAheadField<Map<String, dynamic>>(
            controller: items[index]["name"],
            suggestionsCallback: _searchItems,
            debounceDuration: const Duration(milliseconds: 300),
            emptyBuilder: (context) => const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Search for Items...",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
            builder: (context, controller, focusNode) {
              return buildSmallTextField("Product Name", controller,
                  focusNode: focusNode);
            },
            itemBuilder: (context, suggestion) {
              String name = suggestion['Item name'] ?? 'Unknown';
              String code = suggestion['Item Code'] ?? 'N/A';
              return ListTile(
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Code: $code", style: const TextStyle(fontSize: 11)),
              );
            },
            onSelected: (suggestion) {
              setState(() {
                items[index]["code"].text = suggestion['Item Code']?.toString() ?? '';
                items[index]["name"].text = suggestion['Item name']?.toString() ?? '';
                items[index]["uom"].text = suggestion['UOM']?.toString() ?? '';
              });
            },
          ),
          const SizedBox(height: 12),
          buildLabel("UOM"),
          buildSmallTextField("UOM", items[index]["uom"]),
          const SizedBox(height: 12),
          buildLabel("Ordered QTY"),
          buildSmallTextField("0", items[index]["qty"]),
          const SizedBox(height: 12),
          buildLabel("Remarks"),
          buildSmallTextField("Remarks", items[index]["remarks"]),
          const SizedBox(height: 12),
          buildLabel("Supplier"),
          if (isLoadingSuppliers)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (supplierError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                supplierError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            )
          else
            buildSupplierDropdown(index),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff26A69A)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildSmallTextField(String hint, TextEditingController controller,
      {FocusNode? focusNode}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff26A69A)),
        ),
      ),
    );
  }

  Widget buildSupplierDropdown(int itemIndex) {
    List<String> selected = items[itemIndex]["selectedSuppliers"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: selected.isEmpty
                  ? const Text(
                      "Supplier",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  : Wrap(
                      spacing: 8,
                      children: selected
                          .map(
                            (s) => Chip(
                              label: Text(
                                s,
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.red,
                              ),
                              onDeleted: () {
                                setState(() {
                                  selected.remove(s);
                                });
                              },
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
          DropdownButton<String>(
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            items: allSuppliers.where((s) => !selected.contains(s)).map((
              String s,
            ) {
              return DropdownMenuItem<String>(
                value: s,
                child: Text(s, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selected.add(val);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
