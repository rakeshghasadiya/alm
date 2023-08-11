part of alm.io;

/// IoCommond
enum IoCommond {
  none,
  error,
  connected,
  denied,
  ack,
  msg,
  emit,
  //  here set up your commonds, if you need
}




/// SioData
class SioData {
  IoCommond commond;
  Uint8List data;
  int id = 0;

  String get body => utf8.decode(data);

  SioData(this.commond, this.id, this.data);

  SioData.error(IoCommond commond, String input) {
    this.commond = commond;
    data = utf8.encode(input);
  }

  @override
  String toString() {
    return 'AidioData{commond: $commond, body: $body, id: $id}';
  }
}