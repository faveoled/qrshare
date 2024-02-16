import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrshare/CachingConfigStorage.dart';
import 'package:qrshare/Network.dart';
import 'package:qrshare/QrcpConfig.dart';

class ConfigWidget extends StatefulWidget {
  const ConfigWidget({Key? key}) : super(key: key);

  @override
  _ConfigWidgetState createState() => _ConfigWidgetState();

}

class _ConfigWidgetState extends State<ConfigWidget> {

  @override
  void initState() {
    super.initState();
    availableInterfacesFuture
        .then((value) {
          availableInterfacesLoaded = value;
        })
        .catchError((val) {
          availableInterfacesLoaded = [];
          stderr.write("Failed to load available interfaces: $val");
        });
  }

  // Declare the controller variables for each input field
  TextEditingController bindController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController pathController = TextEditingController();
  TextEditingController outputController = TextEditingController();
  TextEditingController fqdnController = TextEditingController();
  TextEditingController tlsCertController = TextEditingController();
  TextEditingController tlsKeyController = TextEditingController();

  // Declare the boolean variables for each switch
  bool keepAlive = false;
  bool secure = false;

  bool initDone = false;

  String interface = '';
  Future<List<String>> availableInterfacesFuture = Network.getNetworkInterfaces();
  List<String>? availableInterfacesLoaded;

  String bind = '';
  String port = '';
  String path = '';
  String output = '';
  String fqdn = '';
  String tlsCert = '';
  String tlsKey = '';


  @override
  void dispose() {
    bindController.dispose();
    portController.dispose();
    pathController.dispose();
    outputController.dispose();
    fqdnController.dispose();
    tlsCertController.dispose();
    tlsKeyController.dispose();
    super.dispose();
  }

  void setUpController(TextEditingController textEditingController, dynamic cfgVal, void Function(dynamic str) setLocalVar) {
    if (cfgVal != null) {
      textEditingController.text = cfgVal.toString();
    }
    textEditingController.addListener(() {
      setState(() {
        setLocalVar(textEditingController.text);
      });
    });
  }

  String? toStrModel(String textField) {
    if (textField.isEmpty) {
      return null;
    }
    return textField;
  }

  int? toIntModel(String textField) {
    if (textField.isEmpty) {
      return null;
    }
    return int.parse(textField);
  }

  void onSavePressed() {
    final config = QrcpConfig(
        toStrModel(interface),
        toStrModel(bind),
        toIntModel(port),
        toStrModel(path),
        toStrModel(output),
        toStrModel(fqdn),
        keepAlive,
        secure,
        toStrModel(tlsCert),
        toStrModel(tlsKey)
    );
    cfgStorage.writeConfig(config);

    showAlert("Config saved successfully");
  }

  void onResetPressed() {
    showQuestionAlert();
  }

  void writeDefaults() {
    try {
      cfgStorage.writeConfig(QrcpConfig.getDefaults());
      AlertDialog alert = const AlertDialog(
        title: Text('Defaults saved'),
        content: Text('Defaults saved'),
        backgroundColor: Colors.yellow,
      );

      showDialog(context: context, builder: (BuildContext context) {
        return alert;
      });
    } catch (e) {
      print(e);
      AlertDialog alert = const AlertDialog(
        title: Text('Error saving defaults'),
        content: Text('Error saving defaults'),
        backgroundColor: Colors.yellow,
      );

      showDialog(context: context, builder: (BuildContext context) {
        return alert;
      });
    }
  }

  void showQuestionAlert() {
    //ok button
    Widget okButton = ElevatedButton(

      onPressed: () {
        Navigator.of(context).pop();
        writeDefaults();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Reset'),
    );


    Widget cancelButton = ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
      child: const Text('Cancel'),
    );

    AlertDialog alert = AlertDialog(
      title: const Text('Reset to defaults'),
      content: const Text('This will reset the configuration to default state'),
      actions: [
        okButton,
        cancelButton
      ],
      backgroundColor: Colors.grey[200],
    );

    showDialog(context: context, builder: (BuildContext context) {
      return alert;
    });
  }


