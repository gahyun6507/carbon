import 'package:flutter/material.dart';
import 'package:carbon_footprint/services/auth.dart'; // AuthService 가져오기
import 'package:carbon_footprint/screens/home_screen.dart'; // HomeScreen 가져오기
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false; // 로딩 상태

  // 로그인 처리
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;  // 로딩 상태 활성화
    });

    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      // 오류 발생 시 화면에 오류 메시지 표시
      String errorMessage = _getErrorMessage(e);  // Firebase 오류 메시지를 더 친절하게 변환
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("로그인 실패"),
          content: Text(errorMessage),  // 오류 메시지를 사용자에게 안내
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("확인"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;  // 로딩 상태 종료
      });
    }
  }

  // FirebaseAuthException에 따른 에러 메시지 변환
  String _getErrorMessage(Object e) {
    // e가 FirebaseAuthException인지 체크
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return "사용자를 찾을 수 없습니다.";
        case 'wrong-password':
          return "잘못된 비밀번호입니다.";
        case 'account-exists-with-different-credential':
          return "다른 방법으로 로그인한 계정이 있습니다.";
        case 'network-request-failed':
          return "네트워크 연결이 원활하지 않습니다. 다시 시도해주세요.";
        case 'operation-not-allowed':
          return "구글 로그인 기능이 비활성화되었습니다.";
        default:
          return "알 수 없는 오류가 발생했습니다. 다시 시도해주세요.";
      }
    }
    return e.toString();  // 예상치 못한 오류는 그대로 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              CircularProgressIndicator(),  // 로딩 중 표시
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithGoogle,
              child: Text("구글로 로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
