part of alm;

///
/// [Alm] dart lib for developers tool
///

typedef VCallbackT = dynamic Function();
typedef VCallbackT0<T> = dynamic Function([T]);
typedef VCallbackT1<T> = dynamic Function(T);
typedef VCallbackT2<T, Y> = dynamic Function(T, Y);
typedef VCallbackT3<T, Y, R> = dynamic Function(T, Y, R);

class Alm {
  static String version = '1.0.0';

  static bool isWeb = identical(0, 0.0);

  @Deprecated('use tryTo')
  static Object o(obj) => obj;

  ///--------------------------------------------Logger--------------------------------------------

  static Future<void> e(Object msg) => printLog('$times [E]: $msg');

  static Future<void> d(Object msg) => printLog('$times [D]: $msg');

  static Future<void> i(Object msg) => printLog('$times [I]: $msg');

  static Function(dynamic) printLog = (Object msg) => print(msg);

  ///--------------------------------------------Filer--------------------------------------------

  static var pubSpecVersion = file('pubspec.yaml').readAsLinesSync().where((e) => e.startsWith('version')).first.replaces(['version', ':', ' ']);
  static var publishVersion = file('publish.sh').readAsLinesSync().where((e) => e.startsWith('version')).first.replaces(['version', '"', '=']);
  static var buildVersion = file('pubPro.sh').readAsLinesSync().where((e) => e.startsWith('version')).first.replaces(['version', '"', '=']);
  static bool isLocalUtc = false;

  static Duration get duration {
    var t = timedate();
    return Duration(hours: t.hour, minutes: t.minute, seconds: t.second, milliseconds: t.millisecond, microseconds: t.microsecond);
  }

  static int get time => timedate().millisecondsSinceEpoch;

  static int get timem => timedate().microsecondsSinceEpoch;

  static String get times => Alm.timedate().toString().split('.').first;

  static String get AmPm => timedate().hour > 12 ? 'PM' : 'AM';

  ///Use [delay] instead
  @deprecated
  static Future<T> delaySecond<T>([double second = 1, dynamic computation]) => Future.delayed(second.toDuration(), computation);

  static Future<T> delay<T>([double second = 1, dynamic computation]) => Future.delayed(second.toDuration(), computation);

  static T tryWith<T>(VCallbackT func, {onError, value}) {
    try {
      return func();
    } catch (e) {
      if (onError != null) return onError(e);
    }
    return value;
  }

  static var onTimeoutNull = ([v]) => null;

  static Map _config = {};

  static Map get config {
    var fileConfig = file('.config.json');
    if (fileConfig.existsSync()) {
      _config = fileConfig.readAsStringSync().deJson();
    } else {
      fileConfig.writeJson({'version': version, 'timeId': timeId()});
    }
    return _config;
  }

  static final Map<String, dynamic> _envs = {};

  static Map<String, dynamic> get envs {
    _envs.mergeInto(Platform.environment);
    return _envs;
  }

  static T env<T>(String key, [Object val]) => envs.get<T>(key,val);

  ///
  ///=========================== Type ===========================
  ///

  static String type([dynamic o]) {
    if (o == null) return 'null';
    return '${o.runtimeType}';
  }

  static Map success(Object s, {dynamic msg = 'success'}) => {'msg': msg, 'code': 1, 'result': s};

  static bool isSuccess(Object o) {
    var r = o.tryTo<Map>();
    if (r.has('code') || r.has('status')) {
      var t = r.get<int>('code') ?? r.get<int>('status');
      return t.isEq(1);
    }
    return false;
  }

  static Map error(Object s, {dynamic msg = 'error'}) => {'msg': s, 'code': -1, 'result': s};

  static bool isError(Object o) => !isSuccess(o);

  ///
  ///=========================== File ===========================
  ///

  static File file(String path, {@Deprecated('use auto instead') bool autoDir = false, bool auto = false}) {
    var r = File(path);
    if ((autoDir || auto) && !r.parent.existsSync()) r.parent.createSync(recursive: true);
    return r;
  }

