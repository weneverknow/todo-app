import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_database_example/constant.dart';
import 'package:local_database_example/provider/todo_provider.dart';
import 'package:local_database_example/service/save_user_cache.dart';
import 'package:local_database_example/todo_form_page.dart';
import 'package:local_database_example/todo_list_page.dart';
import 'package:local_database_example/todo_splash_screen.dart';
import 'package:local_database_example/widget/text/small_text.dart';
import 'package:local_database_example/widget/text/sub_title_text.dart';
import 'package:local_database_example/widget/text/title_text.dart';
import 'model/todo.dart';
import 'extension/date_time_extension.dart';
import 'extension/string_extension.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({required this.user, Key? key}) : super(key: key);
  final String user;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TodoProvider todoProvider = TodoProvider();

  bool dbIsOpen = false;

  @override
  void initState() {
    initDatabase();
    super.initState();
  }

  initDatabase() async {
    bool isOpen = await todoProvider.initDatabase();
    setState(() {
      dbIsOpen = isOpen;
    });
  }

  TitleText? _titleText;
  SubTitleText? _subText;
  SmallText? _smallText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              buildHeader(),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (_subText = SubTitleText()..text = 'Ongoing Task').child,
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => TodoListPage(
                                    user: widget.user,
                                  )));
                        },
                        child: (_smallText = SmallText()
                              ..text = 'see all'
                              ..weight = FontWeight.w600
                              ..color = secondaryColor)
                            .child)
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                  child: !dbIsOpen
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(
                                color: progressColor,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text('Generating database... Please wait!')
                            ],
                          ),
                        )
                      : FutureBuilder(
                          future: todoProvider.fetchAll(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Something went wrong.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.red.shade300),
                                ),
                              );
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                (!snapshot.hasData ||
                                    (snapshot.data as List).length == 0)) {
                              return Center(
                                child: Text('Data Unavailable'),
                              );
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData &&
                                (snapshot.data as List).length > 0) {
                              var todos = snapshot.data as List<Todo>;
                              todos = todos
                                  .where((todo) =>
                                      todo.date ==
                                      DateTime.now().formatSaving())
                                  .toList();
                              todos.sort((a, b) => (Todo.toDateTime(a)
                                  .compareTo(Todo.toDateTime(b))));
                              todos.sort((a, b) => a.time!
                                  .getPeriod()
                                  .split('')[0]
                                  .toLowerCase()
                                  .compareTo(b.time!
                                      .getPeriod()
                                      .split('')[0]
                                      .toLowerCase()));

                              return ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: todos.length,
                                  itemBuilder: (context, index) {
                                    return buildTaskCard(todos[index]);
                                  });
                            }
                            return const SizedBox.shrink();
                          }))
            ],
          ),
        ),
        floatingActionButton: floatingButton());
  }

  Widget floatingButton() {
    return FloatingActionButton(
      backgroundColor: primaryColor,
      onPressed: () async {
        final back = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const TodoFormPage()));
        if (back != null) {
          if (back) {
            setState(() {});
          }
        }
      },
      child: Icon(Icons.add_rounded),
    );
  }

  showConfirmationDialog(
      {required String title,
      required String content,
      String? continueButtonText,
      Function()? onPressed}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(primary: buttonColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: buttonColor),
                  onPressed: onPressed,
                  child: Text(continueButtonText ?? 'Continue'))
            ],
          );
        });
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (_titleText = TitleText()..text = 'Hi ${widget.user.toCamel()}')
                  .child,
              (_smallText = SmallText()
                    ..text = 'have a great day'
                    ..color = secondaryColor)
                  .child,
            ],
          ),
          GestureDetector(
              onTap: () {
                showConfirmationDialog(
                    title: 'Sign Out',
                    content: 'Are you sure want to sign out the application?',
                    continueButtonText: 'Sign Out',
                    onPressed: () async {
                      final signout = await SaveUserCache.signOut();
                      if (signout) {
                        Get.offAll(() => ToDoSplashScreen());
                      }
                    });
              },
              child: Icon(
                Icons.power_settings_new_rounded,
                color: Colors.red.shade400,
              ))
        ],
      ),
    );
  }

  Widget circleIconButton(
      {IconData? icon, Color? backgroundColor, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: Color(0xffF2F0F0),
        ),
      ),
    );
  }

  Widget buildTaskCard(Todo todo) {
    return Container(
      height: 120,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xffFBFBFB),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: -1,
                blurRadius: 8,
                offset: Offset(0, 2))
          ]),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Text(
                  todo.title!,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
              ),
              Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      circleIconButton(
                          icon: Icons.edit_rounded,
                          backgroundColor: progressColor,
                          onTap: () async {
                            final edit = await Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (_) => TodoFormPage(
                                          todo: todo,
                                        )));
                            if (edit != null) {
                              if (edit) {
                                setState(() {});
                              }
                            }
                          }),
                      const SizedBox(
                        width: 8,
                      ),
                      circleIconButton(
                          icon: Icons.delete_rounded,
                          backgroundColor: buttonColor,
                          onTap: () {
                            showConfirmationDialog(
                                title: 'Remove Task',
                                content:
                                    'Would you like to remove ${todo.title}?',
                                continueButtonText: 'Remove',
                                onPressed: () async {
                                  final count =
                                      await todoProvider.delete(todo.id!);
                                  if (count > 0) {
                                    Navigator.pop(context);
                                  }
                                  setState(() {});
                                });
                          }),
                    ],
                  ))
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Text(
                  todo.description!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w200,
                  ),
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(flex: 1, fit: FlexFit.tight, child: Container())
            ],
          ),
          Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    (_smallText = SmallText()
                          ..text = DateTime.parse(todo.date!).getDateOnly() +
                              ' | ' +
                              todo.time!
                          ..size = 10.0
                          ..weight = FontWeight.w300
                          ..color = primaryColor)
                        .child,
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
