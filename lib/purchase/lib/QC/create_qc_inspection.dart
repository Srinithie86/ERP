import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/core/api_config.dart';

class QCItemData {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController testResultController = TextEditingController();
  String qcStatus = "Select";
  final TextEditingController rejectedQtyController = TextEditingController(text: "0");
  final TextEditingController remarksController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    productNameController.dispose();
    testResultController.dispose();
    rejectedQtyController.dispose();
    remarksController.dispose();
  }
}

class CreateQCInspectionScreen extends StatefulWidget {
  final String? grnNo;
  final List<dynamic>? initialItems;

  const CreateQCInspectionScreen({super.key, this.grnNo, this.initialItems});

  @override
  State<CreateQCInspectionScreen> createState() => _CreateQCInspectionScreenState();
}

class _CreateQCInspectionScreenState extends State<CreateQCInspectionScreen> {
  final TextEditingController inspectionIdController = TextEditingController();
  final TextEditingController grnNoController = TextEditingController();
  final TextEditingController inspectorNameController = TextEditingController();
  final TextEditingController inspectorDateController = TextEditingController();

  List<QCItemData> itemsList = [QCItemData()];
  bool isSubmitting = false;
  bool isFetchingItems = false;

  @override
  void initState() {
    super.initState();
    if (widget.grnNo != null) {
      grnNoController.text = widget.grnNo!;
    }
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      itemsList.clear();
      for (var item in widget.initialItems!) {
        final qcItem = QCItemData();
        qcItem.itemCodeController.text = item['item_code'] ?? '';
        itemsList.add(qcItem);
      }
    }
    inspectorDateController.text = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    inspectionIdController.dispose();
    grnNoController.dispose();
    inspectorNameController.dispose();
    inspectorDateController.dispose();
    for (var item in itemsList) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchGrnItems() async {
    final grnNo = grnNoController.text.trim();
    if (grnNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a GRN No first")));
      return;
    }

    setState(() => isFetchingItems = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4034",
          "cid": cid,
          "device_id": deviceData['device_id'] ?? 'Unknown',
          "ln": deviceData['ln'] ?? '0.0',
          "lt": deviceData['lt'] ?? '0.0',
          "status": "pending", // Usually search in pending
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> allGrns = data['data'];
          final match = allGrns.firstWhere(
            (g) => g['grn_no'].toString().toLowerCase() == grnNo.toLowerCase(),
            orElse: () => null,
          );

          if (match != null) {
            final items = match['items'] as List? ?? [];
            if (items.isNotEmpty) {
              setState(() {
                for (var it in itemsList) it.dispose();
                itemsList.clear();
                for (var item in items) {
                  final newItem = QCItemData();
                  newItem.itemCodeController.text = item['item_code'] ?? '';
                  newItem.productNameController.text = item['product_name'] ?? item['pro_name'] ?? '';
                  newItem.remarksController.text = ""; // Reset remarks
                  itemsList.add(newItem);
                }
                // Also set inspector name if available or other fields
                if (match['inspector_name'] != null) {
                   inspectorNameController.text = match['inspector_name'];
                }
                if (match['id'] != null) {
                   inspectionIdController.text = match['id'].toString();
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Found ${items.length} items for $grnNo")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No items found for this GRN in pending list")));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("GRN No not found in pending inspections")));
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Items Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching items: $e")));
    } finally {
      if (mounted) setState(() => isFetchingItems = false);
    }
  }

