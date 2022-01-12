import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heart_rate/bloc/auth_bloc.dart';
import 'package:heart_rate/bloc/bottomNavBar.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:heart_rate/utils/AuthDetails.dart';
import 'package:heart_rate/utils/MedicalRecord.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

class AddMedicalRecord extends StatefulWidget {
  const AddMedicalRecord({Key? key}) : super(key: key);

  @override
  _AddMedicalRecordState createState() => _AddMedicalRecordState();
}

class _AddMedicalRecordState extends State<AddMedicalRecord> {
  final TextEditingController age = TextEditingController();
  final TextEditingController restingBP = TextEditingController();
  final TextEditingController cholestrol = TextEditingController();
  final TextEditingController fastingBS = TextEditingController();
  final TextEditingController oldpeak = TextEditingController();
  int maxHR = 153;
  String gender = '';
  String chestPainType = 'Select';
  String restingECG = 'Select';
  String exerciseAngina = 'Select';
  String st_slope = 'Select';

  void set_heartBeat(double bpm) {
    print("gett the bpm ${bpm}");
  }

  void onSubmitData() async {
    try {
      final authToken = Provider.of<AuthenticationBloc>(context, listen: false)
          .authData['user']
          .accessToken;
      Dio dio = Dio();
      dio.options.headers['content-Type'] = 'application/json';
      dio.options.headers["authorization"] = "Bearer ${authToken}";

      Map<String, dynamic> data = {
        "age": int.parse(age.text),
        "restingBP": int.parse(restingBP.text),
        "cholestrol": int.parse(cholestrol.text),
        "fastingBS": int.parse(fastingBS.text),
        "maxHR": maxHR,
        "oldpeak": oldpeak.text,
        "sex": gender,
        "chestPainType": chestPainType,
        "restingECG": restingECG,
        "exerciseAngina": exerciseAngina,
        "st_slope": st_slope
      };

      print(data);

      await dio
          .post("https://heart-failure.up.railway.app/rate-prediction",
              data: data)
          .then((value) {
        print("response from post , ${value.data}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${value.data["heartDisease"] == '1' ? 'You have to immediately go to Dr. for checkup.' : "Congratulations! You have no risk of heart failure yet."}'),
            duration: const Duration(milliseconds: 2000),
            width: 320.0, // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0, // Inner padding for SnackBar content.
              vertical: 12.0,
            ),
            backgroundColor: value.data["heartDisease"] == '1'
                ? Colors.red.shade600
                : Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        );
      });
    } on DioError catch (err) {
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
          backgroundColor: Colors.pinkAccent,
          title: const Text(
            "Add Medical Record",
          ),
          elevation: 4,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFFffffff),
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
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                }
                if (index == 2) {
                  final authProvider = Provider.of<AuthenticationBloc>(context);
                  if (authProvider.authDetails['isAuthenticated'] &&
                      authProvider.authDetails['loading']) {
                    authProvider.logout_user();
                  }
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
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text("Select Gender"),
                          ListTile(
                            title: const Text('Male'),
                            leading: Radio(
                              value: "M",
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = "M";
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Female'),
                            leading: Radio(
                              value: 'F',
                              groupValue: gender,
                              onChanged: (value) {
                                setState(() {
                                  gender = 'F';
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: age,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 15, 15, 3),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                hintText: 'Enter your Age',
                                labelText: "Age"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: chestPainType,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.red),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                chestPainType = newValue!;
                              });
                            },
                            hint: Text("Select Chest pain type"),
                            items: [
                              DropdownMenuItem(
                                  enabled: false,
                                  child: Text("Select Chest pain type"),
                                  value: 'Select'),
                              DropdownMenuItem(
                                  child: Text("Typical Angina"), value: 'TA'),
                              DropdownMenuItem(
                                  child: Text("ATypical Angina"), value: 'ATA'),
                              DropdownMenuItem(
                                  child: Text("Non-Anginal Pain"),
                                  value: 'NAP'),
                              DropdownMenuItem(
                                  child: Text("Asymptomatic"), value: 'ASY'),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: restingBP,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 15, 15, 3),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                hintText: 'Enter you Blood Pressure',
                                labelText: "Blood Pressure"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: cholestrol,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 15, 15, 3),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                hintText: 'Enter your Cholestrol',
                                labelText: "Cholestrol"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: fastingBS,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 15, 15, 3),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                hintText: 'Enter your Fasting Blood Sugar',
                                labelText: "Sugar"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: oldpeak,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 15, 15, 3),
                                border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pinkAccent, width: 2)),
                                hintText: 'Enter your Old Peak',
                                labelText: "Old peak"),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          SizedBox(height: 15),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: restingECG,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.red),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                restingECG = newValue!;
                              });
                            },
                            hint: Text("Select"),
                            items: [
                              DropdownMenuItem(
                                  enabled: false,
                                  child:
                                      Text("Select ElectroCardiogram Results"),
                                  value: 'Select'),
                              DropdownMenuItem(
                                  child: Text("Normal"), value: 'Normal'),
                              DropdownMenuItem(
                                  child: Text("ST-T wave abnormality"),
                                  value: 'ST'),
                              DropdownMenuItem(
                                  child: Text(
                                      "Definite Left ventricular Hypertrophy"),
                                  value: 'LVH'),
                            ],
                          ),
                          SizedBox(height: 15),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: exerciseAngina,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.red),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                exerciseAngina = newValue!;
                              });
                            },
                            hint: Text("Select"),
                            items: [
                              DropdownMenuItem(
                                  enabled: false,
                                  child: Text("Select Exercise Induced Angina"),
                                  value: 'Select'),
                              DropdownMenuItem(child: Text("Yes"), value: 'Y'),
                              DropdownMenuItem(child: Text("No"), value: 'N'),
                            ],
                          ),
                          SizedBox(height: 15),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: st_slope,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            elevation: 16,
                            style: const TextStyle(color: Colors.red),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                st_slope = newValue!;
                              });
                            },
                            hint: Text("Select"),
                            items: [
                              DropdownMenuItem(
                                  enabled: false,
                                  child: Text(
                                      "Select Slope of peak exercise ST Segment"),
                                  value: 'Select'),
                              DropdownMenuItem(
                                  child: Text("Up sloping"), value: 'Up'),
                              DropdownMenuItem(
                                  child: Text("Flat"), value: 'Flat'),
                              DropdownMenuItem(
                                  child: Text("Down sloping"), value: 'down'),
                            ],
                          ),
                          SizedBox(height: 15),
                          ElevatedButton(
                              onPressed: () async {
                                var beat = await Navigator.pushNamed(
                                    context, '/heart_rate');
                                setState(() {
                                  maxHR = int.parse("${beat}");
                                });
                              },
                              child: Text(
                                'Calculate Heart Rate',
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 24),
                              )),
                          SizedBox(height: 15),
                          ElevatedButton(
                              child: Text("Save Medical Record"),
                              onPressed: () {
                                onSubmitData();
                              })
                        ],
                      )))),
        ));
  }
}
