part of alm;

extension AlmExtensionResponse on Response {
  T toJson<T>() => jsonDecode(body);
}

extension AlmExtensionStreamedResponse on StreamedResponse {
  Future<Response> toResponse() => Response.fromStream(this);

  Future<Response> toDownload(File file, {int size,progress}) async {
    var total = size ?? headers.get<int>('content-length');
    var fd = file.openWrite();
    var rs = 0;
    var t = Alm.duration;
    await for (var bytes in stream) {
      rs += bytes.length;
      fd.add(bytes);
      if (progress != null) {
        var per = total != null ? (rs / (total / 100)) : 0;
        if (progress is VCallbackT2) progress(rs, per);
        if (progress is VCallbackT1) progress(rs);
      }
    }
    await fd?.close();
    var body={
      'url':request.url,
      'path':file.path,
      'start':t,
      'end':t.elapse,
      'size':rs,
      'speed':(rs / t.elapseSec).round(),
    };
    return Response(body.enJson(), statusCode, request: request, headers: headers, isRedirect: isRedirect, persistentConnection: persistentConnection, reasonPhrase: reasonPhrase);
  }
}

extension AlmExtensionBaseRequest on BaseRequest {
  BaseRequest setContentType(String s) {
    headers['Content-Type'] = s;
    return this;
  }

  BaseRequest setUserAgent(String s) {
    headers['User-Agent'] = s;
    return this;
  }

  BaseRequest setHeaders([Map map]) {
    headers.mergeInto(map);
    return this;
  }

  Future<StreamedResponse> sendTo(BaseClient client)=>client.send(this);

}

extension AlmExtensionBaseClient on BaseClient {}

extension AlmExtensionMultipartRequest on MultipartRequest {
  MultipartRequest setFields(Map fields) {
    fields.forEach((key, value) {
      if (value is File) {
        setFile(key.toString(), value);
      } else {
        setField(key.toString(), value);
      }
    });
    return this;
  }

  MultipartRequest setField(String key, Object value) {
    fields[key] = value.toString();
    return this;
  }

  MultipartRequest setFile(String key, File file, [fieldTypes]) {
    var contentType = Alm.mimeType(file.path, fieldTypes ?? 'application/octet-stream');
    var length = file.lengthSync();
    var stream = ByteStream(file.openRead());
    setStream(key, stream, length, filename: file.basename(), contentType: MediaType.parse(contentType));
    return this;
  }

  MultipartRequest setStream(String field, Stream<List<int>> stream, int length, {String filename, MediaType contentType}) {
    files.add(MultipartFile(field, stream, length, filename: filename, contentType: contentType));
    return this;
  }
}

extension AlmExtensionRequest on Request {
  Request setBody([Object info]) {
    if (info.isNotNull) {
      if (info is String) {
        body = info;
      } else if (info is List) {
        bodyBytes = info.cast<int>();
      } else if (info is Map) {

        var ct = headers.get<String>('content-type',headers.get<String>('Content-Type',''));
        if (ct.contains('x-www-form-urlencoded')) {
          body = info.toQuery();
        } else if (ct.contains('json')) {
          body = info.enJson();
        } else {
          setContentType('application/json');
          body = info.enJson();
        }
      } else {
        throw ArgumentError('${url} Invalid request body "$info".');
      }
    }
    return this;
  }
}

/// todo
class Http{



}
