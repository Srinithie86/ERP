import 'package:flutter/material.dart';

class TaskManagementView extends StatefulWidget {
  const TaskManagementView({super.key});

  @override
  State<TaskManagementView> createState() => _TaskManagementViewState();
}

class _TaskManagementViewState extends State<TaskManagementView> {
  final Color primaryColor = const Color(0xFF26A69A);
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Review New Lead Approvals',
      'priority': 'High',
      'due': 'Today, 2:00 PM',
      'status': 'Pending',
      'category': 'Approval'
    },
    {
      'title': 'Generate Weekly Sales Report',
      'priority': 'Medium',
      'due': 'Tomorrow, 10:00 AM',
      'status': 'Pending',
      'category': 'Reports'
    },
    {
      'title': 'Update Campaign Strategy',
      'priority': 'Low',
      'due': 'Apr 12, 2024',
      'status': 'In Progress',
      'category': 'Marketing'
    },
    {
      'title': 'Team Performance Review',
      'priority': 'High',
      'due': 'Apr 15, 2024',
      'status': 'Planned',
      'category': 'Management'
    },
    {
      'title': 'Server Maintenance Notice',
      'priority': 'Medium',
      'due': 'Apr 11, 2024',
      'status': 'Completed',
      'category': 'System'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskHeader(),
          _buildFilterChips(),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Task Overview",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard('24', 'Total', Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard('12', 'Pending', Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard('08', 'Completed', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Approvals', 'Marketing', 'Systems'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedFilter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filters[index]),
              selectedColor: primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? primaryColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? primaryColor : Colors.grey.shade200),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task['priority']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task['priority'],
                      style: TextStyle(
                        color: _getPriorityColor(task['priority']),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    task['due'],
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task['title'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    task['category'],
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: _getStatusColor(task['status']),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task['status'],
                          style: TextStyle(
                            color: _getStatusColor(task['status']),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String p) {
    if (p == 'High') return Colors.red;
    if (p == 'Medium') return Colors.orange;
    return Colors.blue;
  }

  Color _getStatusColor(String s) {
    if (s == 'Completed') return Colors.green;
    if (s == 'Pending') return Colors.orange;
    if (s == 'In Progress') return Colors.blue;
    return Colors.grey;
  }
}