  static Directory dir(String path, {@Deprecated('use auto instead') bool autoDir = false, bool auto = false}) {
    var r = Directory(path);
    if ((autoDir || auto) && !r.existsSync()) r.createSync(recursive: true);
    return r;
  }

  ///
  ///=========================== Random ===========================
  ///

  static final int RandomId = Random().nextInt(0xFFFFFFFF);
  static int _current_increment = RandomId;

  static int get nextIncrement => _current_increment++;

  static String get objectId => '${timem.toOctet()}${nextIncrement.toOctet()}';

  @Deprecated('just use nextInt nextDouble nextBool')
  static Random get kRandom => Random(timem);

  static int nextInt(int max) {
    var i = Random(timem).nextInt(max);
    if (i == 0) return 1;
    return i;
  }

  static double nextDouble() => Random(timem).nextDouble();

  static bool nextBool() => Random(timem).nextBool();

  static String nextString(int length, {bool isCapital = false}) => ''.random(length, isCapital: isCapital);

  static List<String> randomNames = Alm_DataNames;
  static List<String> randomCountries = Alm_DataCountries;

  ///
  ///=========================== Time ===========================
  ///
  static DateTime timedate([dynamic input]) {
    if (input != null) {
      if (input is DateTime) return input;
      if (input is Duration) {
        if (isLocalUtc) return DateTime.now().toUtc().add(input);
        return DateTime.now().add(input);
      }
      if (input is int) return DateTime.fromMillisecondsSinceEpoch(input);
      if (!(input is String)) throw Exception('Wops! support only [int,duration,string]; not these [${input.runtimeType}] !!!');
      return DateTime.parse(input);
    }
    if (isLocalUtc) return DateTime.now().toUtc();
    return DateTime.now();
  }

  /// The y=year [0001..infinity].
  /// The m=month [1..12].
  /// The d=day of the month [1..31].
  /// The h=hour of the day, expressed as in a 24-hour clock [0..23].
  /// The i=minute [0...59].
  /// The s=second [0...59].
  /// The ms=millisecond [0...999].
  /// The us=microsecond [0...999].
  static String format(String s, {dynamic input, fx = ''}) {
    var date = timedate(input);

    s = s.replaceAll('${fx}w', WEEKS[date.weekday - 1]);
    s = s.replaceAll('${fx}q', MOONS[date.month - 1]);

    s = s.replaceAll('${fx}ms', date.millisecond.digits(3));
    s = s.replaceAll('${fx}us', date.microsecond.digits(3));

    s = s.replaceAll('${fx}y', date.year.digits(4));
    s = s.replaceAll('${fx}m', date.month.digits(2));
    s = s.replaceAll('${fx}d', date.day.digits(2));

    s = s.replaceAll('${fx}h', date.hour.digits(2));
    s = s.replaceAll('${fx}i', date.minute.digits(2));
    s = s.replaceAll('${fx}s', date.second.digits(2));
    return s;
  }

  static String timeId([dynamic input, String jo = '-']) => [format('ymd'), format('his'), input ?? nextString(10)].join(jo).toUpperCase();

  @Deprecated('use times instead')
  static String timehis([dynamic input]) => format('h:i:s', input: input);

  @Deprecated('use times instead')
  static String timestamp([dynamic input]) => timedate(input).toString();

  @Deprecated('use times instead')
  static String timeymd([dynamic input]) => format('y-m-d', input: input);

  @Deprecated('use time')
  static int timeint([dynamic input]) => timedate(input).millisecondsSinceEpoch;

  ///
  ///=========================== Token ===========================
  ///

  static String tokenGen(String sign, {Duration duration}) {
    var expired = duration ?? Duration(days: 7);
    return [expired.inMilliseconds.toRadixString(16), sign, time.toRadixString(16)].join('-');
  }

  static String tokenSign(String token) {
    try {
      if (token.isEmptyOrNull) return null;
      var tokens = token.split('-');
      if (tokens.length != 3) return null;
      return tokens.get(1);
    } catch (e) {
      return null;
    }
  }

