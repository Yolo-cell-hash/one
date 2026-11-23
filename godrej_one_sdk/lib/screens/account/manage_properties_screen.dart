import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:godrej_one_sdk/models/photo.dart';
import 'package:godrej_one_sdk/models/property.dart';
import 'package:godrej_one_sdk/providers/profile_store.dart';
import 'package:godrej_one_sdk/service/show_elegant_toast.dart';
import 'package:godrej_one_sdk/widgets/profile_widgets.dart';

const _brand = Color(0xFF810055);

const _text = TextStyle(
  fontFamily: 'GEG',
  package: 'godrej_one_sdk',
  color: _brand,
);

/// The resident's properties, each with an edit button that opens
/// [EditPropertyScreen].
class ManagePropertiesScreen extends StatelessWidget {
  const ManagePropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = context.watch<ProfileStore>().properties;
    final media = MediaQuery.of(context);
    final barHeight = (media.size.width * 0.19).clamp(66.0, 84.0);

    return ProfileSubpage(
      title: 'Manage Properties',
      body: ListView(
        padding: EdgeInsets.fromLTRB(26, 30, 26, barHeight / 2),
        children: [
          const Center(
            child: ProfileAvatar(
              size: 100,
              ring: true,
              openProfileOnTap: false,
            ),
          ),
          const SizedBox(height: 36),
          for (final (i, property) in properties.indexed) ...[
            _PropertyCard(
              property: property,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditPropertyScreen(index: i),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.onEdit});

  final Property property;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 28,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image(
                  image: property.thumbnailImage,
                  width: 128,
                  height: 90,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.4),
                  gaplessPlayback: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Semantics(
                container: true,
                button: true,
                label: 'Edit ${property.name}',
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_square, size: 19, color: _brand),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One property's photo, name and location. Update saves to
/// [ProfileStore], so the landing page and its properties list change too.
class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({super.key, required this.index});

  final int index;

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  late final _store = context.read<ProfileStore>();
  late final _property = _store.properties[widget.index];
  late final _name = TextEditingController(text: _property.name);
  late final _location = TextEditingController(text: _property.location);

  /// A photo picked but not yet saved with Update.
  String? _photo;

  /// Showing the camera / gallery choice in place of the form.
  bool _choosingPhoto = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
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
    final name = _name.text.trim();
    final location = _location.text.trim();
    if (name.isEmpty || location.isEmpty) {
      showElegantToast(context, 'Enter the property name and location');
      return;
    }
    _store.updateProperty(
      widget.index,
      _store.properties[widget.index].copyWith(
        name: name,
        location: location,
        photo: _photo,
      ),
    );
    showElegantToast(context, 'Property updated');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final property = context.select<ProfileStore, Property>(
      (s) => s.properties[widget.index],
    );
    return PopScope(
      canPop: !_choosingPhoto,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _choosingPhoto = false);
      },
      child: ProfileSubpage(
        title: 'Manage Properties',
        action: FormActionButton(
          label: 'Update',
          onTap: _choosingPhoto ? null : _update,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(32, 30, 32, 16),
          children: [
            Center(
              child: BadgedPhoto(
                icon: Icons.photo_camera_outlined,
                label: 'Change property photo',
                onTap: () => setState(() => _choosingPhoto = !_choosingPhoto),
                child: PhotoCircle(
                  image: _photo != null
                      ? photoImage(_photo!)
                      : property.thumbnailImage,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 34),
            if (_choosingPhoto)
              PhotoSourceButtons(onPick: _pick)
            else ...[
              OutlinedField(
                label: 'Property Name',
                controller: _name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 22),
              OutlinedField(
                label: 'Property Location',
                controller: _location,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
