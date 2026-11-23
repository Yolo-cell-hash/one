/// Where a device's product page lives: the device [deviceName] inside the
/// space [spaceId] (see `SpaceDetailScreen.open`).
class DevicePage {
  const DevicePage(this.spaceId, this.deviceName);

  final String spaceId;
  final String deviceName;
}

/// How a device is doing — the dot on its card.
enum DeviceHealth {
  /// Working normally: a green dot.
  ok,

  /// Needs attention soon, e.g. a low battery: a yellow dot.
  warning,

  /// Can't be reached: a red dot.
  offline,
}

/// A device's card on the Home tab.
class HomeDevice {
  const HomeDevice({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.imageTop,
    required this.imageRight,
    required this.imageHeight,
    this.page,
    this.health = DeviceHealth.ok,
    this.alert,
  });

  final String id;
  final String name;

  /// Where it's fitted — "Main door", "Kids bedroom".
  final String location;

  /// Product shot, cropped to the product, drawn at the card's right: this
  /// far from its top and right edges, at this height.
  final String image;
  final double imageTop;
  final double imageRight;
  final double imageHeight;

  /// The device's product page; `null` until it has one.
  final DevicePage? page;

  final DeviceHealth health;

  /// What's wrong, for the Home banner, when [health] isn't
  /// [DeviceHealth.ok]. `{name}` stands for the device's current name.
  final String? alert;

  String alertFor(String name) => (alert ?? '').replaceAll('{name}', name);

  HomeDevice renamed(String name) => HomeDevice(
    id: id,
    name: name,
    location: location,
    image: image,
    imageTop: imageTop,
    imageRight: imageRight,
    imageHeight: imageHeight,
    page: page,
    health: health,
    alert: alert,
  );

  static const demo = [
    HomeDevice(
      id: 'iot9',
      name: 'IoT 9',
      location: 'Main door',
      image: 'images/devices/home/iot9.png',
      imageTop: 15,
      imageRight: 16,
      imageHeight: 85,
      page: DevicePage('entrance', 'Main Door Lock'),
    ),
    HomeDevice(
      id: 'vdb',
      name: 'VDB',
      location: 'Main door',
      image: 'images/devices/home/vdb.png',
      imageTop: 21,
      imageRight: 25,
      imageHeight: 71,
      page: DevicePage('entrance', 'VDB'),
    ),
    HomeDevice(
      id: 'gsl_d1',
      name: 'GSL D1',
      location: 'Back door',
      image: 'images/devices/home/gsl_d1.png',
      imageTop: 17,
      imageRight: 17,
      imageHeight: 88,
      page: DevicePage('back_door', 'GSL D1'),
      health: DeviceHealth.warning,
      alert: 'Backdoor battery is low. Change within 15 days.',
    ),
    HomeDevice(
      id: 'nx_pro',
      name: 'NX Pro',
      location: 'Master\nbedroom',
      image: 'images/devices/home/nx_pro.png',
      imageTop: 36,
      imageRight: 18,
      imageHeight: 43,
    ),
    HomeDevice(
      id: 'eve_bullet',
      name: 'Eve Pro 4G Bullet',
      location: 'Main door',
      image: 'images/devices/home/eve_pro_4g_bullet.png',
      imageTop: 32,
      imageRight: 16,
      imageHeight: 60,
      page: DevicePage('entrance', 'Entrance Camera'),
    ),
    HomeDevice(
      id: 'eve_mini_pt',
      name: 'Eve Pro 4G Mini-PT',
      location: 'Back door',
      image: 'images/devices/home/eve_pro_4g_mini_pt.png',
      imageTop: 36,
      imageRight: 18,
      imageHeight: 60,
      page: DevicePage('back_door', 'Eve Pro 4G Mini-PT'),
    ),
    HomeDevice(
      id: 'astron',
      name: 'Astron',
      location: 'Master bedroom',
      image: 'images/devices/home/astron.png',
      imageTop: 27,
      imageRight: 19,
      imageHeight: 61,
      health: DeviceHealth.offline,
      alert: '{name} is offline. Check its power and Wi-Fi connection.',
    ),
    HomeDevice(
      id: 'rion',
      name: 'Rion',
      location: 'Kids bedroom',
      image: 'images/devices/home/rion.png',
      imageTop: 29,
      imageRight: 20,
      imageHeight: 57,
    ),
  ];
}
