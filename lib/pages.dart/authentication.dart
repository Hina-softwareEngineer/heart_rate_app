import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:heart_rate/bloc/auth_bloc.dart';
import 'package:heart_rate/bloc/bottomNavBar.dart';
import 'package:heart_rate/utils/AuthDetails.dart';
import 'package:provider/provider.dart';

class AuthenticationComponent extends StatefulWidget {
  const AuthenticationComponent({Key? key}) : super(key: key);

  @override
  _AuthenticationComponentState createState() =>
      _AuthenticationComponentState();
}

class _AuthenticationComponentState extends State<AuthenticationComponent> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Builder(builder: (context) {
          final TabController tabController = DefaultTabController.of(context)!;

          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Color(0xFFFFFFFF),
              body: Container(
                  padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Column(
                    children: [
                      Text("Care your Heart"),
                      TabBar(
                        labelColor: Colors.black,
                        tabs: [
                          Tab(text: 'Login'),
                          Tab(text: 'Signup'),
                        ],
                      ),
                      Container(
                          child: Expanded(
                        child: TabBarView(controller: tabController, children: [
                          Consumer<AuthenticationBloc>(
                            builder: (context, auth, child) {
                              return LoginComp(authData: auth);
                            },
                          ),
                          Consumer<AuthenticationBloc>(
                            builder: (context, auth, child) {
                              return SignUpComponent(authData: auth);
                            },
                          ),
                        ]),
                      ))
                    ],
                  )));
        }));
  }
}

class LoginComp extends StatefulWidget {
  final authData;
  const LoginComp({Key? key, required this.authData}) : super(key: key);

  @override
  _LoginCompState createState() => _LoginCompState();
}

class _LoginCompState extends State<LoginComp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login_user() async {
    widget.authData.auth_pending();
    // authBloc.eventSink.add({'status': AuthEvent.AUTH_PENDING});
    try {
      Dio dio = new Dio();
      dio.options.headers['content-Type'] = 'application/json';
      // dio.options.headers["authorization"] =
      //     "Bearer ${authDetails['access_token']}";
      FormData formData = FormData.fromMap(
          {'email': emailController.text, 'password': passwordController.text});
      await dio
          .post("https://heart-failure.up.railway.app/v1/login/",
              data: formData)
          .then((value) {
        widget.authData.auth_success(AuthDetails.fromJson(value.data['data']));
        Navigator.pushReplacementNamed(context, '/dashboard');
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
        widget.authData.auth_failure(err.response?.data["detail"]);
      }
    }
  }

  @override
  void dispose() {
    // Don't forget to close all the stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("login -> ${widget.authData.authData}");
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: emailController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.pinkAccent, width: 2)),
                contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                labelText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: passwordController,
            style: TextStyle(fontSize: 14),
            obscureText: true,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.pinkAccent, width: 2)),
                contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                labelText: 'Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }
            },
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  login_user();
                },
                child: Text("Login"),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pinkAccent),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                        side: BorderSide(color: Colors.red))))),
          )
        ],
      ),
    );
  }
}

class SignUpComponent extends StatefulWidget {
  final authData;
  const SignUpComponent({Key? key, required this.authData}) : super(key: key);

  @override
  _SignUpComponentState createState() => _SignUpComponentState();
}

class _SignUpComponentState extends State<SignUpComponent> {
  final authBloc = new AuthenticationBloc();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signup_user() async {
    widget.authData.auth_pending();
    Provider.of<BottomNavBarBloc>(context).setIndex(0);
    // authBloc.eventSink.add({'status': AuthEvent.AUTH_PENDING});
    try {
      Dio dio = new Dio();
      dio.options.headers['content-Type'] = 'application/json';

      Map<String, String> data = {
        'email': emailController.text,
        'password': passwordController.text,
        'username': usernameController.text,
        'phone': phoneController.text
      };

      await dio
          .post("https://heart-failure.up.railway.app/v1/signup/", data: data)
          .then((value) {
        widget.authData.auth_success(AuthDetails.fromJson(value.data['data']));
        Navigator.pushReplacementNamed(context, '/dashboard');
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
        widget.authData.auth_failure(err.response?.data["detail"]);
      }
    }
  }

  @override
  void dispose() {
    // Don't forget to close all the stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: usernameController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.pinkAccent, width: 2)),
                contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                labelText: 'Username',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: emailController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.pinkAccent, width: 2)),
                contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                labelText: 'Email',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: phoneController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.pinkAccent, width: 2)),
                contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                labelText: 'Phone',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone is required';
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: passwordController,
            style: TextStyle(fontSize: 14),
            obscureText: true,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.pinkAccent, width: 2)),
                contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                labelText: 'Password',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide:
                        BorderSide(color: Colors.pinkAccent, width: 2))),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }
            },
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  signup_user();
                },
                child: Text("Signup"),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pinkAccent),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                        side: BorderSide(color: Colors.red))))),
          )
        ],
      ),
    );
  }
}
