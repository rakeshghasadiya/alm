part of alm.io;
/// SioServer
class SioServer extends SioProtocol {
  bool auth = false;

  

  Future init({String host = '127.0.0.1', int port = 4041}) async {
    try {
      io = await ServerSocket.bind(host, port);
      print('Server:$host:$port bind success!\n$version\n\nwating->>>');
      server = await io.listen((Socket soc) {
        socket = soc;
        auth = false;
        listen = socket.listen((data) {
          if (!auth) {
            auth = (utf8.decode(data) == securityKey);
            if (!auth) {
              send(IoCommond.denied, 'Access Denied');
              socket.close();
              listen.cancel();
            }
            send(IoCommond.connected, version);
          } else {
            _decode(data);
          }
        });
      });
    } catch (e) {
      controller.add(SioData.error(IoCommond.error, '[$runtimeType-${socket.hashCode}]id:$id,$commond,ack:$ack,' + e.toString()));
    }
  }
}