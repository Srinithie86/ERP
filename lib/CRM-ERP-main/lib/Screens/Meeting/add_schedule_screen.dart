import 'package:flutter/material.dart';
import '../../Models/schedule_api.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> { 
  final Color primaryPurple = const Color(0xFF26A69A);
  String? _selectedScheduleType;
  bool _isScheduleTypeExpanded = false;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _leadNoController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _assignedStaffController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _leadNoController.dispose();
    _phoneNoController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _assignedStaffController.dispose();
    _remarksController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: primaryPurple,
                    onPrimary: Colors.white,
                    surface: Theme.of(context).cardColor,
                  )
                : ColorScheme.light(
                    primary: primaryPurple,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: primaryPurple,
                    onPrimary: Colors.white,
                    surface: Theme.of(context).cardColor,
                  )
                : ColorScheme.light(
                    primary: primaryPurple,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Custom Expandable Selection
            GestureDetector(
              onTap: () {
                setState(() {
                  _isScheduleTypeExpanded = !_isScheduleTypeExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedScheduleType ?? 'Select Schedule Type',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
            if (_isScheduleTypeExpanded) ...[
              const SizedBox(height: 8),
              _buildScheduleOption('Direct'),
              const SizedBox(height: 8),
              _buildScheduleOption('Phone Call'),
              const SizedBox(height: 8),
              _buildScheduleOption('Video Call'),
            ],
            const SizedBox(height: 24),

            // Form Fields
            _buildTextField(
              label: 'Customer Name',
              controller: _customerNameController,
            ),
            const SizedBox(height: 20),
            _buildTextField(label: 'Lead No', controller: _leadNoController),
            const SizedBox(height: 20),
            _buildTextField(label: 'Phone No', controller: _phoneNoController),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Date',
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Time',
                    controller: _timeController,
                    readOnly: true,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Assigned Staff',
              controller: _assignedStaffController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Location',
              controller: _locationController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Address',
              controller: _addressController,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Remarks',
              maxLines: 5,
              controller: _remarksController,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSchedule() async {
    if (_customerNameController.text.isEmpty ||
        _phoneNoController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, Phone and Date are required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ScheduleApi.submitScheduleDetails({
        'cus_name': _customerNameController.text,
        'mobile_1': _phoneNoController.text,
        'meet_date': _dateController.text,
        'time': _timeController.text,
        'mode_of_meet': _selectedScheduleType ?? '',
        'loc': _locationController.text,
        'address': _addressController.text,
        'attended_by': _assignedStaffController.text,
        'feedback': _remarksController.text,
        'cid': _leadNoController.text, // Assuming Lead No is CID
      });

      if (mounted) {
        if (res['error'].toString() == 'false') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule details saved successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Failed to save schedule')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildScheduleOption(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedScheduleType = title;
          _isScheduleTypeExpanded = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: primaryPurple.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPurple),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
