import 'package:alm/alm.dart';

void main() async {


  print({'key':'aa'}.tryMap().has('key'));
  print(null.tryMap().has('key'));



}
