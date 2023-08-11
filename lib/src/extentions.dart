part of alm;

extension AlmExtensionNum on num {

  /// Todo this function not tested on ios
  T random<T>({bool isCapital = false,bool isId=false,chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'}) {
    var max=toInt();
    if(T is int) return Alm.kRandom.nextInt(max) as T;
    if(T is double) return Alm.kRandom.nextDouble()*max as T;
    if(T is bool) return Alm.kRandom.nextBool() as T;
    var s = '${Alm.timem.toOctet()}${Alm.RandomId.toOctet()}${Alm.nextIncrement.toOctet()}';
    return s as T;
  }

  String toOctet({int len=8}) {
    var value=toInt();
    var res = value.toRadixString(16);
    while (res.length < len) {
      res = '0$res';
    }
    return res;
  }


  Duration toDuration() {
    var seconds = floor();
    var after = (this - seconds) * 10000;
    var mil = 0, mic = 0;
    if (after > 0) {
      var ms = after.toString().padLeft(6, '0').tryCut(6);
      mil = ms.trySub(0, 3).tryInt(0);
      mic = ms.trySub(3).tryInt(0);
    }
    return Duration(seconds: seconds, milliseconds: mil, microseconds: mic);
  }

  String toByteString({String format = 'PB', int fixed = 2}) {
    var size = this;
    var Kb = 1024;
    var Mb = Kb * 1024;
    var Gb = Mb * 1024;
    var Tb = Gb * 1024;
    var Pb = Tb * 1024;
    var ret = size;
    if (size < Kb || format == 'B') {
      ret = size;
    } else if (size < Mb || format == 'KB') {
      ret = size / Kb;
    } else if (size < Gb || format == 'MB') {
      ret = size / Mb;
    } else if (size < Tb || format == 'GB') {
      ret = size / Gb;
    } else if (size < Pb || format == 'TB') {
      ret = size / Tb;
    } else {
      ret = size / Pb;
    }
    return ret.toStringAsFixed(fixed) + format.toUp();
  }
  String digits([int digit = 0]) => '$this'.padLeft(digit, '0');
}

extension AlmExtensionInt on int {
  void loop(Function(int) next) {
    for (var i = 0; i < this; i++) {
      next(i);
    }
  }
}

extension AlmExtensionDateTime on DateTime {

  String toStr(){
    return toString().split('.').first;
  }

}
extension AlmExtensionDuration on Duration {
  String toSString() {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }
    var twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
  Duration get elapse => diff();
  String get firstPart => toString().split('.').first;
  double get elapseSec => double.parse((elapseMs/1000).toStringAsFixed(3));
  double get elapseMs => double.parse((elapseMc/1000).toStringAsFixed(3));
  double get elapseMc => elapse.inMicroseconds.toDouble();

  Duration diff([Duration other]) =>(other ?? Alm.duration) - this;

  bool timeOut(Duration s) => elapse>s;

  bool outSide(Object s, {onError}) =>Alm.tryWith(() => s.tryDuration() > this,onError: onError,value: false);
  bool inSide(Object s, {onError}) =>Alm.tryWith(() => s.tryDuration() < this,onError: onError,value: false);

  bool between(Object s, Object e, {onError}) {
    var current = this;
    return Alm.tryWith((){
      var start = s.tryDuration();
      var end = e.tryDuration();
      if (end < start) end += Duration(hours: 24);
      return start <= current && current <= end;
    },onError: onError,value: false);
  }
}

extension AlmExtensionDirectory on Directory {
  void tryDelete({bool recursive = false}) => existsSync() ? deleteSync(recursive: recursive) : null;
}

extension AlmExtensionFile on File {
  String tryString([String val]) => existsSync() ? readAsStringSync() : val;

  Uint8List tryBytes([Uint8List val]) => existsSync() ? readAsBytesSync() : val;

  void writeJson(Object input) => writeAsStringSync(input.tryJson());

  Object readJson([Object val]) => existsSync() ? readAsStringSync().tryDson(onError: (e) => val) : val;

  void tryDelete({bool recursive = false}) => existsSync() ? deleteSync(recursive: recursive) : null;

  int trySize() => existsSync() ? lengthSync() : -1;

  String basename() => path.basename();

  String extent([String val]) => path.fileExt(val);

  File extTo(String s)=>File('$path.$s');
}

extension AlmExtensionMap on Map {

