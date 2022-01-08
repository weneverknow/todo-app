import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_database_example/constant.dart';
import 'package:local_database_example/todo_page.dart';
import 'package:local_database_example/widget/text/small_text.dart';
import 'package:local_database_example/widget/text/sub_title_text.dart';
import 'package:local_database_example/widget/text/title_text.dart';
import 'service/save_user_cache.dart';

class ToDoSplashScreen extends StatefulWidget {
  const ToDoSplashScreen({Key? key}) : super(key: key);

  @override
  State<ToDoSplashScreen> createState() => _ToDoSplashScreenState();
}

class _ToDoSplashScreenState extends State<ToDoSplashScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool isValid = true;

  TitleText? _titleText;
  SubTitleText? _subText;
  SmallText? _smallText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeaderTitle(),
              buildImageHeader(),
              const SizedBox(
                height: 50,
              ),
              isValid
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: (_smallText = SmallText()
                            ..text = 'Name is required!'
                            ..weight = FontWeight.normal
                            ..color = Colors.red.shade300)
                          .child),
              buildInputField(),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: buildStartedButton(),
              )
            ],
          ),
        ),
      ),
    );
  }

  save(String username) async {
    if (username.isEmpty) {
      setState(() {
        isValid = false;
      });
      return;
    }
    bool isSaved = await SaveUserCache.saveUser(_nameController.text);
    if (isSaved) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TodoPage(
                user: _nameController.text,
              )));
    } else {
      Get.snackbar('Authentication Failed',
          'Something went wrong while saving user.\nPlease, try again later',
          backgroundColor: primaryColor, colorText: Colors.white);
    }
  }

  Widget buildStartedButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            primary: primaryColor,
            padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: MediaQuery.of(context).size.width * 0.3)),
        onPressed: () {
          save(_nameController.text);
        },
        child: (_subText = SubTitleText()
              ..text = 'GET STARTED'
              ..color = Colors.white)
            .child);
  }

  Widget buildInputField() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
          color: Color(0xffEDEDED),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: !isValid ? Colors.red.shade400 : greyColor)),
      child: TextField(
          controller: _nameController,
          onChanged: (val) {
            if (!isValid && val.isNotEmpty) {
              setState(() {
                isValid = true;
              });
            }
          },
          decoration: InputDecoration(
              hintText: 'Your name here . . .',
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none)),
    );
  }

  Center buildImageHeader() {
    return Center(
      child: Image.asset(
        'assets/images/Rectangle 1.png',
        fit: BoxFit.cover,
        width: 230,
        height: 230,
      ),
    );
  }

  Widget buildHeaderTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 90, bottom: 50),
      child:
          (_titleText = TitleText()..text = 'Manage Your\nDaily Activity Well')
              .child,
    );
  }
}
