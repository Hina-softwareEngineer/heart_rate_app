import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:heart_rate/bloc/auth_bloc.dart';
import 'package:heart_rate/bloc/bottomNavBar.dart';
import 'package:heart_rate/utils/MedicalRecord.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

      await dio
          .get("https://heart-failure.up.railway.app/week-medical-records")
          .then((value) {
        List<MedicalRecord> weeklyMedicalRecords = [];
        for (var record in value.data['data']) {
          weeklyMedicalRecords.add(new MedicalRecord.fromJson(record));
        }

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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text(
            "Dashboard",
          ),
          elevation: 4,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Color(0xFFffffff),
        bottomNavigationBar:
            Consumer<BottomNavBarBloc>(builder: (context, provider, child) {
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
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            onTap: (int index) {
              if (index != provider.currentIndex) {
                provider.setIndex(index);
                if (index == 1) {
                  Navigator.pushNamed(context, '/addrecord');
                }
                if (index == 2) {
                  Provider.of<AuthenticationBloc>(context, listen: false)
                      .logout_user();
                  Navigator.pushReplacementNamed(context, '/auth');
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
                              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                              child:
                                  CircularProgressIndicator(color: Colors.red),
                            ),
                          ))
                      : Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Consumer<AuthenticationBloc>(
                                    builder: (context, provider, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Welcome",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                          " ${provider.authData['user'].username} !",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  );
                                }),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 3.0,
                                        ),
                                      ]),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 0, 0, 0),
                                        child: Text("Daily Heart Failure Risk",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Container(
                                          height: 300,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: DateAndHeartDiseaseChart(
                                                weeklyData: weeklyData),
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 3.0,
                                        ),
                                      ]),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          "Daily Heart Beat",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Container(
                                          height: 300,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: HeartRateVsHeartDisease(
                                              weeklyData: weeklyData,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text("Medical History",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(
                                  height: 10,
                                ),
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
      elevation: 3.0,
      color: data.heartDisease == 1 ? Colors.red[100] : Colors.green[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite),
            color: Colors.red,
          ),
          Text(
            "${DateFormat("dd-MMM-yyyy HH:mm").format(data.createdAt!)}",
            style: TextStyle(fontSize: 12),
          ),
          Text("Rate : ${data.maxHR}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text(
                            'Record on "${DateFormat("MMM dd, yyyy at HH:mm").format(data.createdAt!)}"',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Heart Disease",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.heartDisease == 1 ? "Yes" : "No"}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: data.heartDisease == 1
                                          ? Colors.red
                                          : Colors.green)),
                              SizedBox(
                                height: 13,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text("Age",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      Text("${data.age}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("Gender",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      Text(
                                          "${data.gender == 'M' ? "Male" : "Female"}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black))
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Resting Blood Pressure ",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.restingBP} mm Hg",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Cholestrol",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.cholestrol} mm/dl",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Fasting Blood Sugar ",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.fastingBS} mg/dl",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Old peak",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text(" ${data.oldpeak}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Maximum Heart Rating",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.maxHR} bpm",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Chest Pain Type",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.chestPainType}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Resting Electro Cardiographic ",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.restingECG}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("Exercise Angine",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text(
                                  "${data.exerciseAngina == 'N' ? 'No' : "Yes"}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                height: 13,
                              ),
                              Text("ST_Slope",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text("${data.stSlope}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                            ],
                          ),
                        ));
              },
              icon: Icon(Icons.more_vert))
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
      behaviors: [
        new charts.ChartTitle('DateTime',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
        new charts.ChartTitle('Risk',
            behaviorPosition: charts.BehaviorPosition.start,
            titleStyleSpec: charts.TextStyleSpec(
              fontSize: 14,
            ),
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea)
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              zeroBound: false, desiredMaxTickCount: 3)),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
      ),
      animate: true,
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
      behaviors: [
        new charts.ChartTitle('DateTime',
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleStyleSpec: charts.TextStyleSpec(fontSize: 14),
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
        new charts.ChartTitle('Heart Beat',
            behaviorPosition: charts.BehaviorPosition.start,
            titleStyleSpec: charts.TextStyleSpec(
              fontSize: 14,
            ),
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
      ],
      animate: true,
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false)),
    );
  }
}
