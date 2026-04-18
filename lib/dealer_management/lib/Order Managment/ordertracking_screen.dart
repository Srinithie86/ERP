import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

enum TrackingStatus { packing, pickedUp, inTransit, delivered }
enum TrackingView { viewList, viewDetails, addNew, filterList }

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  TrackingView _currentView = TrackingView.viewList;
  Map<String, dynamic>? _selectedTracking;
  
  final Color primaryColor = const Color(0xFF26A69A);
  final Color darkBlue = const Color(0xFF1E234E);

  // Controllers for Add New
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dealerController = TextEditingController();
  final TextEditingController _dateRangeController = TextEditingController(text: '08 Apr - 12 Apr 2026');

  final List<Map<String, dynamic>> _trackingRecords = [
    {
      'id': '#412-639-JTO',
      'dealer': 'Sri Julaekha - Jakarta',
      'dateRange': '18 Dec - 22 Dec 2023',
      'from': 'Yogyakarta',
      'to': 'Jakarta (EST)',
      'status': TrackingStatus.inTransit,
      'progress': 0.7,
      'courier': {'name': 'Faza Dzikrulloh', 'phone': '0812-222-2222', 'avatar': 'https://i.pravatar.cc/150?u=faza'},
      'history': [
        {'title': 'Your package is being delivered by courier', 'sub': 'Kebon jeruk, Jakarta', 'time': 'Today, 5:40 PM', 'completed': true},
        {'title': 'In transit', 'sub': 'Central Jakarta', 'time': 'Today, 4:40 PM', 'completed': true},
        {'title': 'Picked up', 'sub': 'Yogyakarta drop point', 'time': 'Yesterday, 8:20 AM', 'completed': true},
        {'title': 'Packing', 'sub': 'Yogyakarta', 'time': 'Yesterday, 7:02 AM', 'completed': true},
      ]
    },
    {
      'id': '#772-105-BKK',
      'dealer': 'Modern Spares - Mumbai',
      'dateRange': '20 Dec - 25 Dec 2023',
      'from': 'Chennai',
      'to': 'Mumbai (EST)',
      'status': TrackingStatus.pickedUp,
      'progress': 0.3,
      'courier': {'name': 'Ravi Kumar', 'phone': '0987-654-3210', 'avatar': 'https://i.pravatar.cc/150?u=ravi'},
      'history': [
        {'title': 'Picked up', 'sub': 'Chennai Main Hub', 'time': 'Today, 10:20 AM', 'completed': true},
        {'title': 'Packing', 'sub': 'Chennai Warehouse', 'time': 'Yesterday, 4:15 PM', 'completed': true},
      ]
    },
  ];

  @override
  void dispose() {
    _idController.dispose();
    _dealerController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  void _saveTracking() {
    if (_idController.text.isEmpty) { return; }
    setState(() {
      _trackingRecords.insert(0, {
        'id': _idController.text,
        'dealer': _dealerController.text,
        'dateRange': _dateRangeController.text,
        'from': 'Main Warehouse',
        'to': 'Dealer Warehouse',
        'status': TrackingStatus.packing,
        'progress': 0.1,
        'courier': {'name': 'Unassigned', 'phone': '-', 'avatar': ''},
        'history': [{'title': 'Packing', 'sub': 'Main Warehouse', 'time': 'Just Now', 'completed': true}]
      });
      _currentView = TrackingView.viewList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMainContent(size),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Order Tracking';
    if (_currentView == TrackingView.viewDetails) { title = 'Details'; }
    if (_currentView == TrackingView.addNew) { title = 'New Track'; }
    if (_currentView == TrackingView.filterList) { title = 'Filter'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E234E)),
            onPressed: () {
              if (_currentView == TrackingView.viewList) {
                Navigator.pop(context);
              } else {
                setState(() => _currentView = TrackingView.viewList);
              }
            },
          ),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
          ),
          _currentView == TrackingView.viewList 
              ? Row(
                  children: [
                    IconButton(icon: Icon(Icons.tune_rounded, color: primaryColor), onPressed: () => setState(() => _currentView = TrackingView.filterList)),
                    IconButton(icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor), onPressed: () => setState(() => _currentView = TrackingView.addNew)),
                  ],
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMainContent(Size size) {
    switch (_currentView) {
      case TrackingView.viewList:
        return _buildTrackingList(size);
      case TrackingView.viewDetails:
        return _buildTrackingDetails(size);
      case TrackingView.addNew:
        return _buildAddForm();
      case TrackingView.filterList:
        return _buildFilterForm();
    }
  }

  Widget _buildTrackingList(Size size) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Current tracking',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: darkBlue),
        ),
        const SizedBox(height: 16),
        ..._trackingRecords.map((record) => _buildTrackingCard(record, size)),
      ],
    );
  }

  Widget _buildVerticalTimeline(List<dynamic> history) {
    return Column(
      children: List.generate(history.length, (index) {
        final item = history[index];
        final isLast = index == history.length - 1;
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.blue : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: index == 0 ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.grey[200],
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(item['title'], 
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item['time'], 
                          style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 10),
                        ),
                      ],
                    ),
                    Text(item['sub'], style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
                    if (index == 0) ...[
                      const SizedBox(height: 12),
                      _buildCourierAction(history[0]['courier'] ?? _trackingRecords[0]['courier']),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCourierAction(Map<String, dynamic> courier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(courier['avatar']), radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courier['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(courier['phone'], style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.chat_bubble_outline_rounded, color: Colors.blue[400], size: 20), onPressed: () {}),
          IconButton(icon: Icon(Icons.phone_in_talk_outlined, color: Colors.green[400], size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(Map<String, dynamic> record, Size size) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTracking = record;
        _currentView = TrackingView.viewDetails;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7EF), // Soft cream/peach from image
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            children: [
              // 3D Cardboard Box Illustration
              Positioned(
                right: -20,
                bottom: -20,
                child: Image.file(
                  File('C:/Users/arun/.gemini/antigravity/brain/4029bb90-92b7-441c-93f6-fffa8f6a719f/3d_cardboard_box_1775640846197.png'),
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.inventory_2_rounded, size: 100, color: Colors.orange[100]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: Text('Transit', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    Text(record['id'], style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: darkBlue, letterSpacing: -0.5)),
                    const SizedBox(height: 24),
                    
                    // The Pixel-Perfect Dot Progress Line
                    Row(
                      children: [
                        _buildDot(true),
                        _buildThickLine(true),
                        _buildDot(true),
                        _buildThickLine(false),
                        _buildDot(false, isOutline: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record['from'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: darkBlue)),
                            Text(record['dateRange'].split(' - ')[0], style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 12)),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record['to'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: darkBlue)),
                            Text(record['dateRange'].split(' - ')[1], style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Dealer: ${record['dealer']}', style: GoogleFonts.outfit(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThickLine(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        color: active ? Colors.black : Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildTrackingDetails(Size size) {
    if (_selectedTracking == null) { return const SizedBox(); }
    final record = _selectedTracking!;
    
    return Column(
      children: [
        // Top Info Box (Matches Right Screen in image)
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking id', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
                      Text(record['id'], style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: darkBlue)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                    child: Text('Transit', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildDot(true),
                  Expanded(child: _buildProgressLine(record['progress'])),
                  _buildDot(false, isOutline: true),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildDetailPoint('From', record['from'], '113345', true),
                  _buildDetailPoint('To', record['to'].replaceAll(' (EST)', ''), '14245', false),
                ],
              ),
            ],
          ),
        ),
        
        // Vertical Timeline Section
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            child: SingleChildScrollView(
              child: _buildVerticalTimeline(record['history']),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPoint(String label, String city, String code, bool isLeft) {
    return Expanded(
      child: Column(
        crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 11)),
          Text(city, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: darkBlue)),
          Text(code, style: GoogleFonts.outfit(color: Colors.grey[300], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDot(bool active, {bool isOutline = false}) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: active ? Colors.black : (isOutline ? const Color(0xFFFFF7EF) : Colors.black.withValues(alpha: 0.05)),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: active ? 0 : 2),
      ),
      child: active && !isOutline 
          ? const Center(child: Icon(Icons.check, color: Colors.white, size: 10))
          : null,
    );
  }

  Widget _buildProgressLine(double progress) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _buildAddForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader('New Tracking Record'),
          const SizedBox(height: 24),
          _buildMedlioField('Tracking ID', _idController, Icons.tag_rounded),
          _buildMedlioField('Dealer Name', _dealerController, Icons.business_rounded),
          _buildMedlioField('Date Range', _dateRangeController, Icons.calendar_today_rounded),
          const SizedBox(height: 40),
          _buildFormButtons('START TRACKING', _saveInvoice, _saveTracking),
        ],
      ),
    );
  }

  Widget _buildFilterForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader('Filter Tracking'),
          const SizedBox(height: 24),
          _buildMedlioField('Date Range', _dateRangeController, Icons.calendar_month_rounded),
          const Spacer(),
          _buildFormButtons('APPLY FILTER', _saveInvoice, () => setState(() => _currentView = TrackingView.viewList)),
        ],
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: darkBlue)),
        Text('Manage your delivery updates smoothly', style: GoogleFonts.outfit(fontSize: 14, color: Colors.blueGrey[300])),
      ],
    );
  }

  Widget _buildMedlioField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: darkBlue)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blueGrey[200], size: 20),
              hintText: 'Enter $label',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blueGrey[50]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blueGrey[50]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormButtons(String primaryLabel, VoidCallback invoiceAction, VoidCallback onPrimary) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _currentView = TrackingView.viewList),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blueGrey[100]!),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.blueGrey[400], fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onPrimary,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(primaryLabel, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
  
  // Placeholder to fix previous context lint
  void _saveInvoice() {}
}
