import 'package:flutter/material.dart';

class DefaultIfaceWidget extends StatefulWidget {
  DefaultIfaceWidget({Key? key}) : super(key: key);

  @override
  _DefaultIfaceWidgetState createState() => _DefaultIfaceWidgetState();
}


class _DefaultIfaceWidgetState extends State<DefaultIfaceWidget> {
  int selectedId = 1;
  final List<String> options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  @override
  void initState() {
    super.initState();
  }

  void setSelectedRadio(int val) {
    setState(() {
      selectedId = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = options.map((option) {
      return ListTile(
        title: Text(option),
        leading: Radio(
          value: options.indexOf(option),
          groupValue: selectedId,
          onChanged: onValChanged,
        ),
      );
    }).toList();


    List<Widget> listWithButton = [];
    listWithButton.addAll(list);
    listWithButton.add(
      ElevatedButton(
        child: const Text('OK'),
        onPressed: () {
          print('Confirmed Choice: ${selectedId}');
        },
      ),
    );
    return Column(children: listWithButton);
  }

  void onValChanged(int? val) {
    if (val == null) {
      return;
    }
    print("Radio $val");
    setSelectedRadio(val);
  }
}