  bool get isSuccess=>has('status',1)||has('code',1);

  void printIt({String to=':'}) => forEach((key, value)=>print('$key $to $value'));

  T get<T>(Object key, [val]) {
    if (isNull || isEmpty || !containsKey(key)) return val;
    Object r = this[key];
    return r.tryTo<T>(val: val);
  }

  T getOr<T>(Object key, Object key2) => get<T>(key) ?? get<T>(key2);

  @Deprecated('use get')
  Object tryGet(Object key) => get(key);

  void keyTo(Object key, Object to) {
    if (isNull) return;
    this[to] = this[key];
    remove(key);
  }

  bool has<T>(Object key, [Object val]) {
    if (isNull || isEmpty) return false;
    if (key.isList) {
      for (var k in key) {
        if (!containsKey(k)) return false;
        if (!(containsKey(k) is T)) return false;
      }
      return true;
    }
    Object r = this[key];
    if (r is T && r.isNotNull) {
      if (val.isNotNull) return r == val;
      return true;
    }
    return false;
  }

  T randomKey<T>() => keys.elementAt(Alm.kRandom.nextInt(length));

  T randomVal<T>() => this[randomKey()];

  @Deprecated('use mergeInto')
  Map<K, V> upOther<K, V>([other]) => mergeInto(other);

  Map<K, V> mergeInto<K, V>(Object other, {List<K> ignoreKeys}) {
    if (other.isNotNull && other is Map) {
      other.forEach((key, value) {
        if (!ignoreKeys.has(key)) {
          this[key] = value;
        }
      });
    }
    return Map<K, V>.from(this);
  }

  Map<K, V> ignore<K, V>(List<K> ignoreKeys) {
    if (isNull || isEmpty) return null;
    var map=<K, V>{};
    forEach((key, value) {
      if (!ignoreKeys.has(key)) {
        map[key] = value;
      }
    });
    return map;
  }

  String enJson() => jsonEncode(this, toEncodable: (o) => o.toString());

  String toQuery({Encoding encoding = utf8}) {
    var pairs = <List<String>>[];
    forEach((key, value) => pairs.add([Uri.encodeQueryComponent(key.toString(), encoding: encoding), Uri.encodeQueryComponent(value.toString(), encoding: encoding)]));
    return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
  }
}


extension AlmExtensionList on List {
  String toHex() => hex.encode(this);

  T get<T>(int key,{val}) {
    if (isNull || isEmpty) return val;
    if(length>key) {
      Object r=this[key];
      return r.tryTo<T>(val: val);
    }
    return val;
  }

  int get tryLength =>(isNull || isEmpty)?0:length;

  bool has(Object key) {
    if (isNull || isEmpty) return false;
    return contains(key);
  }

  int sum() {
    var r = 0;
    forEach((e) {
      r += e;
    });
    return r;
  }

  String tryUtf8() => utf8.decode(List<int>.from(this),allowMalformed: true);

  List<T> trySub<T>(int start, [int end]) => sublist(start, min(length, end.isNull ? length : (end.isNegative ? max(length + end, 0) : end)));
  List<T> slice<T>(int start, [int end]) => trySub<T>(start, end);

  List<T> tryCut<T>(int len) => trySub(0, len);

  int randomKey() => Alm.kRandom.nextInt(length);

  get random => this[randomKey()];

  T randomVal<T>() => this[randomKey()];

  List<T> tryRan<T>(int len) {
    var res = <T>[];
    var ks = [];
    while (len > 0) {
      var k = randomKey();
      if (!ks.contains(k)) {
        ks.add(k);
        res.add(this[k]);
        len--;
      }
    }
    return res;
  }
}

extension AlmExtensionUri on Uri {
  T get<T>(String key,[val])=>queryParameters.get<T>(key,val);
  String pathQuery() {
    var uri = this;
    return (uri.path.isEmpty ? '/' : uri.path) + (uri.hasQuery ? '?${uri.query}' : '');
  }
  String get baseUrl=>toString().split('?').first;
  String get baseHead=>toString().split('?').first.replaces(path,'');
  Uri toUri() => this;
}

extension AlmExtensionString on String {
  String toLo() => toLowerCase();

  String toUp() => toUpperCase();

  String toUpFirst() {
    if (isNull || isEmpty) return this;
    if (length < 2) return tryCut(1).toUp();
    return tryCut(1).toUp() + trySub(1);
  }