  static bool tokenExpired(String token) {
    try {
      if (token.isEmptyOrNull) return true;
      var tokens = token.split('-');
      if (tokens.length != 3) return true;
      var expire = int.parse(tokens.first, radix: 16);
      var timed = int.parse(tokens.last, radix: 16);
      return (time - timed) > expire;
    } catch (e) {
      return true;
    }
  }

  ///
  ///=========================== Utilities|Convert|Math|Numbers ===========================
  ///

  static num px2cm(num m, [num dpi = 2.54]) => m / dpi;

  static num px2m(num m, [num dpi = 0.254]) => px2cm(m, dpi);

  static int m2px(num m, [int dpi = 300]) => ((dpi / 0.254) * m).round();

  static int cm2px(num cm, [int dpi = 300]) => ((dpi / 2.54) * cm).round();

  static int mm2px(num mm, [int dpi = 300]) => ((dpi / 25.4) * mm).round();

  static int lerpInt(int minV, int maxV, int value) => max(minV, min(value, maxV));

  static num degToRad(num deg) => deg * (pi / 180.0);

  static void gitIgnore(String path, {File gitignore}) {
    var _gitignore = gitignore ?? file('.gitignore');
    if (_gitignore.existsSync()) {
      var liens = _gitignore.readAsLinesSync();
      if (!liens.contains(path)) {
        _gitignore.writeAsStringSync(['', '#$path at ${times}', path, ''].join('\n'), mode: FileMode.append);
      }
    }
  }

  static bool needUpgrade(String old, String ver) {
    var upgrade = false;
    if (old != ver) {
      var nvl = ver.split('.');
      var ovl = old.split('.');
      if (nvl.length != ovl.length) {
        upgrade = true;
      } else {
        for (var i = 0; i < nvl.length; i++) {
          var nvln = int.tryParse(nvl[i]) ?? 0;
          var ovln = int.tryParse(ovl[i]) ?? 0;
          if (nvln > ovln) {
            upgrade = true;
            break;
          }
          if (nvln < ovln) break;
        }
      }
    }
    return upgrade;
  }

  static String kNum(num ip) {
    if (ip.isNull) return '0';
    var size = ip / 1.0;

    var z = size / 100000000000000;
    var j = size / 1000000000000;
    var t = size / 10000000000;
    var b = size / 100000000;
    var m = size / 1000000;
    var w = size / 10000;
    var k = size / 1000;

    if (z >= 100) return z.toStringAsFixed(0) + 'z';
    if (j >= 100) return j.toStringAsFixed(0) + 'j';
    if (t >= 100) return t.toStringAsFixed(0) + 't';
    if (b >= 100) return b.toStringAsFixed(0) + 'b';
    if (m >= 100) return m.toStringAsFixed(0) + 'm';
    if (w >= 100) return w.toStringAsFixed(0) + 'w';
    if (k >= 100) return k.toStringAsFixed(0) + 'k';
    return ip.toStringAsFixed(0).toString();
  }

  static List<String> WEEKS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static List<String> MOONS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String GMT([dynamic input]) => format('%w, %d %q %y %h:%i:%s GMT', input: input, fx: '%');

  static String ossCode(String sec, String option) => base64Encode(Hmac(sha1, sec.codeUnits).convert(option.codeUnits).bytes);

  ///--------------------------------------------HTTP--------------------------------------------

  static Function(Uri) httpProxy;
  static BaseClient get httpClient=>baseClient();
  static Duration httpConnectionTimeout = Duration(seconds: 5);

  static BaseClient baseClient() {
    BaseClient cli;
    if (Alm.isWeb) {
      cli=Client();
    }else{
      var inner = HttpClient();
      inner.findProxy = Alm.httpProxy;
      inner.connectionTimeout = httpConnectionTimeout;
      cli = IOClient(inner);
    }
    return cli;
  }

