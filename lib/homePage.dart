import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:heart_rate/charts.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool toggled = false;
  List<SensorValue> alldata = [];
  late CameraController _cameraController =
      CameraController(widget.cameras[0], ResolutionPreset.max);
  bool _processing = false;
  double bpm = 0;

  double _alpha = 0.3;

  @override
  void initState() {
    super.initState();
  }

  // Future<void> initializeCameras() async {
  //   WidgetsFlutterBinding.ensureInitialized();

  //   List cameras = await availableCameras();
  //   _cameraController = CameraController(cameras.first, ResolutionPreset.max);
  // }

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
        print("bpppm $_bpm");
        setState(() {
          bpm = (1 - _alpha) * _bpm + _alpha * _bpm;
        });
      }
      await Future.delayed(Duration(milliseconds: (1000 * 50 / 30).round()));
    }
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("camera controller $_cameraController");
    print(
        "${_cameraController.cameraId}, $bpm, ${!_cameraController.value.isInitialized}");
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                Expanded(
                    child: Center(
                  child: !_cameraController.value.isInitialized
                      ? Container()
                      : CameraPreview(_cameraController),
                )),
                Expanded(
                    child: Center(
                  child: Text(
                    (bpm > 30 && bpm < 150
                        ? bpm.round().toString()
                        : bpm.round().toString()),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ))
              ],
            )),
            Expanded(
                child: Center(
                    child: IconButton(
                        icon: Icon(
                            toggled ? Icons.favorite : Icons.favorite_border),
                        color: Colors.red,
                        iconSize: 128,
                        onPressed: () {
                          if (toggled) {
                            untoggle();
                          } else {
                            toggle();
                          }
                        }))),
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.black),
              child: ChartComp(allData: alldata),
            )),
          ],
        ),
      ),
    );
  }
}
