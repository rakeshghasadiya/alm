part of alm;


@Deprecated('use duration')
class AlmTime{
  DateTime start=DateTime.now();
  DateTime get now=>DateTime.now();

  double get elapseMs => double.parse((elapseMc/1000).toStringAsFixed(3));
  double get elapseSec => double.parse((elapseMs/1000).toStringAsFixed(3));
  double get elapseMc => (now.microsecondsSinceEpoch - start.microsecondsSinceEpoch).toDouble();
  Duration get elapseDuration =>now.difference(start);

  void reset(){
    start=DateTime.now();
  }

  @override
  String toString() =>start.toString();
}