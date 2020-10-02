import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:get/get.dart";
import 'package:web_socket_channel/io.dart';

class User {
  String username;
  bool connected;

  User() {
    this.username = "";
    this.connected = false;
  }

  void connect(String _username) {
    this.connected = true;
    this.username = _username;
  }
}

class Store extends GetxController {
  IOWebSocketChannel channel;
  User user = User();
  bool isConnectionError = false;

  static Store get to => Get.find();

  Future<http.Response> createConnection(String ipAddr, String username) async {
    var url = "http://$ipAddr:41431/register";
    var body = {"username": username};

    final response = await http
        .post(url, body: body)
        .timeout(Duration(seconds: 5), onTimeout: () {
      return http.Response(
          "Connection Timeout: trying to connect with dead server", 408);
    }).catchError((error) {
      return http.Response(
          "Connection error: couldn't found server with address: $ipAddr", 502);
    });

    if (response.statusCode == 200) {
      isConnectionError = false;
      this.user.connect(username);
      this.channel =
          IOWebSocketChannel.connect("ws://$ipAddr:41431/ws/$username");
    } else {
      isConnectionError = true;
    }
    return response;
  }
}