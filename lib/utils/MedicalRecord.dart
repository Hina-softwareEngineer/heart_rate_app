import 'dart:ffi';

import 'package:intl/intl.dart';

class MedicalRecord {
  String? sId;
  int? age;
  int? restingBP;
  int? cholestrol;
  int? fastingBS;
  int? maxHR;
  double? oldpeak;
  String? gender;
  String? chestPainType;
  String? restingECG;
  String? exerciseAngina;
  String? stSlope;
  int? heartDisease;
  DateTime? createdAt;
  String? userId;

  MedicalRecord(
      {this.sId,
      this.age,
      this.restingBP,
      this.cholestrol,
      this.fastingBS,
      this.maxHR,
      this.oldpeak,
      this.gender,
      this.chestPainType,
      this.restingECG,
      this.exerciseAngina,
      this.stSlope,
      this.heartDisease,
      this.createdAt,
      this.userId});

  MedicalRecord.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    age = json['age'];
    restingBP = json['restingBP'];
    cholestrol = json['cholestrol'];
    fastingBS = json['fastingBS'];
    maxHR = json['maxHR'];
    oldpeak = json['oldpeak'];
    gender = json['gender'];
    chestPainType = json['chestPainType'];
    restingECG = json['restingECG'];
    exerciseAngina = json['exerciseAngina'];
    stSlope = json['st_slope'];
    heartDisease = json['heartDisease'];
    DateTime formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(json['created_at']);
    createdAt = formattedDate
        .add(Duration(hours: formattedDate.timeZoneOffset.inHours));
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['age'] = this.age;
    data['restingBP'] = this.restingBP;
    data['cholestrol'] = this.cholestrol;
    data['fastingBS'] = this.fastingBS;
    data['maxHR'] = this.maxHR;
    data['oldpeak'] = this.oldpeak;
    data['gender'] = this.gender;
    data['chestPainType'] = this.chestPainType;
    data['restingECG'] = this.restingECG;
    data['exerciseAngina'] = this.exerciseAngina;
    data['st_slope'] = this.stSlope;
    data['heartDisease'] = this.heartDisease;
    data['created_at'] = this.createdAt?.toUtc();
    data['user_id'] = this.userId;
    return data;
  }
}
