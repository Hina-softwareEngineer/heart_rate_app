import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HeartRateCalculator extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HeartRateCalculator({Key? key, required this.cameras})
      : super(key: key);

  @override
  _HeartRateCalculatorState createState() => _HeartRateCalculatorState();
}

class _HeartRateCalculatorState extends State<HeartRateCalculator> {
  bool toggled = false;
  List<SensorValue> alldata = [];
  late CameraController _cameraController =
      CameraController(widget.cameras[0], ResolutionPreset.max);
  bool _processing = false;
  String _start = 'Start';
  double bpm = 0;

  double _alpha = 0.3;

  Future<void> _initController() async {
    try {
      List _cameras = await availableCameras();
      _cameraController =
          CameraController(_cameras.first, ResolutionPreset.max);
      await _cameraController.initialize();
      Future.delayed(Duration(milliseconds: 500)).then((onValue) {
        _cameraController.setFlashMode(FlashMode.torch);
      });
      _cameraController.startImageStream((CameraImage image) {
        if (!_processing) {
          setState(() {
            _processing = true;
          });
          _scanImage(image);
        }
      });
    } catch (Exception) {
      print(Exception);
    }
  }

  _scanImage(CameraImage image) {
    double avg =
        image.planes.first.bytes.reduce((value, element) => value + element) /
            image.planes.first.bytes.length;
    if (alldata.length >= 50) {
      alldata.removeAt(0);
    }
    setState(() {
      alldata.add(SensorValue(DateTime.now(), avg));
    });

    Future.delayed(Duration(milliseconds: 1000 ~/ 30)).then((onValue) {
      setState(() {
        _processing = false;
      });
    });
  }

  disposeController() {
    _cameraController.dispose();
  }

  toggle() {
    _initController().then((onValue) {
      Wakelock.enable();
      setState(() {
        toggled = true;
        _processing = false;
      });
      _updateBPM();
    });
  }

  untoggle() {
    disposeController();
    Wakelock.disable();
    setState(() {
      toggled = false;
      _processing = false;
      _start = 'Start Again';
    });
  }

  _updateBPM() async {
    List<SensorValue> _values;
    double _avg;
    int _n;
    double _m;
    double _threshold;
    double _bpm;
    int _counter;
    int _previous;
    while (toggled) {
      _values = List.from(alldata);
      _avg = 0;
      _n = _values.length;
      _m = 0;
      for (var value in _values) {
        _avg += value.value / _n;
        if (value.value > _m) _m = value.value;
      }
      _threshold = (_m + _avg) / 2;
      _bpm = 0;
      _counter = 0;
      _previous = 0;
      for (int i = 1; i < _n; i++) {
        if (_values[i - 1].value < _threshold &&
            _values[i].value > _threshold) {
          if (_previous != 0) {
            _counter++;
            _bpm +=
                60000 / (_values[i].time.millisecondsSinceEpoch - _previous);
          }
          _previous = _values[i].time.millisecondsSinceEpoch;
        }
      }
      if (_counter > 0) {
        _bpm = _bpm / _counter;
        setState(() {
          bpm = (1 - _alpha) * _bpm + _alpha * _bpm;
        });
      }
      await Future.delayed(Duration(milliseconds: (1000 * 50 / 30).round()));
    }
  }

  void onClickSave() {
    Navigator.pop(context, bpm.round());
  }

  void onCalculateBPM() {
    setState(() {
      _start = 'Stop';
    });
    toggle();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            "Calculate Heart Beat",
          ),
          elevation: 4,
        ),
        backgroundColor: const Color(0xFFffffff),
        body: SafeArea(
            child: Container(
                child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Text(
                  'Ensure that place your finger on torch and camera before starting. To save heart beat, click on Save.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          if (toggled) {
                            untoggle();
                          } else {
                            onCalculateBPM();
                          }
                        },
                        child: Text("${_start}")),
                  ),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                _start == 'Start'
                                    ? Colors.grey.shade400
                                    : Colors.red)),
                        onPressed: () {
                          if (_start != 'Start') {
                            onClickSave();
                          }
                        },
                        child: Text("Save")),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: 128,
                  color: Colors.red,
                ),
                SizedBox(width: 30),
                Text(
                    "${(bpm > 30 && bpm < 150 ? bpm.round().toString() : '0')}",
                    style:
                        TextStyle(fontSize: 60, fontWeight: FontWeight.w500)),
                Text(" bpm"),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(255, 0, 0, .2)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChartComp(allData: alldata),
              ),
            ))
          ],
        ))));
  }
}

class ChartComp extends StatelessWidget {
  final List<SensorValue> allData;

  const ChartComp({Key? key, required this.allData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
        [
          charts.Series<SensorValue, DateTime>(
            id: 'Values',
            colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
            domainFn: (SensorValue values, _) => values.time,
            measureFn: (SensorValue values, _) => values.value,
            data: allData,
          )
        ],
        animate: false,
        // Optionally pass in a [DateTimeFactory] used by the chart. The factory
        // should create the same type of [DateTime] as the data provided. If none
        // specified, the default creates local date time.
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false),
          // renderSpec: charts.NoneRenderSpec(),
        ),
        behaviors: [
          new charts.ChartTitle('Time',
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
          new charts.ChartTitle('Beat',
              behaviorPosition: charts.BehaviorPosition.start,
              titleStyleSpec: charts.TextStyleSpec(
                fontSize: 14,
              ),
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea)
        ],
        domainAxis: new charts.DateTimeAxisSpec());
  }
}

class SensorValue {
  final DateTime time;
  final double value;

  SensorValue(this.time, this.value);
}
