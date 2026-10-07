import 'package:flutter/material.dart';

class MySpacesCard extends StatefulWidget {
  const MySpacesCard({
    super.key,
    required this.img_path,
    required this.label,
    required this.id,
    required this.handleClick,
  });

  final String img_path, label, id;
  final VoidCallback handleClick;

  @override
  State<MySpacesCard> createState() => _MySpacesCardState();
}

class _MySpacesCardState extends State<MySpacesCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.handleClick,
        child: Container(
          height: 170,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  widget.img_path,
                  package: 'godrej_one_sdk',
                  fit: BoxFit.cover,
                ),
              ),
              // Text Label Overlay
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GEG',
                    package: 'godrej_one_sdk',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
