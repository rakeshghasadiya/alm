part of alm;

extension AlmExtensionImage on Image {
  String get info =>'${width}x${height} isVertical:$isVertical ratio:$ratio';

  double get ratio => width / height;

  bool get isHorizontal => width > height;
  bool get isVertical => width < height;

  bool get isSquare => width == height;

  List<int> saveJpeg({int quality = 95}) => encodeJpg(this, quality: quality);

  ///0=argb, 1=abgr, 2=rgba, 3=bgra, 4=rgb, 5=bgr, 6=luminance
  Image convert({int format = 4, bool hasExif = false, bool hasIcc = false}) {
    var _format= Format.values[format];
    return Image.fromBytes(
      width,
      height,
      getBytes(format: _format),
      format: _format,
      iccp: hasIcc ? iccProfile : null,
      exif: hasExif ? exif : null,
    );
  }

  Image rotate(num angle, {Interpolation interpolation = Interpolation.average}) => copyRotate(this, angle, interpolation: interpolation);

  Image resize({int width, int height, Interpolation interpolation = Interpolation.average}) => copyResize(this, width: width, height: height, interpolation: interpolation);

  Image copyTo(Image back,{bool fit=false}){
    var front=this;
    if (front.isVertical!=back.isVertical&&!front.isSquare) {
      front = front.rotate(90);
    }
    var ifCond=fit?front.ratio>back.ratio:front.ratio<back.ratio;
    if (ifCond) {
      front = front.resize(width: back.width);
    } else {
      front = front.resize(height: back.height);
    }
    return front.fitTo(back);
  }

  Image fitTo(Image back,{bool isFitOrCrop=true}){
    var front=this;
    var dstX = (back.width - front.width) / 2;
    var dstY = (back.height - front.height) / 2;
    return copyInto(back, front, dstY: dstY.round(), dstX: dstX.round());
  }

  Image corner(int radius, [int color = 0xffffffff]) {
    var origin=this;
    if (radius <= 0) return origin;
    var hRadius = radius ~/ 2;
    var corner = Image(radius, radius);
    corner.fill(0xffffffff);
    corner = fillCircle(corner, hRadius, hRadius, hRadius, 0xff000000);
    var points = <Point>[];
    for (var x = 0; x < radius; x++) {
      for (var y = 0; y < radius; y++) {
        if (corner.getPixel(x, y) == 0xffffffff) {
          if (x <= hRadius && y <= hRadius) points.add(Point(x, y));
          if (x >= hRadius && y <= hRadius) points.add(Point(origin.width + x - radius, y));
          if (x >= hRadius && y >= hRadius) points.add(Point(origin.width + x - radius, origin.height + y - radius));
          if (x <= hRadius && y >= hRadius) points.add(Point(x, origin.height + y - radius));
        }
      }
    }
    points.forEach((pt) => drawPixel(origin, pt.xi, pt.yi, color));
    return origin;
  }

}
