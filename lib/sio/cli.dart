part of alm.io;

/// SioClient
class SioClient extends SioProtocol {
  Future init({String host = '127.0.0.1', int port = 4041}) async {
    try {
      socket = await Socket.connect(host, port);
      print('Client:$host:$port connect success!\n$version\n\nwating->>>');
      listen = socket.listen(_decode);
      socket.write(securityKey);
    } catch (e) {
      controller.add(SioData.error(IoCommond.error, '[$runtimeType-${socket.hashCode}]id:$id,$commond,ack:$ack,' + e.toString()));
    }
  }

  @override
  void _onData(IoCommond cmd, Uint8List data) {
    if (id == 1) {
      send(IoCommond.connected, version);
    } else {
      controller.add(SioData(cmd, id, data));
    }
  }
}