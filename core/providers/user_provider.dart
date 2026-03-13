import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _userName = 'مستخدم';
  String _userEmail = '';
  String _userAvatar = '';
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _language = 'ar';

  late SharedPreferences _prefs;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userAvatar => _userAvatar;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  String get language => _language;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    _userName = _prefs.getString('userName') ?? 'مستخدم';
    _userEmail = _prefs.getString('userEmail') ?? '';
    _userAvatar = _prefs.getString('userAvatar') ?? '';
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
    _language = _prefs.getString('language') ?? 'ar';
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    await _prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> updateUserEmail(String email) async {
    _userEmail = email;
    await _prefs.setString('userEmail', email);
    notifyListeners();
  }

  Future<void> updateUserAvatar(String avatar) async {
    _userAvatar = avatar;
    await _prefs.setString('userAvatar', avatar);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _prefs.setBool('soundEnabled', _soundEnabled);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> clearUserData() async {
    await _prefs.clear();
    _userName = 'مستخدم';
    _userEmail = '';
    _userAvatar = '';
    _notificationsEnabled = true;
    _soundEnabled = true;
    _language = 'ar';
    notifyListeners();
  }
}
