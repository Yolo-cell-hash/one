import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:godrej_one_sdk/models/photo.dart';
import 'package:godrej_one_sdk/models/property.dart';
import 'package:godrej_one_sdk/service/user_name_onboarding_handler.dart';

/// The signed-in resident and their properties: who the app greets, whose
/// photo it shows, and which property is selected.
///
/// The single source of truth for them, provided above the whole app, so an
/// edit made in Profile shows up on every screen at once. Edits are saved on
/// the device and restored by [load] on the next launch.
class ProfileStore extends ChangeNotifier {
  static const _usersKey = 'profile.users';
  static const _propertiesKey = 'profile.properties';
  static const _propertyIndexKey = 'profile.propertyIndex';
  static const _deviceNamesKey = 'home.deviceNames';
  static const _hiddenDevicesKey = 'home.hiddenDevices';

  List<OnboardingUser> _users = UserNameOnboardingHandler.users;
  List<Property> _properties = Property.defaults;

  /// Which resident is signed in. Switching residents isn't built yet.
  final int _userIndex = 0;
  int _propertyIndex = 0;

  OnboardingUser get user => _users[_userIndex];

  /// Replaced, never changed in place, so a new list means new data.
  List<Property> get properties => _properties;
  int get propertyIndex => _propertyIndex;
  Property get property => _properties[_propertyIndex];

  /// Names the resident gave Home's devices, by device id.
  Map<String, String> _deviceNames = {};

  /// Devices the resident hid from Home; still in their spaces.
  Set<String> _hiddenDevices = {};

  String? deviceName(String id) => _deviceNames[id];
  bool isHidden(String id) => _hiddenDevices.contains(id);
  int get hiddenCount => _hiddenDevices.length;

  void renameDevice(String id, String name) {
    _deviceNames = {..._deviceNames, id: name};
    notifyListeners();
    _save();
  }

  void hideDevice(String id) {
    _hiddenDevices = {..._hiddenDevices, id};
    notifyListeners();
    _save();
  }

  void showHiddenDevices() {
    _hiddenDevices = {};
    notifyListeners();
    _save();
  }

  /// Restores saved edits. Anything missing or unreadable — including a
  /// photo file that's since been deleted — falls back to the defaults.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getString(_usersKey);
      if (users != null) {
        final restored = [
          for (final json in jsonDecode(users) as List)
            OnboardingUser.fromJson((json as Map).cast()),
        ];
        const defaults = UserNameOnboardingHandler.users;
        _users = [
          for (final (i, u) in restored.indexed)
            u.copyWith(
              image: _onDisk(u.image, defaults[i % defaults.length].image),
            ),
        ];
      }
      final properties = prefs.getString(_propertiesKey);
      if (properties != null) {
        final restored = [
          for (final json in jsonDecode(properties) as List)
            Property.fromJson((json as Map).cast()),
        ];
        const defaults = Property.defaults;
        _properties = [
          for (final (i, p) in restored.indexed)
            _onDisk(p.photo, '') == p.photo
                ? p
                : defaults[i % defaults.length].copyWith(
                    name: p.name,
                    location: p.location,
                  ),
        ];
      }
      final names = prefs.getString(_deviceNamesKey);
      if (names != null) {
        _deviceNames = (jsonDecode(names) as Map).cast<String, String>();
      }
      _hiddenDevices = {...?prefs.getStringList(_hiddenDevicesKey)};
      final index = prefs.getInt(_propertyIndexKey) ?? 0;
      _propertyIndex = index.clamp(0, _properties.length - 1);
      notifyListeners();
    } catch (error) {
      debugPrint('ProfileStore: keeping defaults ($error)');
    }
  }

  /// [photo], or [fallback] if it was a picked photo that's since gone.
  static String _onDisk(String photo, String fallback) =>
      isAssetPhoto(photo) || File(photo).existsSync() ? photo : fallback;

  void selectProperty(int index) {
    if (index == _propertyIndex) return;
    _propertyIndex = index;
    notifyListeners();
    _save();
  }

  void updateUser(OnboardingUser user) {
    final old = _users[_userIndex];
    _users = [..._users]..[_userIndex] = user;
    notifyListeners();
    _save();
    _deleteReplaced(old.image, user.image);
  }

  void updateProperty(int index, Property property) {
    final old = _properties[index];
    _properties = [..._properties]..[index] = property;
    notifyListeners();
    _save();
    _deleteReplaced(old.photo, property.photo);
  }

  /// Takes a photo with the camera or picks one from the gallery, and keeps
  /// a copy in the app's own storage so it outlives the picker's cache.
  /// Returns its path, or `null` if the user backed out.
  Future<String?> pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 88,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final photos = Directory('${dir.path}/photos');
    await photos.create(recursive: true);
    final ext = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    // A new name each time, so the image cache never shows the old photo.
    final path = '${photos.path}/${DateTime.now().microsecondsSinceEpoch}$ext';
    await File(picked.path).copy(path);
    return path;
  }

  /// Removes a photo the user had picked once nothing points to it.
  void _deleteReplaced(String oldPhoto, String newPhoto) {
    if (oldPhoto == newPhoto || isAssetPhoto(oldPhoto)) return;
    final stillUsed =
        _users.any((u) => u.image == oldPhoto) ||
        _properties.any((p) => p.photo == oldPhoto);
    if (!stillUsed) File(oldPhoto).delete().ignore();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _usersKey,
        jsonEncode([for (final u in _users) u.toJson()]),
      );
      await prefs.setString(
        _propertiesKey,
        jsonEncode([for (final p in _properties) p.toJson()]),
      );
      await prefs.setInt(_propertyIndexKey, _propertyIndex);
      await prefs.setString(_deviceNamesKey, jsonEncode(_deviceNames));
      await prefs.setStringList(_hiddenDevicesKey, [..._hiddenDevices]);
    } catch (error) {
      debugPrint('ProfileStore: could not save ($error)');
    }
  }
}
