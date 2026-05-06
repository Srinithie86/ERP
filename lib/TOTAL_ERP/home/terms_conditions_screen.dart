import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/utils/device_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erp_smart/utils/api_config.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _isLoading = true;
  List<dynamic> _terms = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      // Ensure we have fallback ID
      final String deviceId = DeviceService.deviceId.isNotEmpty ? DeviceService.deviceId : '123';
      
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4042",
          "cid": cid,
          "device_id": deviceId,
          "ln": DeviceService.latitude.toString(),
          "lt": DeviceService.longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              _terms = data['data'] ?? [];
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error = data['message'] ?? "Failed to load terms.";
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = "Server Error: ${response.statusCode}";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Connection Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Terms & Conditions",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF00695C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.outfit(color: Colors.red)))
              : _terms.isEmpty
                  ? Center(child: Text("No terms available.", style: GoogleFonts.outfit(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _terms.length,
                      itemBuilder: (context, index) {
                        final term = _terms[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              iconColor: const Color(0xFF26A69A),
                              collapsedIconColor: Colors.grey,
                              initiallyExpanded: index == 0,
                              title: Text(
                                term['title'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF00695C),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                  child: Text(
                                    term['description'] ?? '',
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}