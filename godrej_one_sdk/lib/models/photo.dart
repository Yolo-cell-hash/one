import 'dart:io';

import 'package:flutter/painting.dart';

/// A photo the app shows: either one of the SDK's own assets (a path under
/// `images/`) or a picture the user took or picked, saved as a file on the
/// device.
ImageProvider photoImage(String path) => isAssetPhoto(path)
    ? AssetImage(path, package: 'godrej_one_sdk')
    : FileImage(File(path));

bool isAssetPhoto(String path) => path.startsWith('images/');
