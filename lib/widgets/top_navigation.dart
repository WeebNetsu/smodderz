import 'package:flutter/material.dart';

class TopNavigationActionModel {
  final String text;
  final Future<void> Function()? onClick;
  final Color? textColor;

  TopNavigationActionModel({required this.text, required this.onClick, this.textColor});
}

class TopNavigationWidget extends StatefulWidget {
  const TopNavigationWidget({super.key, required String title, Widget? rightContent})
    : _title = title,
      _rightContent = rightContent;

  final String _title;
  final Widget? _rightContent;

  @override
  _TopNavigationWidgetState createState() => _TopNavigationWidgetState();
}

class _TopNavigationWidgetState extends State<TopNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_circle_left_outlined, size: 30),
        ),
        Text(widget._title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
        widget._rightContent ?? SizedBox(width: 50),
      ],
    );
  }
}
