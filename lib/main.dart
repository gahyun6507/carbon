import 'package:carbon_footprint/widgets/carbon_input_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart'; // 개인용/가정용 선택 화면
import 'screens/login_screen.dart'; // 로그인 화면
import 'screens/household_input_screen.dart'; // 가정용 입력 화면
import 'screens/personal_input_screen.dart'; // 개인용 입력 화면
import 'widgets/household_result_display.dart'; // 결과 화면
import 'services/auth.dart'; // AuthService 가져오기

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '탄소발자국 계산기',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // 첫 화면 정의
      home: StreamBuilder<User?>(
        stream: _authService.user, // AuthService의 user 스트림을 사용
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return HomeScreen(); // 로그인된 경우 HomeScreen
            } else {
              return LoginScreen(); // 로그인되지 않은 경우 LoginScreen
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      // 경로 설정
      routes: {
        '/personal': (context) => PersonalInputScreen(), // 개인용 화면
        '/household': (context) => HouseholdInputScreen(), // 가정용 입력 화면
        '/householdResult': (context) => HouseholdResultDisplay(), // 결과 화면 경로 추가
      },
    );
  }
}