


import 'dart:io';

import 'package:alm/alm.dart';
import 'package:http/http.dart';

void main() async {

  var res=await Alm.http<Map>('get','http://localhost:404/home/list',debug: true);
  //
  // var request = Request('GET', 'http://localhost:404/home/list'.toUri());
  // var client=Alm.httpClient;
  // var res=await client.send(request).catchError((e){
  //   print('catchError:${e}');
  // });

  print('res:${res}');

}