  String withTo(Object o) => this + '$o';

  void printAsTitle({int intend = 20, String t = '-'}) {
    var title = split(' ').map((e) => e.toUpFirst()).join(' ');
    var after = t;
    intend.loop((i) => after += t);
    print('$title-$after');
  }

  String random(int length, {bool isCapital = false}) {
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    if (isCapital) chars = chars.trySub(0, 36);
    final buf = StringBuffer();
    for (var x = 0; x < length; x++) {
      buf.write(chars[Alm.kRandom.nextInt(chars.length)]);
    }
    return this + buf.toString();
  }

  String basename() => toUri().path.split('/').last;

  String get ext => fileExt();

  String extTo(String val) {
    if (isNull || isEmpty) return '${this}.${val}';
    var bn = basename().split('.');
    return '${bn.first}.${val}';
  }


  String fileExt([String val]) {
    if (isNull || isEmpty) return val;
    var bn = basename().split('.');
    if (bn.length >= 2) return bn.last;
    return val;
  }

  Map formUrlDeCode() {
    return Alm.tryWith(() {
      var jsonData = {};
      for (var element in split('&')) {
        var els = element.split('=');
        jsonData[Uri.decodeFull(els.first)] = Uri.decodeFull(els.last);
      }
      return jsonData;
    });
  }

  String trySub(int start, [int end]) => Alm.tryWith(() => substring(start, min(length, end.isNull ? length : (end.isNegative ? max(length + end, 0) : end))));

  String tryCut(int len) => trySub(0, len);

  Uri toUri() => Uri.parse(this);

  String pathQuery() => toUri().pathQuery();

  File toFile() => Alm.file(this);

  String toMd5() => md5.convert(codeUnits).toString();

  String toBase64() => base64Encode(codeUnits);

  String toHex() => hex.encode(codeUnits);

  String toHexStr() => hex.decode(this).tryUtf8();
  List<int> toHexByte() => hex.decode(this);

  String toBase64Str() => base64Decode(this).tryUtf8();

  String tryReplace({int times = 20, String from = '****', String to = '***'}) {
    var string = toString();
    for (var i = 0; i < times; i++) {
      string = string.replaceAll(from, to);
    }
    return string;
  }

  String replaces(Object reg, [Object to = '']) {
    if (reg is List && to != null) {
      var str = this;
      var i = 0;
      for (var r in reg) {
        if (to is List) {
          str = str.replaceAll(r, to[i]);
        } else {
          str = str.replaceAll(r, to);
        }
        i++;
      }
      return str;
    }
    return replaceAll(reg, to);
  }

  Duration toDuration([Duration val, onError]) {
    if (isNull) return val;
    try {
      var parts = split('.');
      var mil = 0, mic = 0;
      if (parts.length >= 2) {
        var ms = parts.last.toString().padRight(6, '0');
        mil = ms.substring(0, 3).tryTo<int>(val: 0);
        mic = ms.substring(3).tryTo<int>(val: 0);
      }
      var arr = parts.first.split(':');
      var arr0 = arr.first.tryTo<int>();
      if (arr0.isNull) throw Exception('0 clock is null');
      if (arr.length == 1) return Duration(hours: arr0, milliseconds: mil, microseconds: mic);
      var arr1 = arr[1].tryTo<int>(val: 0);
      if (arr.length == 2) return Duration(hours: arr0, minutes: arr1, milliseconds: mil, microseconds: mic);
      var arr2 = arr[2].tryTo<int>(val: 0);
      return Duration(hours: arr0, minutes: arr1, seconds: arr2, milliseconds: mil, microseconds: mic);
    } catch (e) {
      if (onError != null) return onError(e);
    }
    return val;
  }

  List<String> chunck({int len=1,val}){
    if (isNull || isEmpty) return val;
    var res=<String>[];
    var i=0;
    while(i<length){
      res.add(trySub(i, i+len));
      i=i+len;
    }
    return res;
  }
  String get reversed=>String.fromCharCodes(runes.toList().reversed);
}

extension AlmExtensionFuture on Future {

  Future<T> errorNull<T>()=>catchError((e)=>null);

