import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/erp_login_api.dart';

class MenuProvider extends ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _menuData = {};

  Map<String, List<Map<String, dynamic>>> get menuData => _menuData;

  List<String> get moduleTitles => _menuData.keys.map((k) => k.trim()).toList();

  List<dynamic> get menuItems {
    return _menuData.keys.map((key) {
      return ModuleItem(key.trim());
    }).toList();
  }

  /// Update the entire menu structure
  void setMenu(dynamic rawMenu) {
    _menuData = {};
    if (rawMenu is Map) {
      rawMenu.forEach((key, value) {
        if (value is List) {
          _menuData[key.trim()] = List<Map<String, dynamic>>.from(value);
        }
      });
    } else if (rawMenu is List) {
      // If it's a list, treat each element as a module
      for (var item in rawMenu) {
        if (item is Map && item.containsKey('name')) {
          _menuData[item['name'].toString().trim()] = [];
        }
      }
    }
    notifyListeners();
    _saveToPrefs();
  }

  /// Get sub-menus for a specific module (e.g., "PURCHASE")
  List<Map<String, dynamic>> getSubMenus(String moduleName) {
    // API keys are often uppercase with spaces, e.g., "PURCHASE", "ACCOUNTING ", " E-COMMERCE"
    // We try to match with normalized keys
    final normalizedKey = _findMatchingKey(moduleName);
    return _menuData[normalizedKey] ?? [];
  }

  /// Check if a menu item name matches a key in the menu and has children (is a Folder)
  bool isFolder(String itemName) {
    return _findMatchingKey(itemName) != null;
  }

  /// Get the children of a specific folder
  List<Map<String, dynamic>> getFolderContents(String folderName) {
    final key = _findMatchingKey(folderName);
    return key != null ? (_menuData[key] ?? []) : [];
  }

  /// Check if a module should be visible in the main grid
  bool isModuleVisible(String moduleName) {
    return _findMatchingKey(moduleName) != null;
  }

  /// Check if a sub-menu or action should be visible within a module
  bool isSubMenuVisible(String moduleName, String subMenuName) {
    final parentKey = _findMatchingKey(moduleName);
    if (parentKey == null) return false;

    final subMenus = _menuData[parentKey];
    if (subMenus == null || subMenus.isEmpty) return false;

    final searchSub = subMenuName.trim().toUpperCase();
    for (final item in subMenus) {
      final name = item['name']?.toString().trim().toUpperCase() ?? '';
      if (name == searchSub) return true;
      
      // Also handle cases where UI label might be "Create PR" but API is "Purchase Request "
      // We can add some common aliases if needed, but strict matching is safer.
    }
    return false;
  }

  String? _findMatchingKey(String moduleName) {
    final search = moduleName.trim().toUpperCase();
    
    // Exact match or simple trim match
    for (final key in _menuData.keys) {
      if (key.trim().toUpperCase() == search) return key;
    }

    // Explicit Mapping for common differences
    final mapping = {
      'DEALER MGMT': 'DEALER MANAGEMENT',
      'ECOMMERCE': ' E-COMMERCE',
      'PURCHASE': 'PURCHASE', // redundant but safe
      'SALES': 'SALES',
      'ACCOUNTING': 'ACCOUNTING ',
    };

    if (mapping.containsKey(search)) {
      final targetKey = mapping[search]!;
      for (final key in _menuData.keys) {
        if (key.toUpperCase() == targetKey.toUpperCase()) return key;
      }
    }

    return null;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_menu_data', json.encode(_menuData));
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('user_menu_data');
    if (saved != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(saved);
        setMenu(decoded);
      } catch (e) {
        debugPrint("Error loading menu from prefs: $e");
      }
    } else {
      // If no local menu, try fetching from server if we have credentials
      await fetchMenuFromServer();
    }
  }

  /// Fetch menu from server using stored credentials
  Future<void> fetchMenuFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? prefs.getString('cid_str') ?? '';
      final roleId = prefs.getString('role_id') ?? '1';
      final deviceId = prefs.getString('device_id') ?? '1';
      final lat = prefs.getString('lt') ?? '123';
      final lng = prefs.getString('ln') ?? '145';

      if (cid.isEmpty) {
        debugPrint("MenuProvider => Cannot fetch menu: CID is missing");
        return;
      }

      final response = await ErpLoginApi.fetchMenu(
        cid: cid,
        roleId: roleId,
        deviceId: deviceId,
        lat: lat,
        lng: lng,
      );

      if (response['success'] == true && response['menu'] != null) {
        setMenu(response['menu']);
        debugPrint("MenuProvider => Successfully refreshed menu from server");
      } else {
        debugPrint("MenuProvider => Failed to fetch menu: ${response['message']}");
      }
    } catch (e) {
      debugPrint("MenuProvider => Error fetching menu: $e");
    }
  }
}

class ModuleItem {
  final String title;
  ModuleItem(this.title);
}
