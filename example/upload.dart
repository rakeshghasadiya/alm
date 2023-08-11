

import 'package:alm/alm.dart';

void main()async{

  var file=Alm.file('LICENSE');
  var res=await Alm.upload<Map>('https://localhost/v1/upload', {'file':file,'token':'asd'});
  print('res:${res}');

}