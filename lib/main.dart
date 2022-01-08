import 'package:flutter/material.dart';
import 'package:local_database_example/service/save_user_cache.dart';
import 'package:local_database_example/todo_page.dart';
import 'package:local_database_example/todo_splash_screen.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({this.user, Key? key}) : super(key: key);
  String? user;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Local Database Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? user;
  @override
  void initState() {
    initUser();
    super.initState();
  }

  initUser() async {
    user = await SaveUserCache.getUser();
    setState(() {});
    print('user exist $user');
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? ToDoSplashScreen()
        : TodoPage(
            user: user!,
          );
  }
}
