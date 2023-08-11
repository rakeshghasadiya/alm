


import 'package:alm/alm.dart';
import 'package:http/src/response.dart';

void main()async{


  var url='https://02b-certf02.bbys.cn/download?file_url=other/fe7082c05bce4dbda7fe31cdfe2b521b.pdf&token=800001&pages=1-1';

  var file=Alm.file('build/temp',auto: true);

  checkTypo<Map>();
  checkTypo<Map<String,dynamic>>();
  // return;

  var head= await Alm.http<Response>('head', url, headers: {'Accept-Encoding': 'br'},debug:true);//.then((res) => res.headers.get<int>('content-length'));
  print(head);
  print(head.headers);
  // var res=await Alm.download<Map>(url,file,isCheckSize: true,debug: true);
  // print(res);

}


void checkTypo<T>(){
  print('checkTypo[$T]:${T is Map<dynamic, dynamic>}');
  print('checkTypo[$T]:${T==Map}');
}