import 'package:alm/alm.dart';

void main() async {

  print('alm'.isNull);
  print('{}'.tryMap());
  dynamic a='{}';
  print(Alm.o(a).tryMap());
  print(Alm.o(a).runtimeType);

  print('alm'.toBase64());
  print('alm'.toBase64().toBase64Str());
  print('alm'.toMd5());
  print(''.random(10));
  print(''.enJson().enJson());
  print('{}'.enJson().enJson());
  print('["w"]'.enJson().enJson());
  print('["w"]'.enJson());
  var url='https://www.baidu.com/s?ie=utf-8&f=8&rsv_bp=1&rsv_idx=1&tn=baidu&wd=image&fenlei=256&rsv_pq=d3fdb40400000ada&rsv_t=d936u9tLwRKFl3v37L4Ms4tjMg83I2NJo0aaAhmK%2BT65FOhN5bHHfvgXUdc&rqlang=cn&rsv_enter=1&rsv_dl=tb&rsv_sug3=6&rsv_sug1=5&rsv_sug7=100&rsv_sug2=0&rsv_btype=i&prefixsug=image&rsp=7&inputT=812&rsv_sug4=1778';
  print(url.toUri().toString().length);
  print(url.length);

  print(3.0003.toDuration());
  print(0.0003.tryBool());
  print(0.1.tryInt());
  print(0.1.tryInt());
  print(0.1.tryBool());
  print(null.tryMap());
  print('true'.tryBool());
  print('A***************************************************************************************************************************************B'.tryReplace());
  print(null.tryReplace());



  /// explain Duration hour
  print(((60*60*15)+0.5).toDuration());
  print('15.5'.toDuration());
  print('15:00.5'.toDuration());
  print('15:00:00.5'.toDuration());




}
