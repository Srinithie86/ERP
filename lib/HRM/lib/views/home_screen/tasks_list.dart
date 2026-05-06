import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_client.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  Timer? _timer;
  bool _isLoading = true;
  List<Map<String, dynamic>> tasks = [];
  bool _isFirstLoad = true;

  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFirstLoad) {
      _fetchTasks();
    }
    _isFirstLoad = false;
  }

  Future<void> _fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? prefs.getString('cid_str') ?? "21472147";
      final String uid =
          prefs.getString('login_cus_id') ??
          prefs.getString('employee_table_id') ??
          prefs.getString('uid') ??
          "54";
      
      final body = {
        "type": "2075",
        "cid": cid,
        "uid": uid,
        "cus_id": uid,
        "id": uid,
      };

      debugPrint("Fetching tasks (Type 2075) body: $body");

      final response = await ApiClient().post(body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["error"] == false) {
          final summaryData = data["summary"];
          final tasksMap = data["data"] ?? {};
          
          List<dynamic> allTasks = [];
          if (tasksMap is Map) {
            allTasks.addAll(tasksMap["pending"] ?? []);
            allTasks.addAll(tasksMap["partial"] ?? []);
            allTasks.addAll(tasksMap["completed"] ?? []);
          }

          List<Map<String, dynamic>> processedTasks = [];
          for (var t in allTasks) {
            final String taskId = t["task_id"].toString();

            final String? localStatus = prefs.getString("task_status_$taskId");
            final int? localSeconds = prefs.getInt("task_seconds_$taskId");
            final bool isRunningLocal = prefs.getBool("task_is_running_$taskId") ?? false;
            final String? startTimeStr = prefs.getString("task_start_time_$taskId");

            final String apiStatus = (t["status"] ?? "pending").toString().toLowerCase();
            final String currentStatus = (localStatus ?? apiStatus).toLowerCase();

            bool isDoneStatus = currentStatus == "done" || currentStatus == "completed" || currentStatus == "1";
            bool isPartial = currentStatus == "partial" || currentStatus == "2";
            bool isPendingStatus = !isDoneStatus;

            int apiSeconds = _parseTimeStringToSeconds(t["spending_time"] ?? "00:00:00");
            int baseSeconds = (localSeconds != null && localSeconds > apiSeconds) ? localSeconds : apiSeconds;
            
            int finalSeconds = baseSeconds;
            if (isRunningLocal && startTimeStr != null) {
              DateTime startTime = DateTime.parse(startTimeStr);
              finalSeconds = baseSeconds + DateTime.now().difference(startTime).inSeconds;
            }

            processedTasks.add({
              "id": taskId,
              "title": t["task_name"] ?? "Untitled Task",
              "deadline": t["due_date"] ?? "N/A",
              "task_timing": t["task_timing"] ?? "00:00:00",
              "priority": t["priority"] ?? "N/A",
              "isPending": isPendingStatus,
              "elapsedSeconds": finalSeconds,
              "baseSeconds": baseSeconds, // Saved seconds before this session
              "isRunning": isRunningLocal,
              "startTimeStr": startTimeStr,
              "timeLimitSeconds": _parseTimeStringToSeconds(t["task_timing"] ?? "00:00:00"),
              "isPartiallyCompleted": isPartial,
              "partialReason": t["reason"] ?? t["remarks"] ?? "",
              "isPartialSubmitted": isPartial,
              "approvalStatus": t["approval_status"]?.toString(),
              "assignedBy": t["assigned_by"] ?? "N/A",
            });
          }

          setState(() {
            _summary = summaryData;
            tasks = processedTasks;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("API Error: $e");
      setState(() => _isLoading = false);
    }
  }

  int _parseTimeStringToSeconds(String timeString) {
    if (timeString.isEmpty || timeString == "null") return 0;
    try {
      List<String> parts = timeString.split(':');
      if (parts.length == 3) {
        int h = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        int s = int.parse(parts[2]);
        return (h * 3600) + (m * 60) + s;
      }
    } catch (_) {}
    return 0;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted) {
        setState(() {
          for (var task in tasks) {
            if (task["isRunning"] == true) {
              final String? startTimeStr = task["startTimeStr"];
              if (startTimeStr != null) {
                DateTime startTime = DateTime.parse(startTimeStr);
                task["elapsedSeconds"] = (task["baseSeconds"] ?? 0) + DateTime.now().difference(startTime).inSeconds;
              } else {
                // Fallback for tasks already marked running from prefs but no startTimeStr in map
                task["elapsedSeconds"] = (task["elapsedSeconds"] ?? 0) + 1;
              }
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildSummaryRow() {
    if (_summary == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            _buildSummaryCard("Pending", _summary!["pending"]?.toString() ?? "0", const Color(0xFFE57373), Icons.pending_actions),
            SizedBox(width: 12.w),
            _buildSummaryCard("Partial", _summary!["partial"]?.toString() ?? "0", const Color(0xFFFFB74D), Icons.hourglass_top),
            SizedBox(width: 12.w),
            _buildSummaryCard("Done", _summary!["completed"]?.toString() ?? "0", const Color(0xFF81C784), Icons.check_circle_outline),
            SizedBox(width: 12.w),
            _buildSummaryCard("Total", _summary!["total"]?.toString() ?? "0", const Color(0xFF64B5F6), Icons.assignment),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Task Management",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2D3748)),
            onPressed: _fetchTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF26A69A)),
            )
          : Column(
              children: [
                _buildSummaryRow(),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            "No tasks found",
                            style: GoogleFonts.poppins(fontSize: 16.sp),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(20.w),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            if (task["approvalStatus"] == 'approved') {
                              return const SizedBox.shrink();
                            }
                            return _buildTaskItem(
                              task,
                              onPartialToggle: () {
                                if (!task["isPending"]) return;
                                setState(() {
                                  task["isPartiallyCompleted"] = true;
                                  task["isPending"] = true;
                                  task["isRunning"] = false;
                                  task["isPartialSubmitted"] = false;
                                });
                              },
                              onPartialSubmit: () async {
                                await _updateTaskOnBackend(
                                  task,
                                  status: "partial",
                                  remarks: task["partialReason"] ?? "",
                                );
                                setState(() {
                                  task["isPartialSubmitted"] = true;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Partial status updated!"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                                _fetchTasks(); // Refresh counts
                              },
                              onToggle: (bool val) async {
                                if (!val) {
                                  await _updateTaskOnBackend(
                                    task,
                                    status: "done",
                                    remarks: "Task completed",
                                  );
                                  setState(() {
                                    task["isPending"] = false;
                                    task["isRunning"] = false;
                                    task["isPartiallyCompleted"] = false;
                                    task["approvalStatus"] = 'pending';
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Task marked as completed!"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                  _fetchTasks(); // Refresh counts
                                } else {
                                  setState(() {
                                    task["isPending"] = true;
                                    task["isPartiallyCompleted"] = false;
                                    task["approvalStatus"] = null;
                                  });
                                }
                              },
                              onTimerToggle: () async {
                                final prefs = await SharedPreferences.getInstance();
                                String nowStr = DateTime.now().toIso8601String();
                                
                                setState(() {
                                  // Stop other timers logic - optional, but usually one task at a time
                                  for (var t in tasks) {
                                    if (t["isRunning"] == true && t["id"] != task["id"]) {
                                      // Logic to stop others would go here if needed
                                    }
                                  }
                                  
                                  task["isRunning"] = true;
                                  task["startTimeStr"] = nowStr;
                                  task["baseSeconds"] = task["elapsedSeconds"] ?? 0;
                                });

                                // Persist state
                                await prefs.setBool("task_is_running_${task["id"]}", true);
                                await prefs.setString("task_start_time_${task["id"]}", nowStr);
                                await prefs.setInt("task_seconds_${task["id"]}", task["elapsedSeconds"] ?? 0);

                                await _updateTaskOnBackend(task, status: "started");
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _updateTaskOnBackend(
    Map<String, dynamic> task, {
    required String status,
    String remarks = "",
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? prefs.getString('cid_str') ?? "21472147";
      final String uid =
          prefs.getString('employee_table_id') ??
          prefs.getString('login_cus_id') ??
          prefs.getString('server_uid') ??
          prefs.getString('uid') ??
          prefs.getInt('uid')?.toString() ??
          "";
      final String deviceId = prefs.getString('device_id') ?? "123456";
      final String lat = prefs.getDouble('lat')?.toString() ?? "0.0";
      final String lng = prefs.getDouble('lng')?.toString() ?? "0.0";
      final String? token = prefs.getString('token');

      // Map status strings to numeric values as required by backend example
      String finalStatus = status;
      if (status == "done" || status == "completed") {
        finalStatus = "1";
      } else if (status == "partial") {
        finalStatus = "2";
      }

      final body = {
        "type": "2074",
        "cid": cid,
        "uid": uid,
        "task_id": task["id"].toString(),
        "status": finalStatus,
        "token": token ?? "",
        "device_id": deviceId,
        "ln": lng,
        "lt": lat,
        "spending_time": _formatDuration(task["elapsedSeconds"] ?? 0),
        "reason": remarks,
        "completion_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      await prefs.setString("task_status_${task["id"]}", status);
      if (status == "partial" || status == "done" || status == "completed") {
        await prefs.setBool("task_is_running_${task["id"]}", false);
        await prefs.remove("task_start_time_${task["id"]}");
        await prefs.setInt("task_seconds_${task["id"]}", task["elapsedSeconds"] ?? 0);
      }
      
      if (status == "partial") {
        await prefs.setString("task_remarks_${task["id"]}", remarks);
      }

      debugPrint("Updating Task (Type 2074) Request Body: $body");

      final response = await ApiClient().post(body);

      debugPrint("Updating Task (Type 2074) Response Body: ${response.body}");
    } catch (e) {
      debugPrint("Error updating task on backend: $e");
    }
  }

  Widget _buildTaskItem(
    Map<String, dynamic> task, {
    required VoidCallback onTimerToggle,
    required VoidCallback onPartialToggle,
    required VoidCallback onPartialSubmit,
    required Function(bool) onToggle,
  }) {
    final String title = task["title"] ?? "Task";
    final String deadline = task["deadline"] ?? "";
    final String taskTiming = task["task_timing"] ?? "";
    final bool isPending = task["isPending"] ?? true;
    final int elapsedSeconds = task["elapsedSeconds"] ?? 0;
    final bool isRunning = task["isRunning"] ?? false;
    final int timeLimitSeconds = task["timeLimitSeconds"] ?? 0;
    final bool isPartiallyCompleted = task["isPartiallyCompleted"] ?? false;
    final String partialReason = task["partialReason"] ?? "";
    final String? approvalStatus = task["approvalStatus"];
    final bool isPartialSubmitted = task["isPartialSubmitted"] ?? false;

    bool isOvertime = timeLimitSeconds > 0 && elapsedSeconds > timeLimitSeconds;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isOvertime)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 12.sp, color: Colors.red),
                      SizedBox(width: 4.w),
                      Text(
                        "OVERTIME",
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isRunning ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isRunning ? "ACTIVE NOW" : "ASSIGNED",
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: isRunning ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              Text(
                deadline,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A202C),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _infoTile(Icons.person_outline, task['assignedBy'], "Assigned By"),
              SizedBox(width: 20.w),
              _infoTile(Icons.timer_outlined, taskTiming, "Target Time"),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Time Spent",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDuration(elapsedSeconds),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: isOvertime ? Colors.red : (isRunning ? Colors.green : const Color(0xFF2D3748)),
                      ),
                    ),
                  ],
                ),
                if (isPending)
                  GestureDetector(
                    onTap: isRunning ? null : onTimerToggle,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: isRunning 
                          ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600])
                          : LinearGradient(colors: [const Color(0xFF4A90E2), const Color(0xFF357ABD)]),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: (isRunning ? Colors.green : Colors.blue).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(isRunning ? Icons.pause_circle_filled : Icons.play_arrow_rounded, color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            isRunning ? "Running" : "Start Task",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: _statusActionButton(
                    "Partial",
                    isPartiallyCompleted,
                    const Color(0xFFFFB74D),
                    isPartiallyCompleted ? Icons.pause_circle_filled : Icons.pause_circle_outline,
                    onPartialToggle,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: _statusActionButton(
                  "Completed",
                  !isPending,
                  const Color(0xFF48BB78),
                  !isPending ? Icons.check_circle : Icons.check_circle_outline,
                  isPending ? () => onToggle(false) : null,
                ),
              ),
            ],
          ),
          if (isPartiallyCompleted && !isPartialSubmitted) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1),
            ),
            Text(
              "Reason & Pending Info",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B2C61),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              onChanged: (val) => setState(() => task["partialReason"] = val),
              controller: TextEditingController(text: partialReason)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: partialReason.length),
                ),
              maxLines: 2,
              style: GoogleFonts.poppins(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "Enter why it's pending...",
                contentPadding: EdgeInsets.all(12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPartialSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  "Submit Partial Info",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          if (isPartialSubmitted && isPartiallyCompleted)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_done,
                      color: Colors.orange.shade800,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        "Partial Info Submitted to Backend",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (approvalStatus != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: approvalStatus == 'pending'
                      ? Colors.blue.shade50
                      : (approvalStatus == 'approved'
                            ? Colors.green.shade50
                            : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      approvalStatus == 'pending'
                          ? Icons.hourglass_empty
                          : (approvalStatus == 'approved'
                                ? Icons.verified
                                : Icons.cancel),
                      color: approvalStatus == 'pending'
                          ? Colors.blue
                          : (approvalStatus == 'approved'
                                ? Colors.green
                                : Colors.red),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        approvalStatus == 'pending'
                            ? "Waiting for TL Approval"
                            : (approvalStatus == 'approved'
                                  ? "Task Approved"
                                  : "Task Rejected"),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: Colors.grey.shade400),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A5568),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _statusActionButton(
    String label,
    bool isActive,
    Color color,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade200,
            width: 1.5.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isActive ? color : Colors.grey.shade400,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isActive ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
