## A library for Dart developers.
 Smart tools, functions,converts,times,random,...
 String,List,Map,int, success, error....
 

## Usage

```dart
import 'package:alm/alm.dart';

void main() {
  print(Alm.version);
    //...
    ///
    print({}.isMap); //true
    print([].isMap); //false
    //
    print(null.isMap); //false
    //
    var map = {'alm': 2, 'foo': 3};
    '# check keys'.printAsTitle();
    print(map.has('alm')); //true
    print(map.has(['alm', 'foo'])); //true
    print(map.has('slm')); //false
    //
    '# check key val'.printAsTitle();
    print(map.has('alm', 2)); //true
    print(map.has('foo', 3.1)); //false
    //
    // //...
  
    '# check timers'.printAsTitle();
  
    print(Alm.duration.between('08:00:00','18:00:00'));
}

```

## References

[google/....](https://google.com/) 