  void showAlert(String msg) {
    Widget okButton = ElevatedButton(
      onPressed: () {
        //action to be taken
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
      child: const Text('OK'),
    
    );
    AlertDialog alert = AlertDialog(
      title: const Text('Saved'),
      content: Text(msg),
      actions: [
        okButton
      ],
      backgroundColor: Colors.grey[200],
    );
    
    showDialog(context: context, builder: (BuildContext context) {
      return alert;
    });
  }

  final cfgStorage = CachingConfigStorage.instance;

  @override
  Widget build(BuildContext context) {
    if (!initDone) {
      final cfg = cfgStorage.readConfig();

      if (cfg.interface != null) {
        interface = cfg.interface!;
      }
      setUpController(bindController, cfg.bind, (str) { bind = str; });
      setUpController(portController, cfg.port, (str) { port = str; });
      setUpController(pathController, cfg.path, (str) { path = str; });
      setUpController(outputController, cfg.output, (str) { output = str; });
      setUpController(fqdnController, cfg.fqdn, (str) { fqdn = str; });
      setUpController(tlsCertController, cfg.tlsCert, (str) { tlsCert = str; });
      setUpController(tlsKeyController, cfg.tlsKey, (str) { tlsKey = str; });

      initDone = true;
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('qrcp Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (availableInterfacesLoaded == null)
              const Text("...")
            else
              // Create a text dropdown for the interface parameter
              DropdownButtonFormField<String>(
                value: interface,
                decoration: const InputDecoration(
                  labelText: 'interface',
                ),
                hint: const Text('Network interface name to bind to.'),
                onChanged: (value) {
                  setState(() {
                    if (value == null) return;
                    interface = value;
                  });
                },
                items: availableInterfacesLoaded!.map((interfaceName) {
                  return DropdownMenuItem<String>(
                    value: interfaceName,
                    child: Text(interfaceName),
                  );
                }).toList() + [
                    const DropdownMenuItem<String>(
                    value: 'any',
                    child: Text('any'),
                  )
                ],
              ),
            const SizedBox(height: 8.0),
            // Create a text field for the bind parameter
            TextField(
              controller: bindController,
              decoration: const InputDecoration(
                labelText: 'bind',
                hintText: 'This value is used by qrcp to bind the web server to. Note: if this value is set, the interface parameter is ignored.',
              ),
            ),
            const SizedBox(height: 8.0),
            // Create a text field for the port parameter
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'port',
                hintText: 'When this value is not set, qrcp will pick a random port at any launch.',
              ),
              keyboardType: TextInputType.number, // Use the number keyboard
              inputFormatters: [ // Add an input formatter
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
              ],
            ),
            const SizedBox(height: 8.0),
            // Create a text field for the path parameter
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                labelText: 'path',
                hintText: 'When this value is not set, qrcp will add a random string at the end of URL.',
              ),
            ),
            const SizedBox(height: 8.0),
            // Create a text field for the output parameter
            TextField(
              controller: outputController,
              decoration: InputDecoration(
                labelText: 'output',
                hintText: 'Default directory to receive files to. If empty, the current working directory is used.',
                suffixIcon: IconButton( // Add a suffix icon
                  icon: const Icon(Icons.folder_open), // Use a folder icon
                  onPressed: () async { // Define the action to open the file picker
                    final initial = isValidDirectoryPath(outputController.text) ? outputController.text : null;
                    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(initialDirectory: initial); // Pick a file
                    if (selectedDirectory != null) { // If a directory is picked
                      outputController.text = selectedDirectory; // Set the text field value to the file path
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Create a text field for the fqdn parameter
            TextField(
              controller: fqdnController,
              decoration: const InputDecoration(
                labelText: 'fqdn',
                hintText: 'When this value is set, qrcp will use it to replace the IP address in the generated URL.',
              ),
            ),
            const SizedBox(height: 8.0),
            // Create a switch for the keepAlive parameter
            SwitchListTile(
              value: keepAlive,
              onChanged: (value) {
                setState(() {
                  keepAlive = value;
                });
              },
              title: const Text('keepAlive'),
              subtitle: const Text('Controls whether qrcp should quit after transferring the file. Defaults to false.'),
            ),
            // Create a switch for the secure parameter
            SwitchListTile(
              value: secure,
              onChanged: (value) {
                setState(() {
                  secure = value;
                });
              },
              title: const Text('secure'),
              subtitle: const Text('Controls whether qrcp should use HTTPS instead of HTTP. Defaults to false.'),
            ),
            // Create a text field for the tls-cert parameter
            TextField(
              controller: tlsCertController,
              decoration: InputDecoration(
                labelText: 'tls-cert',
                hintText: 'Path to the TLS certificate. It\'s only used when secure: true.',
                suffixIcon: IconButton( // Add a suffix icon
                  icon: const Icon(Icons.folder_open), // Use a folder icon
                  onPressed: () async { // Define the action to open the file picker
                    FilePickerResult? result = await FilePicker.platform.pickFiles(); // Pick a file
                    if (result != null && result.files.single.path != null) { // If a file is picked
                      tlsCertController.text = result.files.single.path!; // Set the text field value to the file path
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Create a text field for the tls-key parameter
            TextField(
              controller: tlsKeyController,
              decoration: InputDecoration(
                labelText: 'tls-key',
                hintText: 'Path to the TLS key. It\'s only used when secure: true.',
                suffixIcon: IconButton( // Add a suffix icon
                  icon: const Icon(Icons.folder_open), // Use a folder icon
                  onPressed: () async { // Define the action to open the file picker
                    FilePickerResult? result = await FilePicker.platform.pickFiles(); // Pick a file
                    if (result != null && result.files.single.path != null) { // If a file is picked
                      tlsKeyController.text = result.files.single.path!; // Set the text field value to the file path
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: onResetPressed,
                  child: const Text('Reset to defaults'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onSavePressed,
                  child: const Text('Save'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  bool isValidDirectoryPath(String path) {
    try {
      Directory(path);
      return true;
    } on FileSystemException catch (_) {
      return false;
    }
  }
}