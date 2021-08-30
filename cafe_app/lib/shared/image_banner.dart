import 'package:flutter/material.dart';

class ImageBanner extends StatelessWidget {
  final String _assetPath;

  ImageBanner(this._assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(height: 235.0, width: 200),
        decoration: BoxDecoration(color: Colors.white),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.cover,
        ));
  }
}

class SmallImageBanner extends StatelessWidget {
  final String _assetPath;

  SmallImageBanner(this._assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(height: 100, width: 85),
        decoration: BoxDecoration(color: Colors.white),
        child: Image.asset(
          _assetPath,
          fit: BoxFit.cover,
        ));
  }
}