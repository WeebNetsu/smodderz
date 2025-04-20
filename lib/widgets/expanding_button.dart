import 'package:flutter/material.dart';

class ExpandingButtonActionModel {
  final String text;
  final Future<void> Function()? onClick;
  final Color? textColor;

  ExpandingButtonActionModel({
    required this.text,
    required this.onClick,
    this.textColor,
  });
}

class ExpandingButtonWidget extends StatefulWidget {
  const ExpandingButtonWidget({
    super.key,
    required String text,
    required Future<void> Function() onClick,
    required List<ExpandingButtonActionModel?> actions,
    Widget? centerContent,
    Future<void> Function(String newText)? handleEditText,
  })  : _text = text,
        _onClick = onClick,
        _actions = actions,
        _centerContent = centerContent,
        _handleEditText = handleEditText;

  final String _text;

  /// if expanded, this widget will be displayed
  final Widget? _centerContent;
  final Future<void> Function() _onClick;
  final Future<void> Function(String newText)? _handleEditText;

  /// button actions to display on show more action
  final List<ExpandingButtonActionModel?> _actions;

  @override
  _ExpandingButtonWidgetState createState() => _ExpandingButtonWidgetState();
}

class _ExpandingButtonWidgetState extends State<ExpandingButtonWidget> {
  bool _expandButton = false;
  final TextEditingController _newBasketName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!_expandButton) {
      return Row(
        children: [
          Expanded(
            flex: 5,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
              ),
              onPressed: widget._onClick,
              child: Text(widget._text),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            flex: 1,
            child: IconButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _expandButton = true;
                });
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 62, 62, 62),
                borderRadius: BorderRadius.circular(12), // Adjust the radius as needed
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: widget._handleEditText == null
                          ? TextButton(
                              onPressed: widget._onClick,
                              child: Text(widget._text),
                            )
                          : TextField(
                              controller: _newBasketName,
                              decoration: InputDecoration(
                                hintText: widget._text,
                                suffixIcon: TextButton(
                                  onPressed: () {
                                    if (_newBasketName.text.isNotEmpty && widget._handleEditText != null) {
                                      widget._handleEditText!(_newBasketName.text.trim());
                                    }
                                  },
                                  child: const Icon(Icons.check),
                                ),
                              ),
                            ),
                    ),
                    widget._centerContent ?? Container(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ...widget._actions.where((action) => action != null).map((action) {
                          return Expanded(
                            child: action == null
                                ? Container()
                                : TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                                    ),
                                    onPressed: action.onClick,
                                    child: Text(
                                      action.text,
                                      style: TextStyle(
                                        color: action.textColor,
                                      ),
                                    ),
                                  ),
                          );
                        }),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 62, 62, 62),
                            ),
                            onPressed: () {
                              setState(() {
                                _expandButton = false;
                              });
                            },
                            child: const Text("Close"),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
