import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:godrej_one_sdk/widgets/home_camera_widgets.dart';
import 'package:godrej_one_sdk/widgets/glassy_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.name, required this.asset});

  final String name;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            'images/home_screen_bg.png',
            package: 'godrej_one_sdk',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
      
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            asset,
                            package: 'godrej_one_sdk',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            children: [
                              Text(
                                'Hey, $name!',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'GEG',
                                  package: 'godrej_one_sdk',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Mumbai Home',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'GEG',
                                  package: 'godrej_one_sdk',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      HomeCameraWidgets(status: 1),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  GlassyContainer(
                    height: 85,
                    width: double.infinity,
                    title:
                        'Security system is armed away. All doors are locked. All gates are closed',
                    borderExists: true,
                    borderColor: Colors.green,
                  ),
                  SizedBox(height: 25.0),
                  Row(
                    spacing: 14,
                    children: const [
                      GlassyContainer(
                        flex: 1,
                        height: 150,
                        title: 'Energy Usage',
                        subtitle: '24.6 kWh',
                      ),
                      GlassyContainer(
                        flex: 1,
                        height: 150,
                        title: 'Indoor Temp',
                        subtitle: '24° C',
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  Row(
                    spacing: 14,
                    children: const [
                      GlassyContainer(
                        flex: 2,
                        height: 150,
                        title: 'Air Quality',
                        subtitle: '42',
                      ),
                      GlassyContainer(
                        flex: 5,
                        height: 150,
                        title: 'Main door lock',
                        subtitle: 'LOCKED',
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0),
                  GlassyContainer(
                    title: "Entrance Camera",
                    height: 200,
                    width: double.infinity,
                    imageExists: true,
                    imagePath: 'images/camera_dummy_img.png',
                  ),
                  SizedBox(height: 25.0),
                  Row(
                    spacing: 14,
                    children: const [
                      GlassyContainer(
                        flex: 1,
                        height: 150,
                        title: 'Video Door Bell',
                        subtitle: '24.6 kWh',
                      ),
                      GlassyContainer(
                        flex: 1,
                        height: 150,
                        title: 'Add Widgets',
                        subtitle: '24° C',
                      ),
                    ],
                  ),
                  SizedBox(height: 25.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
