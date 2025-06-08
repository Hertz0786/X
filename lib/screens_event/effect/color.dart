import 'package:flutter/material.dart';

Color getAvatarColor(String id) {
  final hash = id.codeUnits.fold(0, (prev, e) => prev + e);
  final colors = [
    Colors.redAccent,
    Colors.green,
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
  ];
  return colors[hash % colors.length];
}
