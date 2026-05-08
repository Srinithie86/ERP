import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hrm/utils/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await BackgroundFetchService.checkNow();
  });
}

class BackgroundFetchService {
  static Timer? _foregroundTimer;

  static Future<bool> checkNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cid = prefs.get('cid') ?? prefs.get('cid_str') ?? prefs.get('login_cid');
      String? uid = prefs.getString('uid') ?? prefs.getString('login_cus_id') ?? prefs.getString('server_uid');
      if (uid == null || uid.isEmpty) uid = prefs.get('uid')?.toString();
      if (uid == null || uid.isEmpty) uid = prefs.get('login_cus_id')?.toString();

      if (cid == null || uid == null) {
        debugPrint("BACKGROUND FETCH: CID or UID is missing. CID: $cid, UID: $uid");
        return true;
      }
      
      // LOG: Service is running
      debugPrint("BACKGROUND FETCH RUNNING for UID: $uid");
      
      final deviceId = prefs.getString('device_id') ?? "";
      final lat = (prefs.getDouble('lat') ?? 0.0).toString();
      final lng = (prefs.getDouble('lng') ?? 0.0).toString();

      // ===================================
      // Check Leave History (Type 2052)
      // ===================================
      final leaveBody = {
        "type": "2052",
        "uid": uid,
        "id": uid,
        "cid": cid.toString(),
        "device_id": deviceId,
        "lt": lat,
        "ln": lng,
      };

