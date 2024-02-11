import 'package:flutter/material.dart';

class ErrorsWidget extends StatefulWidget {

  final String errors;

  const ErrorsWidget({required this.errors, Key? key}) : super(key: key);

  @override
  _ErrorsWidgetState createState() => _ErrorsWidgetState(errors);
}

class _ErrorsWidgetState extends State<ErrorsWidget> {
  bool isSelected = false;

  final String errors;

  _ErrorsWidgetState(this.errors);

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: SelectableText(
        errors,
        style: TextStyle(
            fontSize: 14, color: isSelected ? Colors.blueAccent : null),
      ),
    );
  }
}
