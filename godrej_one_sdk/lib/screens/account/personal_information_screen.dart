import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/photo.dart';
import 'package:godrej_one_sdk/providers/profile_store.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/profile_widgets.dart';

/// Edit the signed-in resident: photo, full name, in-app name, phone and
/// e-mail. Opens filled with what the app shows today; Update saves to
/// [ProfileStore], so every screen picks the change up at once.
class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  late final _store = context.read<ProfileStore>();
  late final _fullName = TextEditingController(text: _store.user.fullName);
  late final _name = TextEditingController(text: _store.user.name);
  late final _code = TextEditingController(text: _store.user.code);
  late final _mobile = TextEditingController(text: _store.user.mobile);
  late final _email = TextEditingController(text: _store.user.email);

  /// A photo picked but not yet saved with Update.
  String? _photo;

  /// Showing the camera / gallery choice in place of the form.
  bool _choosingPhoto = false;

  @override
  void dispose() {
    for (final c in [_fullName, _name, _code, _mobile, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final path = await _store.pickPhoto(source);
      if (!mounted) return;
      setState(() {
        if (path != null) _photo = path;
        _choosingPhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      showElegantToast(
        context,
        source == ImageSource.camera
            ? "Couldn't open the camera"
            : "Couldn't open the gallery",
      );
    }
  }

  void _update() {
    FocusScope.of(context).unfocus();
    final fullName = _fullName.text.trim();
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (fullName.isEmpty || name.isEmpty) {
      showElegantToast(context, 'Enter your name and in-app name');
      return;
    }
    if (email.isNotEmpty && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      showElegantToast(context, 'Enter a valid e-mail id');
      return;
    }
    _store.updateUser(
      _store.user.copyWith(
        fullName: fullName,
        name: name,
        code: _code.text.trim(),
        mobile: _mobile.text.trim(),
        email: email,
        image: _photo,
      ),
    );
    _photo = null;
    showElegantToast(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    final current = context.select<ProfileStore, String>((s) => s.user.image);
    return PopScope(
      // Back leaves the photo choice before it leaves the page.
      canPop: !_choosingPhoto,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _choosingPhoto = false);
      },
      child: ProfileSubpage(
        title: 'Personal Information',
        action: FormActionButton(
          label: 'Update',
          onTap: _choosingPhoto ? null : _update,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(32, 30, 32, 16),
          children: [
            Center(
              child: BadgedPhoto(
                icon: Icons.edit_square,
                label: 'Change photo',
                onTap: () => setState(() => _choosingPhoto = !_choosingPhoto),
                child: PhotoCircle(
                  image: photoImage(_photo ?? current),
                  size: 100,
                  ring: true,
                ),
              ),
            ),
            const SizedBox(height: 34),
            if (_choosingPhoto)
              PhotoSourceButtons(onPick: _pick)
            else ...[
              OutlinedField(
                label: 'Name',
                controller: _fullName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 22),
              OutlinedField(
                label: 'In app name',
                controller: _name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  SizedBox(
                    width: 92,
                    child: OutlinedField(
                      label: 'Code',
                      controller: _code,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlinedField(
                      label: 'Mobile Number',
                      controller: _mobile,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              OutlinedField(
                label: 'E-Mail id',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
