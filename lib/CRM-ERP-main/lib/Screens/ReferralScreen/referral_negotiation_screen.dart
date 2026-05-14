import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/lead_row_card.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../widgets/responsive_layout.dart';
import '../Leads/call_outcome_screen.dart';

class ReferralNegotiationScreen extends StatefulWidget {
  const ReferralNegotiationScreen({super.key});

  @override
  State<ReferralNegotiationScreen> createState() =>
      _ReferralNegotiationScreenState();
}

class _ReferralNegotiationScreenState extends State<ReferralNegotiationScreen> {
  bool _isLoading = false;
  List<dynamic> _referrals = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    // API Binding removed for re-binding
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildScaffold(context, isMobile: true),
      tablet: _buildScaffold(context, isMobile: false),
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool isMobile}) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        title: Text(
          'Negotiation Referral',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : _referrals.isEmpty
                    ? const Center(child: Text("No negotiation referrals found"))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _referrals.length,
                        itemBuilder: (c, i) => LeadRowCard(
                          lead: _referrals[i],
                          showStatus: false,
                          onCall: () => _confirmCall(context, _referrals[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmCall(BuildContext context, Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => CallConfirmationPopup(
        lead: lead,
        onConfirm: (String selectedPhone) async {
          Navigator.pop(c);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CallOutcomeScreen(lead: lead, autoCall: true),
            ),
          ).then((_) => _fetch());
        },
        onCancel: () => Navigator.pop(c),
      ),
    );
  }
}