  static Future<T> http<T>(String method, url, {Map headers,File file,Object body,Object upload,BaseClient client,progress,size,bool debug=false}) async {
    var _client=client??httpClient;
    if(debug)  d('Req[$T-${method}]:${url}');
    BaseRequest req;
    if(upload.isNotNull){
      req=MultipartRequest(method.toUpperCase(), url.toString().toUri())..setHeaders(headers)..setFields(upload);
    }else{
      req = Request(method.toUpperCase(), url.toString().toUri())..setHeaders(headers)..setBody(body);
    }
    Object ret;
    if(T == Request){
      ret=req;
    }else{
      var stream=await _client.send(req);
      if(T == StreamedResponse) {
        ret=stream;
      }else{
        Response res;
        if(file.isNotNull){
          res=await stream.toDownload(file,size: size,progress: progress);
        }else{
          res=await stream.toResponse();
        }
        if(T == Response){
          ret=res;
        }else{
          ret=res.body.tryTo<T>();
        }
      }
    }
    if(debug)  d('Res[$T-$method}]:${ret}');
    return ret as T;
  }

  static Future<T> post<T>(url, {body,Map headers,bool debug=false})=>http<T>('post', url,headers: headers,body:body,debug:debug);
  static Future<T> get<T>(url, {Map headers,bool debug=false})=>http<T>('get', url,headers: headers,debug:debug);

  static Future<T> download<T>(url, File file,{String method = 'get', Map<String, String> headers,Object body, int size, bool isCheckSize = false, progress,bool debug=false}) async {
    if (isCheckSize && size.isNull) {
      size = await http<Response>('head', url, headers: {'Accept-Encoding': 'br'}.mergeInto(headers),debug:debug).then((res) => res.headers.get<int>('content-length'));
    }
    return http<T>(method,url,headers: headers,body: body,file: file,size: size,progress: progress,debug:debug);
  }

  static Future<T> upload<T>(url, Map<String, dynamic> fields, {Map<String, String> headers,bool debug=false}) =>http<T>('post',url,headers: headers,upload: fields,debug:debug);

  static String mimeType(String path, [String value, List<int> headerBytes]) => lookupMimeType(path, headerBytes: headerBytes) ?? value;

  ///--------------------------------------------IDFile--------------------------------------------
  static String idServer = '01';

  static String idPath(String id) {
    var ids = id.split('-');
    var ret = '';
    if (ids.first.isNotEmpty) ret += '${ids.first}/';
    if (ids.length > 1) ret += '${ids[1]}/';
    if (ids.length > 3) ret += '${ids.trySub(2, -1).join('-')}';
    return '${ret}.${ids.last}';
  }

  static String idExt(String id) => id.split('-').last;

  static String idExtTo(String id, String to) => (id.split('-').trySub(0, -1)..add(to)).join('-').toUpperCase();

  static File idFile(String id, {bool check = false, String path = 'res/'}) {
    var ret = Alm.file('$path${idPath(id)}', auto: true);
    if (check && !ret.existsSync()) throw Exception('id:$id not found!');
    return ret;
  }

  static String idFromId(String id, String fid) {
    var ids = id.split('-');
    var ext = ids.last;
    var fids = fid.split('.');
    if (fids.length >= 2) {
      ext = fids.last;
      fids.removeLast();
    }
    var nid = <String>[...ids.trySub(0, -1), ...fids, ext];
    return nid.join('-').toUpperCase().replaces('--', '-');
  }

  static String idSerNew(String id, {String ser}) {
    var ids = id.split('-');
    var ext = ids.last;
    if (ext.isEmpty || ext == null.toString()) ext = 'none';
    return '${ser.tryTo(val: idServer)}-${timeId(''.random(4, isCapital: true))}-${ext.tryCut(5)}'.toUpperCase();
  }

  static String idUrl(String id) => '/${idPath(id)}';

  ///--------------------------------------------Checker--------------------------------------------

  static Map<String, Duration> mapChecker = {};

  static bool checkerIn(String key, [double second = 1]) {
    if (mapChecker.has(key)) {
      var time = mapChecker[key];
      if (time.timeOut(second.toDuration())) {
        mapChecker[key] = duration;
        return true;
      }
      return false;
    }
    mapChecker[key] = duration;
    return true;
  }

  static bool checkerOut(String key, [double second = 1]) => !checkerIn(key, second);

  @Deprecated('use checker[In|Out]')
  static bool checker(String key, [double second = 1]) => !checkerIn(key, second);
}
