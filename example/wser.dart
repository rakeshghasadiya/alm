

import 'dart:io';
import 'package:alm/alm.dart';

void handleWebSocket(WebSocket webSocket) {
  // Listen for incoming data. We expect the data to be a JSON-encoded String.
  webSocket.add('{"id":"${webSocket.hashCode}"}');
  webSocket.pingInterval=5.toDuration();
  webSocket.listen((json) {
    print('Message to be echoed: $json');
    webSocket.add('{"ser":"${json.runtimeType}"}');
  }, onError: (error) {
    print('Bad WebSocket request');
  });
}


void main() {
  HttpServer.bind('0.0.0.0', 1234).then((server) {
    print('Search server is running on ' "'ws://${server.address.address}:${server.port}/ws'");
    server.listen((http) {
      print(':${http.uri} ${http.headers}');
      WebSocketTransformer.upgrade(http).then(handleWebSocket);
    });
  });
}