      final leaveRes = await http.post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: leaveBody);
      if (leaveRes.statusCode == 200) {
        final data = jsonDecode(leaveRes.body);
        if (data['error'].toString() == "false") {
           List fetchedList = [];
           if (data['data'] is List) {
             fetchedList = data['data'];
           } else if (data['data'] is Map) {
             fetchedList = data['data']['leave_applications'] ?? 
                           data['data']['history'] ?? 
                           data['data']['data'] ?? [];
           } else {
             fetchedList = data['leave_applications'] ?? data['data'] ?? [];
           }
           
           if (fetchedList is! List) fetchedList = [];

           String storedStr = prefs.getString('leave_status_map') ?? "{}";
           Map<String, dynamic> storedMap = jsonDecode(storedStr);
           bool changed = false;

           for (var item in fetchedList) {
             String leaveId = (item['id'] ?? item['leave_id'] ?? item['sl_no'] ?? "").toString();
             if (leaveId.isEmpty) continue;

             String status = (item['status'] ?? "").toString().toLowerCase();
             
             String readableStatus = "Pending";
             if (status == "1" || status == "accept" || status == "approved" || status.contains("approv") || status.contains("accept")) {
                readableStatus = "Approved";
             } else if (status == "2" || status == "reject" || status == "rejected" || status.contains("reject")) {
                readableStatus = "Rejected";
             }

             if (storedMap.containsKey(leaveId)) {
               if (storedMap[leaveId] == "Pending" && readableStatus != "Pending") {
                 debugPrint("TRIGGERING LEAVE NOTIFICATION: $readableStatus");
                 String leaveType = (item['leave_type'] ?? "Leave").toString();
                 String reason = (item['reason'] ?? "").toString();
                 await NotificationService().showInstantNotification(
                   title: "$leaveType Application",
                   body: "Status: $readableStatus | Reason: ${reason.isNotEmpty ? reason : 'N/A'}"
                 );
               }
             }
             if (storedMap[leaveId] != readableStatus) {
                storedMap[leaveId] = readableStatus;
                changed = true;
             }
           }
           if (changed) await prefs.setString('leave_status_map', jsonEncode(storedMap));
        }
      }

      // ===================================
      // Check Permission History (Type 2078)
      // ===================================
      final permissionBody = {
        "type": "2078",
        "uid": uid,
        "id": uid,
        "cid": cid.toString(),
        "device_id": deviceId,
        "lt": lat,
        "ln": lng,
      };

      final permRes = await http.post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: permissionBody);
      if (permRes.statusCode == 200) {
        final data = jsonDecode(permRes.body);
        if (data['error'].toString() == "false") {
           List fetchedList = [];
           if (data['data'] is List) {
             fetchedList = data['data'];
           } else if (data['data'] is Map) {
             fetchedList = data['data']['permission_history'] ?? 
                           data['data']['history'] ?? 
                           data['data']['data'] ?? [];
           } else {
             fetchedList = data['permission_history'] ?? data['data'] ?? [];
           }
           
           if (fetchedList is! List) fetchedList = [];

           String storedStr = prefs.getString('permission_status_map') ?? "{}";
           Map<String, dynamic> storedMap = jsonDecode(storedStr);
           bool changed = false;

            for (var item in fetchedList) {
              String permId = (item['id'] ?? item['permission_id'] ?? item['sl_no'] ?? "").toString();
              if (permId.isEmpty) continue;
              
              String status = (item['status'] ?? "").toString().toLowerCase();
              
              String readableStatus = "Pending";
              if (status == "1" || status == "accept" || status == "approved" || status.contains("approv") || status.contains("accept")) {
                 readableStatus = "Approved";
              } else if (status == "2" || status == "reject" || status == "rejected" || status.contains("reject")) {
                 readableStatus = "Rejected";
              }

              if (storedMap.containsKey(permId)) {
                if (storedMap[permId] == "Pending" && readableStatus != "Pending") {
                  debugPrint("TRIGGERING PERMISSION NOTIFICATION: $readableStatus");
                  await NotificationService().showInstantNotification(
                    title: "${item['permission_type_name'] ?? 'Permission'} Request",
                    body: "Status: $readableStatus | Reason: ${item['reason'] ?? 'N/A'}",
                    payload: "permission_history"
                  );
                }
              }
              if (storedMap[permId] != readableStatus) {
                 storedMap[permId] = readableStatus;
                 changed = true;
              }
            }
            if (changed) await prefs.setString('permission_status_map', jsonEncode(storedMap));
        }
      }

      // ===================================
      // Check Admin Approvals (Leave - 2093)
      // ===================================
      final adminLeaveBody = {
        "type": "2093",
        "cid": cid.toString(),
        "uid": uid,
        "reporting_manager": uid,
        "device_id": deviceId,
        "lt": lat,
        "ln": lng,
      };

      final adminLeaveRes = await http.post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: adminLeaveBody);
      if (adminLeaveRes.statusCode == 200) {
        final data = jsonDecode(adminLeaveRes.body);
        if (data['error'].toString() == "false") {
          List requests = [];
          if (data['team_leaves'] != null) {
            requests = data['team_leaves']['data'] ?? [];
          } else {
            requests = data['data'] ?? [];
          }

          String seenIdsStr = prefs.getString('admin_seen_leave_ids') ?? "[]";
          List<String> seenIds = List<String>.from(jsonDecode(seenIdsStr));
          bool newArrival = false;

          for (var req in requests) {
            String status = (req['status'] ?? "").toString().toLowerCase();
            if (status == "pending" || status == "0" || status == "") {
              String reqId = (req['id'] ?? "").toString();
              if (!seenIds.contains(reqId)) {
                // NEW REQUEST DETECTED
                await NotificationService().showInstantNotification(
                  title: "New Leave Request",
                  body: "Employee: ${req['employee_name'] ?? 'Unknown'} | Type: ${req['leave_type'] ?? 'General'}",
                  payload: "admin_approvals"
                );
                seenIds.add(reqId);
                newArrival = true;
              }
            }
          }
          if (newArrival) await prefs.setString('admin_seen_leave_ids', jsonEncode(seenIds));
        }
      }

      // ===================================
      // Check Admin Approvals (Permission - 2094)
      // ===================================
      final adminPermBody = {
        "type": "2094",
        "cid": cid.toString(),
        "uid": uid,
        "reporting_manager": uid,
        "device_id": deviceId,
        "lt": lat,
        "ln": lng,
      };

      final adminPermRes = await http.post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: adminPermBody);
      if (adminPermRes.statusCode == 200) {
        final data = jsonDecode(adminPermRes.body);
        if (data['error'].toString() == "false") {
          List requests = [];
          if (data['team_permissions'] != null) {
            requests = data['team_permissions']['data'] ?? [];
          } else {
            requests = data['data'] ?? [];
          }

          String seenIdsStr = prefs.getString('admin_seen_perm_ids') ?? "[]";
          List<String> seenIds = List<String>.from(jsonDecode(seenIdsStr));
          bool newArrival = false;

          for (var req in requests) {
            String status = (req['status'] ?? "").toString().toLowerCase();
            if (status == "pending" || status == "0" || status == "") {
              String reqId = (req['id'] ?? "").toString();
              if (!seenIds.contains(reqId)) {
                // NEW REQUEST DETECTED
                await NotificationService().showInstantNotification(
                  title: "New Permission Request",
                  body: "Employee: ${req['employee_name'] ?? 'Unknown'} | Reason: ${req['reason'] ?? 'N/A'}",
                  payload: "admin_approvals"
                );
                seenIds.add(reqId);
                newArrival = true;
              }
            }
          }
          if (newArrival) await prefs.setString('admin_seen_perm_ids', jsonEncode(seenIds));
        }
      }

      return true;
    } catch (e) {
      debugPrint("Background Fetch Error: $e");
      return false;
    }
  }

  static void init() {
    Workmanager().initialize(
      callbackDispatcher,
    );
    
    // Register periodic task (every 15 minutes is the minimum on Android)
    Workmanager().registerPeriodicTask(
      "1",
      "leave_permission_status_check",
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    // Foreground Timer for real-time updates (every 10 seconds)
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkNow();
    });
  }
}
