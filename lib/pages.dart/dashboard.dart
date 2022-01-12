import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:heart_rate/bloc/auth_bloc.dart';
import 'package:heart_rate/bloc/bottomNavBar.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:heart_rate/utils/AuthDetails.dart';
import 'package:heart_rate/utils/MedicalRecord.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<MedicalRecord> weeklyData = [];
  List<MedicalRecord> allMedicalData = [];
  String loading = 'pending';

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    get_weekly_data();
    get_all_data();
  }

  void get_weekly_data() async {
    try {
      final authToken =
          context.watch<AuthenticationBloc>().authData['user'].accessToken;
      Dio dio = new Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer ${authToken}";
      print("await");
      await dio
          .get("https://heart-failure.up.railway.app/week-medical-records")
          .then((value) {
        List<MedicalRecord> weeklyMedicalRecords = [];
        for (var record in value.data['data']) {
          weeklyMedicalRecords.add(new MedicalRecord.fromJson(record));
        }
        print("record ${weeklyMedicalRecords}");
        setState(() {
          weeklyData = weeklyMedicalRecords;
          loading = 'success';
        });
      });
    } on DioError catch (err) {
      loading = 'error';
      if (err.response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${err.response?.data["detail"]}'),
            duration: const Duration(milliseconds: 2000),
            width: 320.0, // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0, // Inner padding for SnackBar content.
              vertical: 12.0,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        );
      }
    }
  }

  void get_all_data() async {
    try {
      final authToken =
          context.watch<AuthenticationBloc>().authData['user'].accessToken;
      Dio dio = new Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer ${authToken}";

      await dio
          .get("https://heart-failure.up.railway.app/all-medical-records")
          .then((value) {
        List<MedicalRecord> allMedicalRecords = [];
        for (var record in value.data['data']) {
          allMedicalRecords.add(new MedicalRecord.fromJson(record));
        }
        setState(() {
          allMedicalData = allMedicalRecords;
          loading = 'success';
        });
      });
    } on DioError catch (err) {
      loading = 'error';
      if (err.response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${err.response?.data["detail"]}'),
            duration: const Duration(milliseconds: 2000),
            width: 320.0, // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0, // Inner padding for SnackBar content.
              vertical: 12.0,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("loading -- ${loading}");
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text(
            "Dashboard",
          ),
          elevation: 4,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Color(0xFFffffff),
        bottomNavigationBar:
            Consumer<BottomNavBarBloc>(builder: (context, provider, child) {
          print('curent ${provider.currentIndex}');
          return BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_rounded),
                label: 'Medical Record',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: 'Logout',
              ),
            ],
            currentIndex: provider.currentIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (int index) {
              if (index != provider.currentIndex) {
                provider.setIndex(index);
                if (index == 1) {
                  Navigator.pushNamed(context, '/addrecord');
                }
              }
            },
          );
        }),
        body: SingleChildScrollView(
          child: SafeArea(
              child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: loading != 'success'
                      ? Container(
                          color: Colors.white,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          ))
                      : Container(
                          color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Consumer<AuthenticationBloc>(
                                    builder: (context, provider, child) {
                                  return Text(
                                      "Welcome ${provider.authData['user'].username} !");
                                }),
                                Container(
                                    color: Colors.blue,
                                    height: 300,
                                    child: DateAndHeartDiseaseChart(
                                        weeklyData: weeklyData)),
                                Text("Your Heart Rate"),
                                Container(
                                    color: Colors.blue,
                                    height: 300,
                                    child: HeartRateVsHeartDisease(
                                      weeklyData: weeklyData,
                                    )),
                                Text("Your Medical History"),
                                Container(
                                  child: ListView.builder(
                                    itemBuilder: (context, index) {
                                      final currentItem = allMedicalData[index];
                                      return MedicalRecordCard(
                                          context, currentItem);
                                    },
                                    itemCount: allMedicalData.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))),
        ));
  }
}

Widget MedicalRecordCard(context, MedicalRecord data) {
  return Card(
      child: Row(
    children: [
      IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
      Text("${DateFormat("dd-MMM-yyyy HH:mm").format(data.createdAt!)}"),
      Text("${data.maxHR}"),
      ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text(
                          'Record at ${DateFormat("dd-MMM-yyyy HH:mm").format(data.createdAt!)}'),
                      content: Column(
                        children: [
                          Text("Heart Disease"),
                          Text("${data.heartDisease == 1 ? "Yes" : "No"}"),
                          Row(
                            children: [
                              Column(
                                children: [Text("Age"), Text("${data.age}")],
                              ),
                              Column(
                                children: [
                                  Text("Gender"),
                                  Text(
                                      "${data.gender == 'M' ? "Male" : "Female"}")
                                ],
                              )
                            ],
                          ),
                          Text("Resting Blood Pressure "),
                          Text("${data.restingBP}"),
                          Text("Cholestrol"),
                          Text("${data.cholestrol}"),
                          Text("Fasting Blood Sugar "),
                          Text("${data.fastingBS}"),
                          Text("Old peak"),
                          Text(" ${data.oldpeak}"),
                          Text("Maximum Heart Rating"),
                          Text("${data.maxHR}"),
                          Text("Chest Pain Type"),
                          Text("${data.chestPainType}"),
                          Text("Resting Electro Cardiographic "),
                          Text("${data.restingECG}"),
                          Text("Exercise Angine"),
                          Text("${data.exerciseAngina}"),
                          Text("ST_Slope"),
                          Text("${data.stSlope}"),
                        ],
                      ),
                    ));
          },
          child: Text("View Details"))
    ],
  ));
}

class DateAndHeartDiseaseChart extends StatelessWidget {
  final List<MedicalRecord> weeklyData;
  DateAndHeartDiseaseChart({Key? key, required this.weeklyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      [
        charts.Series<MedicalRecord, String>(
          id: 'Values',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (MedicalRecord values, _) {
            DateTime value = values.createdAt!;
            return DateFormat('MMM dd, HH:mm').format(value);
          },
          measureFn: (MedicalRecord values, _) => values.heartDisease,
          data: weeklyData,
        )
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              zeroBound: false, desiredMaxTickCount: 3)),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
      ),
      animate: false,
    );
  }
}

class HeartRateVsHeartDisease extends StatelessWidget {
  final List<MedicalRecord> weeklyData;
  HeartRateVsHeartDisease({Key? key, required this.weeklyData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return new charts.TimeSeriesChart(
      [
        charts.Series<MedicalRecord, DateTime>(
          id: 'Values',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (MedicalRecord values, _) {
            DateTime value = values.createdAt!;
            return value;
            // return DateFormat('MMM dd, HH:mm').format(value);
          },
          measureFn: (MedicalRecord values, _) => values.maxHR,
          data: weeklyData,
        )
      ],
      animate: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false)),
    );
  }
}
