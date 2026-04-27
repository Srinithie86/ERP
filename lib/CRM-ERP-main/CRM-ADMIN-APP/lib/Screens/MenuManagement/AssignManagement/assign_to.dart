import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AssignToScreen extends StatefulWidget {
  const AssignToScreen({super.key});

  @override
  State<AssignToScreen> createState() => _AssignToScreenState();
}

class _AssignToScreenState extends State<AssignToScreen> {
  final List<Map<String, dynamic>> _leads = [
    {'name': 'Robert Fox', 'company': 'Global Tech', 'status': 'Unassigned', 'date': 'Today'},
    {'name': 'Jane Cooper', 'company': 'Innovate Co', 'status': 'Unassigned', 'date': 'Yesterday'},
    {'name': 'Cody Fisher', 'company': 'Skyline Inc', 'status': 'Unassigned', 'date': '2 Days ago'},
    {'name': 'Bessie Cooper', 'company': 'NextGen Solutions', 'status': 'Unassigned', 'date': '3 Days ago'},
  ];

  final List<Map<String, dynamic>> _members = [
    {'name': 'John Smith', 'role': 'Sales Lead', 'active': true},
    {'name': 'Sarah Johnson', 'role': 'Senior Consultant', 'active': false},
    {'name': 'Mike Davis', 'role': 'Marketing Executive', 'active': true},
    {'name': 'Emily Chen', 'role': 'Support Agent', 'active': true},
  ];

  void _showAssignSheet(int leadIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignMemberSheet(
        leadName: _leads[leadIndex]['name'],
        members: _members,
        onAssign: (memberName) {
          setState(() {
            _leads[leadIndex]['status'] = 'Assigned to $memberName';
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lead assigned to $memberName successfully!'),
              backgroundColor: const Color(0xFF26A69A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Assign Leads',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: _leads.length,
        itemBuilder: (context, index) {
          final lead = _leads[index];
          final bool isAssigned = lead['status'] != 'Unassigned';

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isAssigned ? Colors.green : const Color(0xFF26A69A)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    lead['name'][0],
                    style: TextStyle(
                      color: isAssigned ? Colors.green : const Color(0xFF26A69A),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead['name'],
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead['company'],
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isAssigned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: isAssigned ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lead['status'],
                            style: TextStyle(
                              color: isAssigned ? Colors.green : Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isAssigned ? null : () => _showAssignSheet(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade100,
                    disabledForegroundColor: Colors.grey.shade400,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isAssigned ? 'Assigned' : 'Assign',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }
}

class _AssignMemberSheet extends StatelessWidget {
  final String leadName;
  final List<Map<String, dynamic>> members;
  final Function(String) onAssign;

  const _AssignMemberSheet({
    required this.leadName,
    required this.members,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 40, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Assign Lead',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              children: [
                const TextSpan(text: 'Assigning '),
                TextSpan(text: leadName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                const TextSpan(text: ' to a team member.'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ...members.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (m['active'] as bool) ? const Color(0xFF26A69A).withOpacity(0.1) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: (m['active'] as bool) ? const Color(0xFF26A69A) : Colors.grey,
                          size: 20,
                        ),
                      ),
                      if (m['active'] as bool)
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A1A))),
                  subtitle: Text(m['role'], style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
                  onTap: () => onAssign(m['name']),
                ),
              )),
        ],
      ),
    );
  }
}

