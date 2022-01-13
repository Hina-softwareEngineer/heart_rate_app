import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_rate/bloc/auth_bloc.dart';
import 'package:heart_rate/bloc/bottomNavBar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heart_rate/pages.dart/addrecord.dart';
import 'package:heart_rate/pages.dart/authentication.dart';
import 'package:heart_rate/pages.dart/dashboard.dart';
import 'package:heart_rate/pages.dart/heartrate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:heart_rate/utils/firebase_message.dart';
import 'package:overlay_support/overlay_support.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationBloc()),
        ChangeNotifierProvider(create: (context) => BottomNavBarBloc()),
      ],
      child: const MyApp(),
    ),
  );

  // runApp(ChangeNotifierProvider(
  //   create: (context) => AuthenticationBloc(),
  //   child: const MyApp(),
  // ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() {
    context.read<AuthenticationBloc>().auth_load();
  }

  @override
  Widget build(BuildContext context) {
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();

    return const Routes();
  }
}

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  _RoutesState createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  String loading = 'idle';
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    final authData = context.watch<AuthenticationBloc>().authData;

    if (authData['loading'] == 'success' && authData['isAuthenticated']) {
      setState(() {
        loading = 'success';
        isAuthenticated = authData['isAuthenticated'];
      });
    } else {
      setState(() {
        loading = 'error';
        isAuthenticated = authData['isAuthenticated'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (loading == 'idle'
        ? Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ))
        : OverlaySupport.global(
            child: MaterialApp(
                title: 'Heart Failure Detector',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.red,
                  fontFamily: 'Poppins',
                ),
                routes: {
                  '/auth': (context) => const AuthenticationComponent(),
                  '/dashboard': (context) => const Dashboard(),
                  '/addrecord': (context) => const AddMedicalRecord(),
                  "/heart_rate": (context) =>
                      HeartRateCalculator(cameras: cameras),
                },
                home: isAuthenticated && loading == 'success'
                    ? const Dashboard()
                    : const AuthenticationComponent())));
  }
}
