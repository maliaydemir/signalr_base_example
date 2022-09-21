import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_core/signalr_core.dart';

class SignalRHelper with ChangeNotifier {
  // static String url = 'http://185.33.234.124:5000';

  // final url = 'http://192.168.6.145:5055/chat';
  final url = 'http://localhost:5055/chat';
  late HubConnection hubConnection;

  static SignalRHelper? _instance;

  SignalRHelper._();

  static SignalRHelper get instance {
    _instance ??= SignalRHelper._();
    return _instance!;
  }

  bool connectionIsOpen = false;

  Future<void> start() async {
    try {
      if (hubConnection.state == HubConnectionState.connected) {
        hubConnection.stop();
      }
    } catch (e) {}
    hubConnection = HubConnectionBuilder()
        .withUrl(
      url,
      HttpConnectionOptions(
        // accessTokenFactory: () async {
        //   return 'TOKEN';
        // },
        logging: (level, message) {
            log(message);
        },
      ),
    )
        .withAutomaticReconnect([500, 1000, 2000, 3000]).build();

    await hubConnection.start();
    hubConnection.onreconnecting((exception) {
      connectionIsOpen = false;
      notifyListeners();
    });
    hubConnection.onreconnected((exception) {
      connectionIsOpen = true;
      notifyListeners();
    });
    hubConnection.onclose((exception) {
      if (exception != null) {
        // FirebaseCrashlytics.instance.recordError(exception.toString(), StackTrace.fromString('SignalR'));

        stop();
        Future.delayed(const Duration(seconds: 1), () {
          start();
        });
      }
      // if (exception != null) {
      //   hubConnection.start();
      // }
    });
    connectionIsOpen = true;
  }

  void stop() {
    hubConnection.stop();
    connectionIsOpen = false;
    carTrackingStatus = false;
    notifyListeners();
  }

  bool carTrackingStatus = false;
}

class _HttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  final Map<String, String> defaultHeaders;

  _HttpClient({required this.defaultHeaders});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(defaultHeaders);
    return _httpClient.send(request);
  }
}