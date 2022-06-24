import 'package:firebase_assignment/constants/size_constants.dart';
import 'package:flutter/material.dart';

Widget messageBubble(
    {required String chatContent,
    required EdgeInsetsGeometry? margin,
    Color? color,
    Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(Sizes.dimen_10),
    margin: margin,
    width: Sizes.dimen_200,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Sizes.dimen_10),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: Sizes.dimen_16, color: textColor),
    ),
  );
}
