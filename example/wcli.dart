import 'dart:io';
import 'package:alm/alm.dart';

main() async {

  var ws=await WebSocket.connect('ws://127.0.0.1:4040/ws');
  ws.pingInterval=1.toDuration();
  ws.add('data');
  ws.listen((event) {
    print('event :$event');
    Alm.delay(5,(){
      ws.add('{"cli":"${event.runtimeType}"}');
    });
  });
}