  Future<void> _submitQC() async {
    setState(() => isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('uid') ?? prefs.getString('id') ?? '1';
      final roleId = prefs.getString('role_id') ?? '1';
      
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      Map<String, String> body = {
        "type": "4037",
        "cid": cid,
        "ln": ln,
        "lt": lt,
        "device_id": deviceId,
        "uid": uid,
        "role_id": roleId,
        "prid": "1",
        "inspection_id": inspectionIdController.text,
        "grn_no": grnNoController.text,
        "inspector_name": inspectorNameController.text,
        "inspection_date": inspectorDateController.text,
      };

      for (int i = 0; i < itemsList.length; i++) {
        var item = itemsList[i];
        body['item_code[$i]'] = item.itemCodeController.text;
        body['qc_test_result[$i]'] = item.testResultController.text; 
        body['qc_status[$i]'] = item.qcStatus;
        body['rejected_qty[$i]'] = item.rejectedQtyController.text;
        body['remarks[$i]'] = item.remarksController.text;
      }

      var request = http.Request('POST', Uri.parse(await ApiConfig.getBaseUrl()));
      request.bodyFields = body;

      final response = await request.send();
      final strResponse = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final decoded = json.decode(strResponse);
        if (decoded['error'] == false || decoded['error'].toString().toLowerCase() == 'false') {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decoded['message'] ?? "QC Inserted Successfully!"), backgroundColor: const Color(0xff2AAA98)));
           Navigator.pop(context);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decoded['message'] ?? decoded['error_msg'] ?? "QC Insert Failed"), backgroundColor: Colors.red));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server error: ${response.statusCode}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection error: $e"), backgroundColor: Colors.red));
      debugPrint("QC Submit Error: $e");
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Widget _buildLabeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, // Larger as per Image
            color: Colors.black, // Dark black text for labels
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildTextField(String hint, {bool isPlaceholder = true, TextEditingController? controller, Widget? suffixIcon, bool readOnly = false}) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 12,
            color: isPlaceholder ? Colors.grey.shade400 : Colors.black87,
            fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, QCItemData itemData) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: itemData.qcStatus,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 18),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => itemData.qcStatus = newValue);
            }
          },
          items: <String>['Select', 'Passed', 'Partial', 'Failed']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFlexibleGrid({
    required BoxConstraints constraints,
    required List<Widget> children,
    bool allowHalfWidthOnMobile = false,
    List<int>? halfWidthIndicesMobile,
  }) {
    double w = constraints.maxWidth;
    bool isMobile = w <= 600;
    bool isTablet = w > 600 && w <= 900;

    double spacing = 16.0;

    double w1 = w;
    double w2 = (w - spacing) / 2;
    double w3 = (w - spacing * 2) / 3;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children.asMap().entries.map((entry) {
        int idx = entry.key;
        Widget child = entry.value;

        double finalWidth;
        if (isMobile) {
          if (allowHalfWidthOnMobile &&
              halfWidthIndicesMobile != null &&
              halfWidthIndicesMobile.contains(idx)) {
            finalWidth = w2;
          } else {
            finalWidth = w1;
          }
        } else if (isTablet) {
          finalWidth = w2;
        } else {
          finalWidth = w3; // Or whatever design needs
        }

        return SizedBox(
          width: (finalWidth - 0.1).clamp(0, double.infinity),
          child: child,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff2AAA98); // Matches the teal

    List<Widget> headerFields = [
      _buildLabeledField("Inspection ID", _buildTextField("Inspection ID", controller: inspectionIdController)),
      _buildLabeledField("GRN No", _buildTextField("GRN No", controller: grnNoController, suffixIcon: InkWell(
        onTap: isFetchingItems ? null : _fetchGrnItems,
        child: isFetchingItems 
          ? const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)))
          : const Icon(Icons.search, color: primaryColor, size: 20),
      ))),
      _buildLabeledField("Inspector Name", _buildTextField("Inspector Name", controller: inspectorNameController)),
      _buildLabeledField("Inspector Date", _buildTextField("YYYY-MM-DD", isPlaceholder: false, controller: inspectorDateController)),
    ];

    // item fields moved to inside the builder

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "QC Inspections",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header Block
            LayoutBuilder(
              builder: (context, constraints) {
                return _buildFlexibleGrid(
                  constraints: constraints,
                  children: headerFields,
                );
              },
            ),
            const SizedBox(height: 24),

            /// Items Container Background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Items",
                    style: TextStyle(
                      color: Color(0xff3B187B), // Indigo from image
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...itemsList.asMap().entries.map((entry) {
                    int index = entry.key + 1;
                    QCItemData item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFFDE7),
                          border: Border.all(color: const Color(0xffF9A825).withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Item $index",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (itemsList.length > 1)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        itemsList.remove(item);
                                      });
                                    },
                                    child: const Icon(Icons.close, color: Color(0xffD32F2F), size: 18),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildFlexibleGrid(
                                  constraints: constraints,
                                  children: [
                                    _buildLabeledField("Product Name", _buildTextField("Product Name", controller: item.productNameController, readOnly: true)),
                                    _buildLabeledField("Item Code", _buildTextField("Enter Item Code", controller: item.itemCodeController)),
                                    _buildLabeledField("QC Test Result", _buildTextField("QC Test Result", controller: item.testResultController)),
                                    _buildLabeledField("QC Status", _buildDropdown("Select", item)),
                                    _buildLabeledField("Rejected QTY", _buildTextField("0", controller: item.rejectedQtyController, isPlaceholder: false)),
                                    _buildLabeledField("Remarks", _buildTextField("Remarks", controller: item.remarksController)),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  /// Add Item Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        setState(() {
                          itemsList.add(QCItemData());
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      label: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Save Changes Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              onPressed: isSubmitting ? null : _submitQC,
              child: isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}