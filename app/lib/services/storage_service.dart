import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

/// 💾 StorageService: Manages local offline device persistence for reframed history & favorites.
class StorageService {
  static const String _storageKey = 'silver_lining_history_v1';

  /// Loads all history items saved on the device.
  static Future<List<HistoryItem>> loadHistoryItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => HistoryItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves a new history item to the top of the local storage list.
  static Future<bool> saveHistoryItem(HistoryItem newItem) async {
    try {
      final items = await loadHistoryItems();
      items.insert(0, newItem); // Add to top of history list

      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Toggles favorite status of an item by ID.
  static Future<bool> toggleFavorite(String id) async {
    try {
      final items = await loadHistoryItems();
      for (final item in items) {
        if (item.id == id) {
          item.isFavorite = !item.isFavorite;
          break;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Deletes a history item by ID.
  static Future<bool> deleteHistoryItem(String id) async {
    try {
      final items = await loadHistoryItems();
      items.removeWhere((item) => item.id == id);

      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(items.map((i) => i.toJson()).toList());
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Clears all local history data.
  static Future<bool> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }
}
