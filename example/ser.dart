import 'package:alm/io.dart';

void main() async {
  var io = SioServer();
  await io.init(host: '127.0.0.1', port: 1999);
  io.stream.listen((SioData data) {
    print('recieve:$data');
  });
}
