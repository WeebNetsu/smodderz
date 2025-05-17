import 'package:flutter/material.dart';

class EnabledButtonWidget extends StatefulWidget {
  const EnabledButtonWidget({
    super.key,
    required String text,
    required Future<void> Function() onClick,
    enabled = false,
  }) : _text = text,
       _onClick = onClick,
       _enabled = enabled;

  final String _text;
  final bool _enabled;

  /// if expanded, this widget will be displayed
  final Future<void> Function() _onClick;

  @override
  _EnabledButtonWidgetState createState() => _EnabledButtonWidgetState();
}

class _EnabledButtonWidgetState extends State<EnabledButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget._onClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: !widget._enabled ? Color.fromARGB(255, 255, 68, 51) : Color(0xFF00C853),
      ),
      child: Text(widget._text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
    );
  }
}
