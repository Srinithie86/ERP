import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_theme.dart';

class ApproveScreen extends StatefulWidget {
  const ApproveScreen({super.key});

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> {
  bool _isLoading = false;
  List<dynamic> _realApprovals = []; // This will hold the items to approve

  final List<Map<String, dynamic>> _approvals = [];

  @override
  void initState() {
    super.initState();
    _fetchApprovalDetails(); // Load real data automatically
  }

  Future<void> _fetchApprovalDetails() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final ln = prefs.getString('ln') ?? '123';
      final lt = prefs.getString('lt') ?? '123';
      final uid = prefs.getString('uid') ?? '1';
      final roleId = prefs.getString('role_id') ?? '2';
      final token = prefs.getString('token') ?? 'guywegdyegd';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type': '8012',
          'cid': cid,
          'device_id': deviceId, 
          'ln': ln,
          'lt': lt,
          'uid': uid,
          'role_id': roleId,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Approval details Response: $data");
        if (data != null && data['error'] == false) {
          final List<dynamic> resDataList = data['data'] ?? [];
          
          setState(() {
            _approvals.clear(); // Clear mock data
            for (var resData in resDataList) {
              final main = resData['main'] ?? {};
              final reqByName = resData['req_by_name'] ?? 'N/A';
              final isA = resData['is_a'];
              // If is_a is null, it is considered already approved
              // If is_a is 1, it needs approval functions
              final bool isApproved = (isA == null); 
              
              _approvals.add({
                'id': main['invoice_no'] ?? '#N/A',
                'realId': resData['id']?.toString() ?? '12',
                'type': 'Sales Invoice',
                'requestedBy': reqByName,
                'customer': main['b_name'] ?? 'N/A',
                'amount': '₹${main['g_total'] ?? '0'}',
                'date': main['date'] ?? 'N/A',
                'isApproved': isApproved,
                'rawData': resData, // Store full data for popup
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching approval details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(String id) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final ln = prefs.getString('ln') ?? '123';
      final lt = prefs.getString('lt') ?? '123';
      final uid = prefs.getString('uid') ?? '1';
      final roleId = prefs.getString('role_id') ?? '2';
      final token = prefs.getString('token') ?? 'guywegdyegd';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'type': '8014',
          'cid': cid,
          'device_id': deviceId,
          'ln': ln,
          'lt': lt,
          'uid': uid,
          'id': id,
          'role_id': roleId,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Approval Response: $data");
        if (data != null && data['error'] == false) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['error_msg'] ?? 'Approved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
          _fetchApprovalDetails(); // Refresh the list
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['error_msg'] ?? 'Failed to approve'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error approving request: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Approve',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          _approvals.isEmpty && !_isLoading
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _approvals.length,
                  itemBuilder: (context, index) {
                    final item = _approvals[index];
                    return _buildApprovalCard(item);
                  },
                ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A))),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No approval found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new requests',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['id'],
                          style: const TextStyle(
                            color: Color(0xFF26A69A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          item['date'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['type'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              //  _buildInfoRow('Date', item['date'] ?? ''),
                const SizedBox(height: 4),
                _buildInfoRow('Requested by', item['requestedBy']),
                const SizedBox(height: 4),
                _buildInfoRow('Customer', item['customer']),
                const SizedBox(height: 12),
                Text(
                  item['amount'],
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Use the raw data already fetched or fallback to the card info
                    if (item.containsKey('rawData')) {
                      _showDetailPopUp(item['rawData']);
                    } else {
                      // Handle fallback if needed
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined, color: Color(0xFF26A69A)),
                  label: const Text(
                    'View Detail',
                    style: TextStyle(
                      color: Color(0xFF26A69A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!(item['isApproved'] ?? false))
                  ElevatedButton.icon(
                    onPressed: () => _approveRequest(item['realId']),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Approved',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          color: Color(0xFF64748B),
        ),
        children: [
          TextSpan(text: '$label - '),
          TextSpan(
            text: value,
            style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showDetailPopUp(Map<String, dynamic> data) {
    final main = data['main'] ?? {};
    final sub = data['sub'] as List? ?? [];
    final reqByName = data['req_by_name'] ?? 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Invoice No', main['invoice_no'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Date', main['date'] ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Requested By', reqByName),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Customer', main['b_name'] ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ... sub.map((prod) => _buildProductItem({
                      'name': prod['pname'] ?? 'Unknown Product',
                      'qty': prod['qty'] ?? '0',
                      'price': prod['taxtotal'] ?? prod['total'] ?? '0',
                    })).toList(),
                    _buildTotalRow('Taxable Amount', '₹${main['taxtotal'] ?? '0'}', isBold: true),
                    _buildTotalRow('SGST', '₹${main['sgst'] ?? '0'}'),
                    _buildTotalRow('CGST', '₹${main['cgst'] ?? '0'}'),

                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                color: const Color(0xFF1B8C4A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      '₹${main['g_total'] ?? '0'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Show Approve button if is_a is NOT null (e.g. if it is 1)
              if (data['is_a'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _approveRequest(data['id']?.toString() ?? '');
                    },
                    icon: const Icon(Icons.check, size: 24),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        Row(
          children: [
            const Text(' - ', style: TextStyle(color: Color(0xFF64748B))),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0052CC),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductItem(Map<String, dynamic> prod) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 8, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prod['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Qty: ${prod['qty']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${prod['price']}',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF64748B),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
