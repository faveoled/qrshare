import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrshare/CachingConfigStorage.dart';
import 'package:qrshare/ConfigWidget.dart';
import 'package:qrshare/ErrorsModel.dart';
import 'package:qrshare/Network.dart';
import 'package:qrshare/QrcpConfig.dart';
import 'package:qrshare/QrcpProcess.dart';
import 'package:window_size/window_size.dart';

import 'ErrorsWidget.dart';

final CachingConfigStorage cfgStorage = CachingConfigStorage.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(const Size(400, 640));

  // load into cache
  final QrcpConfig cfg = cfgStorage.readConfig();
  if (!cfgStorage.isConfigPresent()) {
    String? wlanInterface = await Network.getWlanInterface();
    if (wlanInterface != null) {
      print("Choosing $wlanInterface as default interface");
      final newCfg = cfg.copy();
      newCfg.interface = wlanInterface;
      cfgStorage.writeConfig(newCfg);
    }
  }
  runApp(
      ChangeNotifierProvider(
        create: (context) => ErrorsModel(),
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Share',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'QR Share'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<XFile> _list = [];

  bool _dragging = false;

  bool _sendFileChosen = false;

  String? _sendQrUrl;
  String? _receiveQrUrl;
  Process? _receiveProcess;
  Process? _sendProcess;

  void onTabTap(int index) {
    if (index == 1) {
      // start server
      final cfg = CachingConfigStorage.instance.readConfig();
      final Future<(Future<String>, Process)> completer = qrcpProcess.runReceive(context, cfg.interface);
      completer.then((value) {
        _receiveProcess = value.$2;
        value.$1.then((url) =>
            setState(() {
              _receiveQrUrl = url;
            })
        );
      });
    } else {
      setState(() {
        _receiveQrUrl = null;
      });
    }
    if (_receiveProcess != null) {
      _receiveProcess!.kill();
      _receiveProcess = null;
    }
  }

  List<String> xFileNames(List<XFile> xFiles) {
    return xFiles.map((xFile) => xFile.path).toList();
  }

  void dragDropPressed() {
    print("Drag & Drop pressed");
  }


  Future<List<XFile>> _getFilesFromPickerResult(FilePickerResult result) async {
    if (result.files.isEmpty) {
      return [];
    }
    List<XFile> xFiles = [];
    for (var file in result.files) {
      xFiles.add(XFile(file.path!));
    }
    return xFiles;
  }

  final QrcpProcess qrcpProcess = QrcpProcess();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Consumer<ErrorsModel>(
          builder: (context, errorsModel, child) {
            return DefaultTabController(
              length: errorsModel.hasSome ? 4 : 3,
              child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      const Tab(text: "Send", icon: Icon(Icons.arrow_upward)),
                      const Tab(text: "Receive", icon: Icon(Icons.arrow_downward)),
                      const Tab(text: "Config", icon: Icon(Icons.settings)),
                      if (errorsModel.hasSome) const Tab(text: "Errors", icon: Icon(Icons.error)),
                    ],
                    onTap: (index) {
                      // Add your onPressed functionality here
                      onTabTap(index);
                    },
                  ),
                ),
                body: TabBarView(
                  children: [
                    Column(
                      // Column is also a layout widget. It takes a list of children and
                      // arranges them vertically. By default, it sizes itself to fit its
                      // children horizontally, and tries to be as tall as its parent.
                      //
                      // Column has various properties to control how it sizes itself and
                      // how it positions its children. Here we use mainAxisAlignment to
                      // center the children vertically; the main axis here is the vertical
                      // axis because Columns are vertical (the cross axis would be
                      // horizontal).
                      //
                      // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                      // action in the IDE, or press "p" in the console), to see the
                      // wireframe for each widget.
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            xFileNamesPretty()
                        ),
                        if (_sendFileChosen) Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_sendQrUrl != null)
                              QrImageView(
                                data: _sendQrUrl!,
                                version: QrVersions.auto,
                                size: 300.0,
                              )
                            else
                              const Text("Generating QR code..."),
                            const Text(
                              'Scan QR to send file',
                              style: TextStyle(fontSize: 20),
                            ),
                            TextButton(
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _list.clear();
                                    _sendQrUrl = null;
                                    _sendFileChosen = false;
                                  });
                                },
                                child: const Text("Go back")
                            )
                          ],
                        ),
                        if (!_sendFileChosen) GestureDetector(
                            onTapDown: (_) async {
                              FilePickerResult? result = await FilePicker.platform
                                  .pickFiles(type: FileType.any);
                              if (result == null) {
                                // user cancelled
                              } else {
                                List<XFile> files = await _getFilesFromPickerResult(result);

                                final names = xFileNames(files);
                                final cfg = CachingConfigStorage.instance.readConfig();
                                if (_sendProcess != null) {
                                  _sendProcess!.kill();
                                }
                                final Future<(Future<String>, Process)> completer = qrcpProcess.runSend(context, cfg.interface, names);
                                completer.then((value) {
                                  _sendProcess = value.$2;
                                  value.$1.then((url) {
                                    setState(() {
                                      _sendQrUrl = url;
                                    });
                                  });
                                });
                                setState(() {
                                  _list.addAll(files);
                                  _sendFileChosen = true;
                                });
                              }
                            },
                            child: DropTarget(
                              onDragDone: (detail) {
                                setState(() {
                                  _list.addAll(detail.files);
                                });
                              },
                              onDragEntered: (detail) {
                                setState(() {
                                  _dragging = true;
                                });
                              },
                              onDragExited: (detail) {
                                setState(() {
                                  _dragging = false;
                                });
                              },
                              child: Container(
                                height: 200,
                                width: 200,
                                color: _dragging
                                    ? Colors.blue.withOpacity(0.4)
                                    : Colors.black26,
                                child: _list.isEmpty
                                    ? const Center(
                                    child: Text(
                                      "Drop or Click to select files",
                                    ))
                                    : Text(xFileNamesPretty()),
                              ),
                            )
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_receiveQrUrl == null)
                          const Text("Waiting for server startup...")
                        else
                          QrImageView(
                            data: _receiveQrUrl!,
                            version: QrVersions.auto,
                            size: 300.0,
                          ),
                        const Text(
                          "Scan with your mobile device",
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    const Column(
                      children: [
                        Expanded(
                            child: ConfigWidget()
                        )
                      ],
                    ),
                    if (errorsModel.hasSome)
                      Column(
                        children: [
                          Expanded(child: ErrorsWidget(errors: errorsModel.errors))
                        ],
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String xFileNamesPretty() {
    final names = xFileNames(_list);
    return names.join("\n");
  }
}