  Future<T> tryTo<T>({val, onError}) {
    Object r = this;
    if (r.isNull) return val;
    return then((Object v) => v.tryTo<T>(val: val, onError: onError)).errorNull();
  }
}

extension AlmExtensionDynamic on dynamic {
  String prettyJson({int indent = 2}) => JsonEncoder.withIndent(' ' * indent, (o) => o.toString()).convert(this);

  void printPretty() => print(prettyJson());
  void echo()=>print(this);

  void printWith([before='',after='']) =>print('$before $this $after');

  T tryTo<T>({val, onError}) {
    try {
      Object s = this;
      Object r = s;
      if (s.isNull) return val;
      if (s.runtimeType != T) {
        if (T==num) r = num.tryParse(s.toString()) ?? val;
        if (T==int) r = s.tryInt(val);
        if (T==double) r = s.tryDouble(val);
        if (T==bool) r = s.tryBool(val);
        if (T==Duration) r = s.tryDuration(val);
        if (T==Map) r = s.tryMap(val);
        if (T==List) r = s.tryList(val);
        if (T==String) r = s.toString();
      }
      if (r.isNull) return val;
      return r as T;
    } catch (e, t) {
      if (onError != null && onError is Function(dynamic, dynamic)) return onError(e, t);
      if (onError != null && onError is Function(dynamic)) return onError(e);
      return val;
    }
  }

  bool isEq(Object other) => this == other;

  Object let(Object Function(Object) f) => f(this);

  bool get isNull => this == null;
  bool get isNotEmptyOrNull => !isEmptyOrNull;

  bool get isEmptyOrNull {
    Object s = this;
    if (s.isNull) return true;
    if (s is List) return s.isEmpty;
    if (s is Map) return s.isEmpty;
    if (s is String) return s.isEmpty;
    return false;
  }

  bool get isString => this is String;

  bool get isList => this is List;

  bool get isMap => this is Map;

  bool get isInt => this is int;

  bool get isDouble => this is double;

  bool get isNotNull => !isNull;

  @Deprecated('use tryTo')
  double tryDouble([double val]) {
    if (isNull) return val;
    Object s = this;
    if (s is num) return s.toDouble();
    return double.tryParse(toString()) ?? val;
  }

  @Deprecated('use tryTo')
  int tryInt([int val]) {
    if (isNull) return val;
    Object s = this;
    if (s is num) return s.toInt();
    var d = s.tryDouble();
    if (d.isNotNull) return d.toInt();
    return val;
  }

  @Deprecated('use tryTo')
  bool tryBool([bool val = false]) {
    Object input = this;
    if (input.isNull) return val;
    if (input is bool) return input;
    if (input is num) {
      if (input == 0) return false;
      return true;
    }
    if (input is String) {
      if (input.isEmpty) return false;
      if (input.toLowerCase() == '0') return false;
      if (input.toLowerCase() == 'false') return false;
      return true;
    }
    return input.isNotNull;
  }

  @Deprecated('use tryTo')
  List<T> tryList<T>([Object val]) {
    if (this is List) return List<T>.from(this);
    var o = Alm.o(this);
    if (o.isNull) return val;
    if (o is List) return List<T>.from(o);
    return o.tryDson(onError: (e) => val);
  }

  @Deprecated('use tryTo')
  Map<K, V> tryMap<K, V>([Object val]) {
    if (this is Map) return Map<K, V>.from(this);
    Object o = this;
    if (o.isNull) return val;
    if (o is Map) return Map<K, V>.from(o);
    return o.tryDson(onError: (e) => val);
  }

  String tryJson() {
    var input = this;
    if (input is String && input.tryCut(1) == '"') return input;
    return jsonEncode(input, toEncodable: (o) => o.toString());
  }

  @Deprecated('use [tryJson] instead')
  String enJson() => tryJson();

  T tryDson<T>({Object Function(Object key, Object value) reviver, onError}) {
    try {
      if (this is String) return jsonDecode(this, reviver: reviver);
      return this;
    } catch (e) {
      if (onError != null) return onError(e);
      rethrow;
    }
  }

  @Deprecated('use [tryDson] instead')
  Object deJson<T>({Object Function(Object key, Object value) reviver, onError}) => tryDson(reviver: reviver, onError: onError);

  @Deprecated('use [tryTo] instead')
  Duration tryDuration([Object val]) {
    Object s = this;
    if (s.isNull) s = val;
    if (s is Duration) return s;
    if (s is num) return s.toDuration();
    if (s is String) return s.toDuration();
    return val;
  }
}


