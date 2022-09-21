import 'package:flutter/material.dart';
import 'package:signalr_base_example/LoadingWidget.dart';
import 'package:signalr_base_example/SignalRHelper.dart';
import 'package:signalr_core/signalr_core.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var txtC = TextEditingController();

  var received = <String>[];

  @override
  Widget build(BuildContext context) {
    if (!SignalRHelper.instance.connectionIsOpen) {
      return const LoadingWidget();
    }
    return Scaffold(
      body: received.isNotEmpty
          ? ListView.builder(
          itemCount: received.length,
          itemBuilder: (_, i) {
              return ListTile(
                title: Text(received[i]),
              );
            })
          : Text('Connected'),
      bottomSheet: Card(
        child: Row(
          children: [
            Expanded(
                child: TextField(
              controller: txtC,
            )),
            IconButton(
                onPressed: () {
                  SignalRHelper.instance.hubConnection
                      .send(methodName: 'SendMessage', args: [txtC.text]);
                  txtC.clear();
                },
                icon: Icon(Icons.send))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    initSignalR();
    super.initState();
  }

  Future<void> initSignalR() async {
    await SignalRHelper.instance.start();
      if (SignalRHelper.instance.connectionIsOpen) {
        SignalRHelper.instance.hubConnection.on('ReceiveMessage', (arguments) {
          received.add(arguments![0].toString());
          setState(() {});
        });
      }
    setState(() {});
  }